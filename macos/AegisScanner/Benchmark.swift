import CoreGraphics
import Foundation

/// Testmodus: LFW-Verifikation (Paare) und Identifikation (Ordner = Person).
enum Benchmark {
    static let identifyPeopleCap = 24
    static let photosPerPerson = 6

    static func detectLargest(url: URL) -> FaceObservation? {
        guard let image = FrameExtractor.loadCGImage(url: url) else { return nil }
        let faces = (try? FaceEngine.detect(in: image, mediaId: UUID(), tiles: false)) ?? []
        return faces.max { $0.box.width * $0.box.height < $1.box.width * $1.box.height }
    }

    static func printPercent(_ a: FaceObservation, _ b: FaceObservation) -> (percent: Double, cosine: Double, measured: Bool) {
        let va = FaceEngine.embedding(of: a)
        let vb = FaceEngine.embedding(of: b)
        guard va.count >= 32, va.count == vb.count else {
            return (0, 0, false)
        }
        let cos = MatchMath.cosine(va, vb)
        return (MatchMath.printSigmoid(cosine: cos), cos, true)
    }

    static func verify(
        root: URL,
        pairs: [BenchProtocol.Pair],
        threshold: Double,
        shouldContinue: () -> Bool = { true },
        progress: (Int, Int) -> Void = { _, _ in }
    ) -> String {
        var genuine: [Double] = []
        var impostor: [Double] = []
        var genuineCos: [Double] = []
        var impostorCos: [Double] = []
        var missing = 0
        var undetected = 0
        var noPrint = 0
        var cache: [String: FaceObservation] = [:]
        let total = pairs.count

        func face(_ name: String, _ idx: Int) -> FaceObservation? {
            let key = "\(name)#\(idx)"
            if let hit = cache[key] { return hit }
            guard let url = BenchProtocol.resolve(root: root, name: name, index: idx) else { return nil }
            let obs = detectLargest(url: url)
            if let obs { cache[key] = obs }
            return obs
        }

        for (n, pair) in pairs.enumerated() {
            if !shouldContinue() { break }
            if n % 25 == 0 { progress(n, total) }
            guard BenchProtocol.resolve(root: root, name: pair.aName, index: pair.aIndex) != nil,
                  BenchProtocol.resolve(root: root, name: pair.bName, index: pair.bIndex) != nil
            else {
                missing += 1
                continue
            }
            guard let a = face(pair.aName, pair.aIndex), let b = face(pair.bName, pair.bIndex) else {
                undetected += 1
                continue
            }
            let s = printPercent(a, b)
            if !s.measured {
                noPrint += 1
                continue
            }
            if pair.same {
                genuine.append(s.percent)
                genuineCos.append(s.cosine)
            } else {
                impostor.append(s.percent)
                impostorCos.append(s.cosine)
            }
        }
        progress(total, total)

        var out: [String] = []
        out.append("Verifikation (LFW-Paare, Face-Print-Sigmoid)")
        out.append("Paare in pairs.txt \(pairs.count)  ·  bewertet \(genuine.count + impostor.count)  ·  Datei fehlt \(missing)  ·  kein Gesicht \(undetected)  ·  kein Print \(noPrint)")
        out.append(stats("Genuine %", genuine))
        out.append(stats("Impostor %", impostor))
        out.append(stats("Genuine cosine", genuineCos))
        out.append(stats("Impostor cosine", impostorCos))
        if !genuine.isEmpty {
            out.append("Histogramm Genuine  " + MatchMath.scoreHistogram(genuine))
        }
        if !impostor.isEmpty {
            out.append("Histogramm Impostor " + MatchMath.scoreHistogram(impostor))
        }
        if !genuine.isEmpty, !impostor.isEmpty {
            let acc = BenchProtocol.accuracy(
                scores: genuine.map { $0 } + impostor.map { $0 },
                same: Array(repeating: true, count: genuine.count) + Array(repeating: false, count: impostor.count),
                threshold: threshold
            )
            out.append(String(format: "Accuracy bei Schwelle %.0f  %.1f%%", threshold, 100 * acc))
            out.append(String(format: "Rang-1-analog (genuine ≥ Schwelle)  %.1f%%", 100 * frac(genuine, threshold)))
            out.append(String(format: "FAR bei Schwelle                    %.1f%%", 100 * frac(impostor, threshold)))
            out.append(eerLine(genuine, impostor))
            if let t = MatchMath.tar(atFar: 0.01, genuine: genuine, impostor: impostor) {
                out.append(String(format: "TAR @ 1 %% FAR    %.1f%%  (Schwelle %.1f)", 100 * t.tar, t.threshold))
            }
            if let t = MatchMath.tar(atFar: 0.001, genuine: genuine, impostor: impostor) {
                out.append(String(format: "TAR @ 0,1 %% FAR  %.1f%%  (Schwelle %.1f)", 100 * t.tar, t.threshold))
            }
        } else {
            out.append("Keine bewertbaren Paare — LFW-Bilder fehlen. bench/fetch.sh ausführen.")
        }
        return out.joined(separator: "\n")
    }

