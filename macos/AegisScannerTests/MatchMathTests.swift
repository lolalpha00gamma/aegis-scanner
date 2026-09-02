import Foundation

/// `swiftc macos/AegisScanner/MatchMath.swift macos/AegisScannerTests/MatchMathTests.swift -o /tmp/aegismath && /tmp/aegismath`

@main
enum MatchMathTests {
    static var fails = 0

    static func ok(_ cond: Bool, _ msg: String) {
        if !cond {
            fputs("FAIL \(msg)\n", stderr)
            fails += 1
        }
    }

    static func near(_ a: Double, _ b: Double, _ eps: Double, _ msg: String) {
        ok(abs(a - b) < eps, "\(msg): \(a) != \(b)")
    }

    static func main() {
        let one = MatchMath.floors(gallery: 1, slider: 78)
        near(one.match, 84, 0.01, "1 Person Floor 84")
        near(one.solo, 88, 0.01, "1 Person Solo 88")

        let few = MatchMath.floors(gallery: 3, slider: 78)
        near(few.match, 80, 0.01, "2–3 Personen Floor 80")

        let many = MatchMath.floors(gallery: 8, slider: 78)
        near(many.match, 78, 0.01, "≥4 Personen Floor 78")

        let biased = MatchMath.floors(gallery: 8, slider: 70)
        near(biased.match, 70, 0.01, "Slider 70 → 70")

        let impostor = MatchMath.printSigmoid(cosine: 0.45)
        ok(impostor > 15 && impostor < 28, "Impostor 0,45 ≈ 20 %, nicht 58 % (ist \(impostor))")
        let genuine = MatchMath.printSigmoid(cosine: 0.75)
        ok(genuine > 90, "Genuine 0,75 über 90 % (ist \(genuine))")

        let geoOnly = MatchMath.lookOf(geo: 80, embed: 0.4, pose: 1, printMeasured: false)
        near(geoOnly, 80, 0.01, "KI aus → nur Geometrie")

        let lowPrint = MatchMath.lookOf(geo: 80, embed: 0.4, pose: 1, printMeasured: true)
        ok(lowPrint < 40, "0,4 % Print darf nicht auf 80 % Geometrie fallen (ist \(lowPrint))")

        let deadGeo = MatchMath.lookOf(geo: 20, embed: 99, pose: 1, printMeasured: true)
        near(deadGeo, 60, 0.01, "Geo unter 35 deckelt Print auf 60")

        let blend = MatchMath.lookOf(geo: 80, embed: 90, pose: 1, printMeasured: true)
        near(blend, 0.75 * 90 + 0.25 * 80, 0.2, "Print führt 75/25")

        ok(MatchMath.printWeight(capture: 0.9, frontal: 1) > MatchMath.printWeight(capture: 0.2, frontal: 0.2), "scharfe Frontal-Refs schwerer")
        ok(MatchMath.yawCompatible(probe: 0.05, gallery: 0.10), "nahe Yaw ok")
        ok(!MatchMath.yawCompatible(probe: 0.0, gallery: 0.80), "Profil nicht mit Frontal")

        if let tar = MatchMath.tar(atFar: 0.1, genuine: [90, 92, 88, 70], impostor: [40, 50, 60, 95, 30, 20, 10, 5, 2, 1]) {
            ok(tar.tar >= 0 && tar.tar <= 1, "TAR im [0,1]")
            near(tar.threshold, 95, 0.01, "FAR 10% / 10 Impostoren → höchster Impostor, nicht der Zweite")
        } else {
            ok(false, "TAR@FAR berechenbar")
        }

        if let tar01 = MatchMath.tar(atFar: 0.01, genuine: [90], impostor: Array(repeating: 10.0, count: 100) + [80]) {
            near(tar01.threshold, 80, 0.01, "FAR 1% / 101 Impostoren → floor-Index")
        }

        if fails > 0 {
            fputs("\(fails) MatchMathTests fehlgeschlagen\n", stderr)
            exit(1)
        }
        print("MatchMathTests OK")
    }
}
