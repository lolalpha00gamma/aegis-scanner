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

    private let liveCapture = LiveCapture()
    private var liveMediaId: UUID?
    private var scopedRoots: [URL] = []
    private var liveBusy = false
    private var livePending: (image: CGImage, mediaId: UUID, stamp: TimeInterval)?
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
    private var liveScoreEma: [UUID: Double] = [:]
    private var livePrintTrail: [UUID: [[Double]]] = [:]
    private var livePrintTrailSlot: [UUID: String] = [:]
    private var lastCameraUniqueID: String = ""
    private var pendingRenameId: UUID?
    private var pendingRenameName: String?

    init() {
        let packed = GalleryFile.load()
        identities = packed.identities
        faces = packed.faces
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
    }

    private func persist() {
        GalleryFile.save(identities: identities, faces: faces)
    }

    var canRestoreBackup: Bool { GalleryFile.backupExists }

    func restoreFromBackup() {
        guard let packed = GalleryFile.loadBackup() else {
            status = "Kein gallery.json.bak"
            return
        }
        identities = packed.identities
        faces = packed.faces
        liveNameHist = [:]
        liveScoreEma = [:]
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
        return "Galerie \(identities.count): Floor \(Int(f.match)) · Solo \(Int(f.solo))"
    }

    var enrollmentHint: String {
        guard let face = selectedFace else { return "" }
        return FaceEngine.enrollmentPreview(
            face: face,
            identities: identities,
            faces: faces
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
        liveScoreEma = liveScoreEma.filter { liveFaceIds.contains($0.key) }
        for i in matches.indices {
            let fid = matches[i].faceId
            guard liveFaceIds.contains(fid),
                  let hi = matches[i].hits.firstIndex(where: { $0.strategy == .aegis })
            else { continue }
            var hit = matches[i].hits[hi]
            if !hit.measured {
                continue
            }
            let token = hit.identityId?.uuidString ?? ""
            var hist = liveNameHist[fid] ?? []
            hist.append(token)
            if hist.count > MatchMath.nameVoteFrames {
                hist.removeFirst(hist.count - MatchMath.nameVoteFrames)
            }
            liveNameHist[fid] = hist
            if let voted = MatchMath.nameMajority(hist) {
                if voted.isEmpty {
                    hit.identityId = nil
                } else if let ident = identities.first(where: { $0.id.uuidString == voted }) {
                    hit.identityId = ident.id
                    hit.percent = MatchMath.votedPercent(
                        versus: hit.versus.map { ($0.identityId, $0.percent) },
                        identityId: ident.id,
                        fallback: hit.percent
                    )
                } else {
                    hit.identityId = nil
                }
            }
            let ema = MatchMath.liveScoreEMA(prev: liveScoreEma[fid], next: hit.percent)
            liveScoreEma[fid] = ema
            hit.percent = ema
            matches[i].hits[hi] = hit
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
        if incoming.count >= 32 {
            for existingId in identities[idx].faceIds {
                guard let old = faces.first(where: { $0.id == existingId }) else { continue }
                let ov = FaceEngine.embedding(of: old)
                guard ov.count == incoming.count else { continue }
                let c = MatchMath.cosine(incoming, ov)
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
            if pendingRenameName != name || pendingRenameId != id {
                pendingRenameName = name
                pendingRenameId = id
                status = "Name \(name) existiert. Nochmal Return bestätigt den Konflikt."
                return
            }
        }
        pendingRenameName = nil
        pendingRenameId = nil
        identities[idx].name = name
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
        maskHoldSince.removeAll()
        lastUSlotHint = 0
        boxJumpPending.removeAll()
        liveNameHist = [:]
        liveScoreEma = [:]
        livePrintTrail.removeAll()
        livePrintTrailSlot.removeAll()
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
                self.boxJumpPending.removeAll()
                self.livePrintTrail.removeAll()
                self.livePrintTrailSlot.removeAll()
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
        Task.detached(priority: .userInitiated) {
            let found = (try? FaceEngine.detect(in: image, mediaId: mediaId, tiles: false, continuity: cont, cheapGraph: true)) ?? []
            await MainActor.run { [weak self] in
                guard let self else { return }
                if !self.liveActive || self.liveMediaId != mediaId {
                    self.liveBusy = false
                    self.livePending = nil
                    return
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

    private func applyLiveFaces(_ found: [FaceObservation], image: CGImage, mediaId: UUID, stamp: TimeInterval) {
        liveCapture.setFacesPresent(!found.isEmpty)
        guard let idx = media.firstIndex(where: { $0.id == mediaId }) else { return }
        media[idx].width = image.width
        media[idx].height = image.height
        media[idx].preview = image
        let now = stamp > 0 ? stamp : Date().timeIntervalSince1970
        let enrolled = Set(identities.flatMap(\.faceIds))
        let previous = faces.filter { $0.mediaId == mediaId }
        let namedTracks = Set(previous.compactMap { old -> UUID? in
            let hit = matches.first { $0.faceId == old.id }?.hits.first { $0.strategy == .aegis }
            return hit?.identityId != nil ? old.id : nil
        })
        var used = Set<UUID>()
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
            let takePrint = MatchMath.boxPinTakePrint(
                iouHold: best.map { MatchMath.boxHysteresisHold(iou: bestIoU) } ?? false,
                printPinDifferent: printPin.map { $0.id != best?.id } ?? false,
                printEnrolled: printEnrolled
            )
            if let old = best, !takePrint {
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
                var euro = boxEuro[old.id] ?? (
                    MatchMath.OneEuro(), MatchMath.OneEuro(), MatchMath.OneEuro(), MatchMath.OneEuro()
                )
                face.box = FaceBox(
                    x: euro.x.filter(face.box.x, now: t),
                    y: euro.y.filter(face.box.y, now: t),
                    width: euro.w.filter(face.box.width, now: t),
                    height: euro.h.filter(face.box.height, now: t)
                )
                boxEuro[old.id] = euro
                let blend = MatchMath.liveBlendAlpha(continuity: liveCapture.isContinuity)
                if face.featurePrint.isEmpty, !old.featurePrint.isEmpty {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec
                } else if !old.featurePrint.isEmpty, face.quality.capture + 0.04 < old.quality.capture {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                } else if !old.featurePrint.isEmpty, !face.featurePrint.isEmpty {
                    if MatchMath.holdStillSkip(iou: bestIoU, sharpness: face.quality.sharpness)
                        || MatchMath.skipPrint(sharpness: face.quality.sharpness, continuity: liveCapture.isContinuity)
                    {
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
                    if next.count >= 32 { trail.append(next) }
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
                // Ghost-Box darf nicht kleben: 1-Euro und Ampel der UUID verwerfen.
                boxEuro.removeValue(forKey: old.id)
                boxJumpPending.removeValue(forKey: old.id)
                livePrintTrail.removeValue(forKey: old.id)
                livePrintTrailSlot.removeValue(forKey: old.id)
                face.qualitySpark = []
                let blend = MatchMath.liveBlendAlpha(continuity: liveCapture.isContinuity)
                if face.featurePrint.isEmpty, !old.featurePrint.isEmpty {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                } else if !old.printVec.isEmpty, !face.featurePrint.isEmpty {
                    face.printVec = FaceEngine.blendEmbeddings(old.printVec, FaceEngine.embedding(of: face), alpha: blend)
                }
            }
            adopted.append(face)
        }
        liveGhosts.removeAll { $0.until < now }
        boxEuro = boxEuro.filter { used.contains($0.key) }
        boxJumpPending = boxJumpPending.filter { used.contains($0.key) }
        livePrintTrail = livePrintTrail.filter { used.contains($0.key) }
        livePrintTrailSlot = livePrintTrailSlot.filter { used.contains($0.key) }
        if found.isEmpty {
            for old in previous where !enrolled.contains(old.id) {
                liveGhosts.append((old, now + 1.8))
            }
            liveHeldIds = []
            faces.removeAll { $0.mediaId == mediaId }
        } else {
            let leftoverPinned = previous.filter {
                MatchMath.leftoverNamedTrack(hadName: namedTracks.contains($0.id)) && !used.contains($0.id)
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
                    let o = FaceEngine.iou(old.box, face.box)
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
                let old = item.old
                let oldSlot = FaceEngine.poseSlot(old)
                for cand in remaining {
                    sharp[cand.index] = adopted[cand.index].quality.sharpness
                    sameSlot[cand.index] = FaceEngine.poseSlot(adopted[cand.index]) == oldSlot
                }
                guard let bestJ = MatchMath.leftoverPick(candidates: remaining, sharpness: sharp, sameSlot: sameSlot) else { continue }
                used.insert(old.id)
                adopted[bestJ].id = old.id
                adopted[bestJ].trackId = old.trackId ?? old.id
                adopted[bestJ].enrolledAt = old.enrolledAt ?? adopted[bestJ].enrolledAt
                boxEuro.removeValue(forKey: old.id)
                boxJumpPending.removeValue(forKey: old.id)
                if adopted[bestJ].featurePrint.isEmpty {
                    adopted[bestJ].featurePrint = old.featurePrint
                }
                if adopted[bestJ].printVec.isEmpty, !old.printVec.isEmpty {
                    adopted[bestJ].printVec = old.printVec
                }
                leftoverPins += 1
            }
            if leftoverPins > 0, let line = MatchMath.leftoverPinStatus(count: leftoverPins) {
                status = "Live · \(line)"
            } else if status.hasPrefix("Live · Leftover") {
                status = "Live"
            }
            liveHeldIds = Set(adopted.compactMap { namedTracks.contains($0.id) ? $0.id : nil })
            faces.removeAll { $0.mediaId == mediaId }
            faces.append(contentsOf: adopted)
        }
        if selectedMediaId == mediaId {
            if found.isEmpty {
                selectedFaceId = nil
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
        var lines = ["face,strategy,identity,percent"]
        let idNames = Dictionary(uniqueKeysWithValues: identities.map { ($0.id, $0.name) })
        for row in matches {
            for hit in row.hits {
                let name = hit.identityId.flatMap { idNames[$0] } ?? ""
                lines.append([
                    csvField(row.faceId.uuidString),
                    csvField(hit.strategy.label),
                    csvField(name),
                    csvField(String(format: "%.1f", hit.percent)),
                ].joined(separator: ","))
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
}
