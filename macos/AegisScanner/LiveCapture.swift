import AppKit
import AVFoundation
import CoreGraphics
import CoreImage
import CoreMedia
import CoreVideo
import Foundation
import ImageIO
import Vision
#if canImport(Darwin)
import Darwin
#endif

enum LiveKind: String {
    case webcam, hls, mjpeg, httpVideo, snapshot, rtsp
}

enum CameraChoice: String, CaseIterable, Identifiable {
    case auto, builtIn, continuity
    var id: String { rawValue }
    var titleDE: String {
        switch self {
        case .auto: return "Auto (Built-in zuerst)"
        case .builtIn: return "Built-in Front"
        case .continuity: return "Continuity / Desk-View"
        }
    }
}

@MainActor
final class LiveCapture: NSObject {
    private var player: AVPlayer?
    private var output: AVPlayerItemVideoOutput?
    private var playerTransform = CGAffineTransform.identity
    private var session: AVCaptureSession?
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var outputQueue = DispatchQueue(label: "aegis.live")
    private var timer: Timer?
    private var snapshotURL: URL?
    private var failObserver: NSObjectProtocol?
    private var interruptObserver: NSObjectProtocol?
    private var sessionPauseWork: DispatchWorkItem?
    private var sessionPauseUntil: TimeInterval = 0
    /// Hung-live: SIGTERM-Zeit je PID. Nächster Claim → SIGKILL nach 2 s.
    private static var mutexTermSentAt: [Int32: TimeInterval] = [:]
    private var mutexTermChip: String?
    private var snapshotInFlight = false
    var onFrame: ((CGImage, TimeInterval) -> Void)?
    var onError: ((String) -> Void)?
    var onReady: (() -> Void)?
    /// Live-Tap: Hunt 8/10 fps, Lock 12/15. 5 fps ließ leftoverAdopt sterben.
    private(set) var facesPresent = false
    private(set) var cameraUniqueID: String = ""
    private(set) var cameraName: String = ""
    private(set) var cameraRole: String = ""
    private(set) var orientOverride: String = "auto"
    private(set) var isContinuity = false
    private(set) var formatChip = ""
    private(set) var mutexChip = "—"
    var choice: CameraChoice = .builtIn
    /// Hung-live: SIGTERM/SIGKILL nur wenn Pref an. Default aus.
    var mutexKillEnabled = false
    private var cameraMutexYielded = false
    private var yieldSince: TimeInterval = 0
    var yieldAutoReturn = true
    var yieldGrace: TimeInterval = 4
    private var mutexBeat: Timer?
    private var mutexClaimFails = 0
    private var lastMutexClaimAt: TimeInterval = 0
    private var lastMutexPts: TimeInterval = 0
    private var lastFaceStreak = 0
    private var lastVisMs: Double = 0

    static func orientKey(_ uniqueID: String) -> String { "aegis.camOrient.\(uniqueID)" }

    func setOrientOverride(_ value: String) {
        orientOverride = value
        tap?.orientOverride = value
        if !cameraUniqueID.isEmpty {
            UserDefaults.standard.set(value, forKey: Self.orientKey(cameraUniqueID))
        }
    }

    func setFacesPresent(_ on: Bool, streak: Int = 0) {
        let changed = on != facesPresent
        facesPresent = on
        lastFaceStreak = streak
        applyMinInterval()
        if changed, isContinuity {
            applyCenterStage(force: true)
        }
        if changed, timer != nil {
            startTimer()
        }
    }

    func setVisionBudget(ms: Double) {
        lastVisMs = ms
        applyMinInterval()
    }

    func markFrameConsumed() {
        tap?.markConsumed()
    }

    private func applyMinInterval() {
        let base = MatchMath.liveMinInterval(continuity: isContinuity, faces: facesPresent, streak: lastFaceStreak)
        tap?.minInterval = MatchMath.liveMinIntervalFromVision(base: base, visionMs: lastVisMs)
    }

