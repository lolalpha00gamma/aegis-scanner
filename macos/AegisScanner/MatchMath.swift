import Foundation

/// Schwellen und Kurven an einer Stelle. Engine, Labor, Tests, Slider.
enum MatchMath {
    static let embedMargin = 12.0
    static let landmarkMargin = 14.0
    static let zFloor = 1.5
    static let printSigmoidMid = 0.55
    static let printSigmoidSlope = 14.0
    static let printRevision = "VNGenerateFacePrint/1"
    static let familyCosineLo = 0.80
    static let familyFloorBump = 4.0
    static let rejectCosine = 0.90
    static let sharpnessFloor = 0.12
    /// Continuity/Desk-View: Laplacian oft 0,10–0,14. Nur dort 0,08.
    static let continuitySharpnessFloor = 0.08
    /// Live-Box: IoU unter dem Wert hält die alte Kiste ein Frame.
    static let boxJumpIoU = 0.35
    /// Burst-/Tile-Kopie, nicht neue Pose.
    static let ingestDuplicateCosine = 0.95
    static let liveBlendBuiltIn = 0.35
    static let liveBlendContinuity = 0.20

    static func activeSharpnessFloor(continuity: Bool) -> Double {
        continuity ? continuitySharpnessFloor : sharpnessFloor
    }

    static func liveBlendAlpha(continuity: Bool) -> Double {
        continuity ? liveBlendContinuity : liveBlendBuiltIn
    }

    /// Unscharfe Leave-one-out-Paare sind keine Identitätsfrage.
    static func laborIncludesProbe(qualityRejected: Bool) -> Bool {
        !qualityRejected
    }

    static func laborIncludesRef(qualityRejected: Bool) -> Bool {
        laborIncludesProbe(qualityRejected: qualityRejected)
    }

    static func laborPairKind(probeMasked: Bool) -> String {
        probeMasked ? "genuine-mask" : "genuine-full"
    }

    /// Live-Box: IoU unter 0,35 hält die alte Kiste ein Frame.
    static func boxHysteresisHold(iou: Double, floor: Double = boxJumpIoU) -> Bool {
        iou < floor
    }

    /// Zweites Frame bestätigt den Sprung, wenn es an der pending-Box klebt.
    static func boxHysteresisConfirm(iouToPending: Double, floor: Double = boxJumpIoU) -> Bool {
        iouToPending >= floor
    }

    /// Nahezu identischer Print — Burst-Kopie, nicht neue Pose.
    static func ingestDuplicate(cosine: Double, floor: Double = ingestDuplicateCosine) -> Bool {
        cosine > floor
    }

    /// ASCII-Spark 0…100, 10 Bins. Labor, nicht Live.
    static func scoreHistogram(_ xs: [Double], bins: Int = 10, lo: Double = 0, hi: Double = 100) -> String {
        let n = max(1, bins)
        guard !xs.isEmpty else { return String(repeating: "▁", count: n) }
        let width = max(1e-9, (hi - lo) / Double(n))
        var counts = [Int](repeating: 0, count: n)
        for x in xs {
            var i = Int(((x - lo) / width).rounded(.down))
            i = min(n - 1, max(0, i))
            counts[i] += 1
        }
        let maxC = max(1, counts.max() ?? 1)
        let bars = Array("▁▂▃▄▅▆▇█")
        return counts.map { c in
            let idx = min(bars.count - 1, Int((Double(c) / Double(maxC) * Double(bars.count - 1)).rounded()))
            return String(bars[idx])
        }.joined()
    }


    enum Lamp: String, Equatable {
        case green, amber, red
    }

    /// Live-Ampel, bevor ein Name kommt. Grün/Amber/Rot für Capture, Schärfe, Yaw.
    static func qualityLamps(capture: Double, sharpness: Double, yaw: Double, continuity: Bool = false) -> (capture: Lamp, sharpness: Lamp, yaw: Lamp) {
        func cap(_ v: Double, good: Double, ok: Double) -> Lamp {
            if v >= good { return .green }
            if v >= ok { return .amber }
            return .red
        }
        let ay = abs(yaw)
        let yawLamp: Lamp
        if ay < 0.28 { yawLamp = .green }
        else if ay < 0.70 { yawLamp = .amber }
        else { yawLamp = .red }
        return (
            cap(capture, good: 0.50, ok: 0.35),
            cap(sharpness, good: 0.22, ok: activeSharpnessFloor(continuity: continuity)),
            yawLamp
        )
    }

    /// Laplacian unter Floor: Print-Request lohnt nicht.
    /// Continuity/Desk-View oft 0,10–0,14 — dort 0,08 statt 0,12.
    static func skipPrint(sharpness: Double, continuity: Bool = false) -> Bool {
        sharpness < activeSharpnessFloor(continuity: continuity)
    }

