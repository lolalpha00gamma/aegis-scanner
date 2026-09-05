import Foundation

/// Ein-Klick-LFW. Fotos dürfen nicht auf GitHub (Lizenz der Originalfotografen).
enum BenchFetch {
    static let figshare = URL(string: "https://ndownloader.figshare.com/files/5976018")!
    static let umass = URL(string: "http://vis-www.cs.umass.edu/lfw/lfw.tgz")!
    static let smokePeople = [
        "George_W_Bush", "Colin_Powell", "Tony_Blair", "Donald_Rumsfeld",
        "Gerhard_Schroeder", "Ariel_Sharon", "Hugo_Chavez", "Junichiro_Koizumi",
        "Jean_Chretien", "John_Ashcroft", "Jacques_Chirac", "Serena_Williams"
    ]

    enum FetchError: LocalizedError {
        case download
        case extract
        case empty
        var errorDescription: String? {
            switch self {
            case .download: return "LFW-Download fehlgeschlagen (Netz?)."
            case .extract: return "Entpacken fehlgeschlagen."
            case .empty: return "Nach dem Entpacken keine Gesichter gefunden."
            }
        }
    }

    static func root() -> URL {
        let fm = FileManager.default
        if let dl = fm.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            return dl.appendingPathComponent("AegisBench")
        }
        let support = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support")
        return support.appendingPathComponent("Aegis/AegisBench")
    }

    static func ident20URL() -> URL { root().appendingPathComponent("ident20") }

    static func ident20Ready() -> Bool {
        let url = ident20URL()
        guard let people = try? FileManager.default.contentsOfDirectory(
            at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]
        ) else { return false }
        return people.filter { $0.lastPathComponent != "pairs.txt" }.count >= 20
    }

    static func install(progress: @escaping @Sendable (String) -> Void) async throws -> URL {
        let fm = FileManager.default
        let dest = root()
        try fm.createDirectory(at: dest, withIntermediateDirectories: true)
        copyPairs(to: dest)

        let lfw = try await ensureLFW(in: dest, progress: progress)
        progress("Baue ident20 (Personen mit ≥20 Fotos) …")
        try slice(from: lfw, to: dest.appendingPathComponent("ident20"), minPhotos: 20, maxPhotos: 20)
        progress("Baue ident10 …")
        try slice(from: lfw, to: dest.appendingPathComponent("ident10"), minPhotos: 10, maxPhotos: 20)
        progress("Baue smoke …")
        try sliceSmoke(from: lfw, to: dest.appendingPathComponent("smoke"))
        copyPairs(to: dest.appendingPathComponent("ident20"))
        copyPairs(to: dest.appendingPathComponent("ident10"))
        copyPairs(to: dest.appendingPathComponent("smoke"))
        guard ident20Ready() else { throw FetchError.empty }
        return ident20URL()
    }

    private static func ensureLFW(in dest: URL, progress: @escaping @Sendable (String) -> Void) async throws -> URL {
        let fm = FileManager.default
        for name in ["lfw", "lfw_funneled"] {
            let url = dest.appendingPathComponent(name)
            if fm.fileExists(atPath: url.appendingPathComponent("George_W_Bush").path) {
                return url
            }
        }
        let tgz = dest.appendingPathComponent("lfw.tgz")
        if !fm.fileExists(atPath: tgz.path) {
            progress("Lade LFW (~170 MB, einmalig) …")
            var last: Error = FetchError.download
            for url in [figshare, umass] {
                do {
                    try await download(url, to: tgz)
                    break
                } catch {
                    last = error
                    try? fm.removeItem(at: tgz)
                }
            }
            guard fm.fileExists(atPath: tgz.path) else { throw last }
        }
        progress("Entpacke LFW …")
        try extract(tgz, into: dest)
        for name in ["lfw", "lfw_funneled"] {
            let url = dest.appendingPathComponent(name)
            if fm.fileExists(atPath: url.appendingPathComponent("George_W_Bush").path) {
                return url
            }
        }
        throw FetchError.empty
    }

    private static func download(_ url: URL, to dest: URL) async throws {
        let (tmp, response) = try await URLSession.shared.download(from: url)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw FetchError.download
        }
        let fm = FileManager.default
        if fm.fileExists(atPath: dest.path) { try fm.removeItem(at: dest) }
        try fm.moveItem(at: tmp, to: dest)
        let size = (try? dest.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        if size < 1_000_000 {
            try? fm.removeItem(at: dest)
            throw FetchError.download
        }
    }

    private static func extract(_ tgz: URL, into dest: URL) throws {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
        p.arguments = ["-xzf", tgz.path, "-C", dest.path]
        p.standardOutput = FileHandle.nullDevice
        p.standardError = FileHandle.nullDevice
        try p.run()
        p.waitUntilExit()
        guard p.terminationStatus == 0 else {
            try? FileManager.default.removeItem(at: tgz)
            throw FetchError.extract
        }
    }

    static func slice(from lfw: URL, to dest: URL, minPhotos: Int, maxPhotos: Int) throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: dest.path) { try fm.removeItem(at: dest) }
        try fm.createDirectory(at: dest, withIntermediateDirectories: true)
        let people = try fm.contentsOfDirectory(
            at: lfw, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]
        )
        for person in people {
            var isDir: ObjCBool = false
            fm.fileExists(atPath: person.path, isDirectory: &isDir)
            guard isDir.boolValue else { continue }
            let jpgs = ((try? fm.contentsOfDirectory(at: person, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) ?? [])
                .filter { $0.pathExtension.lowercased() == "jpg" }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
            guard jpgs.count >= minPhotos else { continue }
            let out = dest.appendingPathComponent(person.lastPathComponent)
            try fm.createDirectory(at: out, withIntermediateDirectories: true)
            for url in jpgs.prefix(maxPhotos) {
                let target = out.appendingPathComponent(url.lastPathComponent)
                if !fm.fileExists(atPath: target.path) {
                    try fm.copyItem(at: url, to: target)
                }
            }
        }
    }

    static func sliceSmoke(from lfw: URL, to dest: URL) throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: dest.path) { try fm.removeItem(at: dest) }
        try fm.createDirectory(at: dest, withIntermediateDirectories: true)
        for name in smokePeople {
            let src = lfw.appendingPathComponent(name)
            guard fm.fileExists(atPath: src.path) else { continue }
            let jpgs = ((try? fm.contentsOfDirectory(at: src, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) ?? [])
                .filter { $0.pathExtension.lowercased() == "jpg" }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
            let out = dest.appendingPathComponent(name)
            try fm.createDirectory(at: out, withIntermediateDirectories: true)
            for url in jpgs.prefix(6) {
                let target = out.appendingPathComponent(url.lastPathComponent)
                if !fm.fileExists(atPath: target.path) {
                    try fm.copyItem(at: url, to: target)
                }
            }
        }
    }

    static func copyPairs(to dest: URL) {
        let fm = FileManager.default
        try? fm.createDirectory(at: dest, withIntermediateDirectories: true)
        let target = dest.appendingPathComponent("pairs.txt")
        guard !fm.fileExists(atPath: target.path) else { return }
        if let bundled = Bundle.main.url(forResource: "pairs", withExtension: "txt") {
            try? fm.copyItem(at: bundled, to: target)
        }
    }
}