    func start(url: URL, kind: LiveKind) {
        stop()
        switch kind {
        case .webcam:
            startCamera()
        case .snapshot, .mjpeg:
            snapshotURL = url
            onReady?()
            startTimer()
        case .hls, .httpVideo:
            startPlayer(url: url)
        case .rtsp:
            onError?("RTSP spielt AVFoundation auf macOS nicht. HLS, MJPEG oder Snapshot nutzen.")
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        snapshotURL = nil
        snapshotInFlight = false
        tap = nil
        rotationCoordinator = nil
        isContinuity = false
        facesPresent = false
        cameraUniqueID = ""
        cameraName = ""
        cameraRole = ""
        sessionPauseWork?.cancel()
        sessionPauseWork = nil
        sessionPauseUntil = 0
        if let failObserver {
            NotificationCenter.default.removeObserver(failObserver)
            self.failObserver = nil
        }
        if let interruptObserver {
            NotificationCenter.default.removeObserver(interruptObserver)
            self.interruptObserver = nil
        }
        player?.pause()
        player = nil
        output = nil
        playerTransform = .identity
        let s = session
        session = nil
        if let s {
            outputQueue.async { s.stopRunning() }
        }
        mutexBeat?.invalidate()
        mutexBeat = nil
        releaseCameraMutex()
    }

    private func startCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] ok in
                Task { @MainActor in
                    if ok { self?.configureCamera() }
                    else { self?.onError?("Kamera-Zugriff blockiert.") }
                }
            }
        default:
            onError?("Kamera-Zugriff blockiert. In Systemeinstellungen erlauben.")
        }
    }

    private func configureCamera() {
        let session = AVCaptureSession()
        guard
            let device = preferredCamera(),
            let input = try? AVCaptureDeviceInput(device: device)
        else {
            onError?("Keine Webcam gefunden.")
            return
        }
        cameraUniqueID = device.uniqueID
        cameraName = device.localizedName
        if #available(macOS 14.0, *) {
            isContinuity = device.deviceType == .continuityCamera || device.deviceType == .deskViewCamera
        } else {
            isContinuity = device.deviceType == .continuityCamera
        }
        cameraRole = MatchMath.cameraRoleOf(
            name: device.localizedName,
            isContinuity: isContinuity,
            isExternal: device.deviceType == .external
        )
        if !MatchMath.sessionPresetClampsContinuity(isContinuity) {
            session.sessionPreset = .hd1280x720
        }
        applyCenterStage(force: true)
        if let stored = UserDefaults.standard.string(forKey: Self.orientKey(device.uniqueID)) {
            orientOverride = stored
        }
        UserDefaults.standard.set(orientOverride, forKey: Self.orientKey(device.uniqueID))
        if session.canAddInput(input) { session.addInput(input) }
        let out = AVCaptureVideoDataOutput()
        out.alwaysDiscardsLateVideoFrames = true
        let delegate = FrameTap { [weak self] image, stamp in
            self?.onFrame?(image, stamp)
        }
        delegate.uniqueID = device.uniqueID
        delegate.orientOverride = orientOverride
        self.tap = delegate
        out.setSampleBufferDelegate(delegate, queue: outputQueue)
        applyMinInterval()
        if session.canAddOutput(out) { session.addOutput(out) }
        applyCenterStage(force: true)
        applyBestFormat(device)
        applyNativePixelFormat(out)
        if let conn = out.connection(with: .video) {
            if conn.isVideoMirroringSupported {
                conn.automaticallyAdjustsVideoMirroring = false
                let desk: Bool
                if #available(macOS 14.0, *) {
                    desk = device.deviceType == .deskViewCamera
                } else {
                    desk = false
                }
                conn.isVideoMirrored = MatchMath.mirrorAsFront(
                    positionFront: device.position == .front,
                    unspecified: device.position == .unspecified,
                    deskView: desk
                )
            }
            // Kein RotationCoordinator: physisches Drehen macht Latenz, Box 90°, leftover stiehlt.
            if !MatchMath.physicalCaptureRotation() {
                if conn.isVideoRotationAngleSupported(MatchMath.videoRotationAngleFallback()) {
                    conn.videoRotationAngle = MatchMath.videoRotationAngleFallback()
                }
                delegate.horizonLevel = false
            }
            #if os(iOS) || os(tvOS)
            if !MatchMath.videoStabilizationApplies(continuity: isContinuity),
               conn.isVideoStabilizationSupported
            {
                conn.preferredVideoStabilizationMode = .off
            }
            #endif
        }
        self.session = session
        if !cameraMutexYielded {
            claimCameraMutex()
        }
        if mutexBeat == nil {
            let beat = Timer(timeInterval: MatchMath.cameraMutexHeartbeatSec(), repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.beatCameraMutex()
                }
            }
            RunLoop.main.add(beat, forMode: .common)
            mutexBeat = beat
        }
        outputQueue.async { session.startRunning() }
        installSessionWatch(session)
        onReady?()
    }

    private func installSessionWatch(_ session: AVCaptureSession) {
        if let interruptObserver {
            NotificationCenter.default.removeObserver(interruptObserver)
            self.interruptObserver = nil
        }
        interruptObserver = NotificationCenter.default.addObserver(
            forName: .AVCaptureSessionWasInterrupted,
            object: session,
            queue: .main
        ) { [weak self] _ in
            let capture = self
            Task { @MainActor in
                capture?.pauseSessionForMutex()
            }
        }
    }

    private func pauseSessionForMutex() {
        if MatchMath.cameraMutexPauseArmed(workPending: sessionPauseWork != nil) { return }
        let need = MatchMath.cameraMutexSessionPause()
        sessionPauseWork?.cancel()
        mutexChip = MatchMath.cameraMutexPauseChip(remain: need)
        sessionPauseUntil = Date().timeIntervalSince1970 + need
        if let s = session {
            outputQueue.async { s.stopRunning() }
        }
        let work = DispatchWorkItem { [weak self] in
            Task { @MainActor in self?.resumeAfterMutexPause() }
        }
        sessionPauseWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + need, execute: work)
    }

    private func resumeAfterMutexPause() {
        sessionPauseWork = nil
        sessionPauseUntil = 0
        claimCameraMutex()
        if MatchMath.cameraMutexPauseArmed(workPending: sessionPauseWork != nil) { return }
        if let s = session, !s.isRunning {
            outputQueue.async { s.startRunning() }
        }
    }

    private var tap: FrameTap?

    private func preferredCamera() -> AVCaptureDevice? {
        var types: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,
            .continuityCamera,
            .external
        ]
        if #available(macOS 14.0, *) {
            types.append(.deskViewCamera)
        }
        let discovered = AVCaptureDevice.DiscoverySession(
            deviceTypes: types,
            mediaType: .video,
            position: .unspecified
        ).devices
        let read = readCameraMutex()
        let yield: Bool
        if MatchMath.cameraMutexSkipClaim(readBusy: read.busy) {
            yield = cameraMutexYielded
        } else {
            yield = MatchMath.cameraMutexYieldsNow(
                holder: read.holder,
                owner: MatchMath.cameraMutexOwnerAegis(),
                wasYielded: cameraMutexYielded
            )
        }
        cameraMutexYielded = yield
        if yield {
            // Helios hält Continuity — Built-in, sonst 8 fps und TCC.
            // Vor den Early-Returns, sonst Auto/Built-in nie yield.
            if let front = discovered.first(where: {
                $0.deviceType == .builtInWideAngleCamera && ($0.position == .front || $0.position == .unspecified)
            }) { return front }
            if let builtIn = discovered.first(where: { $0.deviceType == .builtInWideAngleCamera }) { return builtIn }
        }
        if let front = discovered.first(where: {
            $0.deviceType == .builtInWideAngleCamera && ($0.position == .front || $0.position == .unspecified)
        }) {
            if choice != .continuity { return front }
        }
        if let builtIn = discovered.first(where: { $0.deviceType == .builtInWideAngleCamera }) {
            if choice != .continuity { return builtIn }
        }
        let extra = discovered.first(where: {
            if #available(macOS 14.0, *) {
                return $0.deviceType == .continuityCamera || $0.deviceType == .deskViewCamera
            }
            return $0.deviceType == .continuityCamera
        })
        switch choice {
        case .continuity:
            return extra ?? discovered.first ?? AVCaptureDevice.default(for: .video)
        case .builtIn:
            return discovered.first(where: { $0.deviceType == .builtInWideAngleCamera })
                ?? extra ?? discovered.first ?? AVCaptureDevice.default(for: .video)
        case .auto:
            if let front = discovered.first(where: {
                $0.deviceType == .builtInWideAngleCamera && ($0.position == .front || $0.position == .unspecified)
            }) { return front }
            if let builtIn = discovered.first(where: { $0.deviceType == .builtInWideAngleCamera }) { return builtIn }
            return extra ?? discovered.first ?? AVCaptureDevice.default(for: .video)
        }
    }

    private var yieldReconfiguring = false

    private func cameraMutexCachesURL() -> URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let dir = base.appendingPathComponent(MatchMath.cameraMutexCacheFolder(), isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(MatchMath.cameraMutexName())
    }

    private func cameraMutexLegacyURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(MatchMath.cameraMutexName())
    }

    private func cameraMutexURL() -> URL { cameraMutexCachesURL() }

    @discardableResult
    private func writeCameraMutexClaim(owner: String, url: URL, expectedGen: UInt32? = nil) -> Bool {
        let pid = ProcessInfo.processInfo.processIdentifier
        let now = Date().timeIntervalSince1970
        #if canImport(Darwin)
        let fd = open(url.path, O_RDWR | O_CREAT, 0o644)
        if fd >= 0 {
            let flags: Int32 = MatchMath.cameraMutexFlockNonblock() ? (LOCK_EX | LOCK_NB) : LOCK_EX
            if flock(fd, flags) != 0 {
                close(fd)
                return false
            }
            let size = lseek(fd, 0, SEEK_END)
            _ = lseek(fd, 0, SEEK_SET)
            var buf = [UInt8](repeating: 0, count: max(0, Int(size)))
            if !buf.isEmpty {
                _ = buf.withUnsafeMutableBytes { Darwin.read(fd, $0.baseAddress, $0.count) }
            }
            let existing = buf.isEmpty ? nil : String(bytes: buf, encoding: .utf8)
            let holderPid = existing.flatMap { MatchMath.cameraMutexPid($0) }
            let pidLive: Bool? = holderPid.map { p in p > 0 && (kill(p, 0) == 0 || errno == EPERM) }
            if MatchMath.cameraMutexKillPref(mutexKillEnabled),
               let victim = MatchMath.cameraMutexHeartbeatKillPid(
                pid: holderPid,
                live: pidLive,
                now: now,
                stamped: existing.flatMap { MatchMath.cameraMutexStamp($0) }
            ), let killPid = MatchMath.cameraMutexHeartbeatKillAllowed(target: victim, selfPid: pid) {
                let sig = MatchMath.cameraMutexHeartbeatKillSignal(
                    termSentAt: Self.mutexTermSentAt[killPid],
                    now: now
                )
                _ = kill(killPid, sig)
                Self.mutexTermSentAt = MatchMath.cameraMutexHeartbeatTermStamp(
                    prev: Self.mutexTermSentAt, pid: killPid, signal: sig, now: now
                )
                if MatchMath.cameraMutexTermBlocksWrite(signal: sig, pidLive: pidLive) {
                    let remain = MatchMath.cameraMutexTermRemain(
                        termSentAt: Self.mutexTermSentAt[killPid], now: now
                    )
                    mutexTermChip = MatchMath.cameraMutexTermChip(signal: sig, remain: remain)
                    mutexChip = MatchMath.cameraMutexClaimChip(
                        holder: existing.flatMap { MatchMath.cameraMutexParse($0, now: now, pidLive: pidLive) },
                        yielded: false,
                        fails: 0,
                        term: mutexTermChip
                    )
                    _ = flock(fd, LOCK_UN)
                    close(fd)
                    return false
                }
            }
            guard let line = MatchMath.cameraMutexLockedLine(
                existing: existing, owner: owner, pid: pid, now: now, expectedGen: expectedGen, pidLive: pidLive,
                pts: tap?.lastStamp
            ) else {
                _ = flock(fd, LOCK_UN)
                close(fd)
                return false
            }
            _ = ftruncate(fd, 0)
            _ = lseek(fd, 0, SEEK_SET)
            if let data = line.data(using: .utf8) {
                data.withUnsafeBytes { raw in
                    if let p = raw.baseAddress {
                        _ = Darwin.write(fd, p, raw.count)
                    }
                }
            }
            if MatchMath.cameraMutexFsyncBeforeUnlock() {
                _ = fsync(fd)
            }
            _ = flock(fd, LOCK_UN)
            close(fd)
            return true
        }
        #endif
        let existing = try? String(contentsOf: url, encoding: .utf8)
        let holderPid = existing.flatMap { MatchMath.cameraMutexPid($0) }
        let pidLive: Bool? = holderPid.map { p in p > 0 && (kill(p, 0) == 0 || errno == EPERM) }
        guard let line = MatchMath.cameraMutexLockedLine(
            existing: existing, owner: owner, pid: pid, now: now, expectedGen: expectedGen, pidLive: pidLive,
            pts: tap?.lastStamp
        ) else { return false }
        try? line.write(to: url, atomically: true, encoding: .utf8)
        return true
    }

    private func readCameraMutexLocked(url: URL, busy: inout Bool) -> String? {
        #if canImport(Darwin)
        let fd = open(url.path, O_RDONLY)
        if fd >= 0 {
            let flags: Int32 = MatchMath.cameraMutexFlockNonblock() ? (LOCK_SH | LOCK_NB) : LOCK_SH
            if MatchMath.cameraMutexFlockReadShared(), flock(fd, flags) != 0 {
                busy = true
                close(fd)
                return nil
            }
            let size = lseek(fd, 0, SEEK_END)
            _ = lseek(fd, 0, SEEK_SET)
            var buf = [UInt8](repeating: 0, count: max(0, Int(size)))
            if !buf.isEmpty {
                _ = buf.withUnsafeMutableBytes { Darwin.read(fd, $0.baseAddress, $0.count) }
            }
            if MatchMath.cameraMutexFlockReadShared() {
                _ = flock(fd, LOCK_UN)
            }
            close(fd)
            return buf.isEmpty ? "" : String(bytes: buf, encoding: .utf8)
        }
        #endif
        return try? String(contentsOf: url, encoding: .utf8)
    }

    private func readCameraMutex() -> (holder: String?, busy: Bool, gen: UInt32?) {
        let cachesURL = cameraMutexCachesURL()
        let cachesPresent = FileManager.default.fileExists(atPath: cachesURL.path)
        var busy = false
        let caches = readCameraMutexLocked(url: cachesURL, busy: &busy)
        if busy { return (nil, true, nil) }
        var tmpBusy = false
        let tmp = MatchMath.cameraMutexReadOrder().contains("tmp")
            ? readCameraMutexLocked(url: cameraMutexLegacyURL(), busy: &tmpBusy)
            : nil
        if tmpBusy { return (nil, true, nil) }
        let empty = cachesPresent && (caches == nil || caches?.isEmpty == true)
        guard let text = MatchMath.cameraMutexPickText(caches: caches, tmp: tmp, cachesEmpty: empty) else {
            return (nil, false, nil)
        }
        let pid = MatchMath.cameraMutexPid(text)
        let live = pid.map { p in p > 0 && (kill(p, 0) == 0 || errno == EPERM) }
        if let pts = MatchMath.cameraMutexPts(text) { lastMutexPts = pts }
        return (
            MatchMath.cameraMutexParse(text, now: Date().timeIntervalSince1970, pidLive: live),
            false,
            MatchMath.cameraMutexGen(text)
        )
    }

    private func beatCameraMutex() {
        let now = Date().timeIntervalSince1970
        if !MatchMath.cameraMutexClaimDue(last: lastMutexClaimAt, now: now, fails: mutexClaimFails) {
            return
        }
        lastMutexClaimAt = now
        let read = readCameraMutex()
        if MatchMath.cameraMutexSkipClaim(readBusy: read.busy) {
            mutexClaimFails += 1
            mutexChip = MatchMath.cameraMutexClaimChip(
                holder: nil, yielded: cameraMutexYielded, fails: mutexClaimFails
            )
            return
        }
        let holder = read.holder
        let owner = MatchMath.cameraMutexOwnerAegis()
        let yielded = MatchMath.cameraMutexYieldsNow(
            holder: holder, owner: owner, wasYielded: cameraMutexYielded
        )
        if yielded && !cameraMutexYielded {
            yieldSince = now
            cameraMutexYielded = true
            mutexClaimFails = 0
            mutexChip = MatchMath.cameraMutexClaimChip(holder: holder, yielded: true, fails: 0)
            if MatchMath.cameraMutexYieldReconfigure(yielded: true, isContinuity: isContinuity) {
                reconfigureAfterYield()
            }
            return
        }
        cameraMutexYielded = yielded
        mutexChip = MatchMath.cameraMutexClaimChip(
            holder: holder, yielded: yielded, fails: mutexClaimFails
        )
        if MatchMath.cameraMutexYieldAutoReturnPref(yieldAutoReturn),
           MatchMath.cameraMutexYieldAutoReturn(
            yielded: yielded,
            holder: holder,
            owner: owner,
            since: yieldSince,
            now: now,
            grace: MatchMath.cameraMutexYieldGracePref(yieldGrace)
        ) {
            cameraMutexYielded = false
            yieldSince = 0
            if choice != .builtIn {
                reconfigureAfterYield(keepYielded: false)
            }
            claimCameraMutex(expectedGen: read.gen)
            return
        }
        if cameraMutexYielded { return }
        claimCameraMutex(expectedGen: read.gen)
    }

    private func reconfigureAfterYield(keepYielded: Bool = true) {
        guard !yieldReconfiguring else { return }
        yieldReconfiguring = true
        let s = session
        session = nil
        tap = nil
        rotationCoordinator = nil
        cameraMutexYielded = keepYielded
        if let s {
            outputQueue.async { [weak self] in
                s.stopRunning()
                Task { @MainActor in
                    self?.configureCamera()
                    self?.yieldReconfiguring = false
                }
            }
        } else {
            configureCamera()
            yieldReconfiguring = false
        }
    }

    private func claimCameraMutex(expectedGen: UInt32? = nil) {
        let owner = MatchMath.cameraMutexOwnerAegis()
        let read = readCameraMutex()
        if MatchMath.cameraMutexSkipClaim(readBusy: read.busy) {
            mutexClaimFails += 1
            mutexChip = MatchMath.cameraMutexClaimChip(
                holder: nil, yielded: cameraMutexYielded, fails: mutexClaimFails
            )
            return
        }
        let holder = read.holder
        guard MatchMath.cameraMutexClaimWrites(
            holder: holder,
            owner: owner
        ) else {
            mutexChip = MatchMath.cameraMutexClaimChip(
                holder: holder, yielded: cameraMutexYielded, fails: mutexClaimFails
            )
            if MatchMath.cameraMutexWatchdogShouldPause(
                action: MatchMath.cameraMutexWatchdogAction(killEnabled: mutexKillEnabled),
                holder: holder,
                owner: owner,
                wrote: false
            ) {
                pauseSessionForMutex()
            }
            return
        }
        let gen = expectedGen ?? read.gen
        let wrote = writeCameraMutexClaim(owner: owner, url: cameraMutexCachesURL(), expectedGen: gen)
        if MatchMath.cameraMutexWriteTmp() {
            _ = writeCameraMutexClaim(owner: owner, url: cameraMutexLegacyURL(), expectedGen: gen)
        }
        if wrote {
            mutexClaimFails = 0
            mutexTermChip = nil
            mutexChip = MatchMath.cameraMutexClaimChip(holder: owner, yielded: false, fails: 0)
        } else {
            mutexClaimFails += 1
            mutexChip = MatchMath.cameraMutexClaimChip(
                holder: holder, yielded: cameraMutexYielded, fails: mutexClaimFails, term: mutexTermChip
            )
            if MatchMath.cameraMutexWatchdogShouldPause(
                action: MatchMath.cameraMutexWatchdogAction(killEnabled: mutexKillEnabled),
                holder: holder,
                owner: owner,
                wrote: false
            ) {
                pauseSessionForMutex()
            }
        }
    }

    private func releaseCameraMutex() {
        for url in [cameraMutexCachesURL(), cameraMutexLegacyURL()] {
            guard let text = try? String(contentsOf: url, encoding: .utf8) else { continue }
            if MatchMath.cameraMutexParse(text, now: Date().timeIntervalSince1970, stale: 9_999) == MatchMath.cameraMutexOwnerAegis() {
                try? FileManager.default.removeItem(at: url)
            }
        }
    }

    /// Continuity 15–30 nur als 420f. 32BGRA + CGContext war 8 fps und tot auf Planar.
    /// Swift-Overlay: `availableVideoPixelFormatTypes` ([OSType]), nicht ObjC-CV-Infix.
    /// Parameter nicht `output` — Klasse hat `AVPlayerItemVideoOutput? output`.
    private func applyNativePixelFormat(_ videoOut: AVCaptureVideoDataOutput) {
        let preferred: [OSType] = [
            kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
            kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
            kCVPixelFormatType_422YpCbCr8,
            kCVPixelFormatType_32BGRA,
        ]
        let types = videoOut.availableVideoPixelFormatTypes
        guard let fmt = preferred.first(where: { types.contains($0) }) ?? types.first else { return }
        videoOut.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: fmt]
    }

    private func applyBestFormat(_ device: AVCaptureDevice) {
        guard let format = Self.bestFormat(on: device) else { return }
        do {
            try device.lockForConfiguration()
            device.activeFormat = format
            if let range = device.activeFormat.videoSupportedFrameRateRanges.max(by: {
                $0.maxFrameRate < $1.maxFrameRate
            }) {
                let hi = MatchMath.captureLockFrameRate(range.maxFrameRate, continuity: self.isContinuity)
                let lo = MatchMath.captureLockFrameLo(range.maxFrameRate, rangeMin: range.minFrameRate, continuity: self.isContinuity)
                var minDur = CMTimeMake(value: 1, timescale: CMTimeScale(max(1, Int(hi.rounded()))))
                var maxDur = CMTimeMake(value: 1, timescale: CMTimeScale(max(1, Int(lo.rounded()))))
                if minDur < range.minFrameDuration { minDur = range.minFrameDuration }
                if maxDur > range.maxFrameDuration { maxDur = range.maxFrameDuration }
                if minDur > maxDur { minDur = maxDur }
                device.activeVideoMinFrameDuration = minDur
                device.activeVideoMaxFrameDuration = maxDur
                let osType = CMFormatDescriptionGetMediaSubType(device.activeFormat.formatDescription)
                let chip = MatchMath.captureBandChip(osType: osType, lo: lo, hi: hi)
                Task { @MainActor in self.formatChip = chip }
            }
            device.unlockForConfiguration()
        } catch { }
    }

    private func applyCenterStage(force: Bool = false) {
        guard MatchMath.centerStageOff else { return }
        if #available(macOS 12.3, *) {
            let modeRaw = Int(AVCaptureDevice.centerStageControlMode.rawValue)
            if MatchMath.centerStageNeedsAppControl(currentModeRaw: modeRaw) {
                AVCaptureDevice.centerStageControlMode = .app
            }
            if force || MatchMath.centerStageNeedsReassert(enabled: AVCaptureDevice.isCenterStageEnabled) {
                AVCaptureDevice.isCenterStageEnabled = false
            }
        }
    }

    func reselectFormat() {
        applyCenterStage(force: true)
        let device = session?.inputs.compactMap { ($0 as? AVCaptureDeviceInput)?.device }.first
        guard let device else { return }
        applyBestFormat(device)
    }

    func recoverAfterWake() {
        applyCenterStage(force: true)
        if let s = session, !s.isRunning {
            outputQueue.async { s.startRunning() }
        }
        reselectFormat()
        tap?.markConsumed()
    }

    private static func bestFormat(on device: AVCaptureDevice) -> AVCaptureDevice.Format? {
        var best: AVCaptureDevice.Format?
        var bestScore = -1.0
        var bestMin = 0.0
        for format in device.formats {
            let dims = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let ranges = format.videoSupportedFrameRateRanges
            let fps = ranges.map(\.maxFrameRate).max() ?? 0
            let minFps = ranges.map(\.minFrameRate).max() ?? 0
            let osType = CMFormatDescriptionGetMediaSubType(format.formatDescription)
            let s = MatchMath.captureFormatScore(width: Double(dims.width), height: Double(dims.height), fps: fps)
                + MatchMath.capturePixelBonus(osType: osType, fps: fps)
            if best == nil || s > bestScore + 0.5 || (abs(s - bestScore) < 0.5 && minFps > bestMin) {
                bestScore = s
                bestMin = minFps
                best = format
            }
        }
        return best
    }

    private func startPlayer(url: URL) {
        let item = AVPlayerItem(url: url)
        let attrs: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        ]
        let videoOut = AVPlayerItemVideoOutput(pixelBufferAttributes: attrs)
        item.add(videoOut)
        let player = AVPlayer(playerItem: item)
        player.isMuted = true
        self.output = videoOut
        self.player = player
        playerTransform = .identity
        player.play()
        onReady?()
        startTimer()
        Task { [weak self] in
            guard
                let tracks = try? await item.asset.loadTracks(withMediaType: .video),
                let track = tracks.first,
                let t = try? await track.load(.preferredTransform)
            else { return }
            await MainActor.run { self?.playerTransform = t }
        }
        if let failObserver {
            NotificationCenter.default.removeObserver(failObserver)
        }
        failObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] note in
            let err = (note.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error)?.localizedDescription
            let capture = self
            Task { @MainActor in
                capture?.onError?(err ?? "Stream abgebrochen")
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()
        let interval = MatchMath.liveMinInterval(continuity: isContinuity, faces: facesPresent)
        let t = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            let capture = self
            Task { @MainActor in
                capture?.grab()
            }
        }
        t.tolerance = min(0.008, interval * 0.15)
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func grab() {
        if let snapshotURL {
            if snapshotInFlight { return }
            snapshotInFlight = true
            URLSession.shared.dataTask(with: bust(snapshotURL)) { [weak self] data, _, err in
                let capture = self
                if let err {
                    Task { @MainActor in
                        capture?.snapshotInFlight = false
                        capture?.onError?(err.localizedDescription)
                    }
                    return
                }
                guard let data, let image = cgImage(from: data) else {
                    Task { @MainActor in capture?.snapshotInFlight = false }
                    return
                }
                let stamp = Date().timeIntervalSince1970
                Task { @MainActor in
                    capture?.snapshotInFlight = false
                    capture?.onFrame?(image, stamp)
                }
            }.resume()
            return
        }
        guard let output, let player, let item = player.currentItem else { return }
        let t = item.currentTime()
        if output.hasNewPixelBuffer(forItemTime: t),
           let pb = output.copyPixelBuffer(forItemTime: t, itemTimeForDisplay: nil),
           let image = cgImage(from: pb, transform: playerTransform)
        {
            onFrame?(image, Date().timeIntervalSince1970)
        }
        if player.timeControlStatus == .paused, item.duration.isNumeric {
            player.seek(to: .zero)
            player.play()
        }
    }
}