    /// Ampel über bis zu 8 Frames: schlechteste Capture/Schärfe, größtes |Yaw|.
    static func sparkLamps(captures: [Double], sharps: [Double], yaws: [Double], continuity: Bool = false) -> (capture: Lamp, sharpness: Lamp, yaw: Lamp) {
        qualityLamps(
            capture: captures.min() ?? 0,
            sharpness: sharps.min() ?? 0,
            yaw: yaws.map { abs($0) }.max() ?? 0,
            continuity: continuity
        )
    }

    /// Continuity-Override. nil = Auto aus `videoRotationAngle`.
    static func orientOverride(_ stored: String) -> String? {
        switch stored {
        case "0": return "up"
        case "90": return "right"
        case "180": return "down"
        case "270": return "left"
        default: return nil
        }
    }

    struct Floors: Equatable {
        var match: Double
        var solo: Double
    }

    /// Slider ist Bias um 78. Kleine Galerien brauchen höhere Floors.
    /// Solo +2 (nicht +4): sonst landet ein echter 86er-Print unter der Linie.
    static func floors(gallery: Int, slider: Double, familyBump: Double = 0) -> Floors {
        let rec: Double
        if gallery <= 1 { rec = 84 }
        else if gallery <= 3 { rec = 80 }
        else { rec = 78 }
        let match = min(96, max(70, rec + (slider - 78) + familyBump))
        return Floors(match: match, solo: min(96, match + 2))
    }

    /// Genuine Apple-FacePrint-Cosine typisch 0,62–0,92; Impostoren 0,15–0,50.
    static func printSigmoid(cosine: Double) -> Double {
        100.0 / (1.0 + exp(-printSigmoidSlope * (cosine - printSigmoidMid)))
    }

    /// `printMeasured`: Face-Print wurde wirklich berechnet.
    /// Ein Impostor-Print von 0,4 % ist **nicht** „KI aus“ — sonst gewinnt Geometrie
    /// und tauft Fremde. Print *ist* der Score; Geo vetoiert oder gibt bis +4.
    static func lookOf(geo: Double, embed: Double, pose: Double = 1, printMeasured: Bool) -> Double {
        if !printMeasured { return geo }
        if geo < 1 { return embed }
        if geo < 35 { return min(embed, 60) }
        let agree = clamp01((geo - 52) / 38) * clamp01(pose)
        return min(100, embed + 4.0 * agree)
    }

    /// Geschwister: Centroid-Cosine ≥ 0,80 → +4 Floor **für dieses Paar**.
    /// Keine obere Grenze — Zwillinge bei 0,91 brauchen den Bump am meisten.
    /// Nicht global: ein Geschwisterpaar darf den Rest der Galerie nicht anheben.
    static func familyBump(bestPairCosine: Double) -> Double {
        bestPairCosine >= familyCosineLo ? familyFloorBump : 0
    }

    static func familyBump(pairwiseCosine: [Double]) -> Double {
        familyBump(bestPairCosine: pairwiseCosine.max() ?? 0)
    }

    static func cosine(_ a: [Double], _ b: [Double]) -> Double {
        let n = min(a.count, b.count)
        guard n > 0 else { return 0 }
        var dot = 0.0
        var na = 0.0
        var nb = 0.0
        for i in 0 ..< n {
            dot += a[i] * b[i]
            na += a[i] * a[i]
            nb += b[i] * b[i]
        }
        let d = sqrt(na) * sqrt(nb)
        guard d > 1e-12 else { return 0 }
        return max(-1, min(1, dot / d))
    }

    static func l2normalize(_ v: [Double]) -> [Double] {
        var s = 0.0
        for x in v { s += x * x }
        let n = sqrt(s)
        guard n > 1e-12 else { return v }
        return v.map { $0 / n }
    }

    /// Gewichteter Mittelvektor. `weights` parallel zu `vectors`.
    static func weightedMean(_ vectors: [[Double]], weights: [Double]) -> [Double] {
        guard !vectors.isEmpty, vectors.count == weights.count else { return [] }
        let dim = vectors[0].count
        guard dim >= 32 else { return [] }
        var acc = [Double](repeating: 0, count: dim)
        var wsum = 0.0
        for (v, wRaw) in zip(vectors, weights) {
            guard v.count == dim else { continue }
            let w = max(0.08, wRaw)
            for i in 0 ..< dim { acc[i] += v[i] * w }
            wsum += w
        }
        guard wsum > 0 else { return [] }
        let inv = 1.0 / wsum
        for i in acc.indices { acc[i] *= inv }
        return l2normalize(acc)
    }

    static func rejected(_ probe: [Double], by gallery: [[Double]]) -> Bool {
        guard probe.count >= 32 else { return false }
        for v in gallery where v.count == probe.count {
            if cosine(probe, v) >= rejectCosine { return true }
        }
        return false
    }

