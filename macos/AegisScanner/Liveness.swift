import Foundation

/// Presentation-Attack-Hinweise, kein zertifiziertes PAD.
/// Blink + Schärfe + Frontal. MiniFASNet wäre der nächste Drop-in, nicht diese Datei.
enum Liveness {
    enum Verdict: String {
        case live
        case unsure
        case spoof
    }

    static func score(quality: FaceQuality, blink: Bool, spark: [FaceQuality]) -> Double {
        MatchMath.livenessScore(
            capture: quality.capture,
            sharpness: quality.sharpness,
            frontal: quality.frontal,
            blink: blink,
            sparkVar: sparkVariance(spark)
        )
    }

    static func verdict(_ score: Double) -> Verdict {
        if score >= 0.72 { return .live }
        if score <= 0.28 { return .spoof }
        return .unsure
    }

    static func blocksIdentify(_ score: Double) -> Bool {
        MatchMath.livenessBlocksIdentify(score)
    }

    private static func sparkVariance(_ spark: [FaceQuality]) -> Double {
        let xs = spark.map(\.sharpness)
        guard xs.count >= 3 else { return 0 }
        let m = xs.reduce(0, +) / Double(xs.count)
        let v = xs.reduce(0.0) { $0 + ($1 - m) * ($1 - m) } / Double(xs.count)
        return v
    }
}