private final class FrameTap: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let lock = NSLock()
    private var last: TimeInterval = 0
    private var lastRaw: TimeInterval = 0
    private var lastRawWall: TimeInterval = 0
    private var fpsSamples: [Double] = []
    private var slowSince: TimeInterval = 0
    private var _minInterval: TimeInterval = 0.20
    var minInterval: TimeInterval {
        get { lock.lock(); defer { lock.unlock() }; return _minInterval }
        set { lock.lock(); _minInterval = newValue; lock.unlock() }
    }
    var uniqueID: String = ""
    private var _orientOverride: String = "auto"
    var orientOverride: String {
        get { lock.lock(); defer { lock.unlock() }; return _orientOverride }
        set { lock.lock(); _orientOverride = newValue; lock.unlock() }
    }
    var horizonLevel = false
    private var _thermal = false
    var thermal: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _thermal }
        set { lock.lock(); _thermal = newValue; lock.unlock() }
    }
    private var _lastStamp: TimeInterval = 0
    var lastStamp: TimeInterval {
        lock.lock(); defer { lock.unlock() }; return _lastStamp
    }
    private var _emitBusy = false
    private var _busySince: TimeInterval = 0
    private let emit: (CGImage, TimeInterval) -> Void
    init(emit: @escaping (CGImage, TimeInterval) -> Void) { self.emit = emit }
    func markConsumed() {
        lock.lock()
        _emitBusy = false
        _busySince = 0
        lock.unlock()
    }
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let ptsSec = CMTimeGetSeconds(pts)
        let fpsStamp = (pts.isValid && ptsSec.isFinite && ptsSec > 0) ? ptsSec : Date().timeIntervalSince1970
        if lastRaw > 0 {
            let rawDt = fpsStamp - lastRaw
            if rawDt > 0.02, rawDt < 0.50 {
                fpsSamples.append(1.0 / rawDt)
                if fpsSamples.count > 8 { fpsSamples.removeFirst(fpsSamples.count - 8) }
            }
        }
        let wall = Date().timeIntervalSince1970
        let stamp = MatchMath.ptsWallStamp(
            pts: fpsStamp,
            wall: wall,
            prevPts: lastRaw > 0 ? lastRaw : nil,
            prevWall: lastRawWall > 0 ? lastRawWall : nil
        )
        lastRaw = fpsStamp
        lastRawWall = stamp
        lock.lock(); _lastStamp = stamp; lock.unlock()
        let median = fpsSamples.isEmpty ? 0.0 : fpsSamples.sorted()[fpsSamples.count / 2]
        if median > 0, median < 12 {
            if slowSince == 0 { slowSince = fpsStamp }
        } else {
            slowSince = 0
        }
        let slowFor = slowSince > 0 ? fpsStamp - slowSince : 0
        let therm = MatchMath.liveThermalHolds(medianFps: median, slowFor: slowFor)
        thermal = therm
        let interval = MatchMath.liveMinIntervalThermal(base: minInterval, thermal: therm)
        guard stamp - last >= interval else { return }
        lock.lock()
        let busy = _emitBusy
        let busyFor = _busySince > 0 ? stamp - _busySince : 0
        let allow = MatchMath.liveEmitAllows(busy: busy, busyFor: busyFor)
        let pending = busy && MatchMath.liveEmitPendingWhileBusy()
        if allow {
            _emitBusy = true
            _busySince = stamp
        }
        lock.unlock()
        guard allow || pending else { return }
        last = stamp
        if pending, !allow, MatchMath.liveFrameTapSkipsCGImage(busy: busy, busyFor: busyFor) {
            return
        }
        let override = orientOverride
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer),
              let image = cgImage(from: pb, orientation: visionOrientation(
                connection,
                override: override,
                width: CVPixelBufferGetWidth(pb),
                height: CVPixelBufferGetHeight(pb)
              ))
        else {
            if allow { markConsumed() }
            return
        }
        if MatchMath.liveFrameTapEmitsOnCaptureQueue() {
            emit(image, stamp)
        } else {
            DispatchQueue.main.async { self.emit(image, stamp) }
        }
    }
}

