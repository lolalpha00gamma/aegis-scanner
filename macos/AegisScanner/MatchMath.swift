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

    /// Genuine Apple-FacePrint-Cosine typisch 0,62–0,92; Impostoren 0,15–0,50.
    /// Mitte 0,42 hat Impostoren bei 0,45 schon ~58 % gegeben.
    static func printSigmoid(cosine: Double) -> Double {
        100.0 / (1.0 + exp(-printSigmoidSlope * (cosine - printSigmoidMid)))
    }

    /// `printMeasured`: Face-Print wurde wirklich berechnet.
    /// Ein Impostor-Print von 0,4 % ist **nicht** „KI aus“ — sonst gewinnt Geometrie.
    static func lookOf(geo: Double, embed: Double, pose: Double = 1, printMeasured: Bool) -> Double {
        if !printMeasured { return geo }
        if geo < 1 { return embed }
        if geo < 35 { return min(embed, 60) }
        let geoW = 0.25 * min(1, max(0, pose))
        return (1 - geoW) * embed + geoW * geo
    }

    /// TAR bei vorgegebener FAR. Kleine n sind laut — trotzdem ehrlicher als nur EER.
    static func tar(atFar far: Double, genuine: [Double], impostor: [Double]) -> (tar: Double, threshold: Double)? {
        guard !genuine.isEmpty, !impostor.isEmpty, far > 0, far < 1 else { return nil }
        let desc = impostor.sorted(by: >)
        // ceil(far*n)-1: FAR 10 % von 10 Impostoren → Schwelle = höchster Impostor.
        // floor(far*n) war off-by-one und ließ zwei Impostoren durch.
        let k = max(0, Int((far * Double(desc.count)).rounded(.up)) - 1)
        let idx = min(desc.count - 1, k)
        let t = desc[idx]
        let hits = genuine.filter { $0 >= t }.count
        return (Double(hits) / Double(genuine.count), t)
    }
}
