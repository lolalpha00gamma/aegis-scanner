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
    @Published var threshold: Double = 72
    @Published var strategy: StrategyID = .aegis
    @Published var status: String = "Bereit"
    @Published var busy = false
    @Published var newPersonName = ""

    var selectedMedia: MediaItem? {
        media.first { $0.id == selectedMediaId }
    }

    var selectedFace: FaceObservation? {
        faces.first { $0.id == selectedFaceId } ?? faces.first
    }

    var selectedHits: [StrategyHit] {
        guard let id = selectedFace?.id else { return [] }
        return matches.first { $0.faceId == id }?.hits ?? []
    }

    func pickFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.folder, .image, .movie, .jpeg, .png, .heic, .mpeg4Movie, .quickTimeMovie]
        panel.prompt = "Scannen"
        guard panel.runModal() == .OK else { return }
        var urls: [URL] = []
        for url in panel.urls {
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
            if isDir.boolValue {
                urls.append(contentsOf: FrameExtractor.walk(folder: url))
            } else {
                urls.append(url)
            }
        }
        ingest(urls: urls)
        Task { await scan() }
    }

    func ingest(urls: [URL]) {
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
            } else if FrameExtractor.isImage(url), let image = FrameExtractor.loadCGImage(url: url) {
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
            }
        }
        selectedMediaId = media.first { $0.kind == .photo }?.id ?? media.first?.id
    }

    func scan() async {
        busy = true
        status = "Frames extrahieren"
        do {
            let videos = media.filter { $0.kind == .video }
            let haveFrames = Set(media.compactMap { $0.parentId })
            for video in videos where !haveFrames.contains(video.id) {
                status = "Video · \(video.name)"
                let frames = try await FrameExtractor.extract(from: video.url)
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
            }
            let pending = media.filter { item in
                (item.kind == .photo || item.kind == .frame) && !faces.contains { $0.mediaId == item.id }
            }
            for (i, item) in pending.enumerated() {
                status = "Gesicht · \(i + 1)/\(pending.count)"
                let image: CGImage?
                if let preview = item.preview {
                    image = preview
                } else {
                    image = FrameExtractor.loadCGImage(url: item.url)
                }
                guard let image else { continue }
                let found = try FaceEngine.detect(in: image, mediaId: item.id)
                faces.append(contentsOf: found)
            }
            status = "Abgleich"
            rematch()
            if selectedFaceId == nil {
                selectedFaceId = faces.first?.id
            }
            status = "Fertig · \(faces.count) Gesichter"
        } catch {
            status = error.localizedDescription
        }
        busy = false
    }

    func rematch() {
        matches = FaceEngine.match(faces: faces, identities: identities, media: media)
    }

    func createIdentity() {
        guard let face = selectedFace else { return }
        let name = newPersonName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        identities.append(Identity(id: UUID(), name: name, faceIds: [face.id]))
        newPersonName = ""
        rematch()
    }

    func addSelectedTo(_ identityId: UUID) {
        guard let face = selectedFace else { return }
        guard let idx = identities.firstIndex(where: { $0.id == identityId }) else { return }
        if !identities[idx].faceIds.contains(face.id) {
            identities[idx].faceIds.append(face.id)
        }
        rematch()
    }

    func removeIdentity(_ id: UUID) {
        identities.removeAll { $0.id == id }
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
