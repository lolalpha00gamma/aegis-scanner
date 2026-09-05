import AppKit
import Combine
import Foundation
import UniformTypeIdentifiers

private final class AegisScanFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var _alive = true
    func reset() { lock.lock(); _alive = true; lock.unlock() }
    func stop() { lock.lock(); _alive = false; lock.unlock() }
    var alive: Bool { lock.lock(); defer { lock.unlock() }; return _alive }
}

@MainActor
final class LibraryStore: ObservableObject {
    @Published var media: [MediaItem] = []
    @Published var faces: [FaceObservation] = []
    @Published var identities: [Identity] = []
    @Published var matches: [MatchResult] = []
    @Published var selectedMediaId: UUID?
    @Published var selectedFaceId: UUID?
    @Published var threshold: Double = 78
    @Published var strategy: StrategyID = .aegis
    @Published var showAnatomy = true
    @Published var showNMSDebug = false
    @Published var nmsDropped: [FaceBox] = []
    @Published var status: String = "Bereit"
    @Published var busy = false
    @Published var newPersonName = ""
    @Published var liveURLText = ""
    @Published var liveActive = false
    @Published var enabled: Set<StrategyID> = StrategyID.defaultEnabled
    @Published var pendingDuplicateName: String?
    @Published var revisionWarning: String = ""
    @Published var canResumeScan = false
    @Published var cameraOrient: String = "auto"
    @Published var cameraUniqueID: String = ""
    @Published var liveHeldIds: Set<UUID> = []
    @Published var leftoverHold: [UUID: Double] = [:]
    private var leftoverHoldBins: [String: Double] = [:]
    @Published var leftoverPending: [UUID: String] = [:]
    @Published var cameraChoice: CameraChoice = .auto
    @Published var liveFormatChip: String = ""
    @Published var freezeAxis: [UUID: String] = [:]
    @Published var swapFlashUntil: TimeInterval = 0
    @Published var headCountFlashUntil: TimeInterval = 0
    @Published var mergeHint: String = ""

    private let liveCapture = LiveCapture()
    private var liveMediaId: UUID?
    private var leftoverStreak: [UUID: Int] = [:]
    private var leftoverStreakBox: [UUID: FaceBox] = [:]
    private var leftoverStreakSince: [UUID: TimeInterval] = [:]
    private var leftoverMissFrames: [UUID: Int] = [:]
    private var leftoverWipeUntil: [UUID: TimeInterval] = [:]
    private var leftoverPairLast: [UUID: UUID] = [:]
    private var leftoverPairStreak: [UUID: Int] = [:]
    private var leftoverPairCommit: [UUID: UUID] = [:]
    private var tapGuestPending: Set<UUID> = []
    private var lastLiveVisMs: Double = 0
    private var liveSlotHold: [UUID: (slot: String, n: Int)] = [:]
    private var lastLiveHeadCount: Int = 0
    private var lastHeadCountLabel: String?
    private var scopedRoots: [URL] = []
    private var liveBusy = false
    private var livePending: (image: CGImage, mediaId: UUID, stamp: TimeInterval)?
    private var liveRoiTick = 0
    private var liveRoiSkipOnce = false
    private var maskHoldSince: [UUID: TimeInterval] = [:]
    private var lastUSlotHint: TimeInterval = 0
    private var scanGeneration = 0
    private let scanFlag = AegisScanFlag()
    private let enabledKey = "aegis.enabledStrategies"
    private let resumeBookmarkKey = "aegis.scanResume.bookmark"
    private let resumeRemainingKey = "aegis.scanResume.remaining"
    private let resumeDetectKey = "aegis.scanResume.detect"
    private var liveGhosts: [(face: FaceObservation, until: TimeInterval)] = []
    private var reconnectGhosts: [FaceObservation] = []
    private var boxEuro: [UUID: (x: MatchMath.OneEuro, y: MatchMath.OneEuro, w: MatchMath.OneEuro, h: MatchMath.OneEuro)] = [:]
    private var boxJumpPending: [UUID: FaceBox] = [:]
    private var liveNameHist: [UUID: [String]] = [:]
    private var liveNameLock: [UUID: UUID] = [:]
    private var liveScoreEma: [UUID: Double] = [:]
    private var liveYaw: [UUID: Double] = [:]
    private var livePitch: [UUID: Double] = [:]
    private var liveRoll: [UUID: Double] = [:]
    private var liveLastStamp: TimeInterval = 0
    private var liveDt: TimeInterval = 0.125
    private var liveDtSamples: [TimeInterval] = []
    private var liveNameVoteAt: [UUID: TimeInterval] = [:]
    private var tapNameLockUntil: [UUID: TimeInterval] = [:]
    private var liveFaceStreak = 0
    private var livePrintTrail: [UUID: [[Double]]] = [:]
    private var livePrintTrailSlot: [UUID: String] = [:]
    private var liveStillFor: [UUID: TimeInterval] = [:]
    private var livePrintDrift: [UUID: [Double]] = [:]
    private var livePoseAt: [UUID: TimeInterval] = [:]
    private var liveExposureUntil: [UUID: TimeInterval] = [:]
    private var liveCaptureHist: [UUID: [Double]] = [:]
    private var livePosterJitter: [UUID: Double] = [:]
    private var livePosterStill: [UUID: Int] = [:]
    private var liveLandmarkPrev: [UUID: [Point2]] = [:]
    private var liveLidClosed: [UUID: Bool] = [:]
    private var liveBlinkSeen: [UUID: Bool] = [:]
    private var leftoverDisagree: [UUID: Int] = [:]
    private var boxKalman: [UUID: (x: Double, y: Double, w: Double, h: Double, px: Double, py: Double, pw: Double, ph: Double)] = [:]
    private var boxKalmanV: [UUID: (vx: Double, vy: Double)] = [:]
    private var leftoverHoldTrail: [UUID: [Double]] = [:]
    private var leftoverHoldTrailBins: [String: [Double]] = [:]
    private var leftoverHoldByHash: [String: (cosine: Double, at: TimeInterval)] = [:]
    private var leftoverHoldTrailByHash: [String: (samples: [Double], at: TimeInterval)] = [:]
    private var leftoverLastHash: [UUID: String] = [:]
    private var leftoverSparkChipHeld: [UUID: (chip: String, hold: Int)] = [:]
    private var leftoverEmptySince: TimeInterval?
    private var guestOrder: [UUID] = []
    private var guestSeenAt: [UUID: TimeInterval] = [:]
    private var lastCameraUniqueID: String = ""
    private var pendingRenameId: UUID?
    private var pendingRenameName: String?
    private var pendingRenameAt: TimeInterval?

    init() {
        let packed = GalleryFile.load()
        identities = packed.identities
        faces = packed.faces
        leftoverStreakSince = MatchMath.leftoverStreakSinceDecode(packed.leftoverStreakSince)
        if let stored = packed.printRevision, stored != MatchMath.printRevision {
            revisionWarning = "Galerie-Print \(stored), App \(MatchMath.printRevision) — Scores können springen. Neu scannen."
        }
        if let raw = UserDefaults.standard.array(forKey: enabledKey) as? [String] {
            let set = Set(raw.compactMap(StrategyID.init(rawValue:)))
            if !set.isEmpty { enabled = set }
        }
        if !UserDefaults.standard.bool(forKey: "aegis.terFusionDefaultOff") {
            enabled.remove(.terFusion)
            UserDefaults.standard.set(true, forKey: "aegis.terFusionDefaultOff")
            UserDefaults.standard.set(enabled.map(\.rawValue), forKey: enabledKey)
        }
        canResumeScan = hasResumeWork()
        if !identities.isEmpty {
            status = revisionWarning.isEmpty
                ? "Galerie · \(identities.count) Personen"
                : revisionWarning
        }
        if let raw = UserDefaults.standard.string(forKey: "aegis.cameraChoice"),
           let c = CameraChoice(rawValue: raw)
        {
            cameraChoice = c
        }
        liveCapture.choice = cameraChoice
        let digest = GalleryFile.digestStatus()
        if let note = MatchMath.shaVerifyNote(ok: digest.ok, missing: digest.missing) {
            revisionWarning = revisionWarning.isEmpty ? note : revisionWarning + " · " + note
            if identities.isEmpty {
                status = note
            } else if revisionWarning == note {
                status = note
            }
        }
    }

    private func persist() {
        GalleryFile.save(
            identities: identities,
            faces: faces,
            leftoverStreakSince: MatchMath.leftoverStreakSinceEncode(leftoverStreakSince)
        )
        refreshMergeHint()
    }

    func refreshMergeHint() {
        let pairs = IdentityDesk.mergePairs(identities: identities, gallery: faces)
        if let p = pairs.first {
            mergeHint = MatchMath.mergeHintLabel(count: pairs.count, a: p.keepName, b: p.dropName, cosine: p.cosine)
        } else {
            mergeHint = ""
        }
    }

    func acceptMergeHint() {
        let pairs = IdentityDesk.mergePairs(identities: identities, gallery: faces)
        guard let p = pairs.first else { return }
        mergeIdentities(keep: p.keep, drop: p.drop)
    }

    func mergeIdentities(keep: UUID, drop: UUID) {
        guard keep != drop,
              let ki = identities.firstIndex(where: { $0.id == keep }),
              let di = identities.firstIndex(where: { $0.id == drop })
        else { return }
        let extra = identities[di].faceIds
        identities[ki].faceIds.append(contentsOf: extra.filter { !identities[ki].faceIds.contains($0) })
        identities[ki].rejectedVecs.append(contentsOf: identities[di].rejectedVecs)
        let name = identities[ki].name
        identities.remove(at: di)
        persist()
        rematch()
        status = "\(name) zusammengeführt"
    }

    var canRestoreBackup: Bool { GalleryFile.backupExists }

    func restoreFromBackup() {
        guard let packed = GalleryFile.loadBackup() else {
            status = "Kein gallery.json.bak"
            return
        }
        identities = packed.identities
        faces = packed.faces
        leftoverStreakSince = MatchMath.leftoverStreakSinceDecode(packed.leftoverStreakSince)
        liveNameHist = [:]
        liveNameLock = [:]
        liveScoreEma = [:]
        liveYaw = [:]
        livePitch = [:]
        liveRoll = [:]
        liveLastStamp = 0
        liveDt = 0.125
        liveDtSamples = []
        liveNameVoteAt = [:]
        tapNameLockUntil = [:]
        liveFaceStreak = 0
        rematch()
        persist()
        let schema = packed.schemaVersion.map { "Schema \($0)" } ?? "Schema <2"
        status = "Galerie aus Backup · \(identities.count) Personen · \(faces.count) Gesichter · \(schema)"
    }

    func restoreWarning() -> String {
        let age = GalleryFile.backupAgeDays() ?? 0
        let packed = GalleryFile.loadBackup()
        return MatchMath.restoreNote(
            ageDays: age,
            schemaVersion: packed?.schemaVersion,
            printRevision: packed?.printRevision
        )
    }

    var selectedMedia: MediaItem? {
        media.first { $0.id == selectedMediaId }
    }

    var browseItems: [MediaItem] {
        media.filter { $0.kind != .frame && $0.kind != .snapshot }
    }

    var browseIndex: Int {
        let id: UUID?
        if let item = selectedMedia, item.kind == .frame {
            id = item.parentId
        } else {
            id = selectedMediaId
        }
        guard let id else { return 0 }
        return browseItems.firstIndex { $0.id == id } ?? 0
    }

    var browseLabel: String {
        let n = browseItems.count
        guard n > 0 else { return "0 / 0" }
        let name = selectedMedia?.name ?? browseItems[browseIndex].name
        return "\(browseIndex + 1) / \(n)  ·  \(name)"
    }

    var selectedFace: FaceObservation? {
        if let id = selectedFaceId, let face = faces.first(where: { $0.id == id }) {
            return face
        }
        if let mediaId = selectedMediaId {
            return faces.first { $0.mediaId == mediaId }
        }
        return nil
    }

    var liveContinuity: Bool { liveActive && liveCapture.isContinuity }

    var floorHint: String {
        let f = FaceEngine.effectiveFloors(galleryCount: identities.count, slider: threshold)
        let open = Int(MatchMath.unknownRejectFloor(slider: threshold).rounded())
        let unnamed = leftoverPending.values.filter { $0 == MatchMath.conflictTickNote() || $0.hasPrefix("Gast") }.count
        let named = identities.count
        if named + unnamed > 0, unnamed > 0 {
            let far = MatchMath.liveFAR(impostorAbove: unnamed, totalImpostor: named + unnamed)
            return "Galerie \(identities.count): Floor \(Int(f.match)) · Solo \(Int(f.solo)) · Open-Set \(open) · \(MatchMath.liveFARLabel(far))"
        }
        return "Galerie \(identities.count): Floor \(Int(f.match)) · Solo \(Int(f.solo)) · Open-Set \(open)"
    }

    var benchHome: URL { BenchFetch.root() }

    var benchHint: String {
        if BenchFetch.ident20Ready() {
            return "Testdaten bereit in Downloads/AegisBench — Test starten."
        }
        return "Fotos stehen nicht auf GitHub (Lizenz). Testdaten holen: ~170 MB, einmalig."
    }

    var enrollmentHint: String {
        guard let face = selectedFace else { return "" }
        let dest = FaceEngine.identityOwning(face: face, identities: identities, faces: faces)
            ?? (identities.count == 1 ? identities[0] : nil)
        return FaceEngine.enrollmentPreview(
            face: face,
            identities: identities,
            faces: faces,
            addingTo: dest
        )
    }

    var selectedHits: [StrategyHit] {
        guard let id = selectedFace?.id else { return [] }
        return matches.first { $0.faceId == id }?.hits ?? []
    }

    func selectMedia(_ id: UUID?) {
        selectedMediaId = id
        if let id {
            if let current = selectedFaceId,
               faces.contains(where: { $0.id == current && $0.mediaId == id }) {
                return
            }
            selectedFaceId = faces.first { $0.mediaId == id }?.id
        } else {
            selectedFaceId = nil
        }
    }

    func stepMedia(_ delta: Int) {
        let items = browseItems
        guard items.count >= 2 else { return }
        let next = (browseIndex + delta % items.count + items.count) % items.count
        let item = items[next]
        if item.kind == .video {
            selectMedia(media.first { $0.parentId == item.id }?.id ?? item.id)
        } else {
            selectMedia(item.id)
        }
    }