    static func tar(atFar far: Double, genuine: [Double], impostor: [Double]) -> (tar: Double, threshold: Double)? {
        guard !genuine.isEmpty, !impostor.isEmpty, far > 0, far < 1 else { return nil }
        let desc = impostor.sorted(by: >)
        // floor(far·n) − 1: n=10/0,1 → 95; n=10/0,2 → 60; n=101/0,01 → 80.
        // ceil−1 bricht 101 Impostoren (Index 1 → 10 statt 80).
        let m = Int(far * Double(desc.count))
        let idx = min(desc.count - 1, max(0, m - 1))
        let t = desc[idx]
        let hits = genuine.filter { $0 >= t }.count
        return (Double(hits) / Double(genuine.count), t)
    }

    struct TarCI: Equatable {
        var tar: Double
        var threshold: Double
        var lo: Double
        var hi: Double
        var draws: Int
    }

    /// Bootstrap-95 %-CI, wenn n_impostor < 200. Sonst Punkt = Intervall.
    /// Eine Schwelle bei n=10 lügt — der CI macht das sichtbar.
    static func tarBootstrap(
        atFar far: Double,
        genuine: [Double],
        impostor: [Double],
        draws: Int = 200,
        seed: UInt64 = 0xAE615C4A
    ) -> TarCI? {
        guard let point = tar(atFar: far, genuine: genuine, impostor: impostor) else { return nil }
        if impostor.count >= 200 {
            return TarCI(tar: point.tar, threshold: point.threshold, lo: point.tar, hi: point.tar, draws: 0)
        }
        var state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
        func nextU() -> UInt64 {
            state &+= 0x9E3779B97F4A7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            return z ^ (z >> 31)
        }
        func pick(_ xs: [Double]) -> Double {
            xs[Int(nextU() % UInt64(xs.count))]
        }
        var rates: [Double] = []
        rates.reserveCapacity(draws)
        for _ in 0 ..< draws {
            let g = (0 ..< genuine.count).map { _ in pick(genuine) }
            let i = (0 ..< impostor.count).map { _ in pick(impostor) }
            if let t = tar(atFar: far, genuine: g, impostor: i) {
                rates.append(t.tar)
            }
        }
        guard !rates.isEmpty else {
            return TarCI(tar: point.tar, threshold: point.threshold, lo: point.tar, hi: point.tar, draws: 0)
        }
        rates.sort()
        let loI = max(0, Int((0.025 * Double(rates.count - 1)).rounded()))
        let hiI = min(rates.count - 1, Int((0.975 * Double(rates.count - 1)).rounded()))
        return TarCI(tar: point.tar, threshold: point.threshold, lo: rates[loI], hi: rates[hiI], draws: rates.count)
    }

    static func lowerFaceOccluded(eyes: Bool, mouth: Bool) -> Bool {
        eyes && !mouth
    }

    /// Unscharf unter aktivem Floor: harte Ablehnung, nicht nur Score-Dämpfung.
    /// Continuity darf 0,10 — sonst skipPrint erzeugt den Print und qualityRejects wirft ihn weg.
    static func qualityRejects(capture: Double, size: Double, sharpness: Double, continuity: Bool = false) -> Bool {
        (capture < 0.35 && size < 0.16) || sharpness < activeSharpnessFloor(continuity: continuity)
    }

    /// Maske: voller Print enthält Stoff. Teil-Print (Stirn/Augen) führt, Deckel 88.
    /// Ohne Galerie-Teil-Print: nur den vollen Score dämpfen — nie Partial vs Full-Centroid.
    static func combinePrint(full: Double, partial: Double, occluded: Bool, galleryHasPartial: Bool = true) -> Double {
        guard occluded else { return full }
        if !galleryHasPartial {
            return full * 0.45
        }
        return max(full * 0.45, min(88, partial))
    }

    /// 1-Euro auf einem Skalar. Live-Box, nicht der Print.
    struct OneEuro {
        var minCutoff: Double = 1.2
        var beta: Double = 0.007
        var dCutoff: Double = 1.0
        private var xHat: Double?
        private var dxHat: Double = 0
        private var tPrev: Double = 0

        init(minCutoff: Double = 1.2, beta: Double = 0.007, dCutoff: Double = 1.0) {
            self.minCutoff = minCutoff
            self.beta = beta
            self.dCutoff = dCutoff
        }

        mutating func filter(_ value: Double, now: Double) -> Double {
            guard let prev = xHat else {
                xHat = value
                tPrev = now
                return value
            }
            let dt = max(1e-3, now - tPrev)
            tPrev = now
            let dx = (value - prev) / dt
            let ad = alpha(dCutoff, dt: dt)
            dxHat = ad * dx + (1 - ad) * dxHat
            let cutoff = minCutoff + beta * abs(dxHat)
            let a = alpha(cutoff, dt: dt)
            let hat = a * value + (1 - a) * prev
            xHat = hat
            return hat
        }

        mutating func reset() {
            xHat = nil
            dxHat = 0
            tPrev = 0
        }

        private func alpha(_ cutoff: Double, dt: Double) -> Double {
            let tau = 1.0 / (2.0 * Double.pi * max(1e-4, cutoff))
            return 1.0 / (1.0 + tau / dt)
        }
    }

    private static func clamp01(_ n: Double) -> Double { min(1, max(0, n)) }
}
