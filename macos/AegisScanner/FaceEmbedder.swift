import CoreGraphics
import CoreML
import Foundation

/// Trainierter 1:N-Embedder. SFace (Apache-2, OpenCV Zoo) ist der kommerzielle
/// Default — buffalo_l/ArcFace bleibt optionaler Research-Drop-in gleicher
/// 112×112-Schnittstelle, nie stiller FacePrint-Ersatz.
enum FaceEmbedder {
    static let dim = 128
    static let inputSize = 112

    private static let lock = NSLock()
    private static var model: MLModel?
    private static var inputName: String?
    private static var outputName: String?
    private static var didLoad = false

    static var isAvailable: Bool {
        lock.lock(); defer { lock.unlock() }
        if !didLoad { loadLocked() }
        return model != nil
    }

    static var revision: String { MatchMath.embedderRevision }

    static func embed(_ aligned: CGImage) -> [Double]? {
        lock.lock(); defer { lock.unlock() }
        if !didLoad { loadLocked() }
        guard let model, let inputName, let outputName else { return nil }
        guard let arr = multiArray(from: aligned) else { return nil }
        let provider: MLFeatureProvider
        do {
            provider = try MLDictionaryFeatureProvider(dictionary: [inputName: MLFeatureValue(multiArray: arr)])
        } catch {
            return nil
        }
        guard let out = try? model.prediction(from: provider),
              let vec = out.featureValue(for: outputName)?.multiArrayValue
        else { return nil }
        return l2(flatten(vec))
    }

    static func embed(image: CGImage, face: FaceObservation) -> [Double]? {
        guard let crop = FaceAlign.warp(image, face: face) else { return nil }
        return embed(crop)
    }

    private static func loadLocked() {
        didLoad = true
        let urls = candidateURLs()
        for url in urls {
            if let loaded = load(url) {
                model = loaded.0
                inputName = loaded.1
                outputName = loaded.2
                return
            }
        }
    }

    private static func candidateURLs() -> [URL] {
        var out: [URL] = []
        let names = ["SFace", "sface", "ArcFace", "arcface"]
        let exts = ["mlmodelc", "mlmodel", "mlpackage"]
        for n in names {
            for e in exts {
                if let u = Bundle.main.url(forResource: n, withExtension: e) {
                    out.append(u)
                }
                if e == "mlpackage", let u = Bundle.main.url(forResource: n, withExtension: "mlpackage") {
                    out.append(u)
                }
            }
        }
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Aegis", isDirectory: true)
        if let support {
            for n in ["SFace.mlmodelc", "SFace.mlmodel", "SFace.mlpackage", "sface.mlmodelc"] {
                out.append(support.appendingPathComponent(n))
            }
        }
        return out
    }

    private static func load(_ url: URL) -> (MLModel, String, String)? {
        let compiled: URL
        if url.pathExtension == "mlmodelc" {
            compiled = url
        } else if let c = try? MLModel.compileModel(at: url) {
            compiled = c
        } else {
            return nil
        }
        let cfg = MLModelConfiguration()
        cfg.computeUnits = .all
        guard let m = try? MLModel(contentsOf: compiled, configuration: cfg) else { return nil }
        let ins = m.modelDescription.inputDescriptionsByName
        let outs = m.modelDescription.outputDescriptionsByName
        guard let inName = ins.first(where: { $0.value.type == .multiArray })?.key
                ?? ins.keys.first,
              let outName = outs.first(where: { $0.value.type == .multiArray })?.key
                ?? outs.keys.first
        else { return nil }
        return (m, inName, outName)
    }

    /// RGB CHW, (x − 127.5) / 128. OpenCV FaceRecognizerSF mit swapRB=true.
    private static func multiArray(from image: CGImage) -> MLMultiArray? {
        let s = inputSize
        var pixels = [UInt8](repeating: 0, count: s * s * 4)
        let ok = pixels.withUnsafeMutableBytes { raw -> Bool in
            guard let ctx = CGContext(
                data: raw.baseAddress,
                width: s,
                height: s,
                bitsPerComponent: 8,
                bytesPerRow: s * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            ctx.translateBy(x: 0, y: CGFloat(s))
            ctx.scaleBy(x: 1, y: -1)
            ctx.interpolationQuality = .high
            ctx.draw(image, in: CGRect(x: 0, y: 0, width: s, height: s))
            return true
        }
        guard ok else { return nil }
        guard let arr = try? MLMultiArray(shape: [1, 3, NSNumber(value: s), NSNumber(value: s)], dataType: .float32) else {
            return nil
        }
        let plane = s * s
        let ptr = arr.dataPointer.bindMemory(to: Float.self, capacity: 3 * plane)
        for y in 0 ..< s {
            for x in 0 ..< s {
                let i = (y * s + x) * 4
                let p = y * s + x
                ptr[p] = (Float(pixels[i]) - 127.5) / 128.0
                ptr[plane + p] = (Float(pixels[i + 1]) - 127.5) / 128.0
                ptr[2 * plane + p] = (Float(pixels[i + 2]) - 127.5) / 128.0
            }
        }
        return arr
    }

    private static func flatten(_ a: MLMultiArray) -> [Double] {
        let n = a.count
        var out = [Double](repeating: 0, count: n)
        if a.dataType == .float32 {
            let ptr = a.dataPointer.bindMemory(to: Float.self, capacity: n)
            for i in 0 ..< n { out[i] = Double(ptr[i]) }
        } else if a.dataType == .double {
            let ptr = a.dataPointer.bindMemory(to: Double.self, capacity: n)
            for i in 0 ..< n { out[i] = ptr[i] }
        } else {
            for i in 0 ..< n { out[i] = a[i].doubleValue }
        }
        return out
    }

    private static func l2(_ v: [Double]) -> [Double] {
        var s = 0.0
        for x in v { s += x * x }
        let n = sqrt(s)
        guard n > 1e-12 else { return v }
        return v.map { $0 / n }
    }
}