    static func identitiesFromFolders(media: [MediaItem], faces: [FaceObservation]) -> [Identity] {
        var largest: [UUID: FaceObservation] = [:]
        for face in faces {
            if let old = largest[face.mediaId] {
                if face.box.width * face.box.height > old.box.width * old.box.height {
                    largest[face.mediaId] = face
                }
            } else {
                largest[face.mediaId] = face
            }
        }
        var groups: [String: [UUID]] = [:]
        for item in media where item.kind == .photo {
            let name = item.url.deletingLastPathComponent().lastPathComponent
            guard !name.isEmpty else { continue }
            if let face = largest[item.id] {
                groups[name, default: []].append(face.id)
            }
        }
        return groups.keys.sorted().compactMap { name in
            let ids = groups[name] ?? []
            guard ids.count >= 2 else { return nil }
            let label = name.replacingOccurrences(of: "_", with: " ")
            return Identity(id: UUID(), name: label, faceIds: ids)
        }
    }

    static func header(root: URL, mode: String) -> String {
        [
            "Aegis \(AppVersion.display) — Testmodus",
            "Wurzel  \(root.path)",
            "Modus   \(mode)",
            "Print   \(MatchMath.printRevision)  mid=\(MatchMath.printSigmoidMid)  slope=\(MatchMath.printSigmoidSlope)"
        ].joined(separator: "\n")
    }

    private static func frac(_ xs: [Double], _ t: Double) -> Double {
        guard !xs.isEmpty else { return 0 }
        return Double(xs.filter { $0 >= t }.count) / Double(xs.count)
    }

    private static func stats(_ name: String, _ xs: [Double]) -> String {
        guard !xs.isEmpty else { return "\(name): —" }
        let s = xs.sorted()
        let mean = s.reduce(0, +) / Double(s.count)
        let mid = s[s.count / 2]
        return String(format: "%@  n=%d  mean=%.3f  median=%.3f  min=%.3f  max=%.3f", name, s.count, mean, mid, s.first ?? 0, s.last ?? 0)
    }

    private static func eerLine(_ g: [Double], _ i: [Double]) -> String {
        var best = 1.0
        var at = 78.0
        for t in stride(from: 50.0, through: 96.0, by: 1) {
            let frr = 1 - frac(g, t)
            let far = frac(i, t)
            let e = abs(frr - far)
            if e < best {
                best = e
                at = t
            }
        }
        let frr = 1 - frac(g, at)
        let far = frac(i, at)
        return String(format: "EER ≈ %.1f%% bei Schwelle %.0f (FRR %.1f%% / FAR %.1f%%)", 100 * (frr + far) / 2, at, 100 * frr, 100 * far)
    }
}