private func visionOrientation(_ connection: AVCaptureConnection, override: String = "auto", width: Int = 0, height: Int = 0) -> CGImagePropertyOrientation {
    switch override {
    case "0": return .up
    case "90": return .right
    case "180": return .down
    case "270": return .left
    default: break
    }
    if !MatchMath.physicalCaptureRotation() {
        let raw = MatchMath.liveBufferOrientation(width: width, height: height)
        return CGImagePropertyOrientation(rawValue: raw) ?? .up
    }
    let angle: CGFloat
    if #available(macOS 14.0, *) {
        angle = connection.videoRotationAngle
    } else {
        switch connection.videoOrientation {
        case .portrait: angle = 90
        case .portraitUpsideDown: angle = 270
        case .landscapeRight: angle = 180
        default: angle = 0
        }
    }
    let wrapped = Int(((angle.truncatingRemainder(dividingBy: 360)) + 360).truncatingRemainder(dividingBy: 360).rounded())
    switch wrapped {
    case 90: return .right
    case 180: return .down
    case 270: return .left
    default: return .up
    }
}

private func bust(_ url: URL) -> URL {
    var c = URLComponents(url: url, resolvingAgainstBaseURL: false)
    var items = c?.queryItems ?? []
    items.append(URLQueryItem(name: "t", value: String(Int(Date().timeIntervalSince1970 * 1000))))
    c?.queryItems = items
    return c?.url ?? url
}

