import Foundation

enum ProbeState: String {
    case none
    case enrolled
    case candidate
    case unknown
    case unfit
}

struct GalleryPayload: Codable {
    var identities: [Identity]
    var faces: [FaceObservation]
    var printRevision: String?
}

enum GalleryFile {
    static var directory: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Aegis", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static var url: URL {
        directory.appendingPathComponent("gallery.json")
    }

    static func load() -> (identities: [Identity], faces: [FaceObservation], printRevision: String?) {
        guard let data = try? Data(contentsOf: url) else { return ([], [], nil) }
        if let payload = try? JSONDecoder().decode(GalleryPayload.self, from: data) {
            return (payload.identities, payload.faces, payload.printRevision)
        }
        if let identities = try? JSONDecoder().decode([Identity].self, from: data) {
            return (identities, [], nil)
        }
        return ([], [], nil)
    }

    static func save(identities: [Identity], faces: [FaceObservation]) {
        let enrolled = Set(identities.flatMap(\.faceIds))
        let payload = GalleryPayload(
            identities: identities,
            faces: faces.filter { enrolled.contains($0.id) },
            printRevision: MatchMath.printRevision
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(payload) else { return }
        try? data.write(to: url, options: .atomic)
    }
}

enum IdentityDesk {
    static func probeState(
        face: FaceObservation?,
        identities: [Identity],
        matches: [MatchResult],
        threshold: Double,
        continuity: Bool = false
    ) -> ProbeState {
        guard let face else { return .none }
        if identities.contains(where: { $0.faceIds.contains(face.id) }) {
            return .enrolled
        }
        if FaceEngine.qualityRejects(face.quality, continuity: continuity) {
            return .unfit
        }
        if let top = topCandidate(faceId: face.id, matches: matches), top.percent >= threshold {
            return .candidate
        }
        return .unknown
    }

    static func topCandidate(faceId: UUID, matches: [MatchResult]) -> IdentityScore? {
        let hits = matches.first { $0.faceId == faceId }?.hits ?? []
        let row = hits.first { $0.strategy == .aegis } ?? hits.first { $0.strategy == .featurePrint }
        return row?.versus.first
    }

    static func rankedCandidates(faceId: UUID, matches: [MatchResult]) -> [IdentityScore] {
        let hits = matches.first { $0.faceId == faceId }?.hits ?? []
        let row = hits.first { $0.strategy == .aegis } ?? hits.first { $0.strategy == .featurePrint }
        return Array((row?.versus ?? []).prefix(3))
    }
}
