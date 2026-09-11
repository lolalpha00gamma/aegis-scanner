import AppKit
import Foundation
import Vision

/// Standalone Print auf Hugging-Face-LFW-Smoke. Kein ArcFace, kein App-Target.
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
        loadVision()
        let facePrintName = probeFacePrintClass()
        if let facePrintName {
            print("print-klasse  \(facePrintName)")
        } else {
            print("print-klasse  fehlt — Fallback VNGenerateImageFeaturePrintRequest auf Face-Crop")
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
                if let obs = printOf(url: url, className: facePrintName) {
                    prints.append((person, url.lastPathComponent, obs))
                } else {
                    noFace += 1
                }
            }
        }
        let grouped = Dictionary(grouping: prints, by: \.person)
        let withTwo = grouped.filter { $0.value.count >= 2 }
        print("Print smoke  \(people.count) Ordner  \(prints.count) Prints  kein Gesicht \(noFace)")
        if withTwo.count < 8 {
            fputs("FacePrintSmoke: nur \(withTwo.count) Personen mit ≥2 Prints\n", stderr)
            exit(1)
        }

        var genuineDist: [Double] = []
        var genuineCos: [Double] = []
        for (_, items) in withTwo {
            if let d = distance(items[0].obs, items[1].obs) { genuineDist.append(d) }
            if let c = cosine(items[0].obs, items[1].obs) { genuineCos.append(c) }
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

    static func loadVision() {
        _ = Bundle(path: "/System/Library/Frameworks/Vision.framework")?.load()
        _ = VNDetectFaceRectanglesRequest.self
        _ = VNGenerateImageFeaturePrintRequest.self
        _ = VNImageRequestHandler.self
    }

    static let facePrintNames = [
        "VNGenerateFacePrintRequest",
        "VNGenerateFaceprintRequest",
        "_VNGenerateFacePrintRequest"
    ]

    static func probeFacePrintClass() -> String? {
        loadVision()
        for name in facePrintNames {
            if NSClassFromString(name) as? VNRequest.Type != nil { return name }
        }
        return nil
    }

    static func makeRequest(_ className: String) -> VNRequest? {
        (NSClassFromString(className) as? VNRequest.Type)?.init()
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

    static func printOf(url: URL, className: String?) -> VNFeaturePrintObservation? {
        guard let img = NSImage(contentsOf: url) else { return nil }
        var rect = NSRect(origin: .zero, size: img.size)
        guard let cg = img.cgImage(forProposedRect: &rect, context: nil, hints: nil) else { return nil }
        if let className, let req = makeRequest(className) {
            if let fp = runPrint(req, cg: cg) { return fp }
        }
        return cropImagePrint(cg)
    }

    static func runPrint(_ req: VNRequest, cg: CGImage) -> VNFeaturePrintObservation? {
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

    static func cropImagePrint(_ image: CGImage) -> VNFeaturePrintObservation? {
        let detect = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        guard (try? handler.perform([detect])) != nil else { return nil }
        let faces = (detect.results as? [VNFaceObservation]) ?? []
        guard let best = faces.max(by: { $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height }) else {
            return nil
        }
        let crop = crop(image, visionBox: best.boundingBox) ?? image
        let req = VNGenerateImageFeaturePrintRequest()
        return runPrint(req, cg: crop)
    }

    static func crop(_ image: CGImage, visionBox: CGRect) -> CGImage? {
        let w = Double(image.width)
        let h = Double(image.height)
        let pad = 0.18
        var x = (Double(visionBox.origin.x) - pad) * w
        var y = (1 - Double(visionBox.origin.y) - Double(visionBox.height) - pad) * h
        var cw = (Double(visionBox.width) + 2 * pad) * w
        var ch = (Double(visionBox.height) + 2 * pad) * h
        x = max(0, x)
        y = max(0, y)
        cw = min(cw, w - x)
        ch = min(ch, h - y)
        guard cw >= 16, ch >= 16 else { return nil }
        return image.cropping(to: CGRect(x: x, y: y, width: cw, height: ch))
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
