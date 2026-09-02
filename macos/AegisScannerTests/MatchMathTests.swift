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
            near(tar.threshold, 95, 0.01, "FAR 10 % n=10 → höchster Impostor (ceil-1), nicht Index 1")
            near(tar.tar, 0, 0.01, "kein Genuine ≥ 95")
        } else {
            ok(false, "TAR@FAR berechenbar")
        }

        if let tar01 = MatchMath.tar(atFar: 0.2, genuine: [90, 92, 88, 70], impostor: [40, 50, 60, 95, 30, 20, 10, 5, 2, 1]) {
            near(tar01.threshold, 60, 0.01, "FAR 20 % n=10 → zweithöchster Impostor")
            near(tar01.tar, 1, 0.01, "alle Genuine ≥ 60")
        } else {
            ok(false, "TAR@FAR 0,2")
        }

        var euro = MatchMath.OneEuro(minCutoff: 1.0, beta: 0.0, dCutoff: 1.0)
        let first = euro.filter(10, now: 0)
        near(first, 10, 0.01, "1-Euro erster Sample")
        let second = euro.filter(20, now: 0.1)
        ok(second > 10 && second < 20, "1-Euro folgt, ohne den Sprung voll zu nehmen (ist \(second))")
        euro.reset()
        near(euro.filter(99, now: 5), 99, 0.01, "1-Euro reset ist Pass-through")

        ok(MatchMath.lowerFaceOccluded(eyes: true, mouth: false), "Augen ohne Mund = Maske")
        ok(!MatchMath.lowerFaceOccluded(eyes: true, mouth: true), "Mund da = keine Maske")
        ok(!MatchMath.lowerFaceOccluded(eyes: false, mouth: false), "nichts = keine Maske")
        near(MatchMath.combinePrint(full: 90, partial: 70, occluded: false), 90, 0.01, "ohne Okklusion bleibt voller Print")
        ok(MatchMath.combinePrint(full: 90, partial: 70, occluded: true) <= 88, "Maske deckelt vollen Print")
        near(MatchMath.combinePrint(full: 20, partial: 80, occluded: true), 80, 0.01, "Teil-Print führt bei Maske")
        near(MatchMath.combinePrint(full: 20, partial: 95, occluded: true), 88, 0.01, "Teil-Print Deckel 88")
        near(
            MatchMath.combinePrint(full: 90, partial: 80, occluded: true, galleryHasPartial: false),
            40.5,
            0.01,
            "ohne U-Slot: Partial nicht gegen Full-Centroid"
        )
        ok(MatchMath.qualityRejects(capture: 0.9, size: 0.5, sharpness: 0.10), "sharpness 0,10 lehnt ab")
        ok(!MatchMath.qualityRejects(capture: 0.9, size: 0.5, sharpness: 0.20), "scharf reicht")
        ok(MatchMath.qualityRejects(capture: 0.20, size: 0.10, sharpness: 0.50), "winzig + schwach")
        near(MatchMath.sharpnessFloor, 0.12, 0.001, "Schärfe-Floor 0,12")

        let genuineHi = [90.0, 92, 88, 85, 80, 78, 91, 87]
        let impostorLo = [40.0, 50, 60, 30, 20, 10, 5, 2, 1, 15]
        if let ci = MatchMath.tarBootstrap(atFar: 0.1, genuine: genuineHi, impostor: impostorLo, draws: 80, seed: 42) {
            ok(ci.lo <= ci.tar + 1e-9 && ci.tar <= ci.hi + 1e-9, "Bootstrap CI enthält den Punkt (\(ci.lo)–\(ci.hi), tar=\(ci.tar))")
            ok(ci.draws == 80, "80 Draws")
        } else {
            ok(false, "tarBootstrap n=10")
        }
        let manyImp = (0..<200).map { Double($0) * 0.2 }
        if let wide = MatchMath.tarBootstrap(atFar: 0.01, genuine: genuineHi, impostor: manyImp) {
            near(wide.lo, wide.tar, 0.01, "n_imp≥200: CI = Punkt (lo)")
            near(wide.hi, wide.tar, 0.01, "n_imp≥200: CI = Punkt (hi)")
            ok(wide.draws == 0, "kein Bootstrap bei n≥200")
        } else {
            ok(false, "tarBootstrap n=200")
        }

        if fails > 0 {
            fputs("\(fails) MatchMathTests fehlgeschlagen\n", stderr)
            exit(1)
        }
        print("MatchMathTests OK")
    }
}
