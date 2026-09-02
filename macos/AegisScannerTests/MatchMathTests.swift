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
        near(MatchMath.familyBump(bestPairCosine: 0.83), 4, 0.01, "Best-Paar Geschwister")
        near(MatchMath.familyBump(bestPairCosine: 0.50), 0, 0.01, "Best-Paar fremd — Galerie-Geschwister zählen nicht")
        near(MatchMath.familyBump(bestPairCosine: nil), 0, 0.01, "kein Zweiter")

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
        ok(MatchMath.skipPrint(sharpness: 0.10), "Laplacian unter Floor spart den Print")
        ok(!MatchMath.skipPrint(sharpness: 0.20), "scharf geht zum Print")
        ok(!MatchMath.skipPrint(sharpness: 0.10, continuity: true), "Continuity 0,10 geht zum Print")
        ok(MatchMath.skipPrint(sharpness: 0.07, continuity: true), "Continuity 0,07 tot")
        ok(MatchMath.isContinuityCamera(uniqueID: "com.apple.continuity.camera"), "Continuity uniqueID")
        ok(MatchMath.isContinuityCamera(uniqueID: "x", name: "Desk View"), "Desk-View Name")
        ok(!MatchMath.isContinuityCamera(uniqueID: "FaceTime HD Camera"), "Built-in keine Continuity")
        near(MatchMath.continuitySharpnessFloor, 0.08, 0.001, "Continuity-Floor 0,08")

        let tiles = MatchMath.tileOrigins(imageWidth: 2000, imageHeight: 1500, tileWidth: 1160, tileHeight: 870)
        ok(tiles.count == 2, "Tile-Budget 2 (ist \(tiles.count))")
        ok(tiles[0] == (0, 0), "erste Tile oben links")
        ok(tiles[1].0 > 0 && tiles[1].1 > 0, "zweite Tile Diagonale unten rechts")

        let sparkG = MatchMath.sparkLamp([.green, .green, .green, .amber, .green, .green, .green, .green])
        ok(sparkG == .green, "Spark folgt Mehrheit Grün")
        let sparkR = MatchMath.sparkLamp([.red, .red, .red, .amber, .red, .green, .red, .red])
        ok(sparkR == .red, "Spark Rot bei Mehrheit Rot")
        ok(MatchMath.laborPairKind(probeMasked: true) == "genuine-mask", "Labor Maske")
        ok(MatchMath.laborPairKind(probeMasked: false) == "genuine-full", "Labor voll")

        ok(MatchMath.orientConflict(override: "auto", videoAngle: 90) == nil, "Auto kein Konflikt")
        ok(MatchMath.orientConflict(override: "90", videoAngle: 90) == nil, "Override trifft Angle")
        ok(MatchMath.orientConflict(override: "90", videoAngle: 0) != nil, "Override 90 vs 0 loggt")

        let hist = MatchMath.scoreHistogram([90, 92, 88, 40, 50, 20, 10])
        ok(hist.count == 10, "Histogramm 10 Bins (ist \(hist.count))")
        ok(hist.contains("█") || hist.contains("▇") || hist.contains("▆"), "Histogramm hat Balken")

        let age = MatchMath.printAgeDays(modified: Date().addingTimeInterval(-100 * 86_400), now: Date())
        ok((age ?? 0) >= 90, "Print-Alter 100 Tage")
        ok(MatchMath.printStale(days: 90), "90 Tage stale")
        ok(!MatchMath.printStale(days: 10), "10 Tage frisch")
        ok(!MatchMath.printStale(days: nil), "ohne Datum nicht stale")
        ok(MatchMath.maskHoldReady(elapsed: 1.2), "Masken-Hold 1,2 s")
        ok(!MatchMath.maskHoldReady(elapsed: 0.5), "Masken-Hold zu kurz")
        near(MatchMath.maskHoldSeconds, 1.2, 0.001, "Masken-Hold Default")
        near(Double(MatchMath.printStaleDays), 90, 0.001, "Print-Alter 90 Tage")
        ok(MatchMath.laborIncludesProbe(qualityRejected: false), "scharfe Probe in TAR")
        ok(!MatchMath.laborIncludesProbe(qualityRejected: true), "unscharfe Probe raus aus TAR")
        ok(MatchMath.laborIncludesRef(qualityRejected: false), "scharfe Gallery-Ref in TAR")
        ok(!MatchMath.laborIncludesRef(qualityRejected: true), "unscharfe Gallery-Ref raus aus TAR")
        ok(MatchMath.boxHysteresisHold(iou: 0.20), "IoU 0,20 hält die Box")
        ok(!MatchMath.boxHysteresisHold(iou: 0.50), "IoU 0,50 folgt sofort")
        ok(MatchMath.boxHysteresisConfirm(iouToPending: 0.40), "zweites Frame bestätigt Sprung")
        ok(!MatchMath.boxHysteresisConfirm(iouToPending: 0.10), "anderes Ziel bleibt pending")
        ok(MatchMath.ingestDuplicate(cosine: 0.96), "Cosine 0,96 = Burst-Kopie")
        ok(!MatchMath.ingestDuplicate(cosine: 0.90), "Cosine 0,90 bleibt zweite Pose")
        near(MatchMath.boxJumpIoU, 0.35, 0.001, "Box-Hysterese 0,35")
        near(MatchMath.ingestDuplicateCosine, 0.95, 0.001, "Ingest-Duplikat 0,95")
        ok(MatchMath.isNearDuplicate(cosine: 0.99), "0,99 = Gallery-Prune")
        ok(!MatchMath.isNearDuplicate(cosine: 0.96), "0,96 bleibt zweite Pose (Ingest-Dup, nicht Prune)")
        ok(MatchMath.pruneKeepIncoming(cosine: 0.99, incomingSharp: 0.40, existingSharp: 0.20) == true, "schärfere Incoming ersetzt")
        ok(MatchMath.pruneKeepIncoming(cosine: 0.99, incomingSharp: 0.10, existingSharp: 0.40) == false, "unscharfe Incoming raus")
        ok(MatchMath.pruneKeepIncoming(cosine: 0.90, incomingSharp: 0.40, existingSharp: 0.10) == nil, "0,90 kein Prune")
        near(MatchMath.pruneCosine, 0.98, 0.001, "Prune 0,98")
        ok(MatchMath.nameMajority(["A", "A", "B"]) == "A", "Namens-Mehrheit 2 von 3")
        ok(MatchMath.nameMajority(["A", "B", "B"]) == "B", "wechselt nach 2 Ticks")
        ok(MatchMath.nameMajority(["A", "B", "A"]) == "A", "Gleichstand → älteres A")
        ok(MatchMath.nameMajority(["A"]) == "A", "ein Tick")
        ok(MatchMath.nameMajority([]) == nil, "leere History")
        near(MatchMath.liveScoreEMA(prev: nil, next: 90), 90, 0.01, "erster Score roh")
        near(MatchMath.liveScoreEMA(prev: 90, next: 10, alpha: 0.35), 0.35 * 10 + 0.65 * 90, 0.01, "EMA dämpft Sprung")
        near(Double(MatchMath.nameVoteFrames), 3, 0.001, "3-Tick-Fenster")
        near(MatchMath.liveScoreAlpha, 0.35, 0.001, "Score-EMA 0,35")
        ok(!MatchMath.printStale(days: MatchMath.printAgeDays(modified: nil)), "ohne Enrollment-Datum nicht stale")
        let fresh = MatchMath.printAgeDays(modified: Date(), now: Date())
        ok((fresh ?? 1) == 0, "heute enrolled nicht stale")

        let lampsHi = MatchMath.qualityLamps(capture: 0.80, sharpness: 0.40, yaw: 0.05)
        ok(lampsHi.capture == .green && lampsHi.sharpness == .green && lampsHi.yaw == .green, "Ampel grün frontal scharf")
        let lampsLo = MatchMath.qualityLamps(capture: 0.20, sharpness: 0.08, yaw: 0.90)
        ok(lampsLo.capture == .red && lampsLo.sharpness == .red && lampsLo.yaw == .red, "Ampel rot unscharf Profil")
        let lampsMid = MatchMath.qualityLamps(capture: 0.40, sharpness: 0.15, yaw: 0.40)
        ok(lampsMid.capture == .amber && lampsMid.sharpness == .amber && lampsMid.yaw == .amber, "Ampel amber ¾")

        ok(MatchMath.orientOverride("auto") == nil, "Orient auto = videoRotationAngle")
        ok(MatchMath.orientOverride("90") == "right", "Orient 90 = right")
        ok(MatchMath.orientOverride("180") == "down", "Orient 180 = down")
        ok(MatchMath.orientOverride("270") == "left", "Orient 270 = left")
        ok(MatchMath.orientOverride("0") == "up", "Orient 0 = up")

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
