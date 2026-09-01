import AppKit
import Combine
import Foundation
import UniformTypeIdentifiers

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
    @Published var status: String = "Bereit"
    @Published var busy = false
    @Published var newPersonName = ""
    @Published var liveURLText = ""
    @Published var liveActive = false

    private let liveCapture = LiveCapture()
    private var liveMediaId: UUID?
    private var scopedRoots: [URL] = []
    private var liveBusy = false

    init() {
        let packed = GalleryFile.load()
        identities = packed.identities
        faces = packed.faces
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
        var urls: [URL] = []
        var roots: [URL] = []
        for url in panel.urls {
            roots.append(url)
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
            if isDir.boolValue {
                _ = url.startAccessingSecurityScopedResource()
                urls.append(contentsOf: FrameExtractor.walk(folder: url))
            } else {
                urls.append(url)
            }
        }
        retainAccess(roots)
        let before = media.count
        ingest(urls: urls)
        if let firstNew = media.dropFirst(before).first(where: { $0.kind == .photo })
            ?? media.dropFirst(before).first {
            selectedMediaId = firstNew.id
        }
        Task { await scan() }
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

    func scan() async {
        busy = true
        status = "Frames extrahieren"
        let videos = media.filter { $0.kind == .video }
        let haveFrames = Set(media.compactMap { $0.parentId })
        for video in videos where !haveFrames.contains(video.id) {
            status = "Video · \(video.name)"
            do {
                let frames = try await FrameExtractor.extract(from: video.url)
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
            status = "Gesicht · \(i + 1)/\(pending.count)"
            let image = item.preview ?? FrameExtractor.loadCGImage(url: item.url)
            guard let image else { continue }
            let mediaId = item.id
            do {
                let found = try await Task.detached(priority: .userInitiated) {
                    try FaceEngine.detect(in: image, mediaId: mediaId)
                }.value
                faces.append(contentsOf: found)
            } catch {
                continue
            }
        }
        status = "Abgleich"
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
        matches = FaceEngine.match(faces: faces, identities: identities, media: media, threshold: threshold)
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
        identities.append(Identity(id: UUID(), name: name, faceIds: [face.id]))
        newPersonName = ""
        selectedFaceId = face.id
        rematch()
        if let next = FaceEngine.unnamedFace(on: face.mediaId, faces: faces, identities: identities) {
            selectedFaceId = next.id
            status = "\(name) angelegt · nächstes Gesicht gewählt"
        } else {
            status = "\(name) angelegt"
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
        if !identities[idx].faceIds.contains(face.id) {
            identities[idx].faceIds.append(face.id)
        }
        rematch()
        persist()
        status = "Referenz zu \(identities[idx].name) hinzugefügt"
    }

    func removeIdentity(_ id: UUID) {
        identities.removeAll { $0.id == id }
        persist()
        rematch()
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

    private func applyLiveFaces(_ found: [FaceObservation], image: CGImage, mediaId: UUID) {
        guard let idx = media.firstIndex(where: { $0.id == mediaId }) else { return }
        media[idx].width = image.width
        media[idx].height = image.height
        media[idx].preview = image
        let enrolled = Set(identities.flatMap(\.faceIds))
        let pinned = faces.filter { $0.mediaId == mediaId && enrolled.contains($0.id) }
        faces.removeAll { $0.mediaId == mediaId }
        faces.append(contentsOf: pinned + found)
        if selectedMediaId == mediaId {
            selectedFaceId = found.first?.id ?? pinned.first?.id
        }
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
}
