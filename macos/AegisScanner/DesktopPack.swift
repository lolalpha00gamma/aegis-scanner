import Foundation

/// Schreibtisch-Pack: `~/Desktop/AegisTest/PersonName/*.jpg`
/// Download: GitHub Release-Asset `AegisTest.zip`.
enum DesktopPack {
    static let folderName = "AegisTest"
    static let zipName = "AegisTest.zip"
    static let releaseURL = URL(
        string: "https://github.com/lolalpha00gamma/aegis-scanner/releases/latest/download/AegisTest.zip"
    )!

    enum PackError: LocalizedError {
        case download
        case unzip
        case format(String)
        var errorDescription: String? {
            switch self {
            case .download: return "AegisTest.zip vom Release nicht geladen (Netz?)."
            case .unzip: return "AegisTest.zip ließ sich nicht entpacken."
            case .format(let s): return s
            }
        }
    }

    static func desktop() -> URL {
        FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Desktop")
    }

    static func downloads() -> URL {
        FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Downloads")
    }

    static func folderURL() -> URL {
        for root in [desktop(), downloads()] {
            let url = root.appendingPathComponent(folderName)
            if !people(in: url).isEmpty { return url }
        }
        return desktop().appendingPathComponent(folderName)
    }

    static func zipURL() -> URL {
        let onDesk = desktop().appendingPathComponent(zipName)
        if FileManager.default.fileExists(atPath: onDesk.path) { return onDesk }
        return downloads().appendingPathComponent(zipName)
    }

    static func exists() -> Bool {
        !people(in: folderURL()).isEmpty
    }

    static func people(in root: URL) -> [URL] {
        BenchProtocol.personFolders(root: root).filter { BenchProtocol.imageCount($0) >= 2 }
    }

    static func validate(_ root: URL) throws {
        let found = people(in: root)
        guard !found.isEmpty else {
            throw PackError.format(
                "Kein gültiges Pack. Erwartet: \(folderName)/PersonName/foto.jpg — mindestens 2 Fotos je Person."
            )
        }
    }

    /// Vorhandenes Pack, sonst ZIP auf dem Schreibtisch, sonst Release-Download.
    static func ensure(progress: @escaping @Sendable (String) -> Void) async throws -> URL {
        let fm = FileManager.default
        let folder = folderURL()
        if exists() {
            try validate(folder)
            return folder
        }
        let zip = zipURL()
        if fm.fileExists(atPath: zip.path) {
            let dest = zip.deletingLastPathComponent()
            progress("Entpacke \(zipName) …")
            try unzip(zip, into: dest)
            let out = dest.appendingPathComponent(folderName)
            try validate(out)
            return out
        }
        progress("Lade \(zipName) vom GitHub-Release …")
        let destZip = desktop().appendingPathComponent(zipName)
        do {
            try await download(releaseURL, to: destZip)
            progress("Entpacke auf den Schreibtisch …")
            try unzip(destZip, into: desktop())
            let out = desktop().appendingPathComponent(folderName)
            try validate(out)
            return out
        } catch {
            let dlZip = downloads().appendingPathComponent(zipName)
            try await download(releaseURL, to: dlZip)
            progress("Entpacke nach Downloads …")
            try unzip(dlZip, into: downloads())
            let out = downloads().appendingPathComponent(folderName)
            try validate(out)
            return out
        }
    }

    private static func download(_ url: URL, to dest: URL) async throws {
        let (tmp, response) = try await URLSession.shared.download(from: url)
        if let http = response as? HTTPURLResponse, !(200 ..< 300).contains(http.statusCode) {
            throw PackError.download
        }
        let fm = FileManager.default
        if fm.fileExists(atPath: dest.path) { try fm.removeItem(at: dest) }
        try fm.moveItem(at: tmp, to: dest)
        let size = (try? dest.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        if size < 10_000 {
            try? fm.removeItem(at: dest)
            throw PackError.download
        }
    }

    private static func unzip(_ zip: URL, into dest: URL) throws {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        p.arguments = ["-o", "-q", zip.path, "-d", dest.path]
        p.standardOutput = FileHandle.nullDevice
        p.standardError = FileHandle.nullDevice
        try p.run()
        p.waitUntilExit()
        guard p.terminationStatus == 0 else { throw PackError.unzip }
        let nested = dest.appendingPathComponent(folderName).appendingPathComponent(folderName)
        if FileManager.default.fileExists(atPath: nested.path) {
            try? FileManager.default.removeItem(at: dest.appendingPathComponent(folderName))
            try FileManager.default.moveItem(at: nested, to: dest.appendingPathComponent(folderName))
        }
    }
}