    func pickFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.folder, .image, .movie, .jpeg, .png, .heic, .mpeg4Movie, .quickTimeMovie]
        panel.prompt = "Scannen"
        panel.message = "Ordner oder mehrere Fotos wählen — danach mit ← → blättern."
        if let data = UserDefaults.standard.data(forKey: resumeBookmarkKey) {
            var stale = false
            if let url = try? URL(
                resolvingBookmarkData: data,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &stale
            ) {
                panel.directoryURL = url
            }
        }
        guard panel.runModal() == .OK else { return }
        var roots: [URL] = []
        var files: [URL] = []
        var folders: [URL] = []
        for url in panel.urls {
            roots.append(url)
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
            if isDir.boolValue {
                folders.append(url)
            } else {
                files.append(url)
            }
        }
        retainAccess(roots)
        rememberFolder(roots.first)
        scanGeneration += 1
        scanFlag.reset()
        let gen = scanGeneration
        let flag = scanFlag
        busy = true
        status = "Ordner lesen …"
        Task {
            var urls = files
            for folder in folders {
                if gen != self.scanGeneration { return }
                let found = await Task.detached {
                    FrameExtractor.walk(folder: folder) { flag.alive }
                }.value
                if gen != self.scanGeneration {
                    self.rememberRemaining(urls)
                    self.status = "Scan abgebrochen — Fortsetzen möglich"
                    self.busy = false
                    return
                }
                urls.append(contentsOf: found)
            }
            if gen != self.scanGeneration {
                self.rememberRemaining(urls)
                self.status = "Scan abgebrochen — Fortsetzen möglich"
                self.busy = false
                return
            }
            await self.ingestAndScan(urls: urls, generation: gen)
        }
    }

    func resumeScan() {
        let paths = UserDefaults.standard.stringArray(forKey: resumeRemainingKey) ?? []
        let urls = paths.map { URL(fileURLWithPath: $0) }.filter { FileManager.default.fileExists(atPath: $0.path) }
        let detectIds = (UserDefaults.standard.stringArray(forKey: resumeDetectKey) ?? [])
            .compactMap(UUID.init(uuidString:))
        guard !urls.isEmpty || !detectIds.isEmpty else {
            canResumeScan = false
            status = "Nichts zum Fortsetzen"
            return
        }
        scanGeneration += 1
        scanFlag.reset()
        let gen = scanGeneration
        busy = true
        if !urls.isEmpty {
            status = "Scan fortsetzen · \(urls.count) Dateien"
            Task {
                await self.ingestAndScan(urls: urls, generation: gen)
            }
        } else {
            status = "Erkennung fortsetzen · \(detectIds.count) Medien"
            Task {
                await self.scan(generation: gen, onlyMedia: detectIds)
            }
        }
    }

    private func ingestAndScan(urls: [URL], generation: Int) async {
        var remaining = urls
        let before = media.count
        for url in urls {
            if generation != scanGeneration {
                rememberRemaining(remaining)
                status = "Scan abgebrochen — Fortsetzen möglich"
                busy = false
                canResumeScan = true
                return
            }
            ingest(urls: [url])
            remaining.removeAll { $0 == url }
        }
        rememberRemaining([])
        canResumeScan = false
        if let firstNew = media.dropFirst(before).first(where: { $0.kind == .photo })
            ?? media.dropFirst(before).first
        {
            selectedMediaId = firstNew.id
        }
        if generation != scanGeneration {
            busy = false
            return
        }
        await scan(generation: generation)
    }

    private func rememberFolder(_ url: URL?) {
        guard let url else { return }
        if let data = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
            UserDefaults.standard.set(data, forKey: resumeBookmarkKey)
        }
    }

    private func rememberRemaining(_ urls: [URL]) {
        UserDefaults.standard.set(urls.map(\.path), forKey: resumeRemainingKey)
        canResumeScan = hasResumeWork()
    }

    private func rememberDetectRemaining(_ ids: [UUID]) {
        UserDefaults.standard.set(ids.map(\.uuidString), forKey: resumeDetectKey)
        canResumeScan = hasResumeWork()
    }

    private func hasResumeWork() -> Bool {
        let files = UserDefaults.standard.stringArray(forKey: resumeRemainingKey) ?? []
        let detect = UserDefaults.standard.stringArray(forKey: resumeDetectKey) ?? []
        return !files.isEmpty || !detect.isEmpty
    }

    private func retainAccess(_ urls: [URL]) {
        let previous = scopedRoots
        scopedRoots = urls
        for url in scopedRoots {
            _ = url.startAccessingSecurityScopedResource()
        }
        previous.forEach { $0.stopAccessingSecurityScopedResource() }
    }

    func ingest(urls: [URL]) {
        var skipped = 0
        for url in urls {
            if FrameExtractor.isVideo(url) {
                media.append(
                    MediaItem(
                        id: UUID(),
                        url: url,
                        name: url.lastPathComponent,
                        kind: .video,
                        width: 0,
                        height: 0,
                        duration: nil
                    )
                )
            } else if FrameExtractor.isImage(url) {
                if let image = FrameExtractor.loadCGImage(url: url) {
                    media.append(
                        MediaItem(
                            id: UUID(),
                            url: url,
                            name: url.lastPathComponent,
                            kind: .photo,
                            width: image.width,
                            height: image.height,
                            preview: image
                        )
                    )
                } else {
                    skipped += 1
                }
            } else {
                skipped += 1
            }
        }
        selectedMediaId = media.first { $0.kind == .photo }?.id ?? media.first?.id
        let photos = media.filter { $0.kind == .photo }.count
        let videos = media.filter { $0.kind == .video }.count
        if media.isEmpty {
            status = skipped > 0 ? "\(skipped) Dateien unlesbar" : "Keine Medien"
        } else if skipped > 0 {
            status = "\(photos) Fotos, \(videos) Videos · \(skipped) übersprungen · ← → blättern"
        } else {
            status = "\(photos) Fotos, \(videos) Videos · ← → blättern"
        }
    }

    func cancelScan() {
        guard busy else { return }
        scanFlag.stop()
        scanGeneration += 1
        busy = false
        canResumeScan = hasResumeWork()
        status = canResumeScan ? "Scan abgebrochen — Fortsetzen möglich" : "Scan abgebrochen"
    }

    func scan() async {
        scanGeneration += 1
        scanFlag.reset()
        await scan(generation: scanGeneration)
    }

    private func scan(generation: Int, onlyMedia: [UUID]? = nil) async {
        busy = true
        status = "Frames extrahieren"
        let videos = media.filter { $0.kind == .video }
        let haveFrames = Set(media.compactMap { $0.parentId })
        for video in videos where !haveFrames.contains(video.id) {
            if generation != scanGeneration {
                status = "Scan abgebrochen"
                busy = false
                return
            }
            status = "Video · \(video.name)"
            do {
                let frames = try await FrameExtractor.extract(from: video.url)
                if generation != scanGeneration {
                    status = "Scan abgebrochen"
                    busy = false
                    return
                }
                if frames.isEmpty {
                    status = "\(video.name): keine Frames"
                    continue
                }
                for frame in frames {
                    media.append(
                        MediaItem(
                            id: UUID(),
                            url: video.url,
                            name: String(format: "%@ · %.2fs", video.name, frame.time),
                            kind: .frame,
                            width: frame.image.width,
                            height: frame.image.height,
                            parentId: video.id,
                            timeSec: frame.time,
                            preview: frame.image
                        )
                    )
                }
            } catch {
                status = "\(video.name): \(error.localizedDescription)"
                continue
            }
        }
        var pending = media.filter { item in
            (item.kind == .photo || item.kind == .frame) && !faces.contains { $0.mediaId == item.id }
        }
        if let only = onlyMedia, !only.isEmpty {
            let set = Set(only)
            pending = pending.filter { set.contains($0.id) }
        }
        var ingestSkipped = 0
        for (i, item) in pending.enumerated() {
            if generation != scanGeneration {
                rememberDetectRemaining(Array(pending.dropFirst(i).map(\.id)))
                status = "Scan abgebrochen — Fortsetzen möglich"
                busy = false
                canResumeScan = true
                return
            }
            status = "Gesicht · \(i + 1)/\(pending.count)"
            let image = item.preview ?? FrameExtractor.loadCGImage(url: item.url)
            guard let image else { continue }
            let mediaId = item.id
            do {
                let found = try await Task.detached(priority: .userInitiated) {
                    try FaceEngine.detect(in: image, mediaId: mediaId, cheapGraph: true)
                }.value
                if generation != scanGeneration {
                    rememberDetectRemaining(Array(pending.dropFirst(i).map(\.id)))
                    status = "Scan abgebrochen — Fortsetzen möglich"
                    busy = false
                    canResumeScan = true
                    return
                }
                let kept = FaceEngine.filterIngestDuplicates(found, existing: faces)
                let skipped = found.count - kept.count
                ingestSkipped += skipped
                faces.append(contentsOf: kept)
                if skipped > 0 {
                    status = "Gesicht · \(i + 1)/\(pending.count) · \(skipped) Burst-Kopien übersprungen"
                }
            } catch {
                continue
            }
        }
        rememberDetectRemaining([])
        if generation != scanGeneration {
            status = "Scan abgebrochen — Fortsetzen möglich"
            busy = false
            canResumeScan = hasResumeWork()
            return
        }
        status = "Abgleich"
        nmsDropped = FaceEngine.lastNMSDropped
        rematch()
        if let mediaId = selectedMediaId {
            if selectedFaceId == nil || !(faces.contains { $0.id == selectedFaceId && $0.mediaId == mediaId }) {
                selectedFaceId = faces.first { $0.mediaId == mediaId }?.id
            }
        } else if selectedFaceId == nil {
            selectedFaceId = faces.first?.id
        }
        let emptyPrints = faces.filter { $0.featurePrint.isEmpty }.count
        let skipNote = ingestSkipped > 0 ? " · \(ingestSkipped) Burst-Kopien übersprungen" : ""
        if !FaceEngine.facePrintAvailable {
            status = "Fertig · \(faces.count) Gesichter · Face-Print nicht verfügbar — nur Geometrie\(skipNote)"
        } else if !faces.isEmpty, emptyPrints == faces.count {
            status = "Fertig · \(faces.count) Gesichter · Face-Print leer — nur Geometrie\(skipNote)"
        } else {
            status = "Fertig · \(faces.count) Gesichter\(skipNote)"
        }
        busy = false
    }

    func rematch() {
        matches = FaceEngine.match(
            faces: faces,
            identities: identities,
            media: media,
            threshold: threshold,
            enabled: enabled,
            continuity: liveContinuity
        )
        refreshMergeHint()
    }

    /// Live-Frame: Sonden gegen Identitäts-Centroids, nicht jedes Galerie-Foto.
    func rematchLive() {
        guard liveActive, let liveId = liveMediaId else {
            rematch()
            return
        }
        let enrolled = Set(identities.flatMap(\.faceIds))
        let live = faces.filter { $0.mediaId == liveId }
        let gallery = faces.filter { enrolled.contains($0.id) && $0.mediaId != liveId }
        let next = FaceEngine.matchLive(
            probes: live,
            identities: identities,
            gallery: gallery,
            threshold: threshold,
            continuity: liveContinuity
        )
        let probeIds = Set(live.map(\.id))
        matches = matches.filter { !probeIds.contains($0.faceId) } + next
        stabilizeLiveMatches()
    }

    /// Live: 5-Tick-Namensmehrheit + Score der gewählten ID, sonst flackert Overlay zwischen Geschwistern.
    private func stabilizeLiveMatches() {
        guard liveActive, let liveId = liveMediaId else { return }
        let liveFaceIds = Set(faces.filter { $0.mediaId == liveId }.map(\.id))
        liveNameHist = liveNameHist.filter { liveFaceIds.contains($0.key) }
        liveNameLock = liveNameLock.filter { liveFaceIds.contains($0.key) }
        liveNameVoteAt = liveNameVoteAt.filter { liveFaceIds.contains($0.key) }
        liveScoreEma = liveScoreEma.filter { liveFaceIds.contains($0.key) }
        liveYaw = liveYaw.filter { liveFaceIds.contains($0.key) }
        livePitch = livePitch.filter { liveFaceIds.contains($0.key) }
        liveRoll = liveRoll.filter { liveFaceIds.contains($0.key) }
        livePrintDrift = livePrintDrift.filter { liveFaceIds.contains($0.key) }
        livePoseAt = livePoseAt.filter { liveFaceIds.contains($0.key) }
        freezeAxis = freezeAxis.filter { liveFaceIds.contains($0.key) }
        let frameNow = liveLastStamp > 0 ? liveLastStamp : Date().timeIntervalSince1970
        for i in matches.indices {
            let fid = matches[i].faceId
            guard liveFaceIds.contains(fid),
                  let hi = matches[i].hits.firstIndex(where: { $0.strategy == .aegis })
            else { continue }
            var hit = matches[i].hits[hi]
            if !hit.measured {
                continue
            }
            let face = faces.first { $0.id == fid }
            let yaw = face?.quality.yaw ?? 0
            let pitch = face?.quality.pitch ?? 0
            let roll = face?.quality.roll ?? 0
            let prevYaw = liveYaw[fid]
            let prevPitch = livePitch[fid]
            let prevRoll = liveRoll[fid]
            let gap = livePoseAt[fid].map { frameNow - $0 } ?? 0
            let dt = MatchMath.trackDt(now: frameNow, last: livePoseAt[fid], cameraDt: liveDt)
            let dropped = MatchMath.poseDropoutResets(gap: gap, cameraDt: liveDt) && livePoseAt[fid] != nil
            liveYaw[fid] = yaw
            livePitch[fid] = pitch
            liveRoll[fid] = roll
            livePoseAt[fid] = frameNow
            let spinning = !dropped && MatchMath.poseVelocityFreeze(
                yawDelta: prevYaw.map { yaw - $0 } ?? 0,
                pitchDelta: prevPitch.map { pitch - $0 } ?? 0,
                rollDelta: prevRoll.map { roll - $0 } ?? 0,
                dt: dt
            ) && (prevYaw != nil || prevPitch != nil || prevRoll != nil)
            freezeAxis.removeValue(forKey: fid)
            if spinning, let axis = MatchMath.poseFreezeAxis(
                yawDelta: prevYaw.map { yaw - $0 } ?? 0,
                pitchDelta: prevPitch.map { pitch - $0 } ?? 0,
                rollDelta: prevRoll.map { roll - $0 } ?? 0,
                dt: dt
            ) {
                freezeAxis[fid] = axis
            }
            let qualityOK = MatchMath.nameVoteAccepts(
                sharpness: face?.quality.sharpness,
                continuity: liveContinuity,
                occluded: face.map { FaceEngine.lowerFaceOccluded($0) } ?? false,
                gazeAway: MatchMath.gazeAway(yaw: face?.quality.yaw ?? 0, pitch: face?.quality.pitch ?? 0),
                eyesClosed: MatchMath.eyesClosed(
                    openIod: face?.ratioSheet.first { $0.id == "eyeOpen_iod" }?.value
                ),
                mouthOpen: MatchMath.mouthOpen(
                    heightIod: face?.ratioSheet.first { $0.id == "mouthH_iod" }?.value
                )
            )
            let muted = MatchMath.leftoverWipeMutes(
                until: leftoverWipeUntil[fid],
                now: frameNow,
                histCount: (liveNameHist[fid] ?? []).filter { !$0.isEmpty }.count
            )
            // leftover wischt Hist einmal am Pin (applyLiveFaces). Hier nicht jeden Tick
            // leere Tokens füttern — sonst tauft Genuine 0,64–0,79 nie.
            // Drehung / Unschärfe / Gähnen / Wipe-Mute: Token leer = Skip, Lock hält.
            let token: String = {
                if muted { return "" }
                if MatchMath.leftoverStarvesVote() && leftoverHold[fid] != nil { return "" }
                if spinning || !qualityOK { return "" }
                return hit.identityId?.uuidString ?? ""
            }()
            let vs = hit.versus
            let close = MatchMath.nameClosePair(
                best: vs.first?.percent ?? 0,
                second: vs.dropFirst().first?.percent,
                pairCosine: hit.pairCosine
            )
            let need = MatchMath.nameAgreeNeed(family: close, dt: dt)
            let cap = MatchMath.nameHistCap(need: need)
            let hist = MatchMath.nameHistAppend(liveNameHist[fid] ?? [], token: token, cap: cap)
            liveNameHist[fid] = hist
            let voted = MatchMath.nameMajorityAgreeing(hist, window: cap, need: need)
            if let voted, !voted.isEmpty {
                liveNameVoteAt[fid] = frameNow
            }
            let holding = leftoverHold[fid] != nil
            let lockedId = liveNameLock[fid]
            let lockedPrint: Double? = {
                guard let lockedId else { return nil }
                if let row = vs.first(where: { $0.identityId == lockedId }) {
                    return row.percent / 100
                }
                return nil
            }()
            let lockedMissing = lockedId != nil && lockedPrint == nil && !vs.isEmpty
            let keep = MatchMath.nameLockHolds(
                voted: voted,
                locked: MatchMath.leftoverLocked(locked: lockedId?.uuidString, holding: holding),
                lockedPrint: lockedMissing ? 0 : lockedPrint,
                lastVote: liveNameVoteAt[fid],
                now: frameNow
            )
            if let keep, let ident = identities.first(where: { $0.id.uuidString == keep }) {
                leftoverHold.removeValue(forKey: fid)
                liveNameLock[fid] = ident.id
                hit.identityId = ident.id
                hit.percent = MatchMath.votedPercent(
                    versus: hit.versus.map { ($0.identityId, $0.percent) },
                    identityId: ident.id,
                    fallback: hit.percent
                )
            } else {
                liveNameLock.removeValue(forKey: fid)
                hit.identityId = nil
            }
            let ema = MatchMath.liveScoreEMA(prev: liveScoreEma[fid], next: hit.percent)
            liveScoreEma[fid] = ema
            hit.percent = ema
            matches[i].hits[hi] = hit
            var spark = livePrintDrift[fid] ?? []
            let identId = hit.identityId ?? liveNameLock[fid]
            if let identId,
               let ident = identities.first(where: { $0.id == identId }),
               let face
            {
                let owned = faces.filter { ident.faceIds.contains($0.id) }
                let centroid = FaceEngine.liveCentroid(owned, slot: FaceEngine.poseSlot(face))
                let pv = face.printVec.count >= 32 ? face.printVec : FaceEngine.embedding(of: face)
                if pv.count >= 32, centroid.count == pv.count,
                   let sample = MatchMath.printDriftSample(centroidCosine: MatchMath.cosine(pv, centroid))
                {
                    spark.append(sample)
                }
            }
            if spark.count > 8 { spark.removeFirst(spark.count - 8) }
            livePrintDrift[fid] = spark
        }
    }

    private func stampEnrolled(_ faceId: UUID) {
        if let i = faces.firstIndex(where: { $0.id == faceId }), faces[i].enrolledAt == nil {
            faces[i].enrolledAt = Date()
        }
    }

    func setEnabled(_ id: StrategyID, _ on: Bool) {
        if on { enabled.insert(id) } else { enabled.remove(id) }
        UserDefaults.standard.set(enabled.map(\.rawValue), forKey: enabledKey)
        rematch()
    }

    func setTrack(_ track: StrategyTrack, on: Bool) {
        for id in StrategyID.allCases where id.track == track {
            if on { enabled.insert(id) } else { enabled.remove(id) }
        }
        UserDefaults.standard.set(enabled.map(\.rawValue), forKey: enabledKey)
        rematch()
    }

    func createIdentity() {
        let name = newPersonName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        guard let raw = FaceEngine.faceForNewIdentity(
            selected: selectedFace,
            visibleMediaId: selectedMediaId,
            faces: faces,
            identities: identities
        ) else {
            if let selected = selectedFace,
               let owner = FaceEngine.identityOwning(face: selected, identities: identities, faces: faces) {
                status = "Dieses Gesicht gehört schon zu \(owner.name). Anderes Gesicht anklicken für eine neue Person."
            } else if selectedFace == nil {
                status = "Zuerst ein Gesicht auf dem Foto anklicken"
            } else {
                status = "Kein unbenanntes Gesicht auf diesem Foto"
            }
            return
        }
        let face = snapshotLiveIfNeeded(raw)
        if let why = FaceEngine.referenceRejected(face, asFirstReference: true, continuity: liveContinuity) {
            status = why
            dropOrphanSnapshot(face, original: raw)
            return
        }
        if let dup = FaceEngine.duplicateOf(face: face, identities: identities, faces: faces) {
            if pendingDuplicateName != name {
                pendingDuplicateName = name
                status = "Ähnlich \(dup.0.name) (\(Int(dup.1 * 100)) %). Nochmal Anlegen bestätigt (Centroid ≥ 82 %), sonst anderen Namen."
                dropOrphanSnapshot(face, original: raw)
                return
            }
        }
        pendingDuplicateName = nil
        let preview = FaceEngine.enrollmentPreview(face: face, identities: identities, faces: faces)
        let note = preview.isEmpty ? "" : " · \(preview)"
        identities.append(Identity(id: UUID(), name: name, faceIds: [face.id]))
        stampEnrolled(face.id)
        tapNameLockUntil[face.id] = MatchMath.tapNameLockUntil(now: Date().timeIntervalSince1970)
        tapNameLockUntil[raw.id] = MatchMath.tapNameLockUntil(now: Date().timeIntervalSince1970)
        newPersonName = ""
        selectedFaceId = raw.id
        rematch()
        if let next = FaceEngine.unnamedFace(on: raw.mediaId, faces: faces, identities: identities) {
            selectedFaceId = next.id
            status = "\(name) angelegt · nächstes Gesicht gewählt\(note)"
        } else {
            status = "\(name) angelegt\(note)"
        }
        persist()
    }

    func addSelectedTo(_ identityId: UUID) {
        guard let raw = selectedFace else {
            status = "Zuerst ein Gesicht anklicken"
            return
        }
        guard let idx = identities.firstIndex(where: { $0.id == identityId }) else { return }
        let live = selectedMedia?.kind == .live
        if let owner = FaceEngine.identityOwning(face: raw, identities: identities, faces: faces) {
            if owner.id != identityId {
                status = "Dieses Gesicht gehört zu \(owner.name). Anlegen für eine neue Person, nicht +."
                return
            }
            if !live {
                status = "Dieses Gesicht ist schon Referenz von \(owner.name)"
                return
            }
            // Live-Track trägt die UUID der ersten Referenz. + speichert eine Kopie.
        } else if identities[idx].faceIds.contains(raw.id) {
            if !live {
                status = "Dieses Gesicht ist schon Referenz von \(identities[idx].name)"
                return
            }
        }
        let face = snapshotLiveIfNeeded(raw)
        if let why = FaceEngine.referenceRejected(
            face,
            asFirstReference: identities[idx].faceIds.isEmpty,
            continuity: liveContinuity
        ) {
            status = why
            dropOrphanSnapshot(face, original: raw)
            return
        }
        let incoming = FaceEngine.embedding(of: face)
        let incomingSlot = FaceEngine.poseSlot(face).rawValue
        if incoming.count >= 32 {
            for existingId in identities[idx].faceIds {
                guard let old = faces.first(where: { $0.id == existingId }) else { continue }
                let ov = FaceEngine.embedding(of: old)
                guard ov.count == incoming.count else { continue }
                let c = MatchMath.cosine(incoming, ov)
                let age = Date().timeIntervalSince(old.enrolledAt ?? .distantPast)
                if MatchMath.enrollmentBurstDup(
                    sameSlot: FaceEngine.poseSlot(old).rawValue == incomingSlot,
                    cosine: c,
                    within: age
                ) {
                    if MatchMath.enrollBurstReplace(
                        incomingSharp: face.quality.sharpness,
                        existingSharp: old.quality.sharpness
                    ) {
                        identities[idx].faceIds.removeAll { $0 == old.id }
                    } else {
                        dropOrphanSnapshot(face, original: raw)
                        status = "Burst-Duplikat — schärfere Referenz von \(identities[idx].name) bleibt"
                        return
                    }
                }
                if let keepNew = MatchMath.pruneKeepIncoming(
                    cosine: c,
                    incomingSharp: face.quality.sharpness,
                    existingSharp: old.quality.sharpness
                ) {
                    if keepNew {
                        identities[idx].faceIds.removeAll { $0 == old.id }
                    } else {
                        dropOrphanSnapshot(face, original: raw)
                        status = "Burst-Duplikat — schärfere Referenz von \(identities[idx].name) bleibt"
                        return
                    }
                }
            }
        }
        var note = ""
        if let blocked = FaceEngine.poseCoverageBlocks(adding: face, to: identities[idx], faces: faces) {
            status = blocked
            dropOrphanSnapshot(face, original: raw)
            return
        }
        if let warn = FaceEngine.poseCoverageWarning(adding: face, to: identities[idx], faces: faces) {
            note = " · \(warn)"
        }
        let preview = FaceEngine.enrollmentPreview(
            face: face,
            identities: identities,
            faces: faces,
            addingTo: identities[idx]
        )
        if !identities[idx].faceIds.contains(face.id) {
            identities[idx].faceIds.append(face.id)
        }
        stampEnrolled(face.id)
        tapNameLockUntil[face.id] = MatchMath.tapNameLockUntil(now: Date().timeIntervalSince1970)
        tapNameLockUntil[raw.id] = MatchMath.tapNameLockUntil(now: Date().timeIntervalSince1970)
        rematch()
        persist()
        livePrintTrail.removeAll()
        livePrintTrailSlot.removeAll()
        let extra = preview.isEmpty ? note : " · \(preview)\(note)"
        let cov = FaceEngine.poseCoverage(identity: identities[idx], faces: faces)
        let meter = MatchMath.poseMeterLabel(
            frontal: cov.frontal, threeQuarter: cov.threeQuarter, profile: cov.profile, upper: cov.upper
        )
        status = extra.isEmpty
            ? "Referenz zu \(identities[idx].name) hinzugefügt · \(meter)"
            : "Referenz zu \(identities[idx].name)\(extra)"
    }

    /// Live-UUID ist der Track, nicht die Galerie. +/Anlegen legt eine stabile Kopie an,
    /// sonst überschreibt der nächste Frame die Referenz und + sagt „schon drin“.
    private func snapshotLiveIfNeeded(_ face: FaceObservation) -> FaceObservation {
        guard selectedMedia?.kind == .live else { return face }
        var copy = face
        copy.id = UUID()
        copy.mediaId = UUID()
        copy.trackId = face.trackId ?? face.id
        copy.enrolledAt = Date()
        copy.qualitySpark = []
        if !faces.contains(where: { $0.id == copy.id }) {
            faces.append(copy)
        }
        if !media.contains(where: { $0.id == copy.mediaId }) {
            let live = selectedMedia
            media.append(MediaItem(
                id: copy.mediaId,
                url: live?.url ?? URL(fileURLWithPath: "/tmp/aegis-snapshot-\(copy.mediaId.uuidString)"),
                name: "Live-Kopie",
                kind: .snapshot,
                width: live?.width ?? 0,
                height: live?.height ?? 0,
                duration: nil,
                parentId: live?.id,
                timeSec: nil,
                preview: live?.preview
            ))
        }
        return copy
    }

    private func dropOrphanSnapshot(_ face: FaceObservation, original: FaceObservation) {
        guard face.id != original.id else { return }
        faces.removeAll { $0.id == face.id }
    }

    func addSelectedAsPartial(_ identityId: UUID) {
        guard var face = selectedFace else {
            status = "Zuerst ein Gesicht anklicken"
            return
        }
        guard let idx = identities.firstIndex(where: { $0.id == identityId }) else { return }
        guard let item = selectedMedia, let image = item.preview else {
            status = "Kein Bild für Teil-Print"
            return
        }
        if identities[idx].faceIds.isEmpty {
            status = "Erste Referenz muss frei sein — U-Slot nur als Zusatz."
            return
        }
        if let owner = FaceEngine.identityOwning(face: face, identities: identities, faces: faces),
           owner.id != identityId
        {
            status = "Dieses Gesicht gehört zu \(owner.name)"
            return
        }
        face = snapshotLiveIfNeeded(face)
        guard let stamped = FaceEngine.stampForcedPartial(face, from: image) else {
            status = "Teil-Print fehlgeschlagen — Crop ohne Face-Print"
            dropOrphanSnapshot(face, original: selectedFace ?? face)
            return
        }
        if let i = faces.firstIndex(where: { $0.id == stamped.id }) {
            faces[i] = stamped
            face = stamped
        }
        if !identities[idx].faceIds.contains(face.id) {
            identities[idx].faceIds.append(face.id)
        }
        stampEnrolled(face.id)
        rematch()
        persist()
        status = "Teil-Print (U) zu \(identities[idx].name)"
    }

    func setCameraOrient(_ value: String) {
        cameraOrient = value
        liveCapture.setOrientOverride(value)
        if value == "auto" {
            status = "Kamera-Orientierung auto"
        } else {
            status = "Kamera-Orientierung \(value)° — Auto (videoRotationAngle) ignoriert"
        }
    }

    func setCameraChoice(_ choice: CameraChoice) {
        cameraChoice = choice
        liveCapture.choice = choice
        UserDefaults.standard.set(choice.rawValue, forKey: "aegis.cameraChoice")
        status = "Kamera: \(choice.titleDE)"
        if liveActive {
            startWebcam()
        }
    }

    func voteProgress(faceId: UUID) -> String? {
        let hist = liveNameHist[faceId] ?? []
        let hit = matches.first { $0.faceId == faceId }?.hits.first { $0.strategy == .aegis }
        let vs = hit?.versus ?? []
        let close = MatchMath.nameClosePair(
            best: vs.first?.percent ?? 0,
            second: vs.dropFirst().first?.percent,
            pairCosine: hit?.pairCosine
        )
        let need = MatchMath.nameAgreeNeed(family: close, dt: liveDt)
        let progress = MatchMath.nameVoteProgress(history: hist, need: need)
        return MatchMath.nameLockLabel(
            locked: liveNameLock[faceId] != nil,
            leftover: leftoverHold[faceId] != nil,
            progress: progress,
            ttl: liveNameLock[faceId] == nil ? nil : MatchMath.nameLockTTLLabel(
                lastVote: liveNameVoteAt[faceId],
                now: liveLastStamp
            )
        )
    }

    /// Overlay. Mutiert nicht — SwiftUI-Body darf das lesen.
    func guestName(for id: UUID) -> String {
        MatchMath.unknownStickyName(index: MatchMath.guestIndex(of: id, order: guestOrder))
    }

    func leftoverSparkChip(faceId: UUID, yawAbs: Double? = nil) -> String? {
        let bin = MatchMath.leftoverHoldBin(yawAbs: yawAbs ?? 0)
        let binTrail = leftoverHoldTrailBins[MatchMath.leftoverHoldKey(id: faceId, bin: bin)] ?? []
        let idTrail = leftoverHoldTrail[faceId] ?? []
        var nowChip = MatchMath.leftoverCosineSparkLabelOf(
            idTrail: idTrail,
            binTrail: binTrail,
            yawAbs: yawAbs
        )
        if nowChip == nil {
            let hash = leftoverLastHash[faceId]
            let hashTrail = hash.map {
                MatchMath.leftoverTrailLookup(
                    hash: $0,
                    table: leftoverHoldTrailByHash,
                    now: liveLastStamp,
                    ttl: MatchMath.dropoutTTL(dt: liveDt),
                    bin: bin
                )
            } ?? []
            nowChip = MatchMath.leftoverCosineSparkLabel(
                MatchMath.leftoverSparkTrailOf(
                    uuidTrail: idTrail,
                    hashTrail: hashTrail,
                    yawAbs: yawAbs
                )
            )
        }
        let prev = leftoverSparkChipHeld[faceId]
        let held = MatchMath.leftoverSparkChipHold(prev: prev?.chip, now: nowChip, hold: prev?.hold ?? 0)
        if let chip = held.chip {
            leftoverSparkChipHeld[faceId] = (chip: chip, hold: held.hold)
        } else {
            leftoverSparkChipHeld.removeValue(forKey: faceId)
        }
        return held.chip
    }

    func leftoverHoldNow(faceId: UUID, yawAbs: Double? = nil) -> Double? {
        MatchMath.leftoverHoldPrevOf(
            frontal: leftoverHold[faceId],
            yawAbs: yawAbs,
            bins: leftoverHoldBins,
            id: faceId
        )
    }

    func leftoverHasHold(faceId: UUID) -> Bool {
        leftoverHold[faceId] != nil || MatchMath.leftoverHoldIds(leftoverHoldBins).contains(faceId)
    }

    func leftoverHoldChip(faceId: UUID, sharpness: Double? = nil, yawAbs: Double? = nil) -> String? {
        let bin = MatchMath.leftoverHoldBin(yawAbs: yawAbs ?? 0)
        let binTrail = leftoverHoldTrailBins[MatchMath.leftoverHoldKey(id: faceId, bin: bin)] ?? []
        return MatchMath.leftoverHoldOverlayChipOf(
            hold: leftoverHoldNow(faceId: faceId, yawAbs: yawAbs),
            trail: leftoverHoldTrail[faceId] ?? [],
            yawAbs: yawAbs,
            sharpness: sharpness,
            compact: true,
            binTrail: binTrail
        )
    }

    func leftoverAdoptProgress(faceId: UUID) -> String? {
        if MatchMath.leftoverWipeMutes(
            until: leftoverWipeUntil[faceId],
            now: liveLastStamp,
            histCount: (liveNameHist[faceId] ?? []).filter { !$0.isEmpty }.count
        ) {
            return leftoverPending[faceId] ?? "STUMM"
        }
        return leftoverPending[faceId]
    }

    func tapLockChip(faceId: UUID) -> String? {
        MatchMath.tapNameLockLabel(
            until: tapNameLockUntil[faceId],
            now: Date().timeIntervalSince1970
        )
    }

    func ghostFaceIds() -> Set<UUID> {
        Set(liveGhosts.map(\.face.id))
    }

    func ghostFaces() -> [FaceObservation] {
        liveGhosts.map(\.face)
    }

    func exposureLockChip(faceId: UUID) -> String? {
        MatchMath.exposureLockLabel(
            until: liveExposureUntil[faceId],
            now: Date().timeIntervalSince1970
        )
    }

    func ghostTTLChip(faceId: UUID) -> String? {
        guard let g = liveGhosts.first(where: { $0.face.id == faceId }) else { return nil }
        return MatchMath.ghostTTLLabel(until: g.until, now: Date().timeIntervalSince1970)
    }

    func tapOverlay(faceId: UUID, mediaId: UUID? = nil) {
        selectedFaceId = faceId
        if let mediaId { selectedMediaId = mediaId }
        let pinned = identities.contains { $0.faceIds.contains(faceId) }
        if MatchMath.tapOverlayLocksName(pinned: pinned) {
            tapNameLockUntil[faceId] = MatchMath.tapNameLockUntil(now: Date().timeIntervalSince1970)
        } else if MatchMath.tapGuestSuggests(pinned: pinned) {
            if tapGuestPending.contains(faceId),
               MatchMath.guestPersistWrites(tapped: true)
            {
                persistGuestTap(faceId)
            } else {
                tapGuestPending.insert(faceId)
                leftoverPending[faceId] = MatchMath.tapGuestNote()
            }
        }
    }

    /// Zweiter Overlay-Tap auf Gast: Taufe persistiert, nicht nur Chip.
    private func persistGuestTap(_ faceId: UUID) {
        guard let face = faces.first(where: { $0.id == faceId }) else { return }
        guard identities.allSatisfy({ !$0.faceIds.contains(faceId) }) else { return }
        let name = guestName(for: faceId)
        identities.append(Identity(id: UUID(), name: name, faceIds: [face.id]))
        stampEnrolled(face.id)
        let lockAt = Date().timeIntervalSince1970
        tapNameLockUntil[faceId] = MatchMath.tapNameLockUntil(now: lockAt)
        leftoverPending.removeValue(forKey: faceId)
        tapGuestPending.remove(faceId)
        persist()
        rematch()
        status = "\(name) getauft"
    }

    func stillProgress(faceId: UUID) -> Double? {
        let t = liveStillFor[faceId] ?? 0
        guard t > 0 else { return nil }
        let p = MatchMath.holdStillProgress(stillFor: t)
        return p < 1 ? p : nil
    }

    func printDriftSpark(faceId: UUID) -> String {
        MatchMath.printDriftSpark(livePrintDrift[faceId] ?? [])
    }

    func freezeAxisLabel(faceId: UUID) -> String? {
        freezeAxis[faceId]
    }

    func swapFlashing(now: TimeInterval = Date().timeIntervalSince1970) -> Bool {
        now < swapFlashUntil
    }

    func headCountFlashing(now: TimeInterval = Date().timeIntervalSince1970) -> Bool {
        now < headCountFlashUntil
    }

    func headCountFlashText() -> String? {
        headCountFlashing() ? lastHeadCountLabel : nil
    }

    func removeIdentity(_ id: UUID) {
        identities.removeAll { $0.id == id }
        persist()
        rematch()
    }

    func renameIdentity(_ id: UUID, to raw: String) {
        let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        guard let idx = identities.firstIndex(where: { $0.id == id }) else { return }
        guard identities[idx].name != name else { return }
        if MatchMath.renameConflict(newName: name, existing: identities.map(\.name), selfName: identities[idx].name) {
            let now = Date().timeIntervalSince1970
            if pendingRenameName != name
                || !MatchMath.renameConfirmSameId(pending: pendingRenameId, target: id)
                || MatchMath.renameConfirmExpired(since: pendingRenameAt, now: now)
            {
                pendingRenameName = name
                pendingRenameId = id
                pendingRenameAt = now
                status = "Name \(name) existiert. Nochmal Return bestätigt den Konflikt."
                return
            }
        }
        pendingRenameName = nil
        pendingRenameId = nil
        pendingRenameAt = nil
        identities[idx].name = name
        let lockAt = Date().timeIntervalSince1970
        tapNameLockUntil[id] = MatchMath.tapNameLockUntil(now: lockAt)
        for fid in identities[idx].faceIds {
            tapNameLockUntil[fid] = MatchMath.tapNameLockUntil(now: lockAt)
        }
        persist()
        status = "\(name) umbenannt"
    }

    func rejectGuess(_ identityId: UUID) {
        guard let face = selectedFace else { return }
        guard let idx = identities.firstIndex(where: { $0.id == identityId }) else { return }
        let v = FaceEngine.embedding(of: face)
        guard v.count >= 32 else {
            status = "Kein Print — Ablehnen braucht Face-Print"
            return
        }
        identities[idx].rejectedVecs.append(v)
        if identities[idx].rejectedVecs.count > 8 {
            identities[idx].rejectedVecs.removeFirst(identities[idx].rejectedVecs.count - 8)
        }
        persist()
        rematch()
        status = "Nicht \(identities[idx].name) — Hard-Negativ gespeichert"
    }

    func clearReject(_ identityId: UUID) {
        guard let idx = identities.firstIndex(where: { $0.id == identityId }) else { return }
        identities[idx].rejectedVecs.removeAll()
        persist()
        rematch()
        status = "Doch \(identities[idx].name) — Hard-Negativ gelöscht"
    }

    func startLiveFromField() {
        let raw = liveURLText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let parsed = sniffLiveKind(raw) else {
            status = "Keine gültige Kamera-Adresse"
            return
        }
        startLive(url: parsed.1, kind: parsed.0, name: parsed.1.host ?? "Kamera")
    }

    func startWebcam() {
        startLive(url: URL(string: "webcam://local")!, kind: .webcam, name: "Webcam")
    }

    func stopLive() {
        livePending = nil
        liveRoiTick = 0
        liveRoiSkipOnce = false
        maskHoldSince.removeAll()
        lastUSlotHint = 0
        boxJumpPending.removeAll()
        liveNameHist = [:]
        liveNameLock = [:]
        liveScoreEma = [:]
        liveYaw = [:]
        livePitch = [:]
        liveRoll = [:]
        liveLastStamp = 0
        liveDt = 0.125
        liveDtSamples = []
        liveNameVoteAt = [:]
        tapNameLockUntil = [:]
        liveFaceStreak = 0
        livePoseAt.removeAll()
        freezeAxis = [:]
        swapFlashUntil = 0
        headCountFlashUntil = 0
        lastLiveHeadCount = 0
        lastHeadCountLabel = nil
        livePrintTrail.removeAll()
        livePrintTrailSlot.removeAll()
        liveStillFor.removeAll()
        liveCaptureHist.removeAll()
        leftoverStreak = [:]
        leftoverStreakBox = [:]
        leftoverStreakSince = [:]
        leftoverPairLast = [:]
        leftoverPairStreak = [:]
        leftoverPairCommit = [:]
        leftoverPending = [:]
        tapGuestPending = []
        leftoverHold = [:]
        leftoverHoldBins = [:]
        leftoverHoldByHash = [:]
        leftoverHoldTrailByHash = [:]
        leftoverLastHash = [:]
        leftoverSparkChipHeld = [:]
        leftoverHoldTrailBins = [:]
        leftoverEmptySince = nil
        leftoverWipeUntil = [:]
        liveSlotHold = [:]
        guestOrder = []
        guestSeenAt = [:]
        liveCapture.stop()
        liveActive = false
        if let id = liveMediaId {
            let gone = Set(faces.filter { $0.mediaId == id }.map(\.id))
            faces.removeAll { $0.mediaId == id }
            media.removeAll { $0.id == id }
            if !gone.isEmpty {
                for i in identities.indices {
                    identities[i].faceIds.removeAll { gone.contains($0) }
                }
                persist()
            }
            liveMediaId = nil
            selectedMediaId = media.first?.id
            rematch()
        }
        status = "Live beendet"
    }

    private func startLive(url: URL, kind: LiveKind, name: String) {
        if let id = liveMediaId {
            reconnectGhosts = faces.filter { $0.mediaId == id }
        }
        stopLive()
        let id = UUID()
        liveMediaId = id
        media.append(
            MediaItem(
                id: id,
                url: url,
                name: name,
                kind: .live,
                width: 1280,
                height: 720
            )
        )
        selectedMediaId = id
        liveActive = true
        status = "Live · verbindet"
        liveCapture.onReady = { [weak self] in
            guard let self else { return }
            self.status = "Live"
            let uid = self.liveCapture.cameraUniqueID
            if !self.lastCameraUniqueID.isEmpty, uid != self.lastCameraUniqueID {
                self.boxEuro.removeAll()
                self.boxKalman.removeAll()
                self.boxKalmanV.removeAll()
                self.boxJumpPending.removeAll()
                self.livePrintTrail.removeAll()
                self.livePrintTrailSlot.removeAll()
                self.leftoverEmptySince = nil
                self.liveRoiTick = 0
                self.liveRoiSkipOnce = false
            }
            self.lastCameraUniqueID = uid
            self.cameraUniqueID = uid
            self.cameraOrient = self.liveCapture.orientOverride
        }
        liveCapture.onError = { [weak self] msg in
            self?.status = msg
            self?.liveActive = false
        }
        liveCapture.onFrame = { [weak self] image, stamp in
            self?.ingestLiveFrame(image, mediaId: id, stamp: stamp)
        }
        liveCapture.choice = cameraChoice
        liveCapture.start(url: url, kind: kind)
    }

    private func ingestLiveFrame(_ image: CGImage, mediaId: UUID, stamp: TimeInterval) {
        if liveBusy {
            livePending = (image, mediaId, stamp)
            return
        }
        liveBusy = true
        runLiveDetect(image, mediaId: mediaId, stamp: stamp)
    }

    private func runLiveDetect(_ image: CGImage, mediaId: UUID, stamp: TimeInterval) {
        let cont = liveCapture.isContinuity
        let dt = liveDt
        let vis = lastLiveVisMs
        let kalmanSnap: [(x: Double, y: Double, w: Double, h: Double)] = boxKalman.map { (_, v) in
            (x: v.x, y: v.y, w: v.w, h: v.h)
        }
        let roiTuple = MatchMath.liveRoiBox(
            kalman: kalmanSnap,
            imageW: Double(image.width),
            imageH: Double(image.height)
        )
        let skipRoi = liveRoiSkipOnce || MatchMath.liveRoiPeriodicFull(tick: liveRoiTick)
        liveRoiTick += 1
        liveRoiSkipOnce = false
        Task.detached(priority: .userInitiated) {
            let skipPrints = MatchMath.printBudgetSkip(visionMs: vis, dt: dt)
            let t0 = CFAbsoluteTimeGetCurrent()
            var roi = skipRoi ? nil : roiTuple.map { FaceBox(x: $0.x, y: $0.y, width: $0.w, height: $0.h) }
            var found = (try? FaceEngine.detect(in: image, mediaId: mediaId, tiles: false, continuity: cont, cheapGraph: true, live: true, skipPrints: skipPrints, roi: roi)) ?? []
            if found.isEmpty, roi != nil, MatchMath.liveRoiMissRetries(hadROI: true, empty: true) {
                if MatchMath.liveRoiMissGoesFull(dt: dt) {
                    roi = nil
                    found = (try? FaceEngine.detect(in: image, mediaId: mediaId, tiles: false, continuity: cont, cheapGraph: true, live: true, skipPrints: skipPrints, roi: nil)) ?? []
                } else if let raw = roiTuple {
                    let exp = MatchMath.liveRoiExpand(raw, imageW: Double(image.width), imageH: Double(image.height))
                    found = (try? FaceEngine.detect(
                        in: image, mediaId: mediaId, tiles: false, continuity: cont, cheapGraph: true, live: true,
                        skipPrints: skipPrints,
                        roi: FaceBox(x: exp.x, y: exp.y, width: exp.w, height: exp.h)
                    )) ?? []
                    if found.isEmpty {
                        found = (try? FaceEngine.detect(in: image, mediaId: mediaId, tiles: false, continuity: cont, cheapGraph: true, live: true, skipPrints: skipPrints, roi: nil)) ?? []
                    }
                }
            }
            let visMs = (CFAbsoluteTimeGetCurrent() - t0) * 1000
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.lastLiveVisMs = visMs
                self.liveFormatChip = self.liveCapture.formatChip
                if !self.liveActive || self.liveMediaId != mediaId {
                    self.liveBusy = false
                    self.livePending = nil
                    return
                }
                if MatchMath.liveRoiSkipsForStranger(foundCount: found.count, kalmanCount: kalmanSnap.count) {
                    self.liveRoiSkipOnce = true
                }
                self.applyLiveFaces(found, image: image, mediaId: mediaId, stamp: stamp)
                if let pending = self.livePending {
                    self.livePending = nil
                    self.runLiveDetect(pending.image, mediaId: pending.mediaId, stamp: pending.stamp)
                } else {
                    self.liveBusy = false
                }
            }
        }
    }

    private func pinByPrint(
        _ face: FaceObservation,
        pool: [FaceObservation],
        used: Set<UUID>
    ) -> FaceObservation? {
        let v = FaceEngine.embedding(of: face)
        guard v.count >= 32 else { return nil }
        var best: FaceObservation?
        var bestC = MatchMath.pinPrintCosine
        var seen = Set<UUID>()
        for old in pool where !used.contains(old.id) && !seen.contains(old.id) {
            seen.insert(old.id)
            let ov = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
            guard ov.count == v.count else { continue }
            let c = MatchMath.cosine(v, ov)
            if MatchMath.pinByPrint(cosine: c), c > bestC {
                bestC = c
                best = old
            }
        }
        return best
    }

    private func leftoverAdvance(
        oldId: UUID,
        box: FaceBox,
        now: TimeInterval,
        holdPrev: Double? = nil,
        boxId: UUID? = nil,
        dt: TimeInterval = 0.016
    ) -> (ready: Bool, label: String?) {
        let hashed = MatchMath.leftoverStreakBoxWrite(
            kalmanX: boxKalman[boxId ?? oldId]?.x,
            kalmanY: boxKalman[boxId ?? oldId]?.y,
            kalmanW: boxKalman[boxId ?? oldId]?.w,
            kalmanH: boxKalman[boxId ?? oldId]?.h,
            fallback: box
        )
        let same: Bool
        if let prev = leftoverStreakBox[oldId] {
            same = MatchMath.leftoverSameTarget(iou: FaceEngine.iou(prev, hashed))
        } else {
            same = false
        }
        if same {
            leftoverStreakSince[oldId] = MatchMath.leftoverStreakSincePersist(
                since: leftoverStreakSince[oldId],
                now: now
            )
        } else {
            leftoverStreakSince[oldId] = now
        }
        let next = MatchMath.leftoverStreakAdvance(prev: leftoverStreak[oldId] ?? 0, sameTarget: same)
        leftoverStreak[oldId] = next
        leftoverStreakBox[oldId] = hashed
        let elapsed = now - (leftoverStreakSince[oldId] ?? now)
        let needSec = MatchMath.leftoverAdoptNeedSec(dt: dt)
        return (
            MatchMath.leftoverAdoptReady(elapsed: elapsed, streak: next, needSec: needSec, holdPrev: holdPrev),
            MatchMath.leftoverStreakLabel(elapsed: elapsed, needSec: needSec)
        )
    }

    private func leftoverClearStreak(_ id: UUID) {
        leftoverStreak.removeValue(forKey: id)
        leftoverStreakBox.removeValue(forKey: id)
        leftoverStreakSince.removeValue(forKey: id)
        leftoverMissFrames.removeValue(forKey: id)
        leftoverWipeUntil.removeValue(forKey: id)
        leftoverPairLast.removeValue(forKey: id)
        leftoverPairStreak.removeValue(forKey: id)
        leftoverPairCommit.removeValue(forKey: id)
        leftoverDisagree.removeValue(forKey: id)
    }

    private func leftoverMirrorPending(from: UUID, to: UUID) {
        leftoverPending = MatchMath.leftoverPendingMirror(pending: leftoverPending, from: from, to: to)
    }

    private func leftoverBlendAdopted(_ face: inout FaceObservation, oldId: UUID) {
        guard MatchMath.leftoverAdoptKeepsKalman() else { return }
        let k = boxKalman[oldId]
        let live = (x: face.box.x, y: face.box.y, w: face.box.width, h: face.box.height)
        let kal = k.map { (x: $0.x, y: $0.y, w: $0.w, h: $0.h) }
        let b = MatchMath.leftoverAdoptBlend(live: live, kalman: kal)
        face.box = FaceBox(x: b.x, y: b.y, width: b.w, height: b.h)
    }

    private func leftoverLiveHash(
        kalmanX: Double?,
        kalmanY: Double?,
        kalmanW: Double?,
        kalmanH: Double?,
        fallback: FaceBox,
        image: CGImage
    ) -> String {
        MatchMath.leftoverHoldWriteHash(
            kalmanX: kalmanX, kalmanY: kalmanY, kalmanW: kalmanW, kalmanH: kalmanH,
            fallback: fallback,
            imageW: Double(image.width),
            imageH: Double(image.height)
        )
    }

    private func leftoverPredictHeld(keep: Set<UUID>, skip: Set<UUID>) {
        for id in keep where !skip.contains(id) {
            guard let k = boxKalman[id] else { continue }
            let v = boxKalmanV[id] ?? (vx: 0, vy: 0)
            let nx = MatchMath.boxKalmanPredict(x: k.x, v: v.vx, dt: liveDt)
            let ny = MatchMath.boxKalmanPredict(x: k.y, v: v.vy, dt: liveDt)
            let locked = MatchMath.leftoverGhostAspectLock(predX: nx, predY: ny, lastW: k.w, lastH: k.h)
            boxKalman[id] = (locked.x, locked.y, locked.w, locked.h, k.px, k.py, k.pw, k.ph)
            if let i = liveGhosts.firstIndex(where: { $0.face.id == id }) {
                var g = liveGhosts[i]
                g.face.box = FaceBox(x: locked.x, y: locked.y, width: locked.w, height: locked.h)
                liveGhosts[i] = g
            }
        }
    }

    private func leftoverDropKalmanTwins(_ found: [FaceObservation]) -> [FaceObservation] {
        let pred = boxKalman.mapValues { FaceBox(x: $0.x, y: $0.y, width: $0.w, height: $0.h) }
        guard !pred.isEmpty, found.count >= 2 else { return found }
        var best: [UUID: Double] = [:]
        for face in found {
            for (id, box) in pred {
                let o = FaceEngine.iou(face.box, box)
                best[id] = max(best[id] ?? 0, o)
            }
        }
        return found.filter { face in
            for (id, box) in pred {
                let o = FaceEngine.iou(face.box, box)
                if MatchMath.kalmanNmsDrops(iou: o, bestIou: best[id] ?? 0) { return false }
            }
            return true
        }
    }

    private func boxKalmanDrop(_ id: UUID) {
        boxKalman.removeValue(forKey: id)
        boxKalmanV.removeValue(forKey: id)
    }

    private func applyLiveFaces(_ incoming: [FaceObservation], image: CGImage, mediaId: UUID, stamp: TimeInterval) {
        let latch = MatchMath.liveFacesLatch(
            present: !incoming.isEmpty,
            on: liveCapture.facesPresent,
            streak: liveFaceStreak
        )
        liveFaceStreak = latch.streak
        liveCapture.setFacesPresent(latch.on)
        guard let idx = media.firstIndex(where: { $0.id == mediaId }) else { return }
        media[idx].width = image.width
        media[idx].height = image.height
        media[idx].preview = image
        let now = stamp > 0 ? stamp : Date().timeIntervalSince1970
        let found = leftoverDropKalmanTwins(incoming)
        if liveLastStamp > 0, now > liveLastStamp {
            let raw = now - liveLastStamp
            if raw > 0.02, raw < 0.40 {
                liveDtSamples.append(raw)
                if liveDtSamples.count > 8 { liveDtSamples.removeFirst(liveDtSamples.count - 8) }
            }
            liveDt = MatchMath.medianLiveDt(liveDtSamples, fallback: liveDt)
        }
        liveLastStamp = now
        let liveFrameCapture = MatchMath.leftoverFrameCapture(image)
        let enrolled = Set(identities.flatMap(\.faceIds))
        let previous = faces.filter { $0.mediaId == mediaId }
        var foundIouMax = 0.0
        if !found.isEmpty, !previous.isEmpty {
            for face in found {
                for old in previous {
                    foundIouMax = max(foundIouMax, FaceEngine.iou(old.box, face.box))
                }
            }
        }
        let emptyLike = found.isEmpty
            || (!previous.isEmpty && MatchMath.leftoverEmptyIgnoresStranger(foundIouMax: foundIouMax))
        let namedTracks = Set(previous.compactMap { old -> UUID? in
            let hit = matches.first { $0.faceId == old.id }?.hits.first { $0.strategy == .aegis }
            return hit?.identityId != nil ? old.id : nil
        })
        var used = Set<UUID>()
        var leftoverTried = Set<UUID>()
        if emptyLike {
            if leftoverEmptySince == nil { leftoverEmptySince = now }
        } else {
            leftoverEmptySince = nil
        }
        let emptyFor = leftoverEmptySince.map { now - $0 } ?? 0
        let emptyLatch = emptyLike && MatchMath.leftoverLatchKeeps(emptyFor: emptyFor)
        let emptyChip = emptyLike && MatchMath.leftoverLatchChipKeeps(emptyFor: emptyFor)
        if !emptyChip {
            leftoverPending = [:]
        }
        var adopted: [FaceObservation] = []
        adopted.reserveCapacity(found.count)
        for var face in found {
            let probeVec = FaceEngine.embedding(of: face)
            var best: FaceObservation?
            var bestIoU = 0.0
            var bestEnrolled = false
            for old in previous where !used.contains(old.id) {
                let o = FaceEngine.iou(old.box, face.box)
                let pin = namedTracks.contains(old.id) || enrolled.contains(old.id)
                guard MatchMath.trackPin(iou: o, enrolled: pin) else { continue }
                let ov = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
                let cosine: Double? = {
                    if probeVec.count >= 32, ov.count == probeVec.count { return MatchMath.cosine(probeVec, ov) }
                    return nil
                }()
                if pin, MatchMath.iouPrintBlocks(cosine: cosine) {
                    boxEuro.removeValue(forKey: old.id)
                    boxJumpPending.removeValue(forKey: old.id)
                    continue
                }
                if pin && !bestEnrolled {
                    best = old
                    bestIoU = o
                    bestEnrolled = true
                } else if pin == bestEnrolled, o > bestIoU {
                    best = old
                    bestIoU = o
                }
            }
            let printPin = pinByPrint(face, pool: previous + reconnectGhosts + liveGhosts.map(\.face), used: used)
            let printEnrolled = printPin.map { enrolled.contains($0.id) || namedTracks.contains($0.id) } ?? false
            var takePrint = MatchMath.boxPinTakePrint(
                iouHold: best.map { _ in MatchMath.boxHysteresisHold(iou: bestIoU) } ?? false,
                printPinDifferent: printPin.map { $0.id != best?.id } ?? false,
                printEnrolled: printEnrolled
            )
            let pinGhost = printPin.map { pin in
                reconnectGhosts.contains { $0.id == pin.id }
                    || liveGhosts.contains { $0.face.id == pin.id }
            } ?? false
            let dropPrint = MatchMath.reconnectPrefersPrint(gap: liveDt, fromGhost: pinGhost)
            if let pin = printPin, dropPrint {
                let pinVec = pin.printVec.count >= 32 ? pin.printVec : FaceEngine.embedding(of: pin)
                let pinCos: Double? = {
                    if probeVec.count >= 32, pinVec.count == probeVec.count { return MatchMath.cosine(probeVec, pinVec) }
                    return nil
                }()
                if !MatchMath.reconnectGhostNeedsBaptize(fromGhost: pinGhost, cosine: pinCos) {
                    takePrint = true
                }
            }
            // Dropout / Ghost: IoU tot — auch ohne Print keine Box-Taufe.
            if let old = best, !takePrint, !dropPrint {
                used.insert(old.id)
                face.id = old.id
                face.trackId = old.trackId ?? old.id
                face.enrolledAt = old.enrolledAt ?? face.enrolledAt
                if MatchMath.boxHysteresisHold(iou: bestIoU) {
                    if MatchMath.boxEuroResetOnHysteresis(iou: bestIoU, cosine: {
                        if probeVec.count >= 32 {
                            let ov = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
                            if ov.count == probeVec.count { return MatchMath.cosine(probeVec, ov) }
                        }
                        return nil
                    }()) {
                        boxEuro.removeValue(forKey: old.id)
                        boxJumpPending.removeValue(forKey: old.id)
                    } else if let pending = boxJumpPending[old.id],
                       MatchMath.boxHysteresisConfirm(iouToPending: FaceEngine.iou(pending, face.box))
                    {
                        boxJumpPending.removeValue(forKey: old.id)
                        boxEuro.removeValue(forKey: old.id)
                    } else {
                        boxJumpPending[old.id] = face.box
                        face.box = old.box
                        if face.featurePrint.isEmpty, !old.featurePrint.isEmpty {
                            face.featurePrint = old.featurePrint
                            face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                        }
                        var spark = old.qualitySpark
                        spark.append(face.quality)
                        if spark.count > 8 { spark.removeFirst(spark.count - 8) }
                        face.qualitySpark = spark
                        adopted.append(face)
                        continue
                    }
                } else {
                    boxJumpPending.removeValue(forKey: old.id)
                }
                let t = now
                let area = face.box.width * face.box.height
                if MatchMath.boxKalmanUses(dt: liveDt) {
                    let prev = boxKalman[old.id]
                    let px0 = prev?.x ?? face.box.x
                    let py0 = prev?.y ?? face.box.y
                    let pw0 = prev?.w ?? face.box.width
                    let ph0 = prev?.h ?? face.box.height
                    let jump = MatchMath.captureJumps(prev: old.quality.capture, next: face.quality.capture)
                    let q = MatchMath.boxKalmanQ(captureJump: jump)
                    let x = MatchMath.boxKalman(prev: px0, meas: face.box.x, p: prev?.px ?? 0.04, dt: liveDt, q: q)
                    let y = MatchMath.boxKalman(prev: py0, meas: face.box.y, p: prev?.py ?? 0.04, dt: liveDt, q: q)
                    let w = MatchMath.boxKalman(prev: pw0, meas: face.box.width, p: prev?.pw ?? 0.04, dt: liveDt, q: q)
                    let h = MatchMath.boxKalman(prev: ph0, meas: face.box.height, p: prev?.ph ?? 0.04, dt: liveDt, q: q)
                    face.box = FaceBox(x: x.x, y: y.x, width: w.x, height: h.x)
                    boxKalman[old.id] = (x.x, y.x, w.x, h.x, x.p, y.p, w.p, h.p)
                    let prevV = boxKalmanV[old.id]
                    boxKalmanV[old.id] = (
                        vx: MatchMath.boxKalmanVelocity(prev: px0, next: x.x, dt: liveDt, prevV: prevV?.vx ?? 0),
                        vy: MatchMath.boxKalmanVelocity(prev: py0, next: y.x, dt: liveDt, prevV: prevV?.vy ?? 0)
                    )
                } else {
                    var euro = boxEuro[old.id] ?? (
                        MatchMath.OneEuro(), MatchMath.OneEuro(), MatchMath.OneEuro(), MatchMath.OneEuro()
                    )
                    face.box = FaceBox(
                        x: euro.x.filter(face.box.x, now: t, boxArea: area),
                        y: euro.y.filter(face.box.y, now: t, boxArea: area),
                        width: euro.w.filter(face.box.width, now: t, boxArea: area),
                        height: euro.h.filter(face.box.height, now: t, boxArea: area)
                    )
                    boxEuro[old.id] = euro
                }
                let blend = MatchMath.liveBlendAlpha(continuity: liveCapture.isContinuity)
                if face.featurePrint.isEmpty, !old.featurePrint.isEmpty {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec
                } else if !old.featurePrint.isEmpty, face.quality.capture + 0.04 < old.quality.capture {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                } else if !old.featurePrint.isEmpty, !face.featurePrint.isEmpty {
                    if !old.landmarks.isEmpty, !face.landmarks.isEmpty {
                        let j = MatchMath.landmarkJitter(
                            prev: liveLandmarkPrev[old.id] ?? old.landmarks,
                            next: face.landmarks
                        )
                        let acc = MatchMath.posterJitterAccum(prev: livePosterJitter[old.id] ?? j, next: j)
                        livePosterJitter[old.id] = acc
                        livePosterStill[old.id] = MatchMath.posterStillAdvance(
                            jitter: acc,
                            streak: livePosterStill[old.id] ?? 0
                        )
                        liveLandmarkPrev[old.id] = face.landmarks
                    }
                    let closedNow = MatchMath.eyesClosed(
                        openIod: face.ratioSheet.first { $0.id == "eyeOpen_iod" }?.value
                    )
                    if MatchMath.livenessBlink(
                        prevClosed: liveLidClosed[old.id] ?? false,
                        nowClosed: closedNow
                    ) {
                        liveBlinkSeen[old.id] = true
                    }
                    liveLidClosed[old.id] = closedNow
                    if MatchMath.captureJumps(prev: old.quality.capture, next: face.quality.capture) {
                        liveExposureUntil[old.id] = MatchMath.exposureLockUntil(
                            now: now,
                            hold: MatchMath.exposureLockHold(dt: liveDt, reconnect: pinGhost)
                        )
                    }
                    let aeLock = MatchMath.exposureLocks(now: now, until: liveExposureUntil[old.id] ?? 0)
                    let enrolledPin = enrolled.contains(old.id) || namedTracks.contains(old.id)
                    var capHist = liveCaptureHist[old.id] ?? [old.quality.capture]
                    let burst = MatchMath.captureBurstBlocksPrint(
                        history: capHist,
                        next: face.quality.capture,
                        enrolled: enrolledPin
                    )
                    capHist.append(face.quality.capture)
                    if capHist.count > MatchMath.captureBurstFrames {
                        capHist.removeFirst(capHist.count - MatchMath.captureBurstFrames)
                    }
                    liveCaptureHist[old.id] = capHist
                    let skip = aeLock
                        || burst
                        || MatchMath.captureJumpBlocksPrint(
                            prev: old.quality.capture,
                            next: face.quality.capture,
                            enrolled: enrolledPin
                        )
                        || MatchMath.holdStillSkip(iou: bestIoU, sharpness: face.quality.sharpness)
                        || MatchMath.skipPrint(sharpness: face.quality.sharpness, continuity: liveCapture.isContinuity)
                        || MatchMath.motionBlurDrops(
                            aligned: MatchMath.cropAligns(roll: face.quality.roll),
                            sharpness: face.quality.sharpness
                        )
                    if skip {
                        liveStillFor[old.id] = 0
                    } else {
                        liveStillFor[old.id] = (liveStillFor[old.id] ?? 0) + liveDt
                    }
                    if skip || !MatchMath.holdStillReady(stillFor: liveStillFor[old.id] ?? 0) {
                        face.featurePrint = old.featurePrint
                        face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                    } else {
                    let prev = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
                    let next = FaceEngine.embedding(of: face)
                    let nextSlot = FaceEngine.poseSlot(face).rawValue
                    var trail = livePrintTrail[old.id] ?? []
                    if !MatchMath.printTrailAccepts(prevSlot: livePrintTrailSlot[old.id], nextSlot: nextSlot) {
                        trail = []
                    }
                    livePrintTrailSlot[old.id] = nextSlot
                    if prev.count >= 32 { trail.append(prev) }
                    if next.count >= 32, MatchMath.leftoverTrailWriteOk(sharpness: face.quality.sharpness) {
                        trail.append(next)
                    }
                    if trail.count > 5 { trail.removeFirst(trail.count - 5) }
                    livePrintTrail[old.id] = trail
                    let median = MatchMath.medianBlend(trail)
                    face.printVec = median.isEmpty ? FaceEngine.blendEmbeddings(prev, next, alpha: blend) : median
                    }
                } else if face.printVec.isEmpty {
                    face.printVec = FaceEngine.embedding(of: face)
                }
                var spark = old.qualitySpark
                spark.append(face.quality)
                if spark.count > 8 { spark.removeFirst(spark.count - 8) }
                face.qualitySpark = spark
            } else if let old = printPin {
                used.insert(old.id)
                face.id = old.id
                face.trackId = old.trackId ?? old.id
                face.enrolledAt = old.enrolledAt ?? face.enrolledAt
                leftoverBlendAdopted(&face, oldId: old.id)
                liveExposureUntil[old.id] = MatchMath.exposureLockUntil(
                    now: now,
                    hold: MatchMath.exposureLockHold(dt: liveDt, reconnect: pinGhost)
                )
                // Ghost-Box darf nicht kleben: 1-Euro und Ampel der UUID verwerfen.
                boxEuro.removeValue(forKey: old.id)
                boxJumpPending.removeValue(forKey: old.id)
                if !MatchMath.printTrailKeepsOnGhostAdopt() {
                    livePrintTrail.removeValue(forKey: old.id)
                    livePrintTrailSlot.removeValue(forKey: old.id)
                }
                face.qualitySpark = []
                let blend = MatchMath.liveBlendAlpha(continuity: liveCapture.isContinuity)
                let enrolledPin = enrolled.contains(old.id) || namedTracks.contains(old.id)
                var hist = liveCaptureHist[old.id] ?? [old.quality.capture]
                let jump = MatchMath.captureBurstBlocksPrint(
                    history: hist,
                    next: face.quality.capture,
                    enrolled: enrolledPin
                ) || MatchMath.captureJumpBlocksPrint(
                    prev: old.quality.capture,
                    next: face.quality.capture,
                    enrolled: enrolledPin
                )
                hist.append(face.quality.capture)
                if hist.count > MatchMath.captureBurstFrames { hist.removeFirst(hist.count - MatchMath.captureBurstFrames) }
                liveCaptureHist[old.id] = hist
                let blur = MatchMath.skipPrint(
                    sharpness: face.quality.sharpness,
                    continuity: liveCapture.isContinuity
                )
                if jump || blur || face.featurePrint.isEmpty, !old.featurePrint.isEmpty {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                } else if face.featurePrint.isEmpty, !old.featurePrint.isEmpty {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                } else if !old.printVec.isEmpty, !face.featurePrint.isEmpty {
                    face.printVec = FaceEngine.blendEmbeddings(old.printVec, FaceEngine.embedding(of: face), alpha: blend)
                }
            }
            adopted.append(face)
        }
        if adopted.count >= 2 {
            var swapped = Set<UUID>()
            func vec(_ face: FaceObservation) -> [Double] {
                face.printVec.count >= 32 ? face.printVec : FaceEngine.embedding(of: face)
            }
            for (i, j) in MatchMath.pairSwapIndices(count: adopted.count) {
                let a = adopted[i]
                let b = adopted[j]
                guard !swapped.contains(a.id), !swapped.contains(b.id) else { continue }
                guard let oldA = previous.first(where: { $0.id == a.id }),
                      let oldB = previous.first(where: { $0.id == b.id }),
                      oldA.id != oldB.id
                else { continue }
                let va = vec(a)
                let vb = vec(b)
                let oa = vec(oldA)
                let ob = vec(oldB)
                if MatchMath.identitiesCrossed(
                    keepA: MatchMath.cosine(va, oa),
                    keepB: MatchMath.cosine(vb, ob),
                    crossAB: MatchMath.cosine(va, ob),
                    crossBA: MatchMath.cosine(vb, oa)
                ) {
                    adopted[i].id = oldB.id
                    adopted[i].trackId = oldB.trackId ?? oldB.id
                    adopted[i].enrolledAt = oldB.enrolledAt ?? adopted[i].enrolledAt
                    leftoverMirrorPending(from: a.id, to: oldB.id)
                    adopted[j].id = oldA.id
                    adopted[j].trackId = oldA.trackId ?? oldA.id
                    adopted[j].enrolledAt = oldA.enrolledAt ?? adopted[j].enrolledAt
                    leftoverMirrorPending(from: b.id, to: oldA.id)
                    swapped.insert(oldA.id)
                    swapped.insert(oldB.id)
                    swapFlashUntil = now + MatchMath.swapFlashHold()
                    for id in [oldA.id, oldB.id] {
                        boxEuro.removeValue(forKey: id)
                        boxJumpPending.removeValue(forKey: id)
                        livePrintTrail.removeValue(forKey: id)
                        livePrintTrailSlot.removeValue(forKey: id)
                        liveNameHist.removeValue(forKey: id)
                        liveNameLock.removeValue(forKey: id)
                        leftoverHold.removeValue(forKey: id)
                        leftoverHoldBins = MatchMath.leftoverHoldBinDrop(bins: leftoverHoldBins, id: id)
                        liveNameVoteAt.removeValue(forKey: id)
                        liveScoreEma.removeValue(forKey: id)
                        liveYaw.removeValue(forKey: id)
                        livePitch.removeValue(forKey: id)
                        liveRoll.removeValue(forKey: id)
                        livePrintDrift.removeValue(forKey: id)
                    }
                }
            }
        }
        if adopted.count >= 2 {
            let unnamedIdx = adopted.indices.filter { i in
                !namedTracks.contains(adopted[i].id) && !enrolled.contains(adopted[i].id)
            }
            let unusedNamed = previous.filter {
                MatchMath.leftoverNamedTrack(hadName: namedTracks.contains($0.id)) && !used.contains($0.id)
            }
            if unnamedIdx.count == 2, unusedNamed.count == 2 {
                let a = unusedNamed[0]
                let b = unusedNamed[1]
                let i0 = unnamedIdx[0]
                let i1 = unnamedIdx[1]
                let n0 = adopted[i0]
                let n1 = adopted[i1]
                let iouAA = FaceEngine.iou(a.box, n0.box)
                let iouBB = FaceEngine.iou(b.box, n1.box)
                let iouAB = FaceEngine.iou(a.box, n1.box)
                let iouBA = FaceEngine.iou(b.box, n0.box)
                if MatchMath.boxesCrossed(iouSameA: iouAA, iouSameB: iouBB, iouCrossAB: iouAB, iouCrossBA: iouBA) {
                    adopted[i1].id = a.id
                    adopted[i1].trackId = a.trackId ?? a.id
                    adopted[i1].enrolledAt = a.enrolledAt ?? adopted[i1].enrolledAt
                    leftoverMirrorPending(from: n1.id, to: a.id)
                    adopted[i0].id = b.id
                    adopted[i0].trackId = b.trackId ?? b.id
                    adopted[i0].enrolledAt = b.enrolledAt ?? adopted[i0].enrolledAt
                    leftoverMirrorPending(from: n0.id, to: b.id)
                    used.insert(a.id)
                    used.insert(b.id)
                    boxEuro.removeValue(forKey: a.id)
                    boxEuro.removeValue(forKey: b.id)
                    boxJumpPending.removeValue(forKey: a.id)
                    boxJumpPending.removeValue(forKey: b.id)
                }
            }
            let unnamedLeft = unnamedIdx.filter { i in
                !used.contains(adopted[i].id)
            }
            let unusedLeft = unusedNamed.filter { !used.contains($0.id) }
            if unnamedLeft.count >= 2, unusedLeft.count >= 2 {
                var scores: [[Double?]] = []
                scores.reserveCapacity(unusedLeft.count)
                for old in unusedLeft {
                    let ov = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
                    var row: [Double?] = []
                    row.reserveCapacity(unnamedLeft.count)
                    for i in unnamedLeft {
                        let face = adopted[i]
                        let v = face.printVec.count >= 32 ? face.printVec : FaceEngine.embedding(of: face)
                        if v.count >= 32, ov.count == v.count {
                            let c = MatchMath.cosine(v, ov)
                            row.append(MatchMath.leftoverPrintOk(cosine: c, sharpness: face.quality.sharpness) ? c : nil)
                        } else {
                            row.append(nil)
                        }
                    }
                    scores.append(row)
                }
                let assigned = MatchMath.leftoverAssignDropAmbiguous(
                    scores: scores,
                    assigned: MatchMath.leftoverAssign(scores: scores)
                )
                for (r, col) in assigned.enumerated() {
                    guard let col, r < unusedLeft.count, col < unnamedLeft.count else { continue }
                    let old = unusedLeft[r]
                    let i = unnamedLeft[col]
                    guard !used.contains(old.id) else { continue }
                    leftoverTried.insert(old.id)
                    let proposed = adopted[i].id
                    let prevLast = leftoverPairLast[old.id]
                    let maj = MatchMath.leftoverAssignMajority(
                        committed: leftoverPairCommit[old.id],
                        proposed: proposed,
                        lastProposed: leftoverPairLast[old.id],
                        streak: leftoverPairStreak[old.id] ?? 0
                    )
                    leftoverDisagree[old.id] = MatchMath.clusterSplitAdvance(
                        prev: leftoverDisagree[old.id] ?? 0,
                        changed: prevLast != nil && prevLast != proposed && maj.streak == 1
                    )
                    leftoverPairLast[old.id] = maj.last
                    leftoverPairStreak[old.id] = maj.streak
                    if MatchMath.clusterSplit(disagree: leftoverDisagree[old.id] ?? 0) {
                        leftoverPending[adopted[i].id] = MatchMath.clusterSplitNote()
                        continue
                    }
                    if let majLabel = MatchMath.leftoverMajorityLabel(streak: maj.streak) {
                        leftoverPending[adopted[i].id] = majLabel
                    }
                    guard maj.ready else { continue }
                    leftoverPairCommit[old.id] = maj.commit
                    leftoverDisagree[old.id] = 0
                    let step = leftoverAdvance(oldId: old.id, box: adopted[i].box, now: now, boxId: adopted[i].id, dt: liveDt)
                    if let label = step.label {
                        leftoverPending[adopted[i].id] = label
                    }
                    guard step.ready else { continue }
                    leftoverClearStreak(old.id)
                    leftoverPending.removeValue(forKey: adopted[i].id)
                    used.insert(old.id)
                    let newId = adopted[i].id
                    adopted[i].id = old.id
                    leftoverMirrorPending(from: newId, to: old.id)
                    adopted[i].trackId = old.trackId ?? old.id
                    adopted[i].enrolledAt = old.enrolledAt ?? adopted[i].enrolledAt
                    leftoverBlendAdopted(&adopted[i], oldId: old.id)
                    boxEuro.removeValue(forKey: old.id)
                    if !MatchMath.leftoverAdoptKeepsKalman() {
                        boxKalmanDrop(old.id)
                    }
                    boxJumpPending.removeValue(forKey: old.id)
                }
                for old in unusedLeft where !leftoverTried.contains(old.id) {
                    leftoverClearStreak(old.id)
                }
            }
        }
        liveGhosts.removeAll { $0.until < now }
        let dropped = Set(MatchMath.leftoverDropped(previous: previous.map(\.id), used: used))
        for old in previous where dropped.contains(old.id) {
            liveGhosts.removeAll { $0.face.id == old.id }
            liveGhosts.append((old, now + MatchMath.liveGhostHold(dt: liveDt)))
        }
        let ghostIds = liveGhosts.map(\.face.id)
        let liveIds = Array(used)
        let keepBoxes = MatchMath.leftoverKeepBoxes(
            used: used,
            dropped: dropped,
            ghosts: ghostIds,
            hold: emptyLatch ? Array(Set(leftoverHold.keys).union(MatchMath.leftoverHoldIds(leftoverHoldBins))) : []
        )
        boxEuro = boxEuro.filter { keepBoxes.contains($0.key) }
        boxKalman = boxKalman.filter { keepBoxes.contains($0.key) }
        boxKalmanV = boxKalmanV.filter { keepBoxes.contains($0.key) }
        boxJumpPending = boxJumpPending.filter { keepBoxes.contains($0.key) }
        livePrintTrail = livePrintTrail.filter { keepBoxes.contains($0.key) }
        livePrintTrailSlot = livePrintTrailSlot.filter { keepBoxes.contains($0.key) }
        liveStillFor = liveStillFor.filter { keepBoxes.contains($0.key) }
        livePrintDrift = livePrintDrift.filter { keepBoxes.contains($0.key) }
        liveExposureUntil = liveExposureUntil.filter { keepBoxes.contains($0.key) }
        liveCaptureHist = liveCaptureHist.filter { keepBoxes.contains($0.key) }
        livePosterJitter = livePosterJitter.filter { keepBoxes.contains($0.key) }
        livePosterStill = livePosterStill.filter { keepBoxes.contains($0.key) }
        liveLandmarkPrev = liveLandmarkPrev.filter { keepBoxes.contains($0.key) }
        liveLidClosed = liveLidClosed.filter { keepBoxes.contains($0.key) }
        liveBlinkSeen = liveBlinkSeen.filter { keepBoxes.contains($0.key) }
        let holdBefore = leftoverHold.count
        leftoverHold = MatchMath.leftoverHoldSurvive(hold: leftoverHold, ghosts: ghostIds, live: liveIds, emptyKeeps: emptyLatch, emptyFor: emptyFor)
        leftoverHoldBins = MatchMath.leftoverHoldSurviveBins(hold: leftoverHoldBins, ghosts: ghostIds, live: liveIds, emptyKeeps: emptyLatch, emptyFor: emptyFor)
        leftoverHoldTrail = MatchMath.leftoverHoldSurvive(hold: leftoverHoldTrail, ghosts: ghostIds, live: liveIds, emptyKeeps: emptyLatch, emptyFor: emptyFor)
        leftoverHoldTrailBins = MatchMath.leftoverHoldSurviveBinMap(hold: leftoverHoldTrailBins, ghosts: ghostIds, live: liveIds, emptyKeeps: emptyLatch, emptyFor: emptyFor)
        liveSlotHold = MatchMath.leftoverHoldSurvive(hold: liveSlotHold, ghosts: ghostIds, live: liveIds, emptyKeeps: emptyLatch, emptyFor: emptyFor)
        leftoverMissFrames = MatchMath.leftoverHoldSurvive(hold: leftoverMissFrames, ghosts: ghostIds, live: liveIds, emptyKeeps: emptyLatch, emptyFor: emptyFor)
        leftoverHoldByHash = MatchMath.leftoverHoldPrune(leftoverHoldByHash, now: now, ttl: MatchMath.dropoutTTL(dt: liveDt))
        leftoverHoldTrailByHash = MatchMath.leftoverTrailPrune(leftoverHoldTrailByHash, now: now, ttl: MatchMath.dropoutTTL(dt: liveDt))
        if let line = MatchMath.leftoverHoldPruneLine(
            before: holdBefore,
            after: leftoverHold.count,
            liveEmpty: liveIds.isEmpty
        ) {
            status = line
        }
        if MatchMath.leftoverPredictOnEmptyLike(emptyLike), emptyLatch {
            leftoverPredictHeld(keep: keepBoxes, skip: used)
        }
        if found.isEmpty {
            if !MatchMath.leftoverEmptyKeepsOverlay(liveEmpty: true) || !emptyChip {
                liveHeldIds = []
                leftoverPending = [:]
            }
            if !MatchMath.leftoverEmptyKeepsStreak(liveEmpty: true) || !emptyLatch {
                leftoverStreak = [:]
                leftoverStreakBox = [:]
                leftoverStreakSince = [:]
                leftoverMissFrames = [:]
                leftoverPairLast = [:]
                leftoverPairStreak = [:]
                leftoverPairCommit = [:]
                leftoverDisagree = [:]
                leftoverWipeUntil = [:]
                boxKalman = [:]
                boxKalmanV = [:]
                liveStillFor = [:]
            }
            guestOrder = guestOrder.filter {
                MatchMath.guestOrderKeeps(id: $0, live: [], lastSeen: guestSeenAt[$0], now: now)
            }
            guestSeenAt = guestSeenAt.filter { guestOrder.contains($0.key) }
            liveExposureUntil = [:]
            livePosterJitter = [:]
            livePosterStill = [:]
            liveLandmarkPrev = [:]
            liveLidClosed = [:]
            liveBlinkSeen = [:]
            faces.removeAll { $0.mediaId == mediaId }
            if !MatchMath.leftoverEmptyKeepsOverlay(liveEmpty: true) || !emptyChip {
                if let label = MatchMath.headCountFlashLabel(prev: lastLiveHeadCount, next: 0) {
                    lastHeadCountLabel = label
                    headCountFlashUntil = now + MatchMath.headCountFlashHold
                }
                lastLiveHeadCount = 0
            }
        } else {
            let ghostFaces = liveGhosts.map(\.face).filter { $0.mediaId == mediaId }
            let leftoverPool: [FaceObservation] = {
                var seen = Set<UUID>()
                var out: [FaceObservation] = []
                for f in previous + ghostFaces where seen.insert(f.id).inserted {
                    out.append(f)
                }
                return out
            }()
            let leftoverNamed = Set(leftoverPool.compactMap { old -> UUID? in
                if namedTracks.contains(old.id) { return old.id }
                let hit = matches.first { $0.faceId == old.id }?.hits.first { $0.strategy == .aegis }
                return hit?.identityId != nil ? old.id : nil
            })
            let leftoverPinned = leftoverPool.filter {
                MatchMath.leftoverNamedTrack(hadName: leftoverNamed.contains($0.id)) && !used.contains($0.id)
            }
            var leftoverItems: [(old: FaceObservation, bestCos: Double?, cands: [(index: Int, iou: Double, cosine: Double?)])] = []
            leftoverItems.reserveCapacity(leftoverPinned.count)
            for old in leftoverPinned {
                var cands: [(index: Int, iou: Double, cosine: Double?)] = []
                let ov = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
                for (j, face) in adopted.enumerated() {
                    guard MatchMath.leftoverAdoptAllowed(
                        adoptedEnrolled: namedTracks.contains(face.id) || enrolled.contains(face.id)
                    ) else { continue }
                    guard !used.contains(face.id) else { continue }
                    let o = FaceEngine.iou(
                        MatchMath.leftoverStreakBoxWrite(
                            kalmanX: boxKalman[old.id]?.x,
                            kalmanY: boxKalman[old.id]?.y,
                            kalmanW: boxKalman[old.id]?.w,
                            kalmanH: boxKalman[old.id]?.h,
                            fallback: old.box
                        ),
                        MatchMath.leftoverStreakBoxWrite(
                            kalmanX: boxKalman[face.id]?.x,
                            kalmanY: boxKalman[face.id]?.y,
                            kalmanW: boxKalman[face.id]?.w,
                            kalmanH: boxKalman[face.id]?.h,
                            fallback: face.box
                        )
                    )
                    let v = FaceEngine.embedding(of: face)
                    let cosine: Double? = {
                        if v.count >= 32, ov.count == v.count { return MatchMath.cosine(v, ov) }
                        return nil
                    }()
                    cands.append((j, o, cosine))
                }
                leftoverItems.append((old, cands.compactMap(\.cosine).max(), cands))
            }
            let order = MatchMath.leftoverRank(leftoverItems.map { ($0.old.id, $0.bestCos) })
            var leftoverPins = 0
            for id in order {
                guard let item = leftoverItems.first(where: { $0.old.id == id }) else { continue }
                let remaining = item.cands.filter { cand in
                    let face = adopted[cand.index]
                    return MatchMath.leftoverAdoptAllowed(
                        adoptedEnrolled: namedTracks.contains(face.id) || enrolled.contains(face.id)
                    ) && !used.contains(face.id)
                }
                var sharp: [Int: Double] = [:]
                var sameSlot: [Int: Bool] = [:]
                var yawAbs: [Int: Double] = [:]
                var aspectOk: [Int: Bool] = [:]
                var detScore: [Int: Double] = [:]
                var boxX: [Int: Double] = [:]
                let old = item.old
                if leftoverTried.contains(old.id) { continue }
                let oldRaw = FaceEngine.poseSlot(old).rawValue
                let oldHeld = liveSlotHold[old.id]
                let oldSticky = MatchMath.poseSlotSticky(prev: oldHeld?.slot ?? oldRaw, raw: oldRaw, hold: oldHeld?.n ?? 0)
                liveSlotHold[old.id] = (slot: oldSticky.slot, n: oldSticky.hold)
                for cand in remaining {
                    sharp[cand.index] = adopted[cand.index].quality.sharpness
                    yawAbs[cand.index] = abs(adopted[cand.index].quality.yaw)
                    detScore[cand.index] = adopted[cand.index].score
                    boxX[cand.index] = adopted[cand.index].box.x
                    let box = adopted[cand.index].box
                    aspectOk[cand.index] = MatchMath.boxAspectFrontal(width: box.width, height: box.height)
                    let raw = FaceEngine.poseSlot(adopted[cand.index]).rawValue
                    let held = liveSlotHold[adopted[cand.index].id]
                    let sticky = MatchMath.poseSlotSticky(prev: held?.slot ?? oldSticky.slot, raw: raw, hold: held?.n ?? 0)
                    liveSlotHold[adopted[cand.index].id] = (slot: sticky.slot, n: sticky.hold)
                    sameSlot[cand.index] = sticky.slot == oldSticky.slot
                }
                var liveIds: [Int: UUID] = [:]
                for cand in remaining {
                    if let id = matches.first(where: { $0.faceId == adopted[cand.index].id })?
                        .hits.first(where: { $0.strategy == .aegis })?.identityId
                    {
                        liveIds[cand.index] = id
                    }
                }
                let aegisHit = matches.first { $0.faceId == old.id }?.hits.first { $0.strategy == .aegis }
                let liveYaw = remaining.max(by: { $0.iou < $1.iou }).flatMap { yawAbs[$0.index] }
                let lookYaw = MatchMath.leftoverLookawayYawOf(oldYaw: abs(old.quality.yaw), liveYaw: liveYaw)
                let lookEnrolled = namedTracks.contains(old.id) || enrolled.contains(old.id)
                if MatchMath.leftoverLookawayHolds(yawAbs: lookYaw, enrolled: lookEnrolled) {
                    leftoverPins += 1
                    let ghostUntil = liveGhosts.first(where: { $0.face.id == old.id })?.until
                    let weg = MatchMath.leftoverLookawayLabel(until: ghostUntil, now: now)
                    if let pinJ = MatchMath.leftoverLookawayPin(candidates: remaining) {
                        leftoverPending[adopted[pinJ].id] = weg
                        leftoverTried.insert(old.id)
                    } else if let best = remaining.max(by: { $0.iou < $1.iou }),
                              !MatchMath.leftoverLookawayPinsStranger(iou: best.iou)
                    {
                        leftoverPending[adopted[best.index].id] = weg
                        leftoverTried.insert(old.id)
                    }
                    // leftoverHoldSkipLookaway: EMA nicht mit Profil überschreiben. continue hält den Wert.
                    // leftoverHold[id] ist Frontal. ¾-Lookup nicht in die unbinned EMA.
                    if leftoverHold[old.id] == nil,
                       MatchMath.leftoverHoldBin(yawAbs: lookYaw ?? abs(old.quality.yaw)) == 0
                    {
                        leftoverHold[old.id] = MatchMath.leftoverHoldLookupYaw(
                            hash: leftoverLiveHash(
                                kalmanX: boxKalman[old.id]?.x,
                                kalmanY: boxKalman[old.id]?.y,
                                kalmanW: boxKalman[old.id]?.w,
                                kalmanH: boxKalman[old.id]?.h,
                                fallback: old.box,
                                image: image
                            ),
                            table: leftoverHoldByHash,
                            now: now,
                            ttl: MatchMath.dropoutTTL(dt: liveDt),
                            yawAbs: lookYaw ?? abs(old.quality.yaw)
                        )
                    }
                    continue
                }
                guard let bestJ = MatchMath.leftoverPick(
                    candidates: remaining,
                    sharpness: sharp,
                    sameSlot: sameSlot,
                    yawAbs: yawAbs,
                    aspectOk: aspectOk,
                    twinPair: aegisHit?.pairCosine,
                    holdPrev: leftoverHold[old.id],
                    liveIds: liveIds,
                    leftoverId: old.id,
                    printId: aegisHit?.identityId,
                    geoMix: aegisHit?.geoMix,
                    dt: liveDt,
                    lookawayEnrolled: namedTracks.contains(old.id) || enrolled.contains(old.id),
                    lookawayYaw: lookYaw,
                    facesInFrame: adopted.count,
                    detScore: detScore,
                    boxX: boxX,
                    leftoverX: old.box.x,
                    otherX: adopted.filter { $0.id != old.id }.map { $0.box.x },
                    sessionCapture: old.quality.capture,
                    capture: Dictionary(uniqueKeysWithValues: remaining.map {
                        ($0.index, adopted[$0.index].quality.capture)
                    }),
                    imageW: Double(image.width),
                    captureHist: liveCaptureHist[old.id] ?? [],
                    captureBoxHist: Dictionary(uniqueKeysWithValues: remaining.map {
                        ($0.index, liveCaptureHist[adopted[$0.index].id] ?? [])
                    }),
                    holdBins: leftoverHoldBins,
                    holdHash: leftoverLiveHash(
                        kalmanX: boxKalman[old.id]?.x,
                        kalmanY: boxKalman[old.id]?.y,
                        kalmanW: boxKalman[old.id]?.w,
                        kalmanH: boxKalman[old.id]?.h,
                        fallback: old.box,
                        image: image
                    ),
                    holdHashTable: leftoverHoldByHash,
                    holdAt: now,
                    holdTTL: MatchMath.dropoutTTL(dt: liveDt),
                    frameCapture: liveFrameCapture
                ) else {
                    let twin = aegisHit?.pairCosine
                    if let twinLabel = MatchMath.leftoverTwinPairLabel(pairCosine: twin) {
                        for cand in remaining {
                            leftoverPending[adopted[cand.index].id] = twinLabel
                        }
                        if !MatchMath.leftoverTwinKeepsStreak(pairCosine: twin) {
                            leftoverClearStreak(old.id)
                        }
                    } else if remaining.contains(where: { MatchMath.leftoverUnknownKeepsStreak(cosine: $0.cosine) }) {
                        for cand in remaining where MatchMath.leftoverUnknownHard(cosine: cand.cosine) {
                            leftoverPending[adopted[cand.index].id] = MatchMath.leftoverUnknownNote()
                        }
                        leftoverPins += 1
                    } else {
                        let miss = MatchMath.leftoverMissAdvance(prev: leftoverMissFrames[old.id] ?? 0, hit: false)
                        leftoverMissFrames[old.id] = miss
                        if MatchMath.conflictTickAgrees(
                            boxId: nil,
                            printId: aegisHit?.identityId,
                            geoId: nil,
                            lockId: liveIds.values.first,
                            geoMix: aegisHit?.geoMix
                        ) == false {
                            for cand in remaining {
                                guard !MatchMath.leftoverYieldsToLive(liveId: liveIds[cand.index], leftoverId: old.id) else {
                                    continue
                                }
                                leftoverPending[adopted[cand.index].id] = MatchMath.conflictTickNote()
                            }
                        }
                        if MatchMath.leftoverMissClears(miss: miss) {
                            leftoverClearStreak(old.id)
                        }
                    }
                    continue
                }
                leftoverTried.insert(old.id)
                leftoverMissFrames[old.id] = MatchMath.leftoverMissAdvance(prev: leftoverMissFrames[old.id] ?? 0, hit: true)
                let holdHash = leftoverLiveHash(
                    kalmanX: boxKalman[old.id]?.x,
                    kalmanY: boxKalman[old.id]?.y,
                    kalmanW: boxKalman[old.id]?.w,
                    kalmanH: boxKalman[old.id]?.h,
                    fallback: old.box,
                    image: image
                )
                let holdPrev = MatchMath.leftoverHoldPrevOf(
                    frontal: leftoverHold[old.id],
                    yawAbs: abs(adopted[bestJ].quality.yaw),
                    bins: leftoverHoldBins,
                    id: old.id,
                    hash: holdHash,
                    hashTable: leftoverHoldByHash,
                    now: now,
                    ttl: MatchMath.dropoutTTL(dt: liveDt)
                )
                let step = leftoverAdvance(oldId: old.id, box: adopted[bestJ].box, now: now, holdPrev: holdPrev, boxId: adopted[bestJ].id, dt: liveDt)
                if let label = step.label {
                    leftoverPending[adopted[bestJ].id] = label
                }
                guard step.ready else { continue }
                if let cos = remaining.first(where: { $0.index == bestJ })?.cosine {
                    let boxHash = leftoverLiveHash(
                        kalmanX: boxKalman[adopted[bestJ].id]?.x,
                        kalmanY: boxKalman[adopted[bestJ].id]?.y,
                        kalmanW: boxKalman[adopted[bestJ].id]?.w,
                        kalmanH: boxKalman[adopted[bestJ].id]?.h,
                        fallback: adopted[bestJ].box,
                        image: image
                    )
                    leftoverLastHash[adopted[bestJ].id] = MatchMath.leftoverLastHashKeeps(
                        prev: leftoverLastHash[adopted[bestJ].id] ?? leftoverLastHash[old.id],
                        next: boxHash
                    )
                    let yawNow = abs(adopted[bestJ].quality.yaw)
                    let bin = MatchMath.leftoverHoldBin(yawAbs: yawNow)
                    var trail = MatchMath.leftoverTrailNowOf(
                        idTrail: leftoverHoldTrail[old.id] ?? [],
                        binTrail: MatchMath.leftoverTrailLookup(
                            hash: boxHash,
                            table: leftoverHoldTrailByHash,
                            now: now,
                            ttl: MatchMath.dropoutTTL(dt: liveDt),
                            bin: bin
                        ),
                        yawAbs: yawNow
                    )
                    if MatchMath.leftoverTrailWriteOk(
                        sharpness: adopted[bestJ].quality.sharpness,
                        yawAbs: yawNow
                    ) {
                        leftoverHoldTrailByHash = MatchMath.leftoverTrailPut(
                            hash: boxHash,
                            sample: cos,
                            onto: leftoverHoldTrailByHash,
                            now: now,
                            sharpness: adopted[bestJ].quality.sharpness,
                            yawAbs: yawNow,
                            bin: bin
                        )
                        if bin == 0 {
                            trail = MatchMath.leftoverCosineSparkPut(cos, onto: trail)
                            leftoverHoldTrail[old.id] = trail
                        } else {
                            let key = MatchMath.leftoverHoldKey(id: old.id, bin: bin)
                            leftoverHoldTrailBins[key] = MatchMath.leftoverCosineSparkPut(
                                cos, onto: leftoverHoldTrailBins[key] ?? []
                            )
                            trail = leftoverHoldTrailBins[key] ?? MatchMath.leftoverTrailLookup(
                                hash: boxHash,
                                table: leftoverHoldTrailByHash,
                                now: now,
                                ttl: MatchMath.dropoutTTL(dt: liveDt),
                                bin: bin
                            )
                        }
                    }
                    if MatchMath.printMADBlocks(trail) {
                        leftoverPending[adopted[bestJ].id] = MatchMath.printMADNote()
                        continue
                    }
                    if let med = MatchMath.printCommitMedian(trail),
                       MatchMath.unknownCentroid(bestCosine: med)
                    {
                        leftoverPending[adopted[bestJ].id] = "MED"
                        continue
                    }
                }
                if MatchMath.posterFaceReject(
                    jitter: livePosterJitter[old.id] ?? 1,
                    frames: livePosterStill[old.id] ?? 0
                ) {
                    leftoverPending[adopted[bestJ].id] = "POSTER"
                    continue
                }
                if MatchMath.posterNeedsBlink(
                    stillFrames: livePosterStill[old.id] ?? 0,
                    blinked: liveBlinkSeen[old.id] ?? false
                ) {
                    leftoverPending[adopted[bestJ].id] = MatchMath.posterBlinkNote()
                    continue
                }
                leftoverPending.removeValue(forKey: adopted[bestJ].id)
                let pinCos = remaining.first(where: { $0.index == bestJ })?.cosine ?? item.bestCos
                let holdNow = MatchMath.leftoverHoldPrevOf(
                    frontal: leftoverHold[old.id],
                    yawAbs: abs(adopted[bestJ].quality.yaw),
                    bins: leftoverHoldBins,
                    id: old.id,
                    hash: holdHash,
                    hashTable: leftoverHoldByHash,
                    now: now,
                    ttl: MatchMath.dropoutTTL(dt: liveDt)
                )
                let trailNow = MatchMath.leftoverTrailNowOf(
                    idTrail: leftoverHoldTrail[old.id] ?? [],
                    binTrail: MatchMath.leftoverTrailLookup(
                        hash: leftoverLiveHash(
                            kalmanX: boxKalman[adopted[bestJ].id]?.x,
                            kalmanY: boxKalman[adopted[bestJ].id]?.y,
                            kalmanW: boxKalman[adopted[bestJ].id]?.w,
                            kalmanH: boxKalman[adopted[bestJ].id]?.h,
                            fallback: adopted[bestJ].box,
                            image: image
                        ),
                        table: leftoverHoldTrailByHash,
                        now: now,
                        ttl: MatchMath.dropoutTTL(dt: liveDt),
                        bin: MatchMath.leftoverHoldBin(yawAbs: abs(adopted[bestJ].quality.yaw))
                    ),
                    yawAbs: abs(adopted[bestJ].quality.yaw)
                )
                let tapUntil = tapNameLockUntil[old.id] ?? tapNameLockUntil[adopted[bestJ].id]
                if let tap = MatchMath.tapNameLockLabel(until: tapUntil, now: now) {
                    leftoverPending[adopted[bestJ].id] = tap
                }
                let stillFor = liveStillFor[old.id] ?? liveStillFor[adopted[bestJ].id] ?? 0
                let transfer = MatchMath.leftoverTransfersId(
                    cosine: pinCos,
                    holdPrev: holdNow,
                    trail: trailNow,
                    tapUntil: tapUntil,
                    now: now,
                    stillFor: stillFor,
                    sharpness: adopted[bestJ].quality.sharpness,
                    yawAbs: abs(adopted[bestJ].quality.yaw),
                    blink: liveBlinkSeen[old.id] ?? liveBlinkSeen[adopted[bestJ].id] ?? false
                )
                if MatchMath.leftoverHoldsTrack(
                    cosine: pinCos,
                    holdPrev: holdNow,
                    trail: trailNow,
                    tapUntil: tapUntil,
                    now: now,
                    stillFor: stillFor,
                    sharpness: adopted[bestJ].quality.sharpness,
                    yawAbs: abs(adopted[bestJ].quality.yaw),
                    blink: liveBlinkSeen[old.id] ?? liveBlinkSeen[adopted[bestJ].id] ?? false
                ) {
                    leftoverPending[adopted[bestJ].id] = MatchMath.leftoverHoldLabel(
                        cosine: pinCos,
                        sharpness: adopted[bestJ].quality.sharpness,
                        yawAbs: abs(adopted[bestJ].quality.yaw),
                        smooth: holdNow
                    )
                        ?? leftoverPending[adopted[bestJ].id]
                    leftoverPins += 1
                    if let cos = pinCos, MatchMath.leftoverHoldWriteOk(
                        sharpness: adopted[bestJ].quality.sharpness,
                        yawAbs: abs(adopted[bestJ].quality.yaw)
                    ) {
                        leftoverHoldByHash = MatchMath.leftoverHoldPut(
                            hash: leftoverLiveHash(
                                kalmanX: boxKalman[adopted[bestJ].id]?.x,
                                kalmanY: boxKalman[adopted[bestJ].id]?.y,
                                kalmanW: boxKalman[adopted[bestJ].id]?.w,
                                kalmanH: boxKalman[adopted[bestJ].id]?.h,
                                fallback: adopted[bestJ].box,
                                image: image
                            ),
                            cosine: cos,
                            onto: leftoverHoldByHash,
                            now: now,
                            bin: MatchMath.leftoverHoldBin(yawAbs: abs(adopted[bestJ].quality.yaw))
                        )
                        leftoverHold[old.id] = MatchMath.leftoverHoldEMA(
                            prev: leftoverHold[old.id] ?? holdNow,
                            next: cos,
                            alpha: MatchMath.leftoverHoldAlpha(
                                dt: liveDt,
                                captureJump: MatchMath.leftoverCaptureJump(
                                    prev: old.quality.capture,
                                    next: adopted[bestJ].quality.capture
                                )
                            )
                        )
                    }
                    if let cos = pinCos, MatchMath.leftoverHoldBinWriteOk(
                        sharpness: adopted[bestJ].quality.sharpness,
                        yawAbs: abs(adopted[bestJ].quality.yaw)
                    ) {
                        leftoverHoldBins = MatchMath.leftoverHoldBinPut(
                            bins: leftoverHoldBins,
                            id: old.id,
                            yawAbs: abs(adopted[bestJ].quality.yaw),
                            next: cos,
                            prev: MatchMath.leftoverHoldPrevOf(
                                frontal: leftoverHold[old.id] ?? holdNow,
                                yawAbs: abs(adopted[bestJ].quality.yaw),
                                bins: leftoverHoldBins,
                                id: old.id
                            ),
                            dt: liveDt,
                            captureJump: MatchMath.leftoverCaptureJump(
                                prev: old.quality.capture,
                                next: adopted[bestJ].quality.capture
                            )
                        )
                        leftoverHoldByHash = MatchMath.leftoverHoldPut(
                            hash: leftoverLiveHash(
                                kalmanX: boxKalman[adopted[bestJ].id]?.x,
                                kalmanY: boxKalman[adopted[bestJ].id]?.y,
                                kalmanW: boxKalman[adopted[bestJ].id]?.w,
                                kalmanH: boxKalman[adopted[bestJ].id]?.h,
                                fallback: adopted[bestJ].box,
                                image: image
                            ),
                            cosine: cos,
                            onto: leftoverHoldByHash,
                            now: now,
                            bin: MatchMath.leftoverHoldBin(yawAbs: abs(adopted[bestJ].quality.yaw))
                        )
                    }
                    continue
                }
                if !MatchMath.leftoverStreakKeepsLive(transferred: transfer) {
                    leftoverClearStreak(old.id)
                }
                used.insert(old.id)
                if transfer {
                    let newId = adopted[bestJ].id
                    adopted[bestJ].id = old.id
                    leftoverMirrorPending(from: newId, to: old.id)
                    adopted[bestJ].trackId = old.trackId ?? old.id
                    adopted[bestJ].enrolledAt = old.enrolledAt ?? adopted[bestJ].enrolledAt
                    if adopted[bestJ].featurePrint.isEmpty {
                        adopted[bestJ].featurePrint = old.featurePrint
                    }
                    if adopted[bestJ].printVec.isEmpty, !old.printVec.isEmpty {
                        adopted[bestJ].printVec = old.printVec
                    }
                    leftoverBlendAdopted(&adopted[bestJ], oldId: old.id)
                    liveExposureUntil[old.id] = MatchMath.exposureLockUntil(
                        now: now,
                        hold: MatchMath.exposureLockHold(dt: liveDt, reconnect: true)
                    )
                } else {
                    guestOrder = MatchMath.guestOrderAppend(id: adopted[bestJ].id, onto: guestOrder)
                    guestSeenAt[adopted[bestJ].id] = now
                }
                let putHash = leftoverLiveHash(
                    kalmanX: boxKalman[adopted[bestJ].id]?.x ?? boxKalman[old.id]?.x,
                    kalmanY: boxKalman[adopted[bestJ].id]?.y ?? boxKalman[old.id]?.y,
                    kalmanW: boxKalman[adopted[bestJ].id]?.w ?? boxKalman[old.id]?.w,
                    kalmanH: boxKalman[adopted[bestJ].id]?.h ?? boxKalman[old.id]?.h,
                    fallback: adopted[bestJ].box,
                    image: image
                )
                boxEuro.removeValue(forKey: old.id)
                if !MatchMath.leftoverAdoptKeepsKalman() {
                    boxKalmanDrop(old.id)
                }
                boxJumpPending.removeValue(forKey: old.id)
                leftoverPins += 1
                if let cos = pinCos {
                    let spike = MatchMath.leftoverBaptizeSpike(raw: cos, prev: holdPrev)
                    if !spike, MatchMath.leftoverHoldWriteOk(
                        sharpness: adopted[bestJ].quality.sharpness,
                        yawAbs: abs(adopted[bestJ].quality.yaw)
                    ) {
                        leftoverHoldByHash = MatchMath.leftoverHoldPut(
                            hash: putHash,
                            cosine: cos,
                            onto: leftoverHoldByHash,
                            now: now,
                            bin: MatchMath.leftoverHoldBin(yawAbs: abs(adopted[bestJ].quality.yaw))
                        )
                    }
                    if MatchMath.leftoverWipeHist(cosine: cos) {
                        leftoverHold[adopted[bestJ].id] = MatchMath.leftoverHoldEMA(
                            prev: leftoverHold[adopted[bestJ].id] ?? leftoverHold[old.id],
                            next: cos,
                            alpha: MatchMath.leftoverHoldAlpha(
                                dt: liveDt,
                                captureJump: MatchMath.leftoverCaptureJump(
                                    prev: old.quality.capture,
                                    next: adopted[bestJ].quality.capture
                                )
                            )
                        )
                        if MatchMath.leftoverHoldBinWriteOk(
                            sharpness: adopted[bestJ].quality.sharpness,
                            yawAbs: abs(adopted[bestJ].quality.yaw)
                        ) {
                            leftoverHoldBins = MatchMath.leftoverHoldBinPut(
                                bins: leftoverHoldBins,
                                id: adopted[bestJ].id,
                                yawAbs: abs(adopted[bestJ].quality.yaw),
                                next: cos,
                                prev: MatchMath.leftoverHoldPrevOf(
                                    frontal: leftoverHold[adopted[bestJ].id] ?? leftoverHold[old.id],
                                    yawAbs: abs(adopted[bestJ].quality.yaw),
                                    bins: leftoverHoldBins,
                                    id: adopted[bestJ].id
                                ),
                                dt: liveDt,
                                captureJump: MatchMath.leftoverCaptureJump(
                                    prev: old.quality.capture,
                                    next: adopted[bestJ].quality.capture
                                )
                            )
                            leftoverHoldByHash = MatchMath.leftoverHoldPut(
                                hash: putHash,
                                cosine: cos,
                                onto: leftoverHoldByHash,
                                now: now,
                                bin: MatchMath.leftoverHoldBin(yawAbs: abs(adopted[bestJ].quality.yaw))
                            )
                        }
                        leftoverWipeUntil[adopted[bestJ].id] = MatchMath.leftoverWipeMuteUntil(now: now)
                        if transfer {
                            liveNameHist.removeValue(forKey: old.id)
                            liveNameLock.removeValue(forKey: old.id)
                            liveNameVoteAt.removeValue(forKey: old.id)
                            liveScoreEma.removeValue(forKey: old.id)
                            livePrintDrift.removeValue(forKey: old.id)
                        }
                    } else {
                        leftoverHold.removeValue(forKey: adopted[bestJ].id)
                        leftoverHoldBins = MatchMath.leftoverHoldBinDrop(bins: leftoverHoldBins, id: adopted[bestJ].id)
                    }
                }
            }
            let liveIds = Set(adopted.map(\.id))
            let leftoverIds = Set(leftoverPinned.map(\.id))
            leftoverHold = leftoverHold.filter { liveIds.contains($0.key) || leftoverIds.contains($0.key) }
            leftoverHoldBins = leftoverHoldBins.filter { row in
                MatchMath.leftoverHoldId(from: row.key).map { liveIds.contains($0) || leftoverIds.contains($0) } ?? false
            }
            leftoverHoldByHash = MatchMath.leftoverHoldPrune(leftoverHoldByHash, now: now)
            leftoverHoldTrailByHash = MatchMath.leftoverTrailPrune(leftoverHoldTrailByHash, now: now)
            leftoverPending = leftoverPending.filter { liveIds.contains($0.key) }
            tapGuestPending = tapGuestPending.filter { liveIds.contains($0) }
            for id in tapGuestPending {
                if leftoverPending[id] == nil {
                    leftoverPending[id] = MatchMath.tapGuestNote()
                }
            }
            let liveList = Array(liveIds)
            guestOrder = guestOrder.filter {
                MatchMath.guestOrderKeeps(id: $0, live: liveList, lastSeen: guestSeenAt[$0], now: now)
            }
            for id in liveIds where guestOrder.contains(id) {
                guestSeenAt[id] = now
            }
            guestSeenAt = guestSeenAt.filter { guestOrder.contains($0.key) || liveIds.contains($0.key) }
            leftoverStreak = leftoverStreak.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverStreakBox = leftoverStreakBox.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverStreakSince = leftoverStreakSince.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverLastHash = leftoverLastHash.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverSparkChipHeld = leftoverSparkChipHeld.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverPairLast = leftoverPairLast.filter { leftoverIds.contains($0.key) && !used.contains($0.key) }
            leftoverPairStreak = leftoverPairStreak.filter { leftoverIds.contains($0.key) && !used.contains($0.key) }
            leftoverPairCommit = leftoverPairCommit.filter { leftoverIds.contains($0.key) && !used.contains($0.key) }
            leftoverDisagree = leftoverDisagree.filter { leftoverIds.contains($0.key) && !used.contains($0.key) }
            leftoverHoldTrail = leftoverHoldTrail.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverHoldTrailBins = leftoverHoldTrailBins.filter { row in
                MatchMath.leftoverHoldId(from: row.key).map {
                    liveIds.contains($0) || (leftoverIds.contains($0) && !used.contains($0))
                } ?? false
            }
            leftoverWipeUntil = leftoverWipeUntil.filter { liveIds.contains($0.key) || leftoverIds.contains($0.key) }
            liveSlotHold = liveSlotHold.filter { liveIds.contains($0.key) || leftoverIds.contains($0.key) }
            if leftoverPins > 0, let line = MatchMath.leftoverPinStatus(
                count: leftoverPins,
                cosine: leftoverHold.values.max()
            ) {
                status = "Live · \(line)"
            } else if let pending = leftoverPending.values.sorted().last {
                status = "Live · leftover \(pending)"
            } else if status.hasPrefix("Live · Leftover") || status.hasPrefix("Live · leftover") {
                status = "Live"
            }
            liveHeldIds = Set(adopted.compactMap { namedTracks.contains($0.id) ? $0.id : nil })
            faces.removeAll { $0.mediaId == mediaId }
            faces.append(contentsOf: adopted)
            let n = adopted.count
            if let label = MatchMath.headCountFlashLabel(prev: lastLiveHeadCount, next: n) {
                lastHeadCountLabel = label
                headCountFlashUntil = now + MatchMath.headCountFlashHold
            }
            lastLiveHeadCount = n
        }
        if selectedMediaId == mediaId {
            if found.isEmpty {
                if !MatchMath.leftoverEmptyKeepsOverlay(liveEmpty: true) || !emptyChip {
                    selectedFaceId = nil
                }
            } else if let cur = selectedFaceId, adopted.contains(where: { $0.id == cur }) {
                // Auswahl halten, solange der Track da ist.
            } else {
                selectedFaceId = adopted.first?.id
            }
        }
        reconnectGhosts.removeAll { used.contains($0.id) }
        nmsDropped = FaceEngine.lastNMSDropped
        rematchLive()
        suggestUSlotIfHeld(adopted, now: now)
    }

    /// 1,2 s Maske im Track → Vorschlag, nie still schreiben.
    private func suggestUSlotIfHeld(_ adopted: [FaceObservation], now: TimeInterval) {
        let liveIds = Set(adopted.map(\.id))
        maskHoldSince = maskHoldSince.filter { liveIds.contains($0.key) }
        for face in adopted {
            let masked = FaceEngine.lowerFaceOccluded(face)
            if masked {
                if maskHoldSince[face.id] == nil { maskHoldSince[face.id] = now }
            } else {
                maskHoldSince.removeValue(forKey: face.id)
            }
            guard let since = maskHoldSince[face.id], now - since >= 1.2 else { continue }
            guard now - lastUSlotHint >= 4 else { continue }
            let owner = identities.first { $0.faceIds.contains(face.id) }
                ?? (identities.count == 1 ? identities.first : nil)
            guard let owner else { continue }
            let refs = faces.filter { owner.faceIds.contains($0.id) }
            let hasU = refs.contains { $0.forcedPartial || FaceEngine.lowerFaceOccluded($0) }
            if hasU { continue }
            lastUSlotHint = now
            status = "Maske 1,2 s · U für Teil-Print von \(owner.name) — nie still geschrieben"
        }
    }

    func exportCSV() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "aegis-matches.csv"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        var lines = [MatchMath.labCSVHeader()]
        let idNames = Dictionary(uniqueKeysWithValues: identities.map { ($0.id, $0.name) })
        for row in matches {
            for hit in row.hits {
                let name = hit.identityId.flatMap { idNames[$0] } ?? ""
                lines.append(MatchMath.labCSVRow(
                    face: row.faceId.uuidString,
                    strategy: hit.strategy.label,
                    identity: name,
                    percent: hit.percent,
                    note: hit.note
                ))
            }
        }
        try? lines.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
    }

    private func csvField(_ raw: String) -> String {
        if raw.contains(",") || raw.contains("\"") || raw.contains("\n") || raw.contains("\r") {
            return "\"" + raw.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return raw
    }

    func exportLab() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "aegis-labor.txt"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        let faces = self.faces
        let identities = self.identities
        let media = self.media
        let enabled = self.enabled
        let threshold = self.threshold
        let cameraOrient = self.cameraOrient
        busy = true
        status = "Laborbericht"
        Task {
            let text = await Task.detached {
                LabReport.text(
                    faces: faces,
                    identities: identities,
                    media: media,
                    enabled: enabled,
                    threshold: threshold,
                    cameraOrient: cameraOrient
                )
            }.value
            try? text.write(to: url, atomically: true, encoding: .utf8)
            busy = false
            status = "Laborbericht gespeichert"
        }
    }

    func fetchBenchData(thenStart: Bool = false) {
        scanGeneration += 1
        let gen = scanGeneration
        busy = true
        status = "Testdaten · starte Download"
        Task {
            do {
                let ident20 = try await BenchFetch.install { msg in
                    Task { @MainActor in
                        if gen == self.scanGeneration { self.status = msg }
                    }
                }
                if gen != self.scanGeneration {
                    self.busy = false
                    return
                }
                self.status = "Testdaten in \(ident20.deletingLastPathComponent().path)"
                self.busy = false
                if thenStart {
                    self.runBenchmark(root: ident20)
                }
            } catch {
                self.busy = false
                self.status = "Testdaten: \(error.localizedDescription)"
            }
        }
    }

    func startDefaultBenchmark() {
        if BenchFetch.ident20Ready() {
            retainAccess([BenchFetch.root()])
            runBenchmark(root: BenchFetch.ident20URL())
            return
        }
        fetchBenchData(thenStart: true)
    }

    func pickBenchmark() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Testmodus"
        panel.message = "Ordner mit Personen-Unterordnern. Empfohlen: ~/AegisBench/ident20 nach ./bench/fetch.sh"
        let home = benchHome
        if FileManager.default.fileExists(atPath: home.path) {
            panel.directoryURL = home
        } else {
            status = "Kein ~/AegisBench. Repo klonen, dann: ./bench/fetch.sh"
        }
        guard panel.runModal() == .OK, let root = panel.url else { return }
        retainAccess([root])
        runBenchmark(root: root)
    }

    private func runBenchmark(root: URL) {
        scanGeneration += 1
        scanFlag.reset()
        let gen = scanGeneration
        let flag = scanFlag
        let threshold = self.threshold
        let enabled = self.enabled
        let cameraOrient = self.cameraOrient
        let savedMedia = media
        let savedFaces = faces
        let savedIdentities = identities
        let savedMatches = matches
        let savedSelectedMedia = selectedMediaId
        let savedSelectedFace = selectedFaceId
        busy = true
        status = "Testmodus · Ordner lesen"
        Task {
            var parts: [String] = [Benchmark.header(root: root, mode: "Verifikation + Identifikation")]
            let pairsURL = BenchProtocol.findPairsFile(root: root)
                ?? Bundle.main.url(forResource: "pairs", withExtension: "txt")
            let pairsText = pairsURL.flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? ""
            let pairs = BenchProtocol.parsePairs(pairsText)
            let people = BenchProtocol.personFolders(root: root)
            let picked = BenchProtocol.selectPeople(people, cap: Benchmark.identifyPeopleCap)
            let large = people.count > picked.urls.count

            if !pairs.isEmpty {
                self.status = "Testmodus · Verifikation 0/\(pairs.count)"
                let verifyRoot = root
                let tick = BenchProgress()
                let verifyTask = Task.detached {
                    defer { tick.finish() }
                    return Benchmark.verify(
                        root: verifyRoot,
                        pairs: pairs,
                        threshold: threshold,
                        shouldContinue: { flag.alive },
                        progress: { n, total in tick.set(n, total) }
                    )
                }
                while !tick.isFinished {
                    if gen != self.scanGeneration {
                        flag.stop()
                        break
                    }
                    self.status = tick.label
                    try? await Task.sleep(nanoseconds: 200_000_000)
                }
                let report = await verifyTask.value
                parts.append("")
                parts.append(report)
            } else {
                parts.append("")
                parts.append("Kein pairs.txt — nur Identifikation. bench/fetch.sh legt die LFW-Paare nach ~/AegisBench.")
            }

            if gen != self.scanGeneration || !flag.alive {
                self.restoreGallery(savedMedia, savedFaces, savedIdentities, savedMatches, savedSelectedMedia, savedSelectedFace)
                self.busy = false
                self.status = "Testmodus abgebrochen"
                return
            }

            let subset = picked.urls
            var urls: [URL] = []
            for person in subset {
                urls.append(contentsOf: BenchProtocol.images(in: person, limit: Benchmark.photosPerPerson))
            }
            if !urls.isEmpty {
                self.media = []
                self.faces = []
                self.identities = []
                self.matches = []
                self.status = "Testmodus · Identifikation \(urls.count) Fotos, \(subset.count) Personen"
                await self.ingestAndScan(urls: urls, generation: gen)
                self.busy = true
                if gen != self.scanGeneration {
                    self.restoreGallery(savedMedia, savedFaces, savedIdentities, savedMatches, savedSelectedMedia, savedSelectedFace)
                    self.busy = false
                    self.status = "Testmodus abgebrochen"
                    return
                }
                self.identities = Benchmark.identitiesFromFolders(media: self.media, faces: self.faces)
                self.rematch()
                let idFaces = self.faces
                let idIdentities = self.identities
                let idMedia = self.media
                let lab = await Task.detached {
                    LabReport.text(
                        faces: idFaces,
                        identities: idIdentities,
                        media: idMedia,
                        enabled: enabled,
                        threshold: threshold,
                        cameraOrient: cameraOrient
                    )
                }.value
                parts.append("")
                parts.append("Identifikation (Leave-one-out, ≥\(picked.minPhotos) Fotos, max \(Benchmark.identifyPeopleCap) Personen × \(Benchmark.photosPerPerson) Fotos)")
                if large {
                    parts.append("Galerie gekappt: \(people.count) Ordner → \(subset.count) Personen (min \(picked.minPhotos) Bilder). ident10/ident20 sind die vorbereiteten Sätze.")
                }
                parts.append(lab)
            }

            self.restoreGallery(savedMedia, savedFaces, savedIdentities, savedMatches, savedSelectedMedia, savedSelectedFace)
            let text = parts.joined(separator: "\n")
            let save = NSSavePanel()
            save.allowedContentTypes = [.plainText]
            save.nameFieldStringValue = "aegis-testmodus.txt"
            save.directoryURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("AegisBench")
            self.busy = false
            if save.runModal() == .OK, let url = save.url {
                try? text.write(to: url, atomically: true, encoding: .utf8)
                self.status = "Testmodus gespeichert · \(url.lastPathComponent)"
            } else {
                self.status = "Testmodus fertig — Speichern verworfen"
            }
        }
    }

    private func restoreGallery(
        _ media: [MediaItem],
        _ faces: [FaceObservation],
        _ identities: [Identity],
        _ matches: [MatchResult],
        _ selectedMediaId: UUID?,
        _ selectedFaceId: UUID?
    ) {
        self.media = media
        self.faces = faces
        self.identities = identities
        self.matches = matches
        self.selectedMediaId = selectedMediaId
        self.selectedFaceId = selectedFaceId
    }
}
