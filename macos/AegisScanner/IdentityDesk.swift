import CryptoKit
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
    var schemaVersion: Int?
    var leftoverStreakSince: [String: Double]?
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

    static var backupURL: URL {
        directory.appendingPathComponent("gallery.json.bak")
    }

    static func load() -> (identities: [Identity], faces: [FaceObservation], printRevision: String?, schemaVersion: Int?, leftoverStreakSince: [String: Double]?) {
        decode(url) ?? ([], [], nil, nil, nil)
    }

    static var backupExists: Bool {
        FileManager.default.fileExists(atPath: backupURL.path)
    }

    static func loadBackup() -> (identities: [Identity], faces: [FaceObservation], printRevision: String?, schemaVersion: Int?, leftoverStreakSince: [String: Double]?)? {
        decode(backupURL)
    }

    static func backupAgeDays(now: Date = Date()) -> Double? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: backupURL.path),
              let date = attrs[.modificationDate] as? Date
        else { return nil }
        return now.timeIntervalSince(date) / 86_400
    }

    private static func decode(_ file: URL) -> (identities: [Identity], faces: [FaceObservation], printRevision: String?, schemaVersion: Int?, leftoverStreakSince: [String: Double]?)? {
        guard let data = try? Data(contentsOf: file) else { return nil }
        if let payload = try? JSONDecoder().decode(GalleryPayload.self, from: data) {
            return (payload.identities, payload.faces, payload.printRevision, payload.schemaVersion, payload.leftoverStreakSince)
        }
        if let identities = try? JSONDecoder().decode([Identity].self, from: data) {
            return (identities, [], nil, nil, nil)
        }
        return nil
    }

    static func save(identities: [Identity], faces: [FaceObservation], leftoverStreakSince: [String: Double]? = nil) {
        let enrolled = Set(identities.flatMap(\.faceIds))
        let payload = GalleryPayload(
            identities: identities,
            faces: faces.filter { enrolled.contains($0.id) },
            printRevision: MatchMath.printRevision,
            schemaVersion: MatchMath.gallerySchema,
            leftoverStreakSince: leftoverStreakSince
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(payload) else { return }
        let fm = FileManager.default
        if fm.fileExists(atPath: url.path) {
            try? fm.removeItem(at: backupURL)
            try? fm.copyItem(at: url, to: backupURL)
            if let fh = FileHandle(forUpdatingAtPath: backupURL.path) {
                try? fh.synchronize()
                try? fh.close()
            }
        }
        let tmp = url.appendingPathExtension("tmp")
        do {
            try data.write(to: tmp, options: [])
            let fh = try FileHandle(forWritingTo: tmp)
            try fh.synchronize()
            try fh.close()
            _ = try fm.replaceItemAt(url, withItemAt: tmp)
            writeDigest(data)
        } catch {
            try? data.write(to: url, options: .atomic)
            try? fm.removeItem(at: tmp)
            writeDigest(data)
        }
    }

    private static func writeDigest(_ data: Data) {
        let hex = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        let short = MatchMath.digestShort(hex)
        try? short.write(to: url.appendingPathExtension("sha256"), atomically: true, encoding: .utf8)
    }

    static var sidecarURL: URL {
        url.appendingPathExtension("sha256")
    }

    static func digestStatus() -> (ok: Bool, missing: Bool) {
        guard let data = try? Data(contentsOf: url) else { return (true, true) }
        let hex = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        let computed = MatchMath.digestShort(hex)
        let sidecar = try? String(contentsOf: sidecarURL, encoding: .utf8)
        return MatchMath.shaSidecarStatus(computed: computed, sidecar: sidecar)
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

    /// Centroid 0,89–0,94: Merge-Vorschlag, nie still taufen.
    static func mergePairs(
        identities: [Identity],
        gallery: [FaceObservation]
    ) -> [(keep: UUID, drop: UUID, cosine: Double, keepName: String, dropName: String)] {
        var out: [(keep: UUID, drop: UUID, cosine: Double, keepName: String, dropName: String)] = []
        guard identities.count >= 2 else { return out }
        var cents: [UUID: [Double]] = [:]
        for ident in identities {
            let owned = gallery.filter { ident.faceIds.contains($0.id) }
            let v = FaceEngine.liveCentroid(owned)
            if v.count >= 32 { cents[ident.id] = v }
        }
        for i in 0..<identities.count {
            for j in (i + 1)..<identities.count {
                let a = identities[i]
                let b = identities[j]
                guard let va = cents[a.id], let vb = cents[b.id], va.count == vb.count else { continue }
                let c = MatchMath.cosine(va, vb)
                guard MatchMath.mergeSuggest(pairCosine: c) else { continue }
                if a.faceIds.count >= b.faceIds.count {
                    out.append((a.id, b.id, c, a.name, b.name))
                } else {
                    out.append((b.id, a.id, c, b.name, a.name))
                }
            }
        }
        out.sort { $0.cosine > $1.cosine }
        return out
    }
}
