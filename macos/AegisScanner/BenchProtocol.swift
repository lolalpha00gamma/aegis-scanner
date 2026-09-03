import Foundation

/// LFW View-2 und Ordner-Identifikation. Kein Vision — Tests und App teilen den Parser.
enum BenchProtocol {
    struct Pair: Equatable {
        var same: Bool
        var aName: String
        var aIndex: Int
        var bName: String
        var bIndex: Int
        var fold: Int

        func fileName(_ which: String) -> String {
            let name = which == "b" ? bName : aName
            let idx = which == "b" ? bIndex : aIndex
            return String(format: "%@_%04d.jpg", name, idx)
        }

        func relativePath(_ which: String) -> String {
            let name = which == "b" ? bName : aName
            return "\(name)/\(fileName(which))"
        }
    }

    static func parsePairs(_ text: String) -> [Pair] {
        let lines = text.split(whereSeparator: \.isNewline).map { String($0) }
        guard let header = lines.first else { return [] }
        let head = header.split(whereSeparator: { $0 == "\t" || $0 == " " }).compactMap { Int($0) }
        let folds: Int
        let per: Int
        var i = 0
        if head.count >= 2 {
            folds = max(1, head[0])
            per = max(1, head[1])
            i = 1
        } else {
            folds = 1
            per = 300
        }
        var out: [Pair] = []
        for fold in 0 ..< folds {
            for _ in 0 ..< per {
                guard i < lines.count else { return out }
                let cols = splitCols(lines[i]); i += 1
                guard cols.count >= 3, let n1 = Int(cols[1]), let n2 = Int(cols[2]) else { continue }
                out.append(Pair(same: true, aName: cols[0], aIndex: n1, bName: cols[0], bIndex: n2, fold: fold))
            }
            for _ in 0 ..< per {
                guard i < lines.count else { return out }
                let cols = splitCols(lines[i]); i += 1
                guard cols.count >= 4, let n1 = Int(cols[1]), let n2 = Int(cols[3]) else { continue }
                out.append(Pair(same: false, aName: cols[0], aIndex: n1, bName: cols[2], bIndex: n2, fold: fold))
            }
        }
        return out
    }

    static func lfwURL(root: URL, name: String, index: Int) -> URL {
        root.appendingPathComponent(name, isDirectory: true)
            .appendingPathComponent(String(format: "%@_%04d.jpg", name, index))
    }

    /// `lfw/Name/Name_0001.jpg` oder `Name/Name_0001.jpg` oder flach `Name_0001.jpg`.
    static func resolve(root: URL, name: String, index: Int) -> URL? {
        let fm = FileManager.default
        let candidates = [
            lfwURL(root: root, name: name, index: index),
            lfwURL(root: root.appendingPathComponent("lfw"), name: name, index: index),
            root.appendingPathComponent(String(format: "%@_%04d.jpg", name, index))
        ]
        return candidates.first { fm.fileExists(atPath: $0.path) }
    }

    static func findPairsFile(root: URL) -> URL? {
        let fm = FileManager.default
        let names = ["pairs.txt", "pairsDevTest.txt"]
        var dirs = [root, root.deletingLastPathComponent()]
        if root.lastPathComponent == "lfw" || root.lastPathComponent == "smoke"
            || root.lastPathComponent.hasPrefix("ident") {
            dirs.append(root.deletingLastPathComponent())
        }
        dirs.append(root.appendingPathComponent("bench"))
        for dir in dirs {
            for name in names {
                let url = dir.appendingPathComponent(name)
                if fm.fileExists(atPath: url.path) { return url }
            }
        }
        return nil
    }

    static func personFolders(root: URL) -> [URL] {
        let fm = FileManager.default
        let skip: Set<String> = [".", "..", "bench", "data"]
        guard let kids = try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) else {
            return []
        }
        var folders = kids.filter { url in
            var isDir: ObjCBool = false
            fm.fileExists(atPath: url.path, isDirectory: &isDir)
            return isDir.boolValue && !skip.contains(url.lastPathComponent)
        }
        if folders.count == 1, folders[0].lastPathComponent == "lfw" {
            return personFolders(root: folders[0])
        }
        folders.sort { a, b in
            imageCount(a) > imageCount(b)
        }
        return folders
    }

    /// Volle LFW hat 5749 Ordner, die meisten mit 1 Foto. Dann: nur Personen mit
    /// genug Bildern. Liegen ≥`cap` Leute mit 20 Fotos vor, nimm die; sonst min 10.
    static func identificationCut(counts: [Int], cap: Int) -> (minPhotos: Int, kept: Int) {
        let n2 = counts.filter { $0 >= 2 }.count
        if counts.count <= cap {
            return (2, min(cap, n2))
        }
        let n10 = counts.filter { $0 >= 10 }.count
        let n20 = counts.filter { $0 >= 20 }.count
        if n20 >= cap {
            return (20, cap)
        }
        if n10 > 0 {
            return (10, min(cap, n10))
        }
        return (2, min(cap, n2))
    }

    static func selectPeople(_ folders: [URL], cap: Int) -> (urls: [URL], minPhotos: Int) {
        let counts = folders.map { imageCount($0) }
        let cut = identificationCut(counts: counts, cap: cap)
        let picked = folders.filter { imageCount($0) >= cut.minPhotos }
        return (Array(picked.prefix(cap)), cut.minPhotos)
    }

    static func imageCount(_ folder: URL) -> Int {
        let fm = FileManager.default
        let exts: Set<String> = ["jpg", "jpeg", "png", "heic", "pgm", "webp"]
        guard let kids = try? fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return 0
        }
        return kids.filter { exts.contains($0.pathExtension.lowercased()) }.count
    }

    static func images(in folder: URL, limit: Int = 6) -> [URL] {
        let fm = FileManager.default
        let exts: Set<String> = ["jpg", "jpeg", "png", "heic", "pgm", "webp"]
        guard let kids = try? fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return []
        }
        return kids
            .filter { exts.contains($0.pathExtension.lowercased()) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .prefix(limit)
            .map { $0 }
    }

    static func accuracy(scores: [Double], same: [Bool], threshold: Double) -> Double {
        guard scores.count == same.count, !scores.isEmpty else { return 0 }
        var ok = 0
        for i in scores.indices {
            let accept = scores[i] >= threshold
            if accept == same[i] { ok += 1 }
        }
        return Double(ok) / Double(scores.count)
    }

    private static func splitCols(_ line: String) -> [String] {
        line.split(whereSeparator: { $0 == "\t" || $0 == " " }).map(String.init)
    }
}

/// Fortschritt aus einem Detached-Task, ohne MainActor einzufangen.
final class BenchProgress: @unchecked Sendable {
    private let lock = NSLock()
    private var n = 0
    private var total = 1
    private var finished = false

    func set(_ n: Int, _ total: Int) {
        lock.lock()
        self.n = n
        self.total = max(1, total)
        lock.unlock()
    }

    func finish() {
        lock.lock()
        finished = true
        lock.unlock()
    }

    var isFinished: Bool {
        lock.lock(); defer { lock.unlock() }
        return finished
    }

    var label: String {
        lock.lock(); defer { lock.unlock() }
        return "Testmodus · Verifikation \(n)/\(total)"
    }
}
