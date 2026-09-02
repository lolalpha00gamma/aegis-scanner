import Foundation

/// Schwellen und Kurven an einer Stelle. Engine, Labor, Tests, Slider.
enum MatchMath {
    static let embedMargin = 12.0
    static let landmarkMargin = 14.0
    static let zFloor = 1.5
    static let printSigmoidMid = 0.55
    static let printSigmoidSlope = 14.0

    struct Floors {
        var match: Double
        var solo: Double
    }

    /// Slider ist Bias um 78. Kleine Galerien brauchen höhere Floors.
    static func floors(gallery: Int, slider: Double) -> Floors {
        let rec: Double
        if gallery <= 1 { rec = 84 }
        else if gallery <= 3 { rec = 80 }
        else { rec = 78 }
        let match = min(96, max(70, rec + (slider - 78)))
        return Floors(match: match, solo: min(96, match + 4))
    }

    static func printSigmoid(cosine: Double) -> Double {
        100.0 / (1.0 + exp(-printSigmoidSlope * (cosine - printSigmoidMid)))
    }

    /// Scharfe Frontal-Refs zählen mehr als weiche Profil-Frames.
    static func printWeight(capture: Double, frontal: Double = 1) -> Double {
        max(0.25, min(1.6, capture * 1.35 + 0.25 * max(0, min(1, frontal))))
    }

    /// Profil nicht mit Frontal mitteln, solange dieselbe Pose-Klasse existiert.
    static func yawCompatible(probe: Double, gallery: Double) -> Bool {
        abs(probe - gallery) < 0.55
    }

    static func lookOf(geo: Double, embed: Double, pose: Double = 1, printMeasured: Bool) -> Double {
        if !printMeasured { return geo }
        if geo < 1 { return embed }
        if geo < 35 { return min(embed, 60) }
        let geoW = 0.25 * min(1, max(0, pose))
        return (1 - geoW) * embed + geoW * geo
    }

    static func tar(atFar far: Double, genuine: [Double], impostor: [Double]) -> (tar: Double, threshold: Double)? {
        guard !genuine.isEmpty, !impostor.isEmpty, far > 0, far < 1 else { return nil }
        let desc = impostor.sorted(by: >)
        // floor(far·n) − 1: n=10/far=0.1 → idx 0 (95); n=101/far=0.01 → idx 0 (80).
        // ceil(far·n)−1 brach 101 Impostoren (idx 1 → 10 statt 80).
        let m = Int(far * Double(desc.count))
        let idx = min(desc.count - 1, max(0, m - 1))
        let t = desc[idx]
        let hits = genuine.filter { $0 >= t }.count
        return (Double(hits) / Double(genuine.count), t)
    }
}
