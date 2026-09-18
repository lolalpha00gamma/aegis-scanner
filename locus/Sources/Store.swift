import Foundation

final class HistoryStore {
    static let shared = HistoryStore()

    private let url: URL
    private let q = DispatchQueue(label: "gamma.locus.store")

    private init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("Locus", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        url = dir.appendingPathComponent("history.json")
    }

    func load() -> [Fix] {
        q.sync {
            guard let data = try? Data(contentsOf: url) else { return [] }
            let dec = JSONDecoder()
            dec.dateDecodingStrategy = .iso8601
            return (try? dec.decode([Fix].self, from: data)) ?? []
        }
    }

    func save(_ fixes: [Fix]) {
        q.async {
            let enc = JSONEncoder()
            enc.outputFormatting = [.prettyPrinted, .sortedKeys]
            enc.dateEncodingStrategy = .iso8601
            guard let data = try? enc.encode(fixes) else { return }
            try? data.write(to: self.url, options: .atomic)
        }
    }

    func appendUnique(_ incoming: [Fix], into existing: inout [Fix]) -> Int {
        var seen = Set(existing.map { "\($0.id)|\($0.timestamp.timeIntervalSince1970)|\($0.lat)|\($0.lon)" })
        var added = 0
        for f in incoming {
            let k = "\(f.id)|\(f.timestamp.timeIntervalSince1970)|\(f.lat)|\(f.lon)"
            if seen.insert(k).inserted {
                existing.append(f)
                added += 1
            }
        }
        existing.sort { $0.timestamp < $1.timestamp }
        if existing.count > 50_000 {
            existing = Array(existing.suffix(50_000))
        }
        return added
    }
}