private func cgImage(from data: Data) -> CGImage? {
    NSImage(data: data)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
}

private let liveOrientContext = CIContext(options: [.cacheIntermediates: false])

private func cgImage(from pb: CVPixelBuffer, orientation: CGImagePropertyOrientation = .up, transform: CGAffineTransform = .identity) -> CGImage? {
    var oriented = CIImage(cvPixelBuffer: pb)
    if !transform.isIdentity {
        oriented = oriented.transformed(by: transform)
    }
    if orientation != .up {
        oriented = oriented.oriented(orientation)
    }
    return liveOrientContext.createCGImage(oriented, from: oriented.extent)
}

func sniffLiveKind(_ raw: String) -> (LiveKind, URL)? {
    guard let url = URL(string: raw.trimmingCharacters(in: .whitespacesAndNewlines)) else { return nil }
    let s = url.scheme?.lowercased() ?? ""
    let href = url.absoluteString
    if s == "rtsp" || s == "rtsps" { return (.rtsp, url) }
    if href.contains(".m3u8") || href.contains("/hls/") { return (.hls, url) }
    if href.range(of: "mjpeg|mjpg|videostream", options: .regularExpression) != nil { return (.mjpeg, url) }
    if href.range(of: "snapshot|picture|/jpg/", options: .regularExpression) != nil { return (.snapshot, url) }
    if s == "http" || s == "https" { return (.httpVideo, url) }
    return nil
}
