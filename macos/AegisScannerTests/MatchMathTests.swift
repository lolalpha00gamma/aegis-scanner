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

        near(MatchMath.familyBump(bestPairCosine: 0.83), 4, 0.01, "Geschwister-Cosine 0,83")
        near(MatchMath.familyBump(bestPairCosine: 0.91), 4, 0.01, "Zwillinge 0,91 brauchen den Bump")
        near(MatchMath.familyBump(bestPairCosine: 0.50), 0, 0.01, "fremd kein Bump")
        near(MatchMath.familyBump(pairwiseCosine: [0.50, 0.92]), 4, 0.01, "max-Paar 0,92")
        near(MatchMath.familyBump(pairwiseCosine: [0.50, 0.40]), 0, 0.01, "kein Paar ähnlich")

        let impostor = MatchMath.printSigmoid(cosine: 0.45)
        ok(impostor > 15 && impostor < 28, "Impostor 0,45 ≈ 20 %, nicht 58 % (ist \(impostor))")
        let genuine = MatchMath.printSigmoid(cosine: 0.75)
        ok(genuine > 90, "Genuine 0,75 über 90 % (ist \(genuine))")

        let geoOnly = MatchMath.lookOf(geo: 80, embed: 0.4, pose: 1, printMeasured: false)
        near(geoOnly, 80, 0.01, "KI aus → nur Geometrie")

        let lowPrint = MatchMath.lookOf(geo: 80, embed: 0.4, pose: 1, printMeasured: true)
        ok(lowPrint < 5, "0,4 % Print darf nicht auf 80 % Geometrie fallen (ist \(lowPrint))")

        let deadGeo = MatchMath.lookOf(geo: 20, embed: 99, pose: 1, printMeasured: true)
        ok(deadGeo >= 99, "starker Print bleibt Print, Geo 20 deckelt nicht (ist \(deadGeo))")

        let midPrintNoisy = MatchMath.lookOf(geo: 20, embed: 55, pose: 1, printMeasured: true)
        near(midPrintNoisy, 55, 0.01, "schwacher Print + tote Geo bleibt Embed")

        let cappedMid = MatchMath.lookOf(geo: 20, embed: 70, pose: 1, printMeasured: true)
        near(cappedMid, 60, 0.01, "mittlerer Print unter 84 wird bei Geo 20 auf 60 gedeckelt")

        let agree = MatchMath.lookOf(geo: 90, embed: 92, pose: 1, printMeasured: true)
        ok(agree > 92 && agree <= 96, "Print führt, Geo gibt bis +4 (ist \(agree))")

        ok(MatchMath.pruneKeepIncoming(cosine: 0.99, incomingSharp: 0.40, existingSharp: 0.20) == true, "schärfere Incoming ersetzt")
        ok(MatchMath.pruneKeepIncoming(cosine: 0.99, incomingSharp: 0.10, existingSharp: 0.40) == false, "unscharfe Incoming raus")
        ok(MatchMath.pruneKeepIncoming(cosine: 0.90, incomingSharp: 0.40, existingSharp: 0.10) == nil, "0,90 kein Prune")
        ok(MatchMath.nameVoteFrames == 5, "Live 5 Ticks")
        ok(MatchMath.nameMajority(["A", "A", "B"]) == "A", "Namens-Mehrheit 2 von 3")
        ok(MatchMath.nameMajority(["A", "B", "B"]) == "B", "wechselt nach 2 Ticks")
        ok(MatchMath.nameMajority(["A", "B", "A"]) == "A", "Gleichstand → älteres A")
        ok(MatchMath.nameMajority(["A", "B", "B", "B", "B"]) == "B", "5-Tick kippt nach Mehrheit")
        ok(MatchMath.nameMajority(["A"]) == "A", "ein Tick")
        ok(MatchMath.nameMajority([]) == nil, "leere History")
        near(MatchMath.liveScoreEMA(prev: nil, next: 90), 90, 0.01, "erster Score roh")
        near(MatchMath.liveScoreEMA(prev: 90, next: 10, alpha: 0.35), 0.35 * 10 + 0.65 * 90, 0.01, "EMA dämpft Sprung")
        let idA = UUID(uuidString: "00000000-0000-0000-0000-00000000000A")!
        let idB = UUID(uuidString: "00000000-0000-0000-0000-00000000000B")!
        near(MatchMath.votedPercent(versus: [(idA, 91), (idB, 70)], identityId: idB, fallback: 91), 70, 0.01, "Vote nimmt Prozent von B")
        near(MatchMath.votedPercent(versus: [(idA, 91)], identityId: nil, fallback: 40), 40, 0.01, "ohne ID Fallback")
        ok(!MatchMath.geoVetoBlocks(geoAgrees: true, geoMix: 20, printPercent: 80), "einig kein Veto")
        ok(!MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 40, printPercent: 93), "93 % Print trotz Geo 40")
        ok(!MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 18, printPercent: 93), "93 % Print bleibt trotz Geo 18")
        ok(!MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 10, printPercent: 88), "88 % Print skippt Geo-Veto")
        ok(MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 18, printPercent: 80), "80 % Print tot bei Geo 18")
        ok(MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 30, printPercent: 80), "schwacher Print + Geo 30")
        ok(!MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 50, printPercent: 80), "Geo 50 kein Veto")

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
            near(tar.threshold, 95, 0.01, "FAR 10 % n=10 → höchster Impostor (floor-Index)")
            near(tar.tar, 0, 0.01, "kein Genuine ≥ 95")
        } else {
            ok(false, "TAR@FAR berechenbar")
        }

        if let tar101 = MatchMath.tar(atFar: 0.01, genuine: [90], impostor: Array(repeating: 10.0, count: 100) + [80]) {
            near(tar101.threshold, 80, 0.01, "FAR 1% / 101 Impostoren → floor-Index 80, nicht 10")
        }
        if let tar02 = MatchMath.tar(atFar: 0.2, genuine: [90, 92, 88, 70], impostor: [40, 50, 60, 95, 30, 20, 10, 5, 2, 1]) {
            near(tar02.threshold, 60, 0.01, "FAR 20 % n=10 → zweithöchster Impostor")
            near(tar02.tar, 1, 0.01, "alle Genuine ≥ 60")
        }

        let sparkLo = MatchMath.sparkLamps(captures: [0.9, 0.2], sharps: [0.4, 0.08], yaws: [0.05, 0.9])
        ok(sparkLo.capture == .red && sparkLo.sharpness == .red && sparkLo.yaw == .red, "Spark nimmt schlechtesten Frame")

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
        near(MatchMath.continuitySharpnessFloor, 0.08, 0.001, "Continuity-Floor 0,08")
        near(MatchMath.activeSharpnessFloor(continuity: false), 0.12, 0.001, "aktiv 0,12")
        near(MatchMath.activeSharpnessFloor(continuity: true), 0.08, 0.001, "aktiv Continuity 0,08")
        ok(!MatchMath.qualityRejects(capture: 0.9, size: 0.5, sharpness: 0.10, continuity: true), "Continuity 0,10 bleibt")
        ok(MatchMath.qualityRejects(capture: 0.9, size: 0.5, sharpness: 0.06, continuity: true), "Continuity 0,06 lehnt ab")
        ok(MatchMath.skipPrint(sharpness: 0.10), "Laplacian unter Floor spart den Print")
        ok(!MatchMath.skipPrint(sharpness: 0.20), "scharf geht zum Print")
        ok(!MatchMath.skipPrint(sharpness: 0.10, continuity: true), "Continuity 0,10 bleibt über 0,08")
        ok(MatchMath.skipPrint(sharpness: 0.06, continuity: true), "Continuity unter 0,08 spart")

        let lampsHi = MatchMath.qualityLamps(capture: 0.80, sharpness: 0.40, yaw: 0.05)
        ok(lampsHi.capture == .green && lampsHi.sharpness == .green && lampsHi.yaw == .green, "Ampel grün frontal scharf")
        let lampsLo = MatchMath.qualityLamps(capture: 0.20, sharpness: 0.08, yaw: 0.90)
        ok(lampsLo.capture == .red && lampsLo.sharpness == .red && lampsLo.yaw == .red, "Ampel rot unscharf Profil")
        let lampsMid = MatchMath.qualityLamps(capture: 0.40, sharpness: 0.15, yaw: 0.40)
        ok(lampsMid.capture == .amber && lampsMid.sharpness == .amber && lampsMid.yaw == .amber, "Ampel amber ¾")
        let lampsCont = MatchMath.qualityLamps(capture: 0.80, sharpness: 0.10, yaw: 0.05, continuity: true)
        ok(lampsCont.sharpness == .amber, "Continuity 0,10 Ampel amber, nicht rot")
        let lampsBuilt = MatchMath.qualityLamps(capture: 0.80, sharpness: 0.10, yaw: 0.05)
        ok(lampsBuilt.sharpness == .red, "Built-in 0,10 Ampel rot")

        ok(MatchMath.orientOverride("auto") == nil, "Orient auto = videoRotationAngle")
        ok(MatchMath.orientOverride("90") == "right", "Orient 90 = right")
        ok(MatchMath.orientOverride("180") == "down", "Orient 180 = down")
        ok(MatchMath.orientOverride("270") == "left", "Orient 270 = left")
        ok(MatchMath.orientOverride("0") == "up", "Orient 0 = up")

        ok(MatchMath.boxHysteresisHold(iou: 0.20), "IoU 0,20 hält die Box")
        ok(!MatchMath.boxHysteresisHold(iou: 0.50), "IoU 0,50 folgt sofort")
        ok(MatchMath.boxHysteresisConfirm(iouToPending: 0.40), "zweites Frame bestätigt Sprung")
        ok(!MatchMath.boxHysteresisConfirm(iouToPending: 0.10), "anderes Ziel bleibt pending")
        ok(MatchMath.ingestDuplicate(cosine: 0.96), "Cosine 0,96 = Burst-Kopie")
        ok(!MatchMath.ingestDuplicate(cosine: 0.90), "Cosine 0,90 bleibt zweite Pose")
        near(MatchMath.ingestDuplicateCosine, 0.95, 0.001, "Ingest-Duplikat 0,95")
        near(MatchMath.pinPrintCosine, 0.80, 0.001, "Pin-Print 0,80")
        ok(MatchMath.pinByPrint(cosine: 0.85), "0,85 klebt den Track")
        ok(!MatchMath.pinByPrint(cosine: 0.72), "0,72 erbt nicht mehr — Geschwister")
        near(MatchMath.leftoverIoU, 0.28, 0.001, "Leftover-IoU 0,28")
        ok(MatchMath.leftoverPin(iou: 0.30), "IoU 0,30 leftover pin")
        ok(!MatchMath.leftoverPin(iou: 0.18), "IoU 0,18 leftover kein Pin")
        near(MatchMath.strongPrintFloor, 84, 0.01, "starker Print ab 84")
        near(MatchMath.geoVetoSkipPrint, 88, 0.01, "Veto-Skip ab 88")
        ok(MatchMath.visionYawMissing(0), "Yaw 0 = Vision fehlend")
        ok(MatchMath.visionYawMissing(0.01), "Yaw 0,01 = fehlend")
        ok(!MatchMath.visionYawMissing(0.30), "Yaw 0,30 = ¾")
        let yawQ = MatchMath.yawFromLandmarks(
            leftEye: (10, 20),
            rightEye: (50, 20),
            nose: (18, 40)
        )
        ok(yawQ < -0.2, "Nase links vom Augenmittel → Yaw negativ (ist \(yawQ))")
        let yawF = MatchMath.yawFromLandmarks(
            leftEye: (10, 20),
            rightEye: (50, 20),
            nose: (30, 40)
        )
        ok(abs(yawF) < 0.08, "Nase in der Mitte → frontal (ist \(yawF))")
        let med = MatchMath.medianBlend([
            [1] + [Double](repeating: 0, count: 31),
            [0.2] + [Double](repeating: 0, count: 31),
            [0.9] + [Double](repeating: 0, count: 31)
        ])
        ok(med.count == 32, "Median-Blend dim")
        ok(med[0] > 0.8, "Median zieht nicht zum Ausreißer 0,2")
        ok(MatchMath.laborQualityRejects(capture: 0.9, size: 0.5, sharpness: 0.06), "Labor 0,06 raus")
        ok(!MatchMath.laborQualityRejects(capture: 0.9, size: 0.5, sharpness: 0.10), "Labor Continuity 0,10 bleibt (eingeschriebene Refs)")
        near(MatchMath.liveBlendAlpha(continuity: false), 0.35, 0.001, "Built-in Blend 0,35")
        near(MatchMath.liveBlendAlpha(continuity: true), 0.20, 0.001, "Continuity Blend 0,20")
        ok(!MatchMath.laborIncludesProbe(qualityRejected: true), "Labor ohne Unschärfe-Probe")
        ok(MatchMath.laborIncludesProbe(qualityRejected: false), "Labor scharfe Probe")
        ok(MatchMath.laborPairKind(probeMasked: true) == "genuine-mask", "Labor-Paar Maske")
        let hist = MatchMath.scoreHistogram([10, 12, 90, 92, 91])
        ok(hist.count == 10, "Histogramm 10 Bins (ist \(hist.count): \(hist))")
        ok(hist.contains("█") || hist.contains("▇"), "Histogramm hat Peak")

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
