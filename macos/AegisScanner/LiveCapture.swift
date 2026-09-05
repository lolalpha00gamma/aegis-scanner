import AppKit
import AVFoundation
import CoreGraphics
import CoreImage
import CoreMedia
import CoreVideo
import Foundation
import ImageIO
import Vision

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
    private var snapshotInFlight = false
    var onFrame: ((CGImage, TimeInterval) -> Void)?
    var onError: ((String) -> Void)?
    var onReady: (() -> Void)?
    /// Live-Tap: Hunt 8/10 fps, Lock 12/15. 5 fps ließ leftoverAdopt sterben.
    private(set) var facesPresent = false
    private(set) var cameraUniqueID: String = ""
    private(set) var orientOverride: String = "auto"
    private(set) var isContinuity = false
    private(set) var formatChip = ""
    var choice: CameraChoice = .auto

    static func orientKey(_ uniqueID: String) -> String { "aegis.camOrient.\(uniqueID)" }

    func setOrientOverride(_ value: String) {
        orientOverride = value
        tap?.orientOverride = value
        if !cameraUniqueID.isEmpty {
            UserDefaults.standard.set(value, forKey: Self.orientKey(cameraUniqueID))
        }
    }

    func setFacesPresent(_ on: Bool) {
        let changed = on != facesPresent
        facesPresent = on
        tap?.minInterval = MatchMath.liveMinInterval(continuity: isContinuity, faces: on)
        if changed, isContinuity {
            applyCenterStage(force: true)
        }
        if changed, timer != nil {
            startTimer()
        }
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
        case .hls, .httpVideo, .rtsp:
            startPlayer(url: url)
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
        if let failObserver {
            NotificationCenter.default.removeObserver(failObserver)
            self.failObserver = nil
        }
        player?.pause()
        player = nil
        output = nil
        playerTransform = .identity
        session?.stopRunning()
        session = nil
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
        if #available(macOS 14.0, *) {
            isContinuity = device.deviceType == .continuityCamera || device.deviceType == .deskViewCamera
        } else {
            isContinuity = device.deviceType == .continuityCamera
        }
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
        tap?.minInterval = MatchMath.liveMinInterval(continuity: isContinuity, faces: facesPresent)
        if session.canAddOutput(out) { session.addOutput(out) }
        applyCenterStage(force: true)
        applyBestFormat(device)
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
        outputQueue.async { session.startRunning() }
        onReady?()
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
        applyCenterStage(force: true)
        applyBestFormat(device)
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
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            let capture = self
            Task { @MainActor in
                capture?.grab()
            }
        }
    }

    private func grab() {
        if let snapshotURL {
            if snapshotInFlight { return }
            snapshotInFlight = true
            URLSession.shared.dataTask(with: bust(snapshotURL)) { [weak self] data, _, err in
                let capture = self
                Task { @MainActor in
                    capture?.snapshotInFlight = false
                    if let err {
                        capture?.onError?(err.localizedDescription)
                        return
                    }
                    guard let data, let image = cgImage(from: data) else { return }
                    capture?.onFrame?(image, Date().timeIntervalSince1970)
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
            onFrame?(image, CMTimeGetSeconds(t))
        }
        if player.timeControlStatus == .paused, item.duration.isNumeric {
            player.seek(to: .zero)
            player.play()
        }
    }
}

private final class FrameTap: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var last: TimeInterval = 0
    var minInterval: TimeInterval = 0.20
    var uniqueID: String = ""
    var orientOverride: String = "auto"
    var horizonLevel = false
    private let emit: (CGImage, TimeInterval) -> Void
    init(emit: @escaping (CGImage, TimeInterval) -> Void) { self.emit = emit }
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let ptsSec = CMTimeGetSeconds(pts)
        let stamp = (pts.isValid && ptsSec.isFinite && ptsSec > 0) ? ptsSec : Date().timeIntervalSince1970
        guard stamp - last >= minInterval else { return }
        last = stamp
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer),
              let image = cgImage(from: pb, orientation: visionOrientation(
                connection,
                override: orientOverride,
                width: CVPixelBufferGetWidth(pb),
                height: CVPixelBufferGetHeight(pb)
              ))
        else { return }
        DispatchQueue.main.async { self.emit(image, stamp) }
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
        let raw = MatchMath.liveOrientationRaw(width: width, height: height)
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
