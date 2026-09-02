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
        near(one.solo, 86, 0.01, "1 Person Solo 86 (+2)")

        let few = MatchMath.floors(gallery: 3, slider: 78)
        near(few.match, 80, 0.01, "2–3 Personen Floor 80")

        let many = MatchMath.floors(gallery: 8, slider: 78)
        near(many.match, 78, 0.01, "≥4 Personen Floor 78")

        let biased = MatchMath.floors(gallery: 8, slider: 70)
        near(biased.match, 70, 0.01, "Slider 70 → 70")

        let family = MatchMath.floors(gallery: 2, slider: 78, familyBump: 4)
        near(family.match, 84, 0.01, "Familien-Floor +4")

        near(MatchMath.familyBump(pairwiseCosine: [0.83]), 4, 0.01, "Geschwister-Cosine 0,83")
        near(MatchMath.familyBump(pairwiseCosine: [0.50, 0.92]), 0, 0.01, "kein Familien-Bump")

        let impostor = MatchMath.printSigmoid(cosine: 0.45)
        ok(impostor > 15 && impostor < 28, "Impostor 0,45 ≈ 20 %, nicht 58 % (ist \(impostor))")
        let genuine = MatchMath.printSigmoid(cosine: 0.75)
        ok(genuine > 90, "Genuine 0,75 über 90 % (ist \(genuine))")

        let geoOnly = MatchMath.lookOf(geo: 80, embed: 0.4, pose: 1, printMeasured: false)
        near(geoOnly, 80, 0.01, "KI aus → nur Geometrie")

        let lowPrint = MatchMath.lookOf(geo: 80, embed: 0.4, pose: 1, printMeasured: true)
        ok(lowPrint < 5, "0,4 % Print darf nicht auf 80 % Geometrie fallen (ist \(lowPrint))")

        let deadGeo = MatchMath.lookOf(geo: 20, embed: 99, pose: 1, printMeasured: true)
        near(deadGeo, 60, 0.01, "Geo unter 35 deckelt Print auf 60")

        let agree = MatchMath.lookOf(geo: 90, embed: 92, pose: 1, printMeasured: true)
        ok(agree > 92 && agree <= 96, "Print führt, Geo gibt bis +4 (ist \(agree))")

        let unit = MatchMath.l2normalize([3, 4])
        near(hypot(unit[0], unit[1]), 1, 0.001, "L2")

        let mean = MatchMath.weightedMean(
            [[1, 0] + [Double](repeating: 0, count: 30), [0, 1] + [Double](repeating: 0, count: 30)],
            weights: [0.9, 0.1]
        )
        ok(mean.count == 32, "Centroid dim")
        ok(mean[0] > mean[1], "Scharfe Kopie zieht den Mittelvektor")

        ok(MatchMath.rejected([1] + [Double](repeating: 0, count: 31), by: [[1] + [Double](repeating: 0, count: 31)]), "Hard-Negativ Cosine 1")
        ok(!MatchMath.rejected([1] + [Double](repeating: 0, count: 31), by: [[0, 1] + [Double](repeating: 0, count: 30)]), "orthogonales Print kein Negativ")

        if let tar = MatchMath.tar(atFar: 0.1, genuine: [90, 92, 88, 70], impostor: [40, 50, 60, 95, 30, 20, 10, 5, 2, 1]) {
            ok(tar.tar >= 0 && tar.tar <= 1, "TAR im [0,1]")
        } else {
            ok(false, "TAR@FAR berechenbar")
        }

        if fails > 0 {
            fputs("\(fails) MatchMathTests fehlgeschlagen\n", stderr)
            exit(1)
        }
        print("MatchMathTests OK")
    }
}
