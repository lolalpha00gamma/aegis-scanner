import Foundation

enum ProbeState: String {
    case none
    case enrolled
    case candidate
    case unknown
    case unfit
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

    static func load() -> [Identity] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([Identity].self, from: data)) ?? []
    }

    static func save(_ identities: [Identity]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(identities) else { return }
        try? data.write(to: url, options: .atomic)
    }
}

enum IdentityDesk {
    static func probeState(
        face: FaceObservation?,
        identities: [Identity],
        matches: [MatchResult],
        threshold: Double
    ) -> ProbeState {
        guard let face else { return .none }
        if identities.contains(where: { $0.faceIds.contains(face.id) }) {
            return .enrolled
        }
        if FaceEngine.qualityRejects(face.quality) {
            return .unfit
        }
        if let top = topCandidate(faceId: face.id, matches: matches), top.percent >= threshold {
            return .candidate
        }
        return .unknown
    }

    static func topCandidate(faceId: UUID, matches: [MatchResult]) -> IdentityScore? {
        let hits = matches.first { $0.faceId == faceId }?.hits ?? []
        let row = hits.first { $0.strategy == .featurePrint } ?? hits.first { $0.strategy == .aegis }
        return row?.versus.first
    }

    static func rankedCandidates(faceId: UUID, matches: [MatchResult]) -> [IdentityScore] {
        let hits = matches.first { $0.faceId == faceId }?.hits ?? []
        let row = hits.first { $0.strategy == .featurePrint } ?? hits.first { $0.strategy == .aegis }
        return Array((row?.versus ?? []).prefix(3))
    }
}
