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
    @Published var enabled: Set<StrategyID> = Set(StrategyID.allCases)
    @Published var pendingDuplicateName: String?

    private let liveCapture = LiveCapture()
    private var liveMediaId: UUID?
    private var scopedRoots: [URL] = []
    private var liveBusy = false
    private var scanGeneration = 0
    private let scanFlag = AegisScanFlag()
    private let enabledKey = "aegis.enabledStrategies"
    private var liveGhosts: [(face: FaceObservation, until: TimeInterval)] = []
    private var reconnectGhosts: [FaceObservation] = []

    init() {
        let packed = GalleryFile.load()
        identities = packed.identities
        faces = packed.faces
        if let raw = UserDefaults.standard.array(forKey: enabledKey) as? [String] {
            let set = Set(raw.compactMap(StrategyID.init(rawValue:)))
            if !set.isEmpty { enabled = set }
        }
        if !identities.isEmpty {
            status = "Galerie · \(identities.count) Personen"
        }
    }

    private func persist() {
        GalleryFile.save(identities: identities, faces: faces)
    }

    var selectedMedia: MediaItem? {
        media.first { $0.id == selectedMediaId }
    }

    var browseItems: [MediaItem] {
        media.filter { $0.kind != .frame }
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
                if gen != self.scanGeneration { return }
                urls.append(contentsOf: found)
            }
            if gen != self.scanGeneration { return }
            let before = self.media.count
            self.ingest(urls: urls)
            if let firstNew = self.media.dropFirst(before).first(where: { $0.kind == .photo })
                ?? self.media.dropFirst(before).first
            {
                self.selectedMediaId = firstNew.id
            }
            await self.scan(generation: gen)
        }
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
        status = "Scan abgebrochen"
    }

    func scan() async {
        scanGeneration += 1
        scanFlag.reset()
        await scan(generation: scanGeneration)
    }

    private func scan(generation: Int) async {
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
        let pending = media.filter { item in
            (item.kind == .photo || item.kind == .frame) && !faces.contains { $0.mediaId == item.id }
        }
        for (i, item) in pending.enumerated() {
            if generation != scanGeneration {
                status = "Scan abgebrochen"
                busy = false
                return
            }
            status = "Gesicht · \(i + 1)/\(pending.count)"
            let image = item.preview ?? FrameExtractor.loadCGImage(url: item.url)
            guard let image else { continue }
            let mediaId = item.id
            do {
                let found = try await Task.detached(priority: .userInitiated) {
                    try FaceEngine.detect(in: image, mediaId: mediaId)
                }.value
                if generation != scanGeneration {
                    status = "Scan abgebrochen"
                    busy = false
                    return
                }
                faces.append(contentsOf: found)
            } catch {
                continue
            }
        }
        if generation != scanGeneration {
            status = "Scan abgebrochen"
            busy = false
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
        if !FaceEngine.facePrintAvailable {
            status = "Fertig · \(faces.count) Gesichter · Face-Print nicht verfügbar — nur Geometrie"
        } else if !faces.isEmpty, emptyPrints == faces.count {
            status = "Fertig · \(faces.count) Gesichter · Face-Print leer — nur Geometrie"
        } else {
            status = "Fertig · \(faces.count) Gesichter"
        }
        busy = false
    }

    func rematch() {
        matches = FaceEngine.match(
            faces: faces,
            identities: identities,
            media: media,
            threshold: threshold,
            enabled: enabled
        )
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
        guard let face = FaceEngine.faceForNewIdentity(
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
        if let why = FaceEngine.referenceRejected(face, asFirstReference: true) {
            status = why
            return
        }
        if let dup = FaceEngine.duplicateOf(face: face, identities: identities, faces: faces) {
            if pendingDuplicateName != name {
                pendingDuplicateName = name
                status = "Ähnlich \(dup.0.name) (\(Int(dup.1 * 100)) %). Nochmal Anlegen bestätigt, sonst anderen Namen."
                return
            }
        }
        pendingDuplicateName = nil
        let preview = FaceEngine.enrollmentPreview(face: face, identities: identities, faces: faces)
        let note = preview.isEmpty ? "" : " · \(preview)"
        identities.append(Identity(id: UUID(), name: name, faceIds: [face.id]))
        newPersonName = ""
        selectedFaceId = face.id
        rematch()
        if let next = FaceEngine.unnamedFace(on: face.mediaId, faces: faces, identities: identities) {
            selectedFaceId = next.id
            status = "\(name) angelegt · nächstes Gesicht gewählt\(note)"
        } else {
            status = "\(name) angelegt\(note)"
        }
        persist()
    }

    func addSelectedTo(_ identityId: UUID) {
        let typed = newPersonName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !typed.isEmpty {
            createIdentity()
            return
        }
        guard let face = selectedFace else { return }
        guard let idx = identities.firstIndex(where: { $0.id == identityId }) else { return }
        if let owner = FaceEngine.identityOwning(face: face, identities: identities, faces: faces) {
            if owner.id == identityId {
                status = "Dieses Gesicht ist schon Referenz von \(owner.name)"
                return
            }
            status = "Dieses Gesicht gehört zu \(owner.name). Anlegen für eine neue Person, nicht +."
            return
        }
        if let why = FaceEngine.referenceRejected(face, asFirstReference: identities[idx].faceIds.isEmpty) {
            status = why
            return
        }
        if let block = FaceEngine.poseCoverageBlocks(adding: face, to: identities[idx], faces: faces) {
            status = block + " — anderes Pose-Foto wählen, nicht denselben Slot füllen."
            return
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
        rematch()
        persist()
        if preview.isEmpty {
            status = "Referenz zu \(identities[idx].name) hinzugefügt"
        } else {
            status = "Referenz zu \(identities[idx].name) · \(preview)"
        }
    }

    func removeIdentity(_ id: UUID) {
        identities.removeAll { $0.id == id }
        persist()
        rematch()
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
            self?.status = "Live"
        }
        liveCapture.onError = { [weak self] msg in
            self?.status = msg
            self?.liveActive = false
        }
        liveCapture.onFrame = { [weak self] image in
            self?.ingestLiveFrame(image, mediaId: id)
        }
        liveCapture.start(url: url, kind: kind)
    }

    private func ingestLiveFrame(_ image: CGImage, mediaId: UUID) {
        if liveBusy { return }
        liveBusy = true
        Task.detached(priority: .userInitiated) { [weak self] in
            let found = (try? FaceEngine.detect(in: image, mediaId: mediaId, tiles: false)) ?? []
            await MainActor.run {
                guard let self else { return }
                self.applyLiveFaces(found, image: image, mediaId: mediaId)
                self.liveBusy = false
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
        var bestC = 0.72
        var seen = Set<UUID>()
        for old in pool where !used.contains(old.id) && !seen.contains(old.id) {
            seen.insert(old.id)
            let ov = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
            guard ov.count == v.count else { continue }
            let c = MatchMath.cosine(v, ov)
            if c > bestC {
                bestC = c
                best = old
            }
        }
        return best
    }

    private func applyLiveFaces(_ found: [FaceObservation], image: CGImage, mediaId: UUID) {
        liveCapture.setFacesPresent(!found.isEmpty)
        guard let idx = media.firstIndex(where: { $0.id == mediaId }) else { return }
        media[idx].width = image.width
        media[idx].height = image.height
        media[idx].preview = image
        let enrolled = Set(identities.flatMap(\.faceIds))
        let previous = faces.filter { $0.mediaId == mediaId }
        var used = Set<UUID>()
        var adopted: [FaceObservation] = []
        adopted.reserveCapacity(found.count)
        for var face in found {
            var best: FaceObservation?
            var bestIoU = 0.0
            var bestEnrolled = false
            for old in previous where !used.contains(old.id) {
                let o = FaceEngine.iou(old.box, face.box)
                let pin = enrolled.contains(old.id)
                let enough = pin ? o >= 0.12 : o >= 0.18
                guard enough else { continue }
                if pin && !bestEnrolled {
                    best = old
                    bestIoU = o
                    bestEnrolled = true
                } else if pin == bestEnrolled, o > bestIoU {
                    best = old
                    bestIoU = o
                }
            }
            if let old = best {
                used.insert(old.id)
                face.id = old.id
                face.trackId = old.trackId ?? old.id
                face.box = FaceBox(
                    x: 0.62 * old.box.x + 0.38 * face.box.x,
                    y: 0.62 * old.box.y + 0.38 * face.box.y,
                    width: 0.62 * old.box.width + 0.38 * face.box.width,
                    height: 0.62 * old.box.height + 0.38 * face.box.height
                )
                if face.featurePrint.isEmpty, !old.featurePrint.isEmpty {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec
                } else if !old.featurePrint.isEmpty, face.quality.capture + 0.04 < old.quality.capture {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                } else if !old.featurePrint.isEmpty, !face.featurePrint.isEmpty {
                    let prev = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
                    let next = FaceEngine.embedding(of: face)
                    face.printVec = FaceEngine.blendEmbeddings(prev, next, alpha: 0.35)
                } else if face.printVec.isEmpty {
                    face.printVec = FaceEngine.embedding(of: face)
                }
            } else if let old = pinByPrint(face, pool: previous + reconnectGhosts + liveGhosts.map(\.face), used: used) {
                used.insert(old.id)
                face.id = old.id
                face.trackId = old.trackId ?? old.id
                if face.featurePrint.isEmpty, !old.featurePrint.isEmpty {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                } else if !old.printVec.isEmpty, !face.featurePrint.isEmpty {
                    face.printVec = FaceEngine.blendEmbeddings(old.printVec, FaceEngine.embedding(of: face), alpha: 0.35)
                }
            }
            adopted.append(face)
        }
        let now = Date().timeIntervalSince1970
        liveGhosts.removeAll { $0.until < now }
        if found.isEmpty {
            for old in previous where !enrolled.contains(old.id) {
                liveGhosts.append((old, now + 1.8))
            }
        }
        var leftoverPinned = previous.filter { enrolled.contains($0.id) && !used.contains($0.id) }
        if found.isEmpty {
            faces.removeAll { $0.mediaId == mediaId }
            faces.append(contentsOf: leftoverPinned + adopted)
        } else {
            for old in leftoverPinned {
                var bestJ = -1
                var bestD = 0.08
                for (j, face) in adopted.enumerated() where !used.contains(face.id) {
                    let o = FaceEngine.iou(old.box, face.box)
                    if o > bestD {
                        bestD = o
                        bestJ = j
                    }
                }
                if bestJ >= 0 {
                    used.insert(old.id)
                    adopted[bestJ].id = old.id
                    adopted[bestJ].trackId = old.trackId ?? old.id
                    if adopted[bestJ].featurePrint.isEmpty {
                        adopted[bestJ].featurePrint = old.featurePrint
                    }
                    if adopted[bestJ].printVec.isEmpty, !old.printVec.isEmpty {
                        adopted[bestJ].printVec = old.printVec
                    }
                }
            }
            faces.removeAll { $0.mediaId == mediaId }
            faces.append(contentsOf: adopted)
        }
        if selectedMediaId == mediaId {
            selectedFaceId = adopted.first?.id ?? leftoverPinned.first?.id
        }
        reconnectGhosts.removeAll { used.contains($0.id) }
        nmsDropped = FaceEngine.lastNMSDropped
        rematch()
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
                lines.append("\(row.faceId.uuidString),\(hit.strategy.label),\(name),\(String(format: "%.1f", hit.percent))")
            }
        }
        try? lines.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
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
        busy = true
        status = "Laborbericht"
        Task.detached {
            let text = LabReport.text(
                faces: faces,
                identities: identities,
                media: media,
                enabled: enabled,
                threshold: threshold
            )
            await MainActor.run {
                try? text.write(to: url, atomically: true, encoding: .utf8)
                self.busy = false
                self.status = "Laborbericht gespeichert"
            }
        }
    }
}
