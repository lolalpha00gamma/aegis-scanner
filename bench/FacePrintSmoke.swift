import AppKit
import Foundation
import Vision

/// Standalone FacePrint auf Hugging-Face-LFW-Smoke. Kein ArcFace, kein App-Target.
/// `swiftc -parse-as-library bench/FacePrintSmoke.swift -o /tmp/faceprintsmoke -framework AppKit -framework Vision`
@main
enum FacePrintSmoke {
    static func main() {
        let env = ProcessInfo.processInfo.environment["AEGIS_SMOKE_DIR"] ?? "bench/data/smoke"
        let root = URL(fileURLWithPath: env, isDirectory: true)
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: root.path, isDirectory: &isDir), isDir.boolValue else {
            fputs("FacePrintSmoke: Ordner fehlt \(root.path)\n", stderr)
            exit(1)
        }
        guard NSClassFromString("VNGenerateFacePrintRequest") != nil else {
            fputs("FacePrintSmoke: VNGenerateFacePrintRequest fehlt\n", stderr)
            exit(1)
        }

        let people = personFolders(root)
        if people.count < 8 {
            fputs("FacePrintSmoke: nur \(people.count) Personen in \(root.path)\n", stderr)
            exit(1)
        }

        var prints: [(person: String, file: String, obs: VNFeaturePrintObservation)] = []
        var noFace = 0
        for folder in people {
            let person = folder.lastPathComponent
            for url in images(in: folder) {
                if let obs = facePrint(url: url) {
                    prints.append((person, url.lastPathComponent, obs))
                } else {
                    noFace += 1
                }
            }
        }
        let grouped = Dictionary(grouping: prints, by: \.person)
        let withTwo = grouped.filter { $0.value.count >= 2 }
        print("FacePrint smoke  \(people.count) Ordner  \(prints.count) Prints  kein Gesicht \(noFace)")
        if withTwo.count < 8 {
            fputs("FacePrintSmoke: nur \(withTwo.count) Personen mit ≥2 Prints\n", stderr)
            exit(1)
        }

        var genuineDist: [Double] = []
        var genuineCos: [Double] = []
        for (_, items) in withTwo {
            let a = items[0].obs
            let b = items[1].obs
            if let d = distance(a, b) { genuineDist.append(d) }
            if let c = cosine(a, b) { genuineCos.append(c) }
        }

        let firsts = withTwo.keys.sorted().compactMap { grouped[$0]?.first }
        var impostorDist: [Double] = []
        var impostorCos: [Double] = []
        for i in firsts.indices {
            for j in firsts.indices where j > i {
                if let d = distance(firsts[i].obs, firsts[j].obs) { impostorDist.append(d) }
                if let c = cosine(firsts[i].obs, firsts[j].obs) { impostorCos.append(c) }
            }
        }

        func mean(_ xs: [Double]) -> Double { xs.reduce(0, +) / Double(xs.count) }

        var ok = true
        if genuineDist.count >= 8, impostorDist.count >= 8 {
            let g = mean(genuineDist)
            let i = mean(impostorDist)
            print(String(format: "Genuine dist   n=%d  mean=%.3f", genuineDist.count, g))
            print(String(format: "Impostor dist  n=%d  mean=%.3f", impostorDist.count, i))
            if g >= i {
                fputs(String(format: "FAIL Genuine-Dist %.3f ≥ Impostor %.3f\n", g, i), stderr)
                ok = false
            }
        } else {
            fputs("FacePrintSmoke: zu wenige Distanz-Paare genuine=\(genuineDist.count) impostor=\(impostorDist.count)\n", stderr)
            ok = false
        }

        if genuineCos.count >= 8, impostorCos.count >= 8 {
            let g = mean(genuineCos)
            let i = mean(impostorCos)
            print(String(format: "Genuine cosine n=%d  mean=%.3f", genuineCos.count, g))
            print(String(format: "Impostor cosine n=%d  mean=%.3f", impostorCos.count, i))
            if g <= i {
                fputs(String(format: "FAIL Genuine-Cosine %.3f ≤ Impostor %.3f\n", g, i), stderr)
                ok = false
            }
        }

        if !ok { exit(1) }
        print("FacePrintSmoke OK")
    }

    static func personFolders(_ root: URL) -> [URL] {
        let fm = FileManager.default
        guard let kids = try? fm.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        return kids.filter { url in
            var isDir: ObjCBool = false
            fm.fileExists(atPath: url.path, isDirectory: &isDir)
            return isDir.boolValue
        }.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    static func images(in folder: URL) -> [URL] {
        let fm = FileManager.default
        let exts: Set<String> = ["jpg", "jpeg"]
        guard let kids = try? fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return []
        }
        return kids
            .filter { exts.contains($0.pathExtension.lowercased()) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .prefix(3)
            .map { $0 }
    }

    static func facePrint(url: URL) -> VNFeaturePrintObservation? {
        guard let img = NSImage(contentsOf: url) else { return nil }
        var rect = NSRect(origin: .zero, size: img.size)
        guard let cg = img.cgImage(forProposedRect: &rect, context: nil, hints: nil) else { return nil }
        guard let cls = NSClassFromString("VNGenerateFacePrintRequest") as? VNRequest.Type else { return nil }
        let req = cls.init()
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        guard (try? handler.perform([req])) != nil else { return nil }
        for obs in req.results ?? [] {
            if let fp = obs as? VNFeaturePrintObservation { return fp }
            if obs.responds(to: NSSelectorFromString("facePrint")),
               let fp = obs.value(forKey: "facePrint") as? VNFeaturePrintObservation
            {
                return fp
            }
        }
        return nil
    }

    static func distance(_ a: VNFeaturePrintObservation, _ b: VNFeaturePrintObservation) -> Double? {
        var dist: Float = 0
        do {
            try a.computeDistance(&dist, to: b)
            return Double(dist)
        } catch {
            return nil
        }
    }

    static func cosine(_ a: VNFeaturePrintObservation, _ b: VNFeaturePrintObservation) -> Double? {
        guard let va = vector(a), let vb = vector(b), va.count == vb.count, va.count >= 32 else { return nil }
        var dot = 0.0
        var na = 0.0
        var nb = 0.0
        for i in va.indices {
            dot += va[i] * vb[i]
            na += va[i] * va[i]
            nb += vb[i] * vb[i]
        }
        let d = (na * nb).squareRoot()
        guard d > 1e-12 else { return nil }
        return dot / d
    }

    static func vector(_ obs: VNFeaturePrintObservation) -> [Double]? {
        let n = obs.elementCount
        guard n >= 32 else { return nil }
        return obs.data.withUnsafeBytes { raw -> [Double]? in
            switch obs.elementType {
            case .float:
                let buf = raw.bindMemory(to: Float.self)
                guard buf.count >= n else { return nil }
                return (0 ..< n).map { Double(buf[$0]) }
            case .double:
                let buf = raw.bindMemory(to: Double.self)
                guard buf.count >= n else { return nil }
                return Array(buf.prefix(n))
            default:
                return nil
            }
        }
    }
}
