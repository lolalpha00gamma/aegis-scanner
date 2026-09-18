import Foundation

/// Reads the owner's local Find My cache on this Mac.
/// Encrypted blobs (macOS 14.4+) are reported, not decrypted.
enum FindMyCache {
    static var cacheDir: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Caches/com.apple.findmy.fmipcore", isDirectory: true)
    }

    struct Snapshot {
        var fixes: [Fix]
        var notes: [String]
    }

    static func poll() -> Snapshot {
        var notes: [String] = []
        var fixes: [Fix] = []
        let files: [(String, TrackKind)] = [
            ("Items.data", .item),
            ("Devices.data", .device),
            ("People.data", .person),
        ]
        guard FileManager.default.fileExists(atPath: cacheDir.path) else {
            notes.append("Find-My-Cache-Ordner fehlt.")
            return Snapshot(fixes: [], notes: notes)
        }
        for (name, kind) in files {
            let url = cacheDir.appendingPathComponent(name)
            guard let data = try? Data(contentsOf: url) else {
                notes.append("\(name): nicht lesbar")
                continue
            }
            if looksEncrypted(data) {
                notes.append("\(name): verschlüsselt (typisch ab macOS 14.4) — Snapshot unmöglich")
                continue
            }
            let parsed = parseJSON(data, kind: kind, file: name)
            notes.append("\(name): \(parsed.count) Position(en)")
            fixes.append(contentsOf: parsed)
        }
        return Snapshot(fixes: fixes, notes: notes)
    }

    private static func looksEncrypted(_ data: Data) -> Bool {
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return obj["encryptedData"] != nil
        }
        if data.count >= 8 {
            let head = data.prefix(8)
            if head.starts(with: [0x62, 0x70, 0x6C, 0x69, 0x73, 0x74]) { return false }
        }
        return false
    }

    private static func parseJSON(_ data: Data, kind: TrackKind, file: String) -> [Fix] {
        guard let root = try? JSONSerialization.jsonObject(with: data) else { return [] }
        var out: [Fix] = []
        func walk(_ any: Any) {
            if let arr = any as? [Any] {
                arr.forEach(walk)
                return
            }
            guard let dict = any as? [String: Any] else { return }
            if let loc = dict["location"] as? [String: Any] ?? dict["address"] as? [String: Any] {
                if let fix = fix(from: dict, loc: loc, kind: kind, file: file) {
                    out.append(fix)
                }
            }
            for v in dict.values { walk(v) }
        }
        walk(root)
        return out
    }

    private static func fix(from dict: [String: Any], loc: [String: Any], kind: TrackKind, file: String) -> Fix? {
        let lat = number(loc["latitude"] ?? loc["lat"])
        let lon = number(loc["longitude"] ?? loc["lon"] ?? loc["lng"])
        guard let lat, let lon, lat != 0 || lon != 0 else { return nil }
        let name = string(dict["name"] ?? dict["deviceDisplayName"] ?? dict["owner"] ?? dict["id"]) ?? file
        let id = string(dict["id"] ?? dict["baUUID"] ?? dict["identifier"] ?? name) ?? UUID().uuidString
        let tsRaw = number(loc["timeStamp"] ?? loc["timestamp"] ?? dict["timeStamp"] ?? dict["timestamp"])
        let ts: Date
        if let tsRaw {
            ts = tsRaw > 10_000_000_000 ? Date(timeIntervalSince1970: tsRaw / 1000) : Date(timeIntervalSince1970: tsRaw)
        } else {
            ts = Date()
        }
        return Fix(
            id: id,
            name: name,
            kind: kind,
            lat: lat,
            lon: lon,
            altitude: number(loc["altitude"]),
            accuracy: number(loc["horizontalAccuracy"] ?? loc["accuracy"]),
            timestamp: ts,
            source: file
        )
    }

    private static func number(_ any: Any?) -> Double? {
        if let d = any as? Double { return d }
        if let i = any as? Int { return Double(i) }
        if let n = any as? NSNumber { return n.doubleValue }
        if let s = any as? String { return Double(s) }
        return nil
    }

    private static func string(_ any: Any?) -> String? {
        if let s = any as? String, !s.isEmpty { return s }
        return nil
    }
}
