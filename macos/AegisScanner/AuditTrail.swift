import CryptoKit
import Foundation

/// Append-only JSONL mit Hash-Kette. Keine stille Namensvergabe ohne Spur.
enum AuditTrail {
    private static let lock = NSLock()
    private static var lastHash: String = "0"

    private static var url: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Aegis", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("audit.jsonl")
    }

    struct Event: Codable {
        var ts: Double
        var prevHash: String
        var hash: String
        var faceId: String
        var identityId: String?
        var identityName: String?
        var percent: Double
        var sface: Double?
        var facePrint: Double?
        var geo2d: Double?
        var geo3d: Double?
        var note: String
        var galleryN: Int
        var autoNamed: Bool
        var review: Bool
    }

    static func append(
        faceId: UUID,
        identityId: UUID?,
        identityName: String?,
        percent: Double,
        sface: Double?,
        facePrint: Double?,
        geo2d: Double?,
        geo3d: Double?,
        note: String,
        galleryN: Int,
        autoNamed: Bool,
        review: Bool
    ) {
        lock.lock()
        defer { lock.unlock() }
        var ev = Event(
            ts: Date().timeIntervalSince1970,
            prevHash: lastHash,
            hash: "",
            faceId: faceId.uuidString,
            identityId: identityId?.uuidString,
            identityName: identityName,
            percent: percent,
            sface: sface,
            facePrint: facePrint,
            geo2d: geo2d,
            geo3d: geo3d,
            note: note,
            galleryN: galleryN,
            autoNamed: autoNamed,
            review: review
        )
        ev.hash = digest(ev)
        lastHash = ev.hash
        guard let data = try? JSONEncoder().encode(ev),
              var line = String(data: data, encoding: .utf8)
        else { return }
        line.append("\n")
        let trimmed = MatchMath.falseAcceptJSONLTrim(
            ((try? String(contentsOf: url, encoding: .utf8)) ?? "") + line,
            cap: 4000
        )
        try? trimmed.write(to: url, atomically: true, encoding: .utf8)
    }

    static func log(matches: [MatchResult], identities: [Identity], galleryN: Int) {
        let named = Dictionary(uniqueKeysWithValues: identities.map { ($0.id, $0.name) })
        for row in matches {
            guard let hit = row.hits.first(where: { $0.strategy == .aegis }) else { continue }
            let sface = row.hits.first(where: { $0.strategy == .sface })
            let print = row.hits.first(where: { $0.strategy == .featurePrint })
            let geo = row.hits.first(where: { $0.strategy == .ratios })
            let g3 = row.hits.first(where: { $0.strategy == .geom3d })
            let review = hit.note.contains("Prüfen") || hit.identityId == nil && hit.percent >= 70
            guard hit.identityId != nil || review else { continue }
            append(
                faceId: row.faceId,
                identityId: hit.identityId,
                identityName: hit.identityId.flatMap { named[$0] },
                percent: hit.percent,
                sface: sface?.percent,
                facePrint: print?.percent,
                geo2d: geo?.percent,
                geo3d: g3?.percent,
                note: hit.note,
                galleryN: galleryN,
                autoNamed: hit.identityId != nil,
                review: review
            )
        }
    }

    private static func digest(_ ev: Event) -> String {
        let raw = String(
            format: "%.3f|%@|%@|%@|%.2f|%d|%d|%@",
            ev.ts, ev.prevHash, ev.faceId, ev.identityId ?? "-",
            ev.percent, ev.galleryN, ev.autoNamed ? 1 : 0, ev.note
        )
        let d = SHA256.hash(data: Data(raw.utf8))
        return d.prefix(8).map { String(format: "%02x", $0) }.joined()
    }
}
