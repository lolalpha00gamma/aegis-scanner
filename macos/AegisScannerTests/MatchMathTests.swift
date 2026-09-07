import CoreGraphics
import Foundation

/// `swiftc macos/AegisScanner/Models.swift macos/AegisScanner/MatchMath.swift macos/AegisScanner/BenchProtocol.swift macos/AegisScannerTests/MatchMathTests.swift -o /tmp/aegismath && /tmp/aegismath`

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
        near(cappedMid, 70, 0.01, "70 % Print bei Geo 20 bleibt 70, nicht 60")

        let eightyNoCap = MatchMath.lookOf(geo: 20, embed: 82, pose: 1, printMeasured: true)
        ok(eightyNoCap >= 82, "82 % Print nie auf 60 kappen (ist \(eightyNoCap))")

        let weakCap = MatchMath.lookOf(geo: 20, embed: 65, pose: 1, printMeasured: true)
        near(weakCap, 60, 0.01, "schwacher Print < 70 bei Geo 20 auf 60")
        ok(MatchMath.lookOfCapped(geo: 20, embed: 65), "65 % Print bei Geo 20 gekappt")
        ok(!MatchMath.lookOfCapped(geo: 20, embed: 82), "82 % nicht gekappt")
        ok(!MatchMath.lookOfCapped(geo: 20, embed: 50), "50 % schon unter 60, kein Deckel-Log")
        ok(MatchMath.lookOfCapNote(geo: 20, embed: 65) == "Print gekappt", "Deckel-Notiz")
        ok(MatchMath.lookOfCapNote(geo: 80, embed: 65) == nil, "einig keine Deckel-Notiz")
        ok(MatchMath.overlayNoteFirst("Print gekappt. Beste Nähe 60%.") == "Print gekappt", "Deckel erste Overlay-Klausel")
        ok(MatchMath.lookPrintLabel(printPercent: 82, look: 82) == "P 82 · L 82", "P/L Overlay")
        ok(MatchMath.lookPrintLabel(printPercent: 65, look: 60) == "P 65 · L 60", "P/L gekappt")
        ok(MatchMath.boxPinTakePrint(iouHold: true, printPinDifferent: true), "Print gewinnt Hysterese im selben Pass")
        ok(!MatchMath.boxPinTakePrint(iouHold: true, printPinDifferent: false), "gleiche UUID bleibt IoU")
        ok(!MatchMath.boxPinTakePrint(iouHold: false, printPinDifferent: true), "ohne Hold kein Override")
        ok(
            !MatchMath.boxPinTakePrint(iouHold: true, printPinDifferent: true, printEnrolled: false),
            "namenloser Print-Pin stiehlt IoU-Hold nicht"
        )
        ok(
            MatchMath.boxPinTakePrint(iouHold: true, printPinDifferent: true, printEnrolled: true),
            "enrolled Print-Pin darf Hold überschreiben"
        )
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.40, 0.70), (1, 0.40, 0.69)],
                sharpness: [0: 0.20, 1: 0.20],
                sameSlot: [0: false, 1: true]
            ) == 1,
            "sameSlot gewinnt gegen 0,01 Cosine"
        )
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.40, 0.82), (1, 0.40, 0.64)],
                sharpness: [0: 0.20, 1: 0.20],
                sameSlot: [:]
            ) == 0,
            "ohne Slot-Hint bleibt höherer Print"
        )
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.40, 0.75)],
                sharpness: [0: 0.20],
                sameSlot: [0: false]
            ) == 0,
            "Cross-Slot 0,75 hält leftover"
        )
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.40, 0.50)],
                sharpness: [0: 0.20],
                sameSlot: [0: false]
            ) == nil,
            "Cross-Slot ohne Print tot"
        )
        let idLook = UUID(uuidString: "00000000-0000-0000-0000-0000000000AA")!
        let idPrint = UUID(uuidString: "00000000-0000-0000-0000-0000000000BB")!
        ok(MatchMath.liveNameAgree(lookId: idLook, printId: idLook, printMeasured: true), "Look=Print tauft")
        ok(!MatchMath.liveNameAgree(lookId: idLook, printId: idPrint, printMeasured: true), "Look≠Print 3-arg keine Taufe")
        ok(MatchMath.liveNameAgree(lookId: idLook, printId: idPrint, printMeasured: false), "ohne Print Look nicht blocken")
        ok(!MatchMath.liveNameAgree(lookId: nil, printId: idPrint, printMeasured: true), "Look fehlt keine Taufe")
        ok(
            MatchMath.liveNamePrintLeads(lookId: idLook, printId: idPrint, printMeasured: true, printMargin: 12),
            "Print-Abstand 12 → Print führt"
        )
        ok(
            MatchMath.liveNamePrintLeads(lookId: idLook, printId: idPrint, printMeasured: true, printMargin: 4),
            "Fremde Margin 4 führt (Geo-Jacke)"
        )
        ok(
            !MatchMath.liveNamePrintLeads(lookId: idLook, printId: idPrint, printMeasured: true, printMargin: 4, family: true),
            "Familie Margin 4 nicht — Geschwister brauchen 8"
        )
        ok(
            MatchMath.liveNamePrintLeads(lookId: idLook, printId: idPrint, printMeasured: true, printMargin: 8, family: true),
            "Familie Margin 8 führt"
        )
        ok(
            !MatchMath.liveNamePrintLeads(lookId: idLook, printId: idPrint, printMeasured: true, printMargin: 2),
            "Print-Abstand 2 Geschwister, nicht führen"
        )
        ok(
            !MatchMath.liveNamePrintLeads(lookId: idLook, printId: idLook, printMeasured: true, printMargin: 12),
            "Look=Print braucht kein Führen"
        )
        ok(
            !MatchMath.liveNamePrintLeads(lookId: idLook, printId: idPrint, printMeasured: false, printMargin: 12),
            "ohne Print nicht führen"
        )
        ok(MatchMath.liveNamePrintLeadsNote() == "Print führt", "Print-führt-Notiz")
        ok(!MatchMath.leftoverStarvesVote(), "leftover hungert Votes nicht jeden Tick")
        ok(
            MatchMath.nameHistAppend(["A", "A"], token: "", cap: 5) == ["A", "A"],
            "leere Tokens belegen den Cap nicht"
        )
        ok(
            MatchMath.nameHistAppend(["A", "A"], token: "A", cap: 5) == ["A", "A", "A"],
            "agreeing Token hängt an"
        )
        let locked = Array(repeating: "A", count: 7)
        let afterEmpty = (0..<12).reduce(locked) { acc, _ in
            MatchMath.nameHistAppend(acc, token: "", cap: 10)
        }
        ok(afterEmpty.filter { $0 == "A" }.count == 7, "12 Uneinig wischen Taufe nicht")
        ok(MatchMath.nameLockHolds(voted: "B", locked: "A") == "B", "neue Mehrheit kippt Lock")
        ok(MatchMath.nameLockHolds(voted: nil, locked: "A") == "A", "ohne Mehrheit hält Lock")
        ok(MatchMath.nameLockHolds(voted: "", locked: "A") == "A", "leere Vote hält Lock")
        ok(MatchMath.nameLockHolds(voted: nil, locked: nil) == nil, "ohne Lock tot")
        ok(MatchMath.leftoverSkipsLock(holding: true), "leftover überspringt Lock")
        ok(!MatchMath.leftoverSkipsLock(holding: false), "ohne leftover Lock gilt")
        ok(MatchMath.leftoverLocked(locked: "A", holding: true) == nil, "Hold 0,64 kein Lock-Anna")
        ok(MatchMath.leftoverLocked(locked: "A", holding: false) == "A", "ohne Hold Lock bleibt")
        ok(
            MatchMath.nameLockHolds(voted: nil, locked: MatchMath.leftoverLocked(locked: "A", holding: true)) == nil,
            "0,64 leftover tauft nicht über Lock"
        )
        ok(
            MatchMath.nameLockHolds(voted: "A", locked: MatchMath.leftoverLocked(locked: "A", holding: true)) == "A",
            "Mehrheit tauft leftover"
        )
        ok(MatchMath.liveNameDisagreeNote() == "Look und Print uneinig", "Uneinig-Notiz")
        ok(MatchMath.printTrailAccepts(prevSlot: nil, nextSlot: "frontal"), "erster Slot darf in den Trail")
        ok(MatchMath.printTrailAccepts(prevSlot: "frontal", nextSlot: "frontal"), "gleicher Slot bleibt")
        ok(!MatchMath.printTrailAccepts(prevSlot: "frontal", nextSlot: "threeQuarter"), "¾ leert Frontal-Trail")
        ok(MatchMath.renameConflict(newName: "Anna", existing: ["Anna", "Ben"], selfName: "Ben"), "Rename-Konflikt")
        ok(!MatchMath.renameConflict(newName: "Ben", existing: ["Anna", "Ben"], selfName: "Ben"), "eigener Name kein Konflikt")
        ok(!MatchMath.renameConflict(newName: "Cara", existing: ["Anna", "Ben"], selfName: "Ben"), "neuer Name frei")
        ok(MatchMath.renameConflict(newName: "anna", existing: ["Anna"], selfName: "Ben"), "Rename case-insensitive")

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
        ok(MatchMath.nameMajorityAgreeing(["A"]) == nil, "ein agreeing Tick tauft nicht")
        ok(MatchMath.nameMajorityAgreeing(["A", "A"]) == "A", "zwei agreeing Ticks taufen")
        ok(MatchMath.nameMajorityAgreeing(["", "", "A", "A"]) == "A", "leere Look≠Print zählen nicht")
        ok(MatchMath.nameMajorityAgreeing(["A", "B", "A"]) == "A", "Mehrheit unter agreeing")
        ok(MatchMath.nameMajorityAgreeing(["A", "B"]) == nil, "Gleichstand unter need")
        ok(MatchMath.nameAgreeNeed(family: false) == 2, "Fremde 2 Ticks")
        ok(MatchMath.nameAgreeNeed(family: true) == 5, "Geschwister 5 Ticks")
        ok(MatchMath.nameAgreeNeed(family: false, dt: 0.125) == 3, "8 fps Fremde 0,28 s → 3")
        ok(MatchMath.nameAgreeNeed(family: true, dt: 0.125) == 7, "8 fps Familie 0,80 s → 7")
        ok(MatchMath.nameAgreeNeed(family: false, dt: 0.04) >= 7, "24 fps Fremde nicht 80 ms")
        ok(MatchMath.nameAgreeNeed(family: true, dt: 0.04) >= 8, "24 fps Familie länger")
        ok(MatchMath.nameClosePair(best: 84, second: 80), "Abstand 4 = close")
        ok(!MatchMath.nameClosePair(best: 90, second: 70), "Abstand 20 nicht close")
        ok(!MatchMath.nameClosePair(best: 90, second: nil), "ohne Zweit keinen close")
        ok(MatchMath.nameClosePair(best: 84, second: 80, pairCosine: 0.83), "close + Centroid 0,83")
        ok(!MatchMath.nameClosePair(best: 84, second: 80, pairCosine: 0.50), "Look-Delta ohne Cosine keine Geschwister")
        ok(MatchMath.leftoverBaptize(cosine: 0.81), "0,81 leftover tauft")
        ok(!MatchMath.leftoverBaptize(cosine: 0.64), "0,64 leftover hält, tauft nicht")
        ok(MatchMath.leftoverWipeHist(cosine: 0.64), "0,64 wischt Namens-Hist")
        ok(!MatchMath.leftoverWipeHist(cosine: 0.81), "0,81 behält Hist")
        ok(!MatchMath.leftoverBaptize(cosine: nil), "nil leftover tauft nicht")
        ok(MatchMath.nameHistCap(need: 5) >= 8, "Hist länger als Familien-Need")
        ok(MatchMath.nameMajorityAgreeing(["A", "A", "A", "A"], need: 5) == nil, "4 Familien-Ticks taufen nicht")
        ok(MatchMath.nameMajorityAgreeing(["A", "A", "A", "A", "A"], need: 5) == "A", "5 Familien-Ticks taufen")
        ok(
            MatchMath.nameMajorityAgreeing(Array(repeating: "A", count: 7), need: 7) == "A",
            "Familien-Need 7 trotz Default-Window 5"
        )
        ok(
            MatchMath.nameMajorityAgreeing(Array(repeating: "A", count: 6), need: 7) == nil,
            "6 < 7 trotz Window-Lift"
        )
        ok(MatchMath.nameMajorityAgreeing(["", "A", "A", "A", "A", "A"], need: 5) == "A", "leere Tokens hungern Familie nicht")
        ok(MatchMath.leftoverHoldLabel(cosine: 0.64) == "gehalten 0,64", "Leftover-Hold Overlay")
        ok(MatchMath.leftoverHoldLabel(cosine: 0.50) == nil, "unter Floor kein Hold-Label")
        ok(MatchMath.leftoverHoldLabel(cosine: nil) == nil, "nil kein Hold-Label")
        ok(
            MatchMath.leftoverPinStatus(count: 1, cosine: 0.64) == "Leftover-Pin 1 Track · gehalten 0,64",
            "Status mit Hold-Cosine"
        )
        let idRenA = UUID(uuidString: "00000000-0000-0000-0000-0000000000A1")!
        let idRenB = UUID(uuidString: "00000000-0000-0000-0000-0000000000B1")!
        ok(MatchMath.renameConfirmSameId(pending: idRenA, target: idRenA), "Confirm gleiche UUID")
        ok(!MatchMath.renameConfirmSameId(pending: idRenA, target: idRenB), "Confirm andere UUID tot")
        ok(!MatchMath.renameConfirmSameId(pending: nil, target: idRenA), "ohne pending kein Confirm")
        ok(MatchMath.renameConfirmExpired(since: nil, now: 10), "ohne Stempel expired")
        ok(!MatchMath.renameConfirmExpired(since: 10, now: 14, hold: 8), "4 s noch gültig")
        ok(MatchMath.renameConfirmExpired(since: 10, now: 19, hold: 8), "9 s tot")
        ok(MatchMath.slotLetter("frontal") == "F", "Slot F")
        ok(MatchMath.slotLetter("threeQuarter") == "¾", "Slot ¾")
        ok(MatchMath.slotTone("frontal") == "green", "Slot F grün")
        ok(MatchMath.slotTone("threeQuarter") == "amber", "Slot ¾ amber")
        ok(MatchMath.slotTone("profile") == "red", "Slot P rot")
        ok(MatchMath.overlayBoxKind(selected: true, pinned: true, leftover: true) == .selected, "Select vor leftover")
        ok(MatchMath.overlayBoxKind(selected: false, pinned: false, leftover: true) == .leftover, "leftover orange")
        ok(MatchMath.overlayBoxKind(selected: false, pinned: true, leftover: false) == .enrolled, "enrolled grün")
        ok(MatchMath.overlayBoxKind(selected: false, pinned: false, leftover: false) == .unmatched, "unmatched")
        ok(MatchMath.overlayBoxKind(selected: false, pinned: false, leftover: false, ghost: true) == .ghost, "Ghost vor unmatched")
        ok(MatchMath.overlayBoxDash(.leftover) == [5, 3], "leftover gestrichelt")
        ok(MatchMath.overlayBoxDash(.ghost) == [5, 3], "Ghost gestrichelt")
        ok(MatchMath.overlayBoxDash(.enrolled).isEmpty, "enrolled durchgezogen")
        ok(MatchMath.nameVoteProgress(history: ["A"], need: 3) == "1/3", "Taufe-Hold 1/3")
        ok(MatchMath.nameVoteProgress(history: ["A", "A", "A"], need: 3) == nil, "getauft kein Progress")
        ok(MatchMath.nameVoteProgress(history: ["", "A", "A"], need: 5) == "2/5", "leere Tokens zählen nicht")
        ok(MatchMath.nameLockLabel(locked: true, leftover: false, progress: "2/3") == "hält", "Lock-HUD hält")
        ok(MatchMath.nameLockLabel(locked: true, leftover: true, progress: "2/3") == "2/3", "leftover kein Lock-HUD")
        ok(MatchMath.nameLockLabel(locked: false, leftover: false, progress: "2/3") == "2/3", "ohne Lock Progress")
        ok(MatchMath.nameLockLabel(locked: false, leftover: false, progress: nil) == nil, "ohne alles tot")
        ok(MatchMath.yawVelocityFreeze(delta: 0.20), "Δyaw 0,20 friert Vote")
        ok(!MatchMath.yawVelocityFreeze(delta: 0.05), "Δyaw 0,05 läuft")
        ok(MatchMath.yawVelocityFreeze(delta: -0.18), "Vorzeichen egal")
        ok(!MatchMath.nameVoteAccepts(sharpness: 0.05, continuity: false), "Built-in unscharf keine Stimme")
        ok(MatchMath.nameVoteAccepts(sharpness: 0.20, continuity: false), "scharf zählt")
        ok(MatchMath.nameVoteAccepts(sharpness: 0.10, continuity: true), "Continuity 0,10 zählt")
        ok(!MatchMath.nameVoteAccepts(sharpness: 0.05, continuity: true), "Continuity unter 0,08 tot")
        ok(MatchMath.nameVoteAccepts(sharpness: nil, continuity: false), "ohne Schärfe darf")
        ok(!MatchMath.nameVoteAccepts(sharpness: 0.50, continuity: false, occluded: true), "Maske keine Stimme")
        ok(!MatchMath.nameVoteAccepts(sharpness: 0.50, continuity: false, gazeAway: true), "Blick weg")
        ok(!MatchMath.nameVoteAccepts(sharpness: 0.50, continuity: false, eyesClosed: true), "Lid zu")
        ok(MatchMath.eyesClosed(openIod: 0.10), "Lid 0,10 zu")
        ok(!MatchMath.eyesClosed(openIod: 0.40), "Lid 0,40 offen")
        ok(!MatchMath.eyesClosed(openIod: nil), "ohne IOD kein Close")
        ok(MatchMath.gazeAway(yaw: 0.70, pitch: 0), "Yaw Profil")
        ok(MatchMath.gazeAway(yaw: 0, pitch: 0.50), "Pitch Stirn")
        ok(!MatchMath.gazeAway(yaw: 0.10, pitch: 0.05), "frontal Blick")
        near(MatchMath.boxIoU(ax: 0, ay: 0, aw: 0.2, ah: 0.2, bx: 0, by: 0, bw: 0.2, bh: 0.2), 1, 0.01, "gleiche Box IoU 1")
        near(MatchMath.boxIoU(ax: 0, ay: 0, aw: 0.2, ah: 0.2, bx: 0.6, by: 0, bw: 0.2, bh: 0.2), 0, 0.01, "fremd IoU 0")
        ok(
            MatchMath.boxesCrossed(iouSameA: 0.05, iouSameB: 0.04, iouCrossAB: 0.70, iouCrossBA: 0.68),
            "Kreuz = Swap"
        )
        ok(
            !MatchMath.boxesCrossed(iouSameA: 0.80, iouSameB: 0.75, iouCrossAB: 0.10, iouCrossBA: 0.08),
            "gleiche Boxen kein Swap"
        )
        ok(
            !MatchMath.boxesCrossed(iouSameA: 0.05, iouSameB: 0.04, iouCrossAB: 0.10, iouCrossBA: 0.70),
            "einseitig kein Swap"
        )
        ok(
            MatchMath.boxesCrossed(iouSameA: 0.30, iouSameB: 0.32, iouCrossAB: 0.70, iouCrossBA: 0.68),
            "Keep 0,30 über Pin — Kreuz klar besser = Swap"
        )
        ok(
            !MatchMath.boxesCrossed(iouSameA: 0.40, iouSameB: 0.42, iouCrossAB: 0.48, iouCrossBA: 0.47),
            "Kreuz nur knapp besser kein Swap"
        )
        ok(MatchMath.poseVelocityFreeze(yawDelta: 0.20, pitchDelta: 0), "Yaw friert Vote")
        ok(MatchMath.poseVelocityFreeze(yawDelta: 0, pitchDelta: 0.20), "Pitch-Nicken friert Vote")
        ok(!MatchMath.poseVelocityFreeze(yawDelta: 0.05, pitchDelta: -0.04), "kleines Nicken läuft")
        ok(MatchMath.poseVelocityFreeze(yawDelta: -0.02, pitchDelta: -0.18), "Pitch Vorzeichen egal")
        ok(MatchMath.poseVelocityFreeze(yawDelta: 0, pitchDelta: 0, rollDelta: 0.20), "Roll-Schulter friert Vote")
        ok(!MatchMath.poseVelocityFreeze(yawDelta: 0.02, pitchDelta: 0.03, rollDelta: 0.04), "kleines Rollen läuft")
        ok(!MatchMath.poseVelocityFreeze(yawDelta: 0, pitchDelta: 0.12, dt: 0.125), "8 fps Pitch-Rauschen 0,12 läuft")
        ok(MatchMath.poseVelocityFreeze(yawDelta: 0, pitchDelta: 0.12, dt: 0.04), "24 fps Pitch 0,12 friert")
        ok(!MatchMath.poseVelocityFreeze(yawDelta: 0.05, pitchDelta: 0.05, dt: 0.04), "24 fps kleines Nicken läuft")
        ok(MatchMath.pairSwapIndices(count: 3).count == 3, "3 Köpfe → 3 Paare")
        ok(MatchMath.pairSwapIndices(count: 3).map { "\($0.0)-\($0.1)" }.joined(separator: ",") == "0-1,0-2,1-2", "Paare 0-1 0-2 1-2")
        ok(MatchMath.pairSwapIndices(count: 2).count == 1, "2 Köpfe → 1 Paar")
        ok(MatchMath.pairSwapIndices(count: 1).isEmpty, "1 Kopf kein Swap")
        let tid = UUID(uuidString: "ABCDEF01-2345-6789-ABCD-EF0123456789")!
        ok(MatchMath.trackLabel(tid) == "TABC", "Track-Label 3 Hex")
        ok(MatchMath.trackLabel(nil) == "T—", "ohne Track T—")
        ok(MatchMath.printDriftSpark([90, 90, 90, 90]).contains("█") || MatchMath.printDriftSpark([90, 90, 90, 90]).contains("▇"), "starker Print-Spark hoch")
        ok(MatchMath.printDriftSpark([50, 50, 50, 50]).contains("▁") || MatchMath.printDriftSpark([50, 50, 50, 50]).contains("▂"), "schwacher Print-Spark niedrig")
        ok(MatchMath.printDriftSpark([]) == "", "ohne Samples leer")
        ok(
            MatchMath.identitiesCrossed(keepA: 0.40, keepB: 0.38, crossAB: 0.78, crossBA: 0.80),
            "Print-Kreuz klar besser = Swap"
        )
        ok(
            !MatchMath.identitiesCrossed(keepA: 0.85, keepB: 0.82, crossAB: 0.40, crossBA: 0.42),
            "Keep-Print hoch kein Swap"
        )
        ok(
            !MatchMath.identitiesCrossed(keepA: 0.70, keepB: 0.68, crossAB: 0.72, crossBA: 0.71),
            "Kreuz nur knapp besser kein Swap"
        )
        ok(
            !MatchMath.identitiesCrossed(keepA: 0.10, keepB: 0.12, crossAB: 0.50, crossBA: 0.78),
            "einseitig unter Floor kein Swap"
        )
        ok(MatchMath.siblingBadge(pairCosine: 0.83) == "Geschwister?", "close Pair Badge")
        ok(MatchMath.siblingBadge(pairCosine: 0.50) == nil, "fremd kein Badge")
        ok(MatchMath.siblingBadge(pairCosine: nil) == nil, "nil kein Badge")
        ok(MatchMath.enrollmentCoach(haveFrontal: true, haveThreeQuarter: true, yaw: 0) == nil, "Pose fertig kein Coach")
        ok(MatchMath.enrollmentCoach(haveFrontal: false, haveThreeQuarter: false, yaw: 0) == "halten — Frontal sitzt", "erste Ref frontal halten")
        ok(MatchMath.enrollmentCoach(haveFrontal: false, haveThreeQuarter: false, yaw: 0.80) == "Blick zur Kamera — erste Referenz frontal", "Profil als erste Ref")
        ok(MatchMath.enrollmentCoach(haveFrontal: false, haveThreeQuarter: false, yaw: 0.40) == "Blick zur Kamera", "¾ noch nicht frontal")
        ok(MatchMath.enrollmentCoach(haveFrontal: true, haveThreeQuarter: false, yaw: 0) == "Kopf nach links drehen (¾)", "¾ fehlt")
        ok(MatchMath.enrollmentCoach(haveFrontal: true, haveThreeQuarter: false, yaw: 0.40) == "halten — ¾ sitzt", "¾ halten")
        ok(MatchMath.enrollmentCoach(haveFrontal: true, haveThreeQuarter: false, yaw: -0.80) == "etwas zurück — ¾, nicht Profil", "Profil zu weit")
        ok(MatchMath.leftoverWipeHist(cosine: 0.64), "0,64 leftover-Kiste, keine Taufe")
        ok(!MatchMath.leftoverWipeHist(cosine: 0.81), "0,81 leftover tauft — keine orange Kiste")
        ok(MatchMath.liveNameDisagreeLabel(lookName: "Anna", printName: "Ben") == "L Anna · P Ben", "Uneinig-Namen")
        ok(MatchMath.liveNameDisagreeLabel(lookName: nil, printName: "Ben") == "L — · P Ben", "Look fehlt")
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
        ok(!MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 18, printPercent: 80), "80 % Print wie lookOf — kein Veto")
        ok(MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 18, printPercent: 72), "72 % tot bei Geo 18")
        ok(MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 30, printPercent: 75), "75 % + Geo 30 veto")
        ok(!MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 50, printPercent: 75), "Geo 50 kein Veto")
        ok(
            !MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 15, printPercent: 82, yawAbs: 0.30),
            "¾ + 82 % Print: Maße vs. Frontal lügen — kein Veto"
        )
        ok(
            !MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 15, printPercent: 82, yawAbs: 0.10),
            "frontal 82 % wie lookOf — kein Veto"
        )
        ok(
            !MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 15, printPercent: 80, yawAbs: 0.28),
            "¾-Kante 80 % skip"
        )
        ok(
            MatchMath.geoVetoBlocks(geoAgrees: false, geoMix: 15, printPercent: 79, yawAbs: 0.50),
            "¾ + 79 % noch Veto"
        )
        near(MatchMath.geoVetoYawSkip, 0.28, 0.001, "Yaw-Skip 0,28 = ¾-Slot")
        near(MatchMath.geoVetoYawPrint, 80, 0.01, "Yaw-Skip ab 80 % Print")
        ok(MatchMath.leftoverNamedTrack(hadName: true), "genannter Live-Track leftover")
        ok(!MatchMath.leftoverNamedTrack(hadName: false), "namenlos kein leftover")
        ok(MatchMath.leftoverNeedsPrint(cosine: nil), "ohne Print kein leftover-Pin")
        ok(!MatchMath.leftoverNeedsPrint(cosine: 0.90), "mit Print leftover darf")
        ok(MatchMath.gallerySchema == 15, "gallery.json Schema 15")

        ok(MatchMath.holdStillSkip(iou: 0.50), "Bewegung 0,50 skippt neuen Print")
        ok(!MatchMath.holdStillSkip(iou: 0.90), "Stillstand 0,90 nimmt Print")
        near(MatchMath.holdStillIoU, 0.70, 0.001, "Hold-Still IoU 0,70")
        ok(!MatchMath.holdStillSkip(iou: 0.75, sharpness: 0.40), "Nicken + scharf nimmt Print")
        ok(MatchMath.holdStillSkip(iou: 0.75, sharpness: 0.10), "Nicken + unscharf behält alt")
        ok(MatchMath.holdStillSkip(iou: 0.50, sharpness: 0.20), "Sprung + weich skippt")
        ok(!MatchMath.holdStillSkip(iou: 0.50, sharpness: 0.40), "scharfer Reframe darf")
        near(MatchMath.leftoverPrintCosine, 0.64, 0.001, "Leftover-Print 0,64")
        ok(MatchMath.leftoverPrintOk(cosine: 0.75), "Genuine 0,75 leftover ok")
        ok(MatchMath.leftoverPrintOk(cosine: 0.65), "0,65 leftover ok")
        ok(!MatchMath.leftoverPrintOk(cosine: 0.60), "0,60 leftover zu schwach")
        ok(MatchMath.leftoverPrintOk(cosine: 0.62, sharpness: 0.30), "scharfer Genuine 0,62 leftover")
        ok(!MatchMath.leftoverPrintOk(cosine: 0.62, sharpness: 0.10), "unscharf 0,62 kein leftover")
        ok(!MatchMath.leftoverPrintOk(cosine: nil), "nil leftover kein Print")
        let leftoverE: [(index: Int, iou: Double, cosine: Double?)] = [(0, 0.40, 0.75)]
        ok(MatchMath.leftoverPick(candidates: leftoverE) == 0, "0,75 leftover pinnt (nicht 0,80)")
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.40, 0.62)], sharpness: [0: 0.30]) == 0,
            "scharf 0,62 leftover"
        )
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.40, 0.62)], sharpness: [0: 0.10]) == nil,
            "unscharf 0,62 kein leftover"
        )
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.40, 0.73), (1, 0.40, 0.72)],
                sharpness: [0: 0.10, 1: 0.42]
            ) == 1,
            "scharf 0,72 schlägt unscharf 0,73"
        )
        ok(MatchMath.leftoverScore(cosine: 0.72, sharpness: 0.42) > MatchMath.leftoverScore(cosine: 0.73, sharpness: 0.10), "Score-Bonus Schärfe")
        let idOld = UUID(uuidString: "00000000-0000-0000-0000-0000000000AA")!
        let idNew = UUID(uuidString: "00000000-0000-0000-0000-0000000000BB")!
        let leftoverA: [(index: Int, iou: Double, cosine: Double?)] = [
            (0, 0.40, 0.92),
            (1, 0.35, 0.50)
        ]
        ok(MatchMath.leftoverPick(candidates: leftoverA) == 0, "Leftover nimmt nächsten Print, nicht first-in-order")
        let leftoverB: [(index: Int, iou: Double, cosine: Double?)] = [
            (0, 0.32, 0.45),
            (1, 0.40, 0.91)
        ]
        ok(MatchMath.leftoverPick(candidates: leftoverB) == 1, "höherer Cosine gewinnt trotz zweiter Stelle")
        let leftoverC: [(index: Int, iou: Double, cosine: Double?)] = [(0, 0.10, 0.95)]
        ok(MatchMath.leftoverPick(candidates: leftoverC) == nil, "IoU unter leftover-Floor kein Pin")
        let leftoverD: [(index: Int, iou: Double, cosine: Double?)] = [(0, 0.40, nil)]
        ok(MatchMath.leftoverPick(candidates: leftoverD) == nil, "ohne Print kein leftover-Pick")
        ok(
            MatchMath.leftoverRank([(idOld, 0.40), (idNew, 0.90)]) == [idNew, idOld],
            "Leftover-Rank nächster Print zuerst"
        )
        ok(MatchMath.leftoverPinStatus(count: 0) == nil, "kein Leftover keine Statuszeile")
        ok(MatchMath.leftoverPinStatus(count: 1) == "Leftover-Pin 1 Track", "Leftover-Status 1")
        ok(
            !MatchMath.geoVetoYawSkipped(geoAgrees: false, geoMix: 15, printPercent: 82, yawAbs: 0.30),
            "Print ≥ 80 skippt Veto schon ohne Yaw-Zweig"
        )
        ok(
            !MatchMath.geoVetoYawSkipped(geoAgrees: false, geoMix: 15, printPercent: 82, yawAbs: 0.10),
            "frontal kein Yaw-Skip-Hinweis"
        )
        ok(
            !MatchMath.geoVetoYawSkipped(geoAgrees: true, geoMix: 80, printPercent: 90, yawAbs: 0.40),
            "einig kein Yaw-Skip-Hinweis"
        )
        ok(MatchMath.yawSkipNote() == "¾, Maße ignoriert", "Yaw-Skip-Notiz")
        ok(MatchMath.overlayNoteFirst("¾, Maße ignoriert. Abstand 14 Pkt zu B.") == "¾, Maße ignoriert", "Yaw-Skip erste Overlay-Klausel")
        ok(!MatchMath.poseMeterReady(frontal: 1, threeQuarter: 0), "ohne ¾ nicht fertig")
        ok(MatchMath.poseMeterReady(frontal: 1, threeQuarter: 1), "Frontal+¾ fertig")
        ok(MatchMath.poseMeterLabel(frontal: 0, threeQuarter: 1, profile: 0, upper: 0).contains("Frontal"), "Meter fehlt Frontal")
        ok(MatchMath.poseMeterLabel(frontal: 1, threeQuarter: 1, profile: 0, upper: 0).contains("fertig"), "Meter fertig")
        ok(MatchMath.preferSlotCentroid(slotCount: 1), "Slot mit Refs bevorzugt")
        ok(!MatchMath.preferSlotCentroid(slotCount: 0), "leerer Slot kein Slot-Mean")
        ok(MatchMath.slotCentroidFallsBackToFrontal(slotCount: 0), "leerer Slot → Frontal")
        ok(!MatchMath.slotCentroidFallsBackToFrontal(slotCount: 2), "Slot-Hit kein Frontal-Fallback")

        let old = Date().addingTimeInterval(-100 * 86_400)
        ok(MatchMath.printAgePaler(enrolledAt: old), "Print ≥ 90 Tage paler")
        ok(!MatchMath.printAgePaler(enrolledAt: Date()), "frischer Print nicht paler")
        ok(MatchMath.sparkContinuityFloor(sharpness: 0.10, continuity: true), "Continuity 0,10 markiert Floor")
        ok(!MatchMath.sparkContinuityFloor(sharpness: 0.10, continuity: false), "Built-in 0,10 kein Continuity-Mark")
        ok(MatchMath.liveGeoSpark(72.4) == "G72", "Live-Geo-Spark")
        ok(MatchMath.trackHoldLabel(held: true) == "gehalten", "Track gehalten")
        ok(MatchMath.trackHoldLabel(held: false) == "neu", "Track neu")
        ok(MatchMath.restoreNeedsConfirm(ageDays: 8, schemaVersion: 2, printRevision: MatchMath.printRevision), "Backup 8 Tage")
        ok(MatchMath.restoreNeedsConfirm(ageDays: 1, schemaVersion: 1, printRevision: MatchMath.printRevision), "Schema <3")
        ok(MatchMath.restoreNeedsConfirm(ageDays: 1, schemaVersion: 2, printRevision: MatchMath.printRevision), "Schema 2 < 3 Gast")
        ok(MatchMath.restoreNote(ageDays: 1, schemaVersion: nil, printRevision: nil).contains("<\(MatchMath.gallerySchema)"), "Schema <3 erwähnt")
        ok(MatchMath.boxEuroResetOnHysteresis(iou: 0.20, cosine: 0.90), "Print-Pin gewinnt gegen Hysterese-Box")
        ok(!MatchMath.boxEuroResetOnHysteresis(iou: 0.90, cosine: 0.90), "kein Hysterese-Hold kein Euro-Reset")
        ok(!MatchMath.boxEuroResetOnHysteresis(iou: 0.50, cosine: 0.40), "schwacher Print kein Euro-Reset")
        ok(MatchMath.identityRatios([true, false, true], [1, 2, 3]) == [1, 3], "Live nur Identitäts-Maße")
        ok(MatchMath.diagnoseOnly.contains("terFusion"), "TER-Fusion Diagnose")

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
        ok(MatchMath.tar(atFar: 0.001, genuine: [90], impostor: Array(repeating: 10.0, count: 50)) == nil, "0,1 % FAR n=50 undefiniert")

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
        near(MatchMath.trackPinIoU, 0.28, 0.001, "Track-Pin 0,28")
        ok(MatchMath.trackPin(iou: 0.30, enrolled: true), "enrolled IoU 0,30 klebt")
        ok(!MatchMath.trackPin(iou: 0.12, enrolled: true), "enrolled IoU 0,12 klebt nicht mehr")
        ok(MatchMath.trackPin(iou: 0.30, enrolled: false), "unerfasst IoU 0,30")
        ok(MatchMath.leftoverAdoptAllowed(adoptedEnrolled: false), "Leftover namenlos ok")
        ok(!MatchMath.leftoverAdoptAllowed(adoptedEnrolled: true), "Leftover nicht auf enrolled")
        ok(!MatchMath.iouPrintBlocks(cosine: nil), "ohne Print darf IoU")
        ok(!MatchMath.iouPrintBlocks(cosine: 0.85), "0,85 IoU ok")
        ok(MatchMath.iouPrintBlocks(cosine: 0.45), "0,45 IoU blockt UUID-Diebstahl")
        ok(MatchMath.iouPrintBlocks(cosine: 0.72), "0,72 unter pinPrint — kein Steal")
        ok(MatchMath.overlayNoteFirst("Abstand 14.0 Pkt zu B.") == "Abstand 14.0 Pkt zu B.", "Notiz ohne Klausel")
        ok(MatchMath.overlayNoteFirst("Print + Maße einig. Abstand 14 Pkt zu B.") == "Print + Maße einig", "erste Klausel Punkt")
        ok(MatchMath.overlayNoteFirst("Anna 80% und Ben 70% zu nah — nicht zugeordnet.") == "Anna 80% und Ben 70% zu nah", "erste Klausel Gedankenstrich")
        ok(MatchMath.liveGeoAgrees(printBest: nil, geoBest: nil, geoAvailable: false), "ohne Geo kein Veto")
        let geoA = UUID(uuidString: "00000000-0000-0000-0000-0000000000AA")!
        let geoB = UUID(uuidString: "00000000-0000-0000-0000-0000000000BB")!
        ok(MatchMath.liveGeoAgrees(printBest: geoA, geoBest: geoA, geoAvailable: true), "Print und Geo einig")
        ok(!MatchMath.liveGeoAgrees(printBest: geoA, geoBest: geoB, geoAvailable: true), "Print und Geo uneinig")
        ok(MatchMath.liveGeoAgrees(printBest: geoA, geoBest: geoB, geoAvailable: false), "fehlende Geo vetoet nicht")
        near(MatchMath.ratioPercent([1, 1, 1], [1, 1, 1]), 100, 1, "identische Maße ≈ 100")
        ok(MatchMath.ratioPercent([1, 1], [3, 3]) < 40, "fremde Maße niedrig")
        ok(MatchMath.ratioPercent([], [1, 1]) == 0, "leere Probe kein Geo")
        let med = MatchMath.medianComponents([[1, 10], [1.2, 8], [0.9, 9]])
        ok(med.count == 2, "Median-Komponenten dim")
        near(med[0], 1.0, 0.01, "Median erste Komponente")
        near(med[1], 9.0, 0.01, "Median zweite Komponente")
        ok(!MatchMath.overlayAlienHint(cosine: 0.75), "Genuine 0,75 kein Alien-Hint")
        ok(MatchMath.overlayAlienHint(cosine: 0.40), "Impostor 0,40 Alien-Hint")
        near(MatchMath.hintCosineFloor, 0.50, 0.001, "Hint-Cosine 0,50")
        near(MatchMath.liveCentroidFront, 0.72, 0.001, "Live-Centroid 72 % Frontal")
        near(MatchMath.oneEuroCutoff(base: 1.2, dt: 0.04), 1.2, 0.001, "24 fps Cutoff")
        ok(MatchMath.oneEuroCutoff(base: 1.2, dt: 0.125) > 1.8, "8 fps Cutoff höher")
        ok(MatchMath.oneEuroCutoff(base: 1.2, dt: 0.04, boxArea: 0.02) > 1.5, "kleine Box Cutoff höher")
        near(MatchMath.strongPrintFloor, 84, 0.01, "starker Print ab 84")
        near(MatchMath.geoVetoSkipPrint, 80, 0.01, "Veto-Skip ab 80")
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
        let blend = MatchMath.medianBlend([
            [1] + [Double](repeating: 0, count: 31),
            [0.2] + [Double](repeating: 0, count: 31),
            [0.9] + [Double](repeating: 0, count: 31)
        ])
        ok(blend.count == 32, "Median-Blend dim")
        ok(blend[0] > 0.8, "Median zieht nicht zum Ausreißer 0,2")
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
        ok(MatchMath.slotCountLabel(frontal: 2, threeQuarter: 1, profile: 0, upper: 0) == "F 2 · ¾ 1 · P 0 · U 0", "Slot-Count Liste")
        ok(MatchMath.nameLockDrops(printCosine: 0.40), "Lock drop unter 0,50")
        ok(!MatchMath.nameLockDrops(printCosine: 0.62), "Lock hält bei 0,62")
        ok(!MatchMath.nameLockDrops(printCosine: nil), "ohne Print kein Drop")
        ok(MatchMath.nameLockDrops(printCosine: nil, missing: true), "Lock-ID fehlt in Versus → Drop")
        ok(MatchMath.nameLockHolds(voted: nil, locked: "A", lockedPrint: 0.40) == nil, "schwacher Print kippt Lock")
        ok(MatchMath.nameLockHolds(voted: nil, locked: "A", lockedPrint: 0.80) == "A", "starker Print hält Lock")
        ok(MatchMath.nameLockHolds(voted: "B", locked: "A", lockedPrint: 0.20) == "B", "Mehrheit vor Drop")
        ok(MatchMath.poseMeter(frontal: 2, threeQuarter: 1, profile: 0) == "F ██ ¾ █░ P ░░", "Pose-Balken")
        ok(MatchMath.poseMeter(frontal: 0, threeQuarter: 0, profile: 0) == "F ░░ ¾ ░░ P ░░", "Pose leer")
        ok(MatchMath.coachArrow(haveFrontal: true, haveThreeQuarter: true, yaw: 0) == nil, "fertig kein Pfeil")
        ok(MatchMath.coachArrow(haveFrontal: false, haveThreeQuarter: false, yaw: 0) == "·", "halten Frontal")
        ok(MatchMath.coachArrow(haveFrontal: false, haveThreeQuarter: false, yaw: 0.80) == "‹", "Profil → links zur Kamera")
        ok(MatchMath.coachArrow(haveFrontal: true, haveThreeQuarter: false, yaw: 0) == "‹", "¾ fehlt → links")
        ok(MatchMath.coachArrow(haveFrontal: true, haveThreeQuarter: false, yaw: 0.40) == "·", "¾ halten")
        near(MatchMath.holdStillProgress(stillFor: 0), 0, 0.01, "Hold-Still 0")
        near(MatchMath.holdStillProgress(stillFor: 0.40), 0.5, 0.01, "Hold-Still halb")
        near(MatchMath.holdStillProgress(stillFor: 0.80), 1, 0.01, "Hold-Still voll")
        ok(!MatchMath.holdStillReady(stillFor: 0.40), "Hold-Still 0,4 s nicht bereit")
        ok(MatchMath.holdStillReady(stillFor: 0.80), "Hold-Still 0,8 s bereit")
        ok(MatchMath.digestShort("ABCDEF0123456789ffff") == "abcdef012345", "Digest 12 Hex")
        ok(MatchMath.digestShort("") == "", "Digest leer")
        ok(MatchMath.digestShort("xyz") == "", "Digest ohne Hex")
        near(MatchMath.eyeRoll(left: CGPoint(x: 0, y: 0), right: CGPoint(x: 1, y: 0)), 0, 0.01, "Augen waagerecht")
        ok(MatchMath.cropAligns(roll: 0.20), "12° roll aligned")
        ok(!MatchMath.cropAligns(roll: 0.05), "3° bleibt")
        ok(MatchMath.labCSVHeader().contains("percent"), "CSV Header")
        ok(MatchMath.labCSVRow(face: "a", strategy: "Aegis Ensemble", identity: "Anna, B", percent: 82.4, note: "") == "a,Aegis Ensemble,\"Anna, B\",82.4,", "CSV Quote")
        ok(MatchMath.poseDropoutResets(gap: 0.40, cameraDt: 0.125), "3 Frames Dropout reset")
        ok(!MatchMath.poseDropoutResets(gap: 0.125, cameraDt: 0.125), "ein Frame kein Reset")
        near(MatchMath.trackDt(now: 1.0, last: nil, cameraDt: 0.125), 0.125, 0.001, "ohne last = Kamera-dt")
        near(MatchMath.trackDt(now: 1.125, last: 1.0, cameraDt: 0.125), 0.125, 0.001, "stetiger Track")
        near(MatchMath.trackDt(now: 1.50, last: 1.0, cameraDt: 0.125), 0.125, 0.001, "Dropout-dt = Kamera, nicht 0,50")
        ok(MatchMath.poseFreezeAxis(yawDelta: 0.20, pitchDelta: 0, rollDelta: 0, dt: 0.125) == "Y", "Freeze-Achse Y")
        ok(MatchMath.poseFreezeAxis(yawDelta: 0, pitchDelta: 0.25, rollDelta: 0, dt: 0.125) == "P", "Freeze-Achse P")
        ok(MatchMath.poseFreezeAxis(yawDelta: 0, pitchDelta: 0, rollDelta: 0.25, dt: 0.125) == "R", "Freeze-Achse R")
        ok(MatchMath.poseFreezeAxis(yawDelta: 0.02, pitchDelta: 0.02, rollDelta: 0.02, dt: 0.125) == nil, "Rauschen keine Achse")
        near(MatchMath.printDriftSample(centroidCosine: 0.82) ?? -1, 82, 0.01, "Spark aus Cosine")
        ok(MatchMath.printDriftSample(centroidCosine: nil) == nil, "ohne Cosine kein Spark")
        let shaOk = MatchMath.shaSidecarStatus(computed: "abcdef012345", sidecar: "abcdef012345")
        ok(shaOk.ok && !shaOk.missing, "SHA gleich")
        let shaMiss = MatchMath.shaSidecarStatus(computed: "abcdef012345", sidecar: nil)
        ok(shaMiss.ok && shaMiss.missing, "SHA fehlend = alte Galerie")
        let shaBad = MatchMath.shaSidecarStatus(computed: "abcdef012345", sidecar: "deadbeef0000")
        ok(!shaBad.ok && !shaBad.missing, "SHA falsch")
        ok(MatchMath.shaVerifyNote(ok: false, missing: false) != nil, "SHA-Banner")
        ok(MatchMath.shaVerifyNote(ok: true, missing: true) == nil, "ohne Sidecar kein Banner")
        let assign2 = MatchMath.leftoverAssign(scores: [
            [0.40, 0.90],
            [0.85, 0.30]
        ])
        ok(assign2[0] == 1 && assign2[1] == 0, "2×2 Kreuz-Assign")
        let assign3 = MatchMath.leftoverAssign(scores: [
            [0.70, 0.68, nil],
            [0.69, 0.40, 0.20],
            [0.10, 0.15, 0.88]
        ])
        ok(assign3[2] == 2, "C nimmt Box 2")
        ok(assign3[0] == 1 && assign3[1] == 0, "2-opt tauscht A/B")
        let assignCols = assign3.compactMap { $0 }
        ok(Set(assignCols).count == assignCols.count, "2-opt keine Doppel-Spalte")
        let greedyTrap = MatchMath.leftoverAssign(scores: [
            [0.70, 0.68],
            [0.69, 0.40]
        ])
        ok(greedyTrap[0] == 1 && greedyTrap[1] == 0, "2-opt schlägt greedy 0,70+0,40")
        ok(MatchMath.leftoverAssign(scores: []).isEmpty, "Assign leer")
        ok(MatchMath.leftoverAdoptNeed(dt: 0.125) == 10, "8 fps leftover 1,2 s → 10")
        ok(MatchMath.leftoverAdoptNeed(dt: 0.016) == 50, "24 fps leftover 0,80 s → 50")
        ok(MatchMath.leftoverAdoptNeed(dt: 0.067) == 12, "15 fps leftover 0,80 s → 12")
        ok(MatchMath.leftoverAdoptNeed(dt: 0) == 10, "ohne dt Continuity-Takt")
        ok(!MatchMath.leftoverAdoptReady(streak: 9, need: 10), "9/10 noch nicht")
        ok(MatchMath.leftoverAdoptReady(streak: 10, need: 10), "10/10 Adopt")
        ok(MatchMath.leftoverStreakLabel(streak: 1, need: 10) == "1/10", "Streak Overlay")
        ok(MatchMath.leftoverStreakLabel(streak: 10, need: 10) == nil, "ready kein Overlay")
        ok(MatchMath.leftoverSameTarget(iou: 0.50), "gleiche Box Streak")
        ok(!MatchMath.leftoverSameTarget(iou: 0.10), "andere Box Reset")
        ok(MatchMath.leftoverStreakAdvance(prev: 2, sameTarget: true) == 3, "gleiche Box +1")
        ok(MatchMath.leftoverStreakAdvance(prev: 2, sameTarget: false) == 1, "andere Box 1")
        ok(MatchMath.palePrintDrops(enrolledAt: Date().addingTimeInterval(-100 * 86_400)), "Print ≥ 90 d drop")
        ok(!MatchMath.palePrintDrops(enrolledAt: Date()), "frischer Print bleibt")
        ok(!MatchMath.palePrintDrops(enrolledAt: nil), "ohne Datum kein Drop")
        ok(MatchMath.palePrintDroppedCount(["old", "new"], enrolledAt: { $0 == "old" ? Date().addingTimeInterval(-100 * 86_400) : Date() }) == 1, "ein Pale in zwei")
        let idCacheA = UUID(uuidString: "00000000-0000-0000-0000-0000000000CA")!
        let idCacheB = UUID(uuidString: "00000000-0000-0000-0000-0000000000CB")!
        ok(
            MatchMath.liveCentroidCacheKey(ids: [idCacheA, idCacheB], slot: "frontal", paleDropped: 0)
                == MatchMath.liveCentroidCacheKey(ids: [idCacheB, idCacheA], slot: "frontal", paleDropped: 0),
            "Key sortiert IDs"
        )
        ok(
            MatchMath.liveCentroidCacheKey(ids: [idCacheA], slot: "frontal", paleDropped: 0)
                != MatchMath.liveCentroidCacheKey(ids: [idCacheA], slot: "threeQuarter", paleDropped: 0),
            "Slot im Key"
        )
        ok(
            MatchMath.liveCentroidCacheKey(ids: [idCacheA], slot: "frontal", paleDropped: 0)
                != MatchMath.liveCentroidCacheKey(ids: [idCacheA], slot: "frontal", paleDropped: 1),
            "Pale im Key"
        )
        ok(MatchMath.headCountJumped(prev: 1, next: 2), "1→2 Flash")
        ok(!MatchMath.headCountJumped(prev: 0, next: 1), "erster Kopf kein Flash")
        ok(!MatchMath.headCountJumped(prev: 2, next: 2), "gleich kein Flash")
        ok(MatchMath.headCountJumped(prev: 2, next: 0), "alle weg Flash")
        ok(MatchMath.headCountFlashLabel(prev: 1, next: 2) == "KOPF 1→2", "Label")
        ok(MatchMath.headCountFlashLabel(prev: 0, next: 1) == nil, "erster kein Label")
        near(MatchMath.headCountFlashHold, 0.45, 0.001, "Kopf-Blitz 0,45 s")
        ok(MatchMath.motionBlurDrops(aligned: true, sharpness: 0.08), "Deskew-Blur drop")
        ok(!MatchMath.motionBlurDrops(aligned: true, sharpness: 0.18), "scharf nach Roll bleibt")
        ok(!MatchMath.motionBlurDrops(aligned: false, sharpness: 0.08), "ohne Align kein extra Drop")
        near(MatchMath.swapFlashHold(), 0.45, 0.001, "Swap-Blitz 0,45 s")

        ok(MatchMath.leftoverAmbiguous(scores: [0.70, 0.69]), "0,01 Spread = Zwilling")
        ok(!MatchMath.leftoverAmbiguous(scores: [0.82, 0.64]), "0,18 Spread klar")
        ok(!MatchMath.leftoverAmbiguous(scores: [0.80]), "ein Score nicht ambiguous")
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.40, 0.70), (1, 0.40, 0.69)],
                sharpness: [0: 0.20, 1: 0.20],
                sameSlot: [:]
            ) == nil,
            "Twin-Spread leftover kein Adopt"
        )
        ok(MatchMath.leftoverTwinBlocksBox(pairCosine: 0.92, printCosine: 0.70), "Twin + 0,70 kein Box")
        ok(!MatchMath.leftoverTwinBlocksBox(pairCosine: 0.92, printCosine: 0.81), "Twin + Print 0,80 darf")
        ok(!MatchMath.leftoverTwinBlocksBox(pairCosine: 0.70, printCosine: 0.50), "kein Twin-Paar")
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.70)],
                sharpness: [0: 0.20],
                sameSlot: [:],
                twinPair: 0.93
            ) == nil,
            "Twin-Veto leftover 0,70 tot"
        )
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.82)],
                sharpness: [0: 0.20],
                sameSlot: [:],
                twinPair: 0.93
            ) == nil,
            "Twin 0,92 Hard-Veto auch Baptize"
        )
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.82)],
                sharpness: [0: 0.20],
                sameSlot: [:],
                twinPair: 0.905
            ) == 0,
            "Twin 0,90 weich: Baptize darf"
        )
        let sticky0 = MatchMath.poseSlotSticky(prev: "frontal", raw: "threeQuarter", hold: 0)
        ok(sticky0.slot == "frontal" && sticky0.hold == 1, "F→¾ Frame 1 hält F")
        let sticky1 = MatchMath.poseSlotSticky(prev: "frontal", raw: "threeQuarter", hold: 1)
        ok(sticky1.slot == "threeQuarter" && sticky1.hold == 0, "F→¾ Frame 2 wechselt")
        let stickySame = MatchMath.poseSlotSticky(prev: "frontal", raw: "frontal", hold: 1)
        ok(stickySame.slot == "frontal" && stickySame.hold == 0, "gleicher Slot reset")
        let stickyU = MatchMath.poseSlotSticky(prev: "frontal", raw: "upper", hold: 0)
        ok(stickyU.slot == "upper", "Maske sofort U")
        ok(MatchMath.leftoverWipeMutes(until: 10.8, now: 10.4), "Wipe-Mute 400 ms")
        ok(!MatchMath.leftoverWipeMutes(until: 10.8, now: 10.9), "Mute vorbei")
        ok(!MatchMath.leftoverWipeMutes(until: nil, now: 10), "ohne Wipe kein Mute")
        near(MatchMath.leftoverWipeMuteUntil(now: 5) - 5, 0.80, 0.001, "Mute 800 ms")
        ok(MatchMath.mouthOpen(heightIod: 0.50), "Mund 0,50 Gähnen")
        ok(!MatchMath.mouthOpen(heightIod: 0.20), "Mund 0,20 zu")
        ok(!MatchMath.mouthOpen(heightIod: nil), "ohne Mund-Ratio")
        ok(!MatchMath.nameVoteAccepts(sharpness: 0.50, continuity: false, mouthOpen: true), "Gähnen keine Stimme")
        ok(MatchMath.reconnectPrefersPrint(gap: 0.45), "Dropout 450 ms Print zuerst")
        ok(!MatchMath.reconnectPrefersPrint(gap: 0.12), "8 fps IoU ok")
        ok(MatchMath.reconnectPrefersPrint(gap: 0.12, fromGhost: true), "Ghost-Print vor IoU")
        ok(!MatchMath.reconnectPrefersPrint(gap: 0.12, fromGhost: false), "ohne Ghost 8 fps IoU")
        near(MatchMath.reconnectGapSec, 0.40, 0.001, "Reconnect 0,40 s")
        near(MatchMath.leftoverAmbiguousSpread, 0.08, 0.001, "Spread 0,08")
        near(MatchMath.twinPairCosine, 0.90, 0.001, "Twin 0,90")
        near(MatchMath.mouthOpenFloor, 0.42, 0.001, "Mund-Floor")
        ok(
            MatchMath.leftoverAmbiguousBlocks(raw: [0.73, 0.72], scored: [0.73, 0.77]) == false,
            "Schärfe dreht Sieger → kein Twin-Block"
        )
        ok(
            MatchMath.leftoverAmbiguousBlocks(raw: [0.70, 0.69], scored: [0.70, 0.69]),
            "gleicher Sieger + Spread = Block"
        )
        ok(
            !MatchMath.leftoverAmbiguousBlocks(raw: [0.82, 0.64], scored: [0.82, 0.64]),
            "klarer Spread kein Block"
        )
        let ambigAssign = MatchMath.leftoverAssignDropAmbiguous(
            scores: [[0.70, 0.69], [0.88, 0.40]],
            assigned: [0, 1]
        )
        ok(ambigAssign[0] == nil, "2-opt Twin-Zeile drop")
        ok(ambigAssign[1] == 1, "klare Zeile bleibt")
        ok(MatchMath.reconnectSkipsIoU(gap: 0.45), "Dropout IoU tot")
        ok(!MatchMath.reconnectSkipsIoU(gap: 0.12), "stetig IoU bleibt")
        ok(MatchMath.reconnectGhostNeedsBaptize(fromGhost: true, cosine: 0.64), "Ghost 0,64 kein Pin")
        ok(!MatchMath.reconnectGhostNeedsBaptize(fromGhost: true, cosine: 0.82), "Ghost 0,82 darf")
        ok(!MatchMath.reconnectGhostNeedsBaptize(fromGhost: false, cosine: 0.64), "kein Ghost kein Baptize-Zwang")
        ok(MatchMath.enrollmentBurstDup(sameSlot: true, cosine: 0.97, within: 0.20), "Burst Dedup")
        ok(!MatchMath.enrollmentBurstDup(sameSlot: true, cosine: 0.97, within: 0.80), "Burst Fenster vorbei")
        ok(!MatchMath.enrollmentBurstDup(sameSlot: false, cosine: 0.97, within: 0.20), "anderer Slot kein Dedup")
        ok(MatchMath.printDeadLabel(capture: 0.8, sharpness: 0.05, masked: false) == "Print tot · unscharf", "tot weil unscharf")
        ok(MatchMath.printDeadLabel(capture: 0.8, sharpness: 0.40, masked: true) == "Print tot · Maske?", "tot + Maske nur mit Augen/Mund")
        ok(MatchMath.printDeadLabel(capture: 0.8, sharpness: 0.40, masked: false) == "Print tot", "tot ohne Okklusions-Rate")
        ok(MatchMath.printDeadLabel(capture: 0.20, sharpness: 0.40, masked: false) == "Print tot · Aufnahme schwach", "tot schwach")
        ok(MatchMath.unknownReject(bestPercent: 42), "Open-Set unter 50")
        ok(!MatchMath.unknownReject(bestPercent: 78), "78 % tauft")
        ok(MatchMath.unknownRejectNote() == "unbekannt — keine Nähe", "Unknown-Note")
        near(MatchMath.liveGhostHold(), MatchMath.leftoverAdoptSec, 0.001, "Ghost-TTL 24 fps = leftover 1,2 s")
        ok(MatchMath.leftoverAdoptReady(elapsed: 1.20, streak: 3), "1,2 s + 3 Frames")
        ok(!MatchMath.leftoverAdoptReady(elapsed: 0.40, streak: 10), "10 Frames bei 0,4 s reicht nicht")
        ok(!MatchMath.leftoverAdoptReady(elapsed: 1.20, streak: 1), "1 Frame reicht nicht")
        ok(MatchMath.leftoverWipeMutes(until: 10, now: 9.5), "Wipe-Mute ohne Hist")
        ok(!MatchMath.leftoverWipeMutes(until: 10, now: 9.5, histCount: 7), "starke Lock nicht stumm")
        ok(MatchMath.leftoverWipeMutes(until: 10, now: 9.5, histCount: 2), "schwache Hist stumm")
        ok(!MatchMath.leftoverWipeMutes(until: 10, now: 10.1, histCount: 0), "Mute abgelaufen")
        ok(MatchMath.leftoverStreakLabel(elapsed: 0.12) == "1/10", "0,12 s → 1/10")
        ok(MatchMath.leftoverStreakLabel(elapsed: 0.60) == "5/10", "halbe Zeit 5/10")
        ok(MatchMath.leftoverStreakLabel(elapsed: 1.20) == nil, "1,2 s ready kein Overlay")
        ok(MatchMath.leftoverStreakLabel(elapsed: 0) == nil, "0 s still")
        ok(!MatchMath.mirrorAsFront(positionFront: false, unspecified: true, deskView: true), "Desk-View nicht spiegeln")
        ok(MatchMath.mirrorAsFront(positionFront: true, unspecified: false, deskView: false), "FaceTime Front")
        ok(MatchMath.mirrorAsFront(positionFront: false, unspecified: true, deskView: false), "unspecified Front")
        ok(!MatchMath.mirrorAsFront(positionFront: false, unspecified: false, deskView: false), "Back tot")
        near(MatchMath.medianLiveDt([0.125, 0.120, 0.50, 0.130]), 0.125, 0.01, "Dropout 0,50 raus")
        near(MatchMath.medianLiveDt([], fallback: 0.125), 0.125, 0.001, "leer = Fallback")
        ok(!MatchMath.nameLockExpired(lastVote: 1, now: 8), "7 s hält Lock")
        ok(MatchMath.nameLockExpired(lastVote: 1, now: 9.1), "8 s Lock tot")
        ok(!MatchMath.nameLockExpired(lastVote: nil, now: 20), "ohne Vote kein TTL")
        ok(MatchMath.nameLockHolds(voted: nil, locked: "A", lastVote: 1, now: 10) == nil, "TTL kippt Lock")
        ok(MatchMath.nameLockHolds(voted: "A", locked: "A", lastVote: 1, now: 10) == "A", "Vote schlägt TTL")
        ok(MatchMath.nameLockHolds(voted: nil, locked: "A") == "A", "ohne now hält Lock")
        let blink = MatchMath.liveFacesLatch(present: true, on: false, streak: 0)
        ok(!blink.on && blink.streak == 1, "1. Frame kein 8 fps")
        let latch2 = MatchMath.liveFacesLatch(present: true, on: false, streak: 1)
        ok(latch2.on, "2. Frame 8 fps")
        let gone = MatchMath.liveFacesLatch(present: false, on: true, streak: 0)
        ok(!gone.on && gone.streak == 0, "weg → 5 fps")
        ok(MatchMath.liveDuplicate(iou: 0.46, nested: 0.10), "Live-IoU 0,45")
        ok(MatchMath.liveDuplicate(iou: 0.20, nested: 0.60), "Live nested Tile-Twin")
        ok(!MatchMath.liveDuplicate(iou: 0.30, nested: 0.40), "zwei Personen kein Twin")
        near(MatchMath.leftoverHoldEMA(prev: 0.64, next: 0.70), 0.35 * 0.70 + 0.65 * 0.64, 0.001, "Hold-EMA")
        near(MatchMath.leftoverHoldEMA(prev: nil, next: 0.64), 0.64, 0.001, "erster Hold roh")
        ok(MatchMath.printCacheDropCount(count: 512) == 0, "512 hält")
        ok(MatchMath.printCacheDropCount(count: 513) == 1, "513 älteste raus")
        ok(MatchMath.printCacheDropCount(count: 600) == 88, "Burst drop auf Cap")
        ok(
            MatchMath.leftoverScore(cosine: 0.80, sharpness: nil, yawAbs: 0)
                > MatchMath.leftoverScore(cosine: 0.80, sharpness: nil, yawAbs: 0.50),
            "Yaw-Penalty"
        )
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.78), (1, 0.50, 0.78)],
                sameSlot: [0: true, 1: true],
                yawAbs: [0: 0.50, 1: 0.05]
            ) == 1,
            "Frontal schlägt Profil bei gleichem Print"
        )
        let majA = UUID()
        let majB = UUID()
        let s1 = MatchMath.leftoverAssignMajority(committed: nil, proposed: majA, lastProposed: nil, streak: 0)
        ok(!s1.ready && s1.streak == 1, "1. Tick kein Switch")
        let s2 = MatchMath.leftoverAssignMajority(committed: nil, proposed: majA, lastProposed: s1.last, streak: s1.streak)
        ok(!s2.ready && s2.streak == 2, "2. Tick")
        let s3 = MatchMath.leftoverAssignMajority(committed: nil, proposed: majA, lastProposed: s2.last, streak: s2.streak)
        ok(s3.ready && s3.commit == majA, "3. Tick Switch")
        let flip = MatchMath.leftoverAssignMajority(committed: nil, proposed: majB, lastProposed: majA, streak: 2)
        ok(!flip.ready && flip.streak == 1, "Kreuz setzt Streak")
        ok(MatchMath.leftoverMajorityLabel(streak: 1) == "MAJ 1/3", "MAJ-Label")
        ok(MatchMath.leftoverMajorityLabel(streak: 3) == nil, "ready kein MAJ")
        ok(!MatchMath.printBudgetSkip(visionMs: 10, dt: 0.016), "10 ms Print frei")
        ok(MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016), "24 fps 19 ms Print skip")
        ok(!MatchMath.printBudgetSkip(visionMs: 19, dt: 0.125), "8 fps Print bleibt")
        ok(MatchMath.nameLockTTLLabel(lastVote: 1, now: 5.5) != nil, "TTL letzte 4 s")
        ok(MatchMath.nameLockTTLLabel(lastVote: 1, now: 2) == nil, "TTL 6 s noch still")
        ok(MatchMath.nameLockTTLLabel(lastVote: nil, now: 10) == nil, "ohne Vote kein TTL-Chip")
        ok(MatchMath.nameLockLabel(locked: true, leftover: false, progress: nil, ttl: "TTL 3s") == "hält · TTL 3s", "Lock+TTL")
        ok(MatchMath.posterFaceReject(jitter: 0, frames: 4), "Poster 4 Frames tot")
        ok(!MatchMath.posterFaceReject(jitter: 0.01, frames: 4), "lebendes Gesicht")
        ok(!MatchMath.posterFaceReject(jitter: 0, frames: 2), "zu früh")
        ok(MatchMath.boxAspectFrontal(width: 80, height: 100), "Frontal-Aspekt")
        ok(!MatchMath.boxAspectFrontal(width: 20, height: 100), "Profil-schmal")
        near(MatchMath.printCommitMedian([0.70, 0.90, 0.72]) ?? -1, 0.72, 0.001, "Median nicht Mittel")
        ok(MatchMath.printCommitMedian([]) == nil, "leerer Median")
        ok(MatchMath.exposureLocks(now: 1.10, until: 1.20), "AE-Lock 200 ms")
        ok(!MatchMath.exposureLocks(now: 1.21, until: 1.20), "AE frei")
        near(MatchMath.exposureLockUntil(now: 1.0) - 1.20, 0, 0.001, "AE +200 ms")
        ok(MatchMath.partialPrintMasked(occluded: true, hasUpperRefs: true), "Maske + U-Refs")
        ok(!MatchMath.partialPrintMasked(occluded: true, hasUpperRefs: false), "Maske ohne U")
        ok(MatchMath.unknownCentroid(bestCosine: 0.40), "Centroid unbekannt")
        ok(!MatchMath.unknownCentroid(bestCosine: 0.80), "Centroid bekannt")
        ok(MatchMath.unknownCentroid(bestCosine: nil), "nil unbekannt")
        ok(MatchMath.leftoverPickAspect(ok: false, cosine: 0.70) == false, "schmal ohne Baptize tot")
        ok(MatchMath.leftoverPickAspect(ok: false, cosine: 0.82), "schmal + Baptize darf")
        ok(MatchMath.leftoverPickAspect(ok: true, cosine: 0.66), "Frontal-Aspekt frei")
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.70)],
                aspectOk: [0: false]
            ) == nil,
            "Profil-schmal 0,70 kein leftover"
        )
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.82)],
                aspectOk: [0: false]
            ) == 0,
            "Profil-schmal 0,82 Baptize"
        )
        let j0 = MatchMath.landmarkJitter(
            prev: [Point2(x: 0, y: 0), Point2(x: 1, y: 0), Point2(x: 0, y: 1), Point2(x: 1, y: 1)],
            next: [Point2(x: 0, y: 0), Point2(x: 1, y: 0), Point2(x: 0, y: 1), Point2(x: 1, y: 1)]
        )
        ok(j0 < 1e-9, "Poster-Jitter 0")
        ok(MatchMath.posterStillAdvance(jitter: 0, streak: 3) == 4, "Poster-Streak")
        ok(MatchMath.posterStillAdvance(jitter: 0.01, streak: 3) == 0, "Leben setzt Streak")
        ok(MatchMath.captureJumps(prev: 0.40, next: 0.60), "AE-Sprung 0,20")
        ok(!MatchMath.captureJumps(prev: 0.40, next: 0.45), "0,05 kein AE-Sprung")
        near(MatchMath.leftoverHoldSmooth(raw: 0.70, prev: 0.64) ?? -1, 0.35 * 0.70 + 0.65 * 0.64, 0.001, "Smooth vor Pick")
        ok(MatchMath.leftoverHoldSmooth(raw: nil, prev: 0.64) == nil, "ohne Print kein Smooth")
        ok(MatchMath.leftoverHoldBlocks(raw: 0.70, prev: 0.64), "Spike 0,06 blockt Taufe")
        ok(!MatchMath.leftoverHoldBlocks(raw: 0.82, prev: 0.64), "Baptize 0,82 darf")
        ok(!MatchMath.leftoverHoldBlocks(raw: 0.70, prev: nil), "erster Frame roh")
        ok(!MatchMath.leftoverHoldBlocks(raw: 0.65, prev: 0.64), "0,01 kein Spike")
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.50, 0.70)], holdPrev: 0.64) == nil,
            "Twin-Spike 0,70 nach Hold 0,64 kein Pick"
        )
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.50, 0.82)], holdPrev: 0.64) == 0,
            "Baptize 0,82 trotz Spike"
        )
        ok(MatchMath.mergeSuggest(pairCosine: 0.91), "0,91 Merge-Vorschlag")
        ok(!MatchMath.mergeSuggest(pairCosine: 0.88), "unter 0,89 still")
        ok(!MatchMath.mergeSuggest(pairCosine: 0.95), "0,95 Twin, kein Wizard")
        near(MatchMath.unknownRejectFloor(slider: 78), 50, 0.01, "Slider 78 → Floor 50")
        near(MatchMath.unknownRejectFloor(slider: 70), 42, 0.01, "Slider 70 → 42")
        near(MatchMath.unknownRejectFloor(slider: 96), 68, 0.01, "Slider 96 → 68")
        ok(MatchMath.unknownReject(bestPercent: 49, floor: MatchMath.unknownRejectFloor(slider: 78)), "Open-Set Slider")
        var order = [Data([1]), Data([2]), Data([3])]
        MatchMath.printCacheTouch(order: &order, key: Data([1]))
        ok(order.last == Data([1]), "LRU hit ans Ende")
        ok(order.first == Data([2]), "älteste bleibt vorn")

        ok(MatchMath.leftoverShowsName(cosine: 0.82), "Baptize zeigt Namen")
        ok(!MatchMath.leftoverShowsName(cosine: 0.70), "0,70 leftover kein Name")
        ok(!MatchMath.leftoverShowsName(cosine: nil), "nil kein Name")
        ok(MatchMath.unknownStickyName(index: 1) == "Gast 1", "Gast 1")
        ok(MatchMath.unknownStickyKeeps(bestCosine: 0.40, enrolled: true), "Gast hält UUID")
        ok(!MatchMath.unknownStickyKeeps(bestCosine: 0.80, enrolled: true), "Print darf pin")
        ok(MatchMath.leftoverTwinSuggest(pairCosine: 0.91), "Twin-Wizard 0,91")
        ok(!MatchMath.leftoverTwinSuggest(pairCosine: 0.70), "fremd kein Twin")
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.50, 0.70)], twinPair: 0.91) == nil,
            "Twin 0,91 leftover tot"
        )
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.50, 0.70)], twinPair: 0.895) == nil,
            "Twin 0,895 Wizard, nicht leftover"
        )
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.50, 0.70)], twinPair: 0.50) == 0,
            "fremd leftover darf"
        )
        ok(MatchMath.twoPersonAnd(printAgree: true, geoAgree: false, gallery: 2) == false, "2 Personen AND")
        ok(MatchMath.twoPersonAnd(printAgree: true, geoAgree: false, gallery: 8), "8 Personen kein AND")
        ok(MatchMath.twoPersonAnd(printAgree: true, geoAgree: true, gallery: 2), "2 Personen einig")
        let hinted = MatchMath.mergeHintLabel(count: 3, a: "Anna", b: "Annika", cosine: 0.91)
        ok(hinted.contains("+2"), "Merge +2 weitere")
        ok(MatchMath.mergeHintLabel(count: 1, a: "A", b: "B", cosine: 0.90).contains("zusammenführen"), "ein Paar")
        let pairs = MatchMath.mergeSuggestPairs([(0, 1, 0.91), (0, 2, 0.50), (1, 2, 0.93)])
        ok(pairs.count == 2 && pairs[0].2 >= pairs[1].2, "Merge-Paare sortiert")
        ok(MatchMath.livenessBlink(prevClosed: true, nowClosed: false), "Lid auf = Blink")
        ok(!MatchMath.livenessBlink(prevClosed: false, nowClosed: false), "offen bleibt")
        ok(MatchMath.posterNeedsBlink(stillFrames: 8, blinked: false), "Poster ohne Blink")
        ok(!MatchMath.posterNeedsBlink(stillFrames: 8, blinked: true), "geblinkt lebt")
        ok(MatchMath.posterBlinkNote() == "BLINK", "BLINK-Note")
        ok(MatchMath.boxKalmanUses(dt: 0.125), "8 fps Kalman")
        ok(!MatchMath.boxKalmanUses(dt: 0.016), "24 fps 1-Euro")
        ok(MatchMath.clusterSplitAdvance(prev: 3, changed: true) == 4, "Split +1")
        ok(MatchMath.clusterSplitAdvance(prev: 3, changed: false) == 3, "Split hält")
        ok(MatchMath.clusterSplit(disagree: 10), "10 Ticks Split")
        ok(!MatchMath.clusterSplit(disagree: 3), "3 Ticks kein Split")
        ok(MatchMath.visionQualityLamp(0.80) == .green, "Vision grün")
        ok(MatchMath.visionQualityLamp(0.10) == .red, "Vision rot")
        let kal = MatchMath.boxKalman(prev: 0.20, meas: 0.80, p: 0.04, dt: 0.125)
        ok(kal.x > 0.20 && kal.x < 0.80, "Kalman zwischen")
        ok(MatchMath.centroidWeight(capture: 1, sharpness: 1) > MatchMath.centroidWeight(capture: 0.2, sharpness: 0.1), "Centroid-Gewicht")
        let sharpMul = MatchMath.leftoverScore(cosine: 0.72, sharpness: 0.42)
        let blurMul = MatchMath.leftoverScore(cosine: 0.73, sharpness: 0.10)
        ok(sharpMul > blurMul, "Score multiplikativ Schärfe (\(sharpMul) > \(blurMul))")

        let anna = UUID(uuidString: "00000000-0000-0000-0000-0000000000A1")!
        let bob = UUID(uuidString: "00000000-0000-0000-0000-0000000000B2")!
        ok(MatchMath.leftoverYieldsToLive(liveId: anna, leftoverId: bob), "Live Anna, leftover Bob weicht")
        ok(!MatchMath.leftoverYieldsToLive(liveId: anna, leftoverId: anna), "gleiche ID leftover frei")
        ok(!MatchMath.leftoverYieldsToLive(liveId: nil, leftoverId: bob), "kein Live-Name leftover frei")
        ok(MatchMath.conflictTickAgrees(boxId: anna, printId: anna, geoId: anna, lockId: anna), "alle einig")
        ok(!MatchMath.conflictTickAgrees(boxId: anna, printId: bob, geoId: nil, lockId: nil), "BOX≠PRINT Konflikt")
        ok(MatchMath.conflictTickAgrees(boxId: nil, printId: anna, geoId: bob, lockId: nil, geoMix: 20), "Geo 20 votet nicht")
        ok(!MatchMath.conflictTickAgrees(boxId: nil, printId: anna, geoId: bob, lockId: nil, geoMix: 80), "Geo 80 ≠ Print")
        ok(MatchMath.conflictTickBaptize(boxId: anna, printId: anna, geoId: anna, lockId: anna) == anna, "Baptize einig")
        ok(MatchMath.conflictTickBaptize(boxId: anna, printId: bob, geoId: nil, lockId: nil) == nil, "Baptize tot")
        ok(MatchMath.conflictTickNote() == "KONFLIKT", "KONFLIKT-Note")
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.50, 0.85)], liveIds: [0: anna], leftoverId: bob) == nil,
            "leftover weicht Live-Taufe"
        )
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.50, 0.85)], liveIds: [0: anna], leftoverId: anna) == 0,
            "leftover = Live darf"
        )
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.50, 0.85)], leftoverId: bob, printId: anna) == 0,
            "Track-UUID ≠ Print-ID leftover darf ohne Live-Name"
        )
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.85)],
                leftoverId: bob,
                printId: anna,
                geoId: bob,
                geoMix: 80
            ) == nil,
            "Print≠Geo leftover tot"
        )
        ok(
            MatchMath.liveCentroidCacheKey(ids: [anna], slot: "frontal", paleDropped: 0, camera: "builtin")
                != MatchMath.liveCentroidCacheKey(ids: [anna], slot: "frontal", paleDropped: 0, camera: "continuity"),
            "Centroid je Kamera"
        )
        ok(
            MatchMath.liveCentroidCacheKey(ids: [anna], slot: "frontal", paleDropped: 0)
                == MatchMath.liveCentroidCacheKey(ids: [anna], slot: "frontal", paleDropped: 0, camera: nil),
            "ohne Kamera alter Key"
        )
        ok(MatchMath.enrollBurstReady(count: 3), "Burst 3 fertig")
        ok(!MatchMath.enrollBurstReady(count: 2), "Burst 2 zu früh")
        ok(MatchMath.enrollBurstPick(sharpness: [0.10, 0.42, 0.20]) == 1, "schärfstes Ref")
        ok(MatchMath.enrollBurstReplace(incomingSharp: 0.40, existingSharp: 0.20), "schärfer ersetzt")
        ok(!MatchMath.enrollBurstReplace(incomingSharp: 0.20, existingSharp: 0.40), "unschärfer bleibt")
        near(MatchMath.liveFAR(impostorAbove: 1, totalImpostor: 10), 0.10, 0.001, "FAR 10 %")
        ok(MatchMath.liveFARLabel(0.10) == "FAR 10.0%", "FAR-Label")
        ok(MatchMath.guestPersistId(index: 1) == "guest.1", "Gast-ID")
        ok(MatchMath.guestPersistName("guest.2") == "Gast 2", "Gast-Name")
        ok(MatchMath.guestPersistKeeps(name: "Gast 1"), "Gast sticky")
        ok(MatchMath.guestPersistKeeps(name: "guest.1"), "guest sticky")
        ok(!MatchMath.guestPersistKeeps(name: "Anna"), "Anna kein Gast")
        near(MatchMath.leftoverStreakSincePersist(since: nil, now: 4), 4, 0.001, "Streak-Since start")
        near(MatchMath.leftoverStreakSincePersist(since: 1.5, now: 4), 1.5, 0.001, "Streak-Since hält")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.64), "0,64 hält, stiehlt keine UUID")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.70), "0,70 leftover kein Transfer")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.82), "0,82 ohne Hold keine Taufe")
        ok(!MatchMath.leftoverTransfersId(cosine: nil), "nil kein Transfer")
        ok(MatchMath.leftoverBaptizeSpike(raw: 0.82, prev: 0.64), "0,82 nach 0,64 Twin-Spike")
        ok(!MatchMath.leftoverBaptizeSpike(raw: 0.82, prev: 0.80), "0,82 nach 0,80 kein Spike")
        ok(!MatchMath.leftoverBaptizeSpike(raw: 0.82, prev: nil), "ohne Hold kein Spike")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.64), "0,82 nach 0,64 kein Steal")
        ok(MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.80), "0,82 nach 0,80 Steal")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.82, trail: [0.64, 0.64, 0.80]), "MAD-Trail blockt Steal")
        ok(MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.64, trail: [0.81, 0.82, 0.83]), "3 Baptize nach Spike = Anstieg")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.64, trail: [0.80, 0.81]), "2 Baptize noch Twin")
        let idHoldA = UUID(uuidString: "00000000-0000-0000-0000-0000000000C3")!
        let idHoldB = UUID(uuidString: "00000000-0000-0000-0000-0000000000D4")!
        ok(MatchMath.guestIndex(of: idHoldA, order: [idHoldA, idHoldB]) == 1, "Gast 1 Index")
        ok(MatchMath.guestIndex(of: idHoldB, order: [idHoldA, idHoldB]) == 2, "Gast 2 Index")
        ok(MatchMath.guestIndex(of: idHoldA, order: []) == 1, "unbekannt Gast 1")
        ok(MatchMath.guestOrderAppend(id: idHoldA, onto: []) == [idHoldA], "Order start")
        ok(MatchMath.guestOrderAppend(id: idHoldB, onto: [idHoldA]) == [idHoldA, idHoldB], "Order append")
        ok(MatchMath.guestOrderAppend(id: idHoldA, onto: [idHoldA]) == [idHoldA], "Order kein Duplikat")
        ok(MatchMath.unknownStickyName(index: MatchMath.guestIndex(of: idHoldB, order: [idHoldA, idHoldB])) == "Gast 2", "Gast 2 Name")
        let boxA = FaceBox(x: 0.10, y: 0.20, width: 0.15, height: 0.20)
        let boxB = FaceBox(x: 0.11, y: 0.21, width: 0.15, height: 0.20)
        let boxFar = FaceBox(x: 0.80, y: 0.80, width: 0.15, height: 0.20)
        ok(MatchMath.leftoverBoxHash(boxA) == MatchMath.leftoverBoxHash(boxB), "nahe Box gleicher Hash")
        ok(MatchMath.leftoverBoxHash(boxA) != MatchMath.leftoverBoxHash(boxFar), "ferne Box anderer Hash")
        let pxA = FaceBox(x: 200, y: 180, width: 120, height: 140)
        let pxB = FaceBox(x: 900, y: 400, width: 120, height: 140)
        ok(MatchMath.leftoverBoxHash(pxA) == MatchMath.leftoverBoxHash(pxB), "Pixel ohne Bildmaß ein Bin")
        ok(MatchMath.leftoverBoxHash(pxA, imageW: 1280, imageH: 720) != MatchMath.leftoverBoxHash(pxB, imageW: 1280, imageH: 720), "Pixel mit Bildmaß getrennt")
        let uA = MatchMath.leftoverBoxUnit(pxA, imageW: 1280, imageH: 720)
        ok(uA.cx > 0.1 && uA.cx < 0.3, "Pixel-Unit cx")
        let hashPx = MatchMath.leftoverHoldWriteHash(
            kalmanX: 200, kalmanY: 180, kalmanW: 120, kalmanH: 140,
            fallback: pxA, imageW: 1280, imageH: 720
        )
        let hashFar = MatchMath.leftoverHoldWriteHash(
            kalmanX: 900, kalmanY: 400, kalmanW: 120, kalmanH: 140,
            fallback: pxB, imageW: 1280, imageH: 720
        )
        ok(hashPx != hashFar, "Hold-Write Pixel getrennt")
        var blurTab: [String: (samples: [Double], at: TimeInterval)] = [:]
        blurTab = MatchMath.leftoverTrailPut(hash: "9.9.9.9", sample: 0.70, onto: blurTab, now: 1, sharpness: 0.10)
        ok(MatchMath.leftoverTrailLookup(hash: "9.9.9.9", table: blurTab, now: 1.1).isEmpty, "Blur-Trail kein Append")
        var holdTab: [String: (cosine: Double, at: TimeInterval)] = [:]
        holdTab = MatchMath.leftoverHoldPut(hash: "1.2.3.4", cosine: 0.64, onto: holdTab, now: 10)
        ok(abs((MatchMath.leftoverHoldLookup(hash: "1.2.3.4", table: holdTab, now: 10.5) ?? -1) - 0.64) < 0.001, "Hold überlebt Dropout")
        ok(MatchMath.leftoverHoldLookup(hash: "1.2.3.4", table: holdTab, now: 12.0) == nil, "Hold TTL 1,2 s")
        ok(MatchMath.leftoverHoldLookup(hash: "9.9.9.9", table: holdTab, now: 10.1) == nil, "anderer Hash leer")
        let neigh = MatchMath.leftoverBoxHashNeighbors("1.2.3.4")
        ok(neigh.contains("1.2.3.4"), "Nachbar enthält Exact")
        ok(neigh.contains("1.3.3.4"), "Nachbar cy+1")
        ok(neigh.contains("2.2.3.4"), "Nachbar cx+1")
        ok(neigh.contains("1.2.4.4"), "Nachbar Breite w+1")
        ok(neigh.contains("1.2.3.5"), "Nachbar Höhe h+1")
        ok(!neigh.contains("9.9.9.9"), "ferne Bins nicht")
        ok(abs((MatchMath.leftoverHoldLookup(hash: "1.3.3.4", table: holdTab, now: 10.5) ?? -1) - 0.64) < 0.001, "Hold über Bin-Kante")
        ok(abs((MatchMath.leftoverHoldLookup(hash: "1.2.4.4", table: holdTab, now: 10.5) ?? -1) - 0.64) < 0.001, "Hold über Größen-Kante")
        ok(MatchMath.leftoverHoldLookup(hash: "9.9.9.9", table: holdTab, now: 10.5) == nil, "ferner Hash kein Nachbar")
        ok(MatchMath.printMAD([0.64]) == nil, "1 Sample kein MAD")
        ok(MatchMath.printMAD([0.64, 0.65]) == nil, "2 Samples kein MAD")
        ok(!MatchMath.printMADBlocks([0.64, 0.65]), "unter 3 kein Block")
        ok(MatchMath.printMADBlocks([0.64, 0.64, 0.80]), "Twin 0,80 neben 0,64 blockt")
        ok(!MatchMath.printMADBlocks([0.80, 0.81, 0.82]), "Baptize-Band kein MAD")
        ok(MatchMath.printMADNote() == "MAD", "MAD-Note")
        ok(MatchMath.guestIndex(of: UUID(uuidString: "00000000-0000-0000-0000-0000000000E5")!, order: [idHoldA]) == 2, "unbekannt ist Gast 2 nicht Gast 1")
        ok(MatchMath.guestOrderKeeps(id: idHoldA, live: [idHoldA], lastSeen: nil, now: 10), "live hält")
        ok(MatchMath.guestOrderKeeps(id: idHoldA, live: [], lastSeen: 9, now: 10), "8 s Dropout hält")
        ok(!MatchMath.guestOrderKeeps(id: idHoldA, live: [], lastSeen: 1, now: 10), "9 s Dropout tot")
        ok(!MatchMath.guestOrderKeeps(id: idHoldA, live: [], lastSeen: nil, now: 10), "ohne Seen tot")
        ok(MatchMath.leftoverAdoptReady(elapsed: 0.20, streak: 1, holdPrev: 0.64), "Hash-Hold skippt 1,2 s")
        ok(!MatchMath.leftoverAdoptReady(elapsed: 0.20, streak: 1), "ohne Hold 0,2 s tot")
        ok(!MatchMath.leftoverAdoptReady(elapsed: 0.20, streak: 1, holdPrev: 0.10), "0,10 Hold skippt nicht")
        ok(MatchMath.leftoverAllowsCrossSlot(sameSlot: true, cosine: 0.50), "sameSlot immer")
        ok(MatchMath.leftoverAllowsCrossSlot(sameSlot: false, cosine: 0.70), "0,70 Cross-Slot Hold")
        ok(!MatchMath.leftoverAllowsCrossSlot(sameSlot: false, cosine: 0.50), "0,50 Cross-Slot tot")
        ok(MatchMath.leftoverHoldsTrack(cosine: 0.70), "0,70 Hold ohne Steal")
        ok(MatchMath.leftoverHoldsTrack(cosine: 0.82), "0,82 ohne Smooth Overlay halten")
        ok(MatchMath.leftoverHoldsTrack(cosine: 0.82, holdPrev: 0.64), "Spike 0,82 nach 0,64 hält statt Steal")
        let tinyN = MatchMath.leftoverBoxHashNeighbors("1.2.0.0")
        ok(tinyN.contains("1.2.2.0"), "kleine Box w+2")
        ok(tinyN.contains("3.2.0.0"), "kleine Box cx+2")
        let survive = MatchMath.leftoverHoldSurvive(
            hold: [idHoldA: 0.70, idHoldB: 0.50],
            ghosts: [idHoldA]
        )
        ok(survive[idHoldA] == 0.70, "Ghost-Hold überlebt Dropout")
        ok(survive[idHoldB] == nil, "ohne Ghost Wipe")
        ok(MatchMath.leftoverHoldSurvive(hold: [idHoldA: 0.70], ghosts: []).isEmpty, "ohne Ghosts leer")
        let keepEmpty = MatchMath.leftoverHoldSurvive(
            hold: [idHoldA: 0.70],
            ghosts: [],
            emptyKeeps: true
        )
        ok(keepEmpty[idHoldA] == 0.70, "leerer Frame hält Hold")
        let keepLive = MatchMath.leftoverHoldSurvive(
            hold: [idHoldA: 0.70, idHoldB: 0.50],
            ghosts: [idHoldB],
            live: [idHoldA]
        )
        ok(keepLive[idHoldA] == 0.70, "Partial: Live-Hold bleibt")
        ok(keepLive[idHoldB] == 0.50, "Partial: Ghost-Hold bleibt")
        ok(MatchMath.leftoverLatchKeeps(emptyFor: 0), "erster leerer Frame Latch")
        ok(MatchMath.leftoverLatchKeeps(emptyFor: 2.0), "2 s empty Hold")
        ok(!MatchMath.leftoverLatchKeeps(emptyFor: 4.1), "nach Latch empty tot")
        ok(!MatchMath.leftoverLatchKeeps(emptyFor: -0.01), "negativ kein Latch")
        let keepLatch = MatchMath.leftoverHoldSurvive(
            hold: [idHoldA: 0.70],
            ghosts: [],
            emptyKeeps: true,
            emptyFor: 2.0
        )
        ok(keepLatch[idHoldA] == 0.70, "Latch Hold 2 s")
        ok(
            MatchMath.leftoverHoldSurvive(
                hold: [idHoldA: 0.70],
                ghosts: [],
                emptyKeeps: true,
                emptyFor: 4.1
            ).isEmpty,
            "nach Latch Hold tot"
        )
        let keep2 = MatchMath.leftoverKeepBoxes(
            used: [],
            dropped: [],
            ghosts: [idHoldA],
            hold: [idHoldA]
        )
        ok(keep2.contains(idHoldA), "zweiter leerer Frame hält Kalman")
        ok(
            MatchMath.leftoverKeepBoxes(used: [idHoldA], dropped: [], ghosts: [], hold: []).contains(idHoldA),
            "Live used Kalman"
        )
        ok(
            MatchMath.leftoverKeepBoxes(used: [], dropped: [idHoldB], ghosts: [], hold: []).contains(idHoldB),
            "Dropped Kalman"
        )
        ok(
            MatchMath.leftoverKeepBoxes(used: [], dropped: [], ghosts: [], hold: []).isEmpty,
            "ohne Ghost/Hold Kalman tot"
        )
        ok(MatchMath.leftoverLatchChipKeeps(emptyFor: 4.2), "Chip 0,4 s nach Latch")
        ok(!MatchMath.leftoverLatchChipKeeps(emptyFor: 4.5), "Chip tot nach 4,4 s")
        ok(!MatchMath.leftoverLatchKeeps(emptyFor: 4.2), "Kalman tot, Chip noch")
        let fromId = UUID()
        let toId = UUID()
        let mirrored = MatchMath.leftoverPendingMirror(
            pending: [fromId: "Anna"],
            from: fromId,
            to: toId
        )
        ok(mirrored[toId] == "Anna", "Pending folgt Adopt-ID")
        ok(mirrored[fromId] == nil, "Ghost-UUID tot")
        let same = MatchMath.leftoverPendingMirror(pending: [fromId: "Anna"], from: fromId, to: fromId)
        ok(same[fromId] == "Anna", "gleiche ID no-op")
        let keepName = MatchMath.leftoverPendingMirror(
            pending: [fromId: "Anna", toId: "Bert"],
            from: fromId,
            to: toId
        )
        ok(keepName[toId] == "Bert", "Live-Name sticht Ghost")
        near(MatchMath.boxKalmanVelocity(prev: 0.10, next: 0.20, dt: 0.125), 0.55 * 0.8, 0.02, "vx EMA")
        near(MatchMath.boxKalmanPredict(x: 0.20, v: 0.40, dt: 0.125), 0.25, 0.001, "cx += vx·dt")
        near(MatchMath.boxKalmanPredict(x: 0.20, v: 8.0, dt: 0.125), 0.32, 0.001, "Cap 0,12")
        ok(MatchMath.leftoverAdoptKeepsKalman(), "Adopt hält Kalman")
        ok(MatchMath.leftoverEmptyIgnoresStranger(foundIouMax: 0.05), "Poster kein Reconnect")
        ok(!MatchMath.leftoverEmptyIgnoresStranger(foundIouMax: 0.40), "Anna zurück")
        ok(MatchMath.leftoverHoldWriteOk(sharpness: 0.40), "scharf Hold")
        ok(!MatchMath.leftoverHoldWriteOk(sharpness: 0.10), "Blur kein Hold")
        let pred = MatchMath.leftoverPredictBoxes(
            boxes: [idHoldA: (x: 0.20, y: 0.30)],
            vel: [idHoldA: (vx: 0.40, vy: 0)],
            dt: 0.125
        )
        near(pred[idHoldA]?.x ?? -1, 0.25, 0.001, "Predict-Box x")
        near(pred[idHoldA]?.y ?? -1, 0.30, 0.001, "Predict-Box y still")
        near(MatchMath.dropoutTTL(dt: 0.016), 1.20, 0.001, "24 fps TTL 1,2 s")
        near(MatchMath.dropoutTTL(dt: 0.125), 4.0, 0.001, "8 fps TTL 4 s Latch")
        near(MatchMath.liveGhostHold(dt: 0.125), 4.0, 0.001, "8 fps Ghost 4 s")
        ok(MatchMath.captureJumpBlocksPrint(prev: 0.40, next: 0.70, enrolled: true), "Enrolled Capture-Jump blockt Print")
        ok(!MatchMath.captureJumpBlocksPrint(prev: 0.40, next: 0.70, enrolled: false), "Gast Capture-Jump darf")
        ok(!MatchMath.captureJumpBlocksPrint(prev: 0.40, next: 0.45, enrolled: true), "kleines Delta kein Block")
        ok(MatchMath.tapNameLockBlocks(until: 13, now: 11), "Tap-Lock 3 s hält")
        ok(!MatchMath.tapNameLockBlocks(until: 13, now: 14), "Tap-Lock abgelaufen")
        ok(!MatchMath.tapNameLockBlocks(until: nil, now: 10), "ohne Tap kein Lock")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.82, tapUntil: 13, now: 11), "Tap sperrt Taufe")
        ok(MatchMath.leftoverHoldsTrack(cosine: 0.82, tapUntil: 13, now: 11), "Tap: Overlay halten statt Steal")
        ok(MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.80, tapUntil: 13, now: 14), "nach Tap darf Taufe")
        ok(MatchMath.tapNameLockLabel(until: 13, now: 11)?.hasPrefix("TAP") == true, "TAP-Chip")
        let ghostIds = MatchMath.leftoverGhostIds(previous: [], ghosts: [idHoldA])
        ok(ghostIds == [idHoldA], "Ghost-Pool nach Dropout")
        ok(MatchMath.leftoverGhostIds(previous: [idHoldA], ghosts: [idHoldA]) == [idHoldA], "Ghost-Dedup")
        let drop = MatchMath.leftoverDropped(previous: [idHoldA, idHoldB], used: [idHoldA])
        ok(drop == [idHoldB], "Partial-Dropout enrolled")
        ok(MatchMath.leftoverDropped(previous: [idHoldA], used: []).contains(idHoldA), "Leerer Frame ghosted enrolled")
        ok(MatchMath.captureBurstBlocksPrint(history: [0.40, 0.70, 0.68], next: 0.52, enrolled: true), "Burst-AE blockt Undershoot")
        ok(!MatchMath.captureBurstBlocksPrint(history: [0.50, 0.51, 0.50], next: 0.52, enrolled: true), "ruhig kein Burst")
        ok(!MatchMath.captureBurstBlocksPrint(history: [0.40, 0.70], next: 0.68, enrolled: false), "Gast Burst darf")
        near(MatchMath.exposureLockHold(dt: 0.016), 0.20, 0.001, "24 fps AE 0,20 s")
        near(MatchMath.exposureLockHold(dt: 0.125), 0.40, 0.001, "8 fps AE 0,40 s")
        ok(MatchMath.printTrailKeepsOnGhostAdopt(), "Ghost-Adopt hält Trail")
        ok(MatchMath.tapOverlayLocksName(pinned: true), "Overlay-Tap sperrt enrolled")
        ok(!MatchMath.tapOverlayLocksName(pinned: false), "Gast-Tap kein Lock")
        ok(MatchMath.leftoverHoldPruneLine(before: 2, after: 1) == "Hold prune 1", "Prune-Log")
        ok(MatchMath.leftoverHoldPruneLine(before: 2, after: 2) == nil, "ohne Prune still")
        ok(MatchMath.leftoverHoldPruneLine(before: 2, after: 1, liveEmpty: false) == nil, "Partial kein Prune-Log")
        ok(MatchMath.tapGuestSuggests(pinned: false), "Gast-Tap Tauf-Vorschlag")
        ok(!MatchMath.tapGuestSuggests(pinned: true), "enrolled kein Taufen")
        ok(MatchMath.tapGuestNote() == "TAUFEN?", "Taufen-Chip")
        ok(MatchMath.leftoverTwinHardBlocks(pairCosine: 0.93), "0,93 Hard-Veto")
        ok(!MatchMath.leftoverTwinHardBlocks(pairCosine: 0.91), "0,91 weich")
        ok(MatchMath.leftoverLookawayBlocks(yawAbs: 0.40, enrolled: true), "Enrolled wegsieht freeze")
        ok(!MatchMath.leftoverLookawayBlocks(yawAbs: 0.40, enrolled: false), "Gast wegsieht darf")
        ok(!MatchMath.leftoverLookawayBlocks(yawAbs: 0.10, enrolled: true), "frontal kein Freeze")
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.82)],
                sharpness: [0: 0.20],
                lookawayEnrolled: true,
                lookawayYaw: 0.40
            ) == nil,
            "Lookaway leftover tot"
        )
        let a8 = MatchMath.leftoverHoldAlpha(dt: 0.125)
        ok(a8 < 0.12 && a8 > 0.04, "8 fps EMA träge")
        near(MatchMath.leftoverHoldAlpha(dt: 0.016), 0.35, 0.001, "24 fps EMA 0,35")
        let s8 = MatchMath.leftoverHoldSmooth(raw: 0.70, prev: 0.64, dt: 0.125) ?? -1
        ok(abs(s8 - 0.64) < 0.03, "8 fps Spike 0,06 dämpft")
        ok(MatchMath.exposureLockLabel(until: 1.3, now: 1.0) == "AE 0,3s", "AE-HUD")
        ok(MatchMath.exposureLockLabel(until: 1.0, now: 1.2) == nil, "AE vorbei")
        ok(MatchMath.ghostTTLLabel(until: 2.0, now: 1.2) == "GHOST 0,8s", "Ghost-TTL HUD")
        ok(MatchMath.leftoverBlurBlocks(sharpness: 0.10, cosine: 0.64), "Blur sperrt Hold-Pick")
        ok(!MatchMath.leftoverBlurBlocks(sharpness: 0.10, cosine: 0.82), "Baptize trotz Blur")
        ok(!MatchMath.leftoverBlurBlocks(sharpness: 0.40, cosine: 0.64), "scharf Hold ok")
        ok(!MatchMath.leftoverPrintOk(cosine: 0.64, sharpness: 0.10), "0,64 blur kein Pick")
        ok(MatchMath.leftoverPrintOk(cosine: 0.64, sharpness: 0.30), "0,64 scharf Pick")
        ok(MatchMath.leftoverPrintOk(cosine: 0.82, sharpness: 0.10), "0,82 blur tauft")
        let rawBox = FaceBox(x: 0.10, y: 0.10, width: 0.20, height: 0.20)
        let kBox = MatchMath.leftoverHashBox(kalmanX: 0.12, kalmanY: 0.11, kalmanW: 0.18, kalmanH: 0.19, fallback: rawBox)
        ok(abs(kBox.x - 0.12) < 0.001, "Kalman-Hash X")
        let fb = MatchMath.leftoverHashBox(kalmanX: nil, kalmanY: nil, kalmanW: nil, kalmanH: nil, fallback: rawBox)
        ok(fb == rawBox, "Hash Fallback")
        let writeH = MatchMath.leftoverHoldWriteHash(kalmanX: 0.50, kalmanY: 0.50, kalmanW: 0.40, kalmanH: 0.40, fallback: rawBox)
        let rawH = MatchMath.leftoverBoxHash(rawBox)
        ok(writeH != rawH, "Kalman-Hash ≠ Roh-Box")
        let trailH = MatchMath.leftoverTrailWriteHash(kalmanX: 0.50, kalmanY: 0.50, kalmanW: 0.40, kalmanH: 0.40, fallback: rawBox)
        ok(trailH == writeH, "Trail-Hash = Hold-Hash")
        ok(trailH != rawH, "Trail-Hash ≠ Roh-Box")
        let writeFb = MatchMath.leftoverHoldWriteHash(kalmanX: nil, kalmanY: nil, kalmanW: nil, kalmanH: nil, fallback: rawBox)
        ok(writeFb == rawH, "Write-Hash Fallback Roh")
        let midN = MatchMath.leftoverBoxHashNeighbors("1.2.2.2")
        ok(midN.contains("1.2.4.2"), "mittlere Box w+2")
        var trailTab: [String: (samples: [Double], at: TimeInterval)] = [:]
        trailTab = MatchMath.leftoverTrailPut(hash: "1.2.3.4", sample: 0.64, onto: trailTab, now: 10)
        trailTab = MatchMath.leftoverTrailPut(hash: "1.2.3.4", sample: 0.65, onto: trailTab, now: 10.1)
        ok(MatchMath.leftoverTrailLookup(hash: "1.3.3.4", table: trailTab, now: 10.5).count == 2, "Trail über Bin-Kante")
        ok(MatchMath.leftoverTrailLookup(hash: "1.2.3.4", table: trailTab, now: 12.0).isEmpty, "Trail TTL")
        let encoded = MatchMath.leftoverStreakSinceEncode([idHoldA: 4.5])
        let decoded = MatchMath.leftoverStreakSinceDecode(encoded)
        ok(decoded[idHoldA] == 4.5, "Streak-Since roundtrip")
        ok(MatchMath.leftoverStreakSinceDecode(nil).isEmpty, "nil Decode leer")
        ok(MatchMath.guestPersistWrites(tapped: true), "Tauf-Button schreibt")
        ok(!MatchMath.guestPersistWrites(tapped: false), "ohne Tap kein Write")
        ok(!MatchMath.guestPersistSilent(8), "nie 8 s silent")
        ok(MatchMath.leftoverLookawayHolds(yawAbs: 0.40, enrolled: true), "Lookaway Hold")
        ok(!MatchMath.leftoverLookawayHolds(yawAbs: 0.40, enrolled: false), "Gast Lookaway kein Hold")
        ok(MatchMath.leftoverLookawayLabel() == "WEG", "WEG-Chip")
        ok(MatchMath.leftoverLookawayYawOf(oldYaw: 0.40, liveYaw: 0.10) == 0.10, "Live-Yaw sticht Ghost")
        ok(MatchMath.leftoverLookawayYawOf(oldYaw: 0.40, liveYaw: nil) == 0.40, "ohne Live Ghost-Yaw")
        ok(MatchMath.leftoverHoldSkipLookaway(enrolled: true, yawAbs: 0.40), "Lookaway skippt EMA")
        ok(!MatchMath.leftoverHoldSkipLookaway(enrolled: true, yawAbs: 0.10), "frontal EMA lebt")
        let pinJ = MatchMath.leftoverLookawayPin(candidates: [
            (index: 0, iou: 0.20, cosine: 0.70),
            (index: 1, iou: 0.55, cosine: 0.71)
        ])
        ok(pinJ == 1, "WEG auf nächste Live-Kiste")
        ok(MatchMath.leftoverLookawayPin(candidates: [(index: 0, iou: 0.05, cosine: 0.70)]) == nil, "IoU tot kein Pin")
        ok(MatchMath.leftoverLookawayPin(candidates: [(index: 0, iou: 0.20, cosine: 0.70)]) == 0, "Lookaway 0,20 pinnt")
        ok(MatchMath.leftoverLookawayLabel() == "WEG", "WEG ohne TTL")
        ok(MatchMath.leftoverLookawayLabel(until: 2.0, now: 1.2) == "WEG in 0,8 s", "WEG Countdown")
        ok(MatchMath.leftoverTwinKeepsStreak(pairCosine: 0.90), "TWIN? hält Streak")
        ok(!MatchMath.leftoverTwinKeepsStreak(pairCosine: 0.93), "TWIN hart löscht Streak")
        ok(!MatchMath.leftoverTwinKeepsStreak(pairCosine: 0.50), "fremd kein Twin-Streak")
        ok(MatchMath.leftoverHoldsTrack(cosine: 0.62, sharpness: 0.30), "0,62 scharf Overlay halten")
        ok(!MatchMath.leftoverHoldsTrack(cosine: 0.62), "0,62 ohne Schärfe kein Hold")
        ok(MatchMath.leftoverHoldLabel(cosine: 0.62, sharpness: 0.30) == "gehalten 0,62", "0,62 scharf Label")
        ok(MatchMath.leftoverHoldLabel(cosine: 0.62) == "gehalten 0,62", "Hold-Dict 0,62 Label")
        ok(MatchMath.leftoverHoldLabel(cosine: 0.50) == nil, "0,50 kein gehalten")
        ok(MatchMath.leftoverLookawayPinsStranger(iou: 0.05), "IoU 0,05 Fremder")
        ok(!MatchMath.leftoverLookawayPinsStranger(iou: 0.20), "IoU 0,20 kein Fremder")
        ok(MatchMath.leftoverMissAdvance(prev: 0, hit: false) == 1, "Miss +1")
        ok(MatchMath.leftoverMissAdvance(prev: 2, hit: true) == 0, "Hit löscht Miss")
        ok(!MatchMath.leftoverMissClears(miss: 2), "2 Miss halten")
        ok(MatchMath.leftoverMissClears(miss: 3), "3 Miss löschen")
        ok(abs(MatchMath.leftoverAdoptNeedSec(dt: 0.016) - 0.80) < 0.001, "24 fps Adopt 0,80 s")
        ok(abs(MatchMath.leftoverAdoptNeedSec(dt: 0.067) - 0.80) < 0.001, "15 fps Adopt 0,80 s")
        ok(abs(MatchMath.leftoverAdoptNeedSec(dt: 0.125) - 1.20) < 0.001, "8 fps Adopt 1,2 s")
        ok(MatchMath.leftoverTwinTint(pairCosine: 0.90) == "amber", "TWIN? amber")
        ok(MatchMath.leftoverTwinTint(pairCosine: 0.93) == "red", "TWIN hart rot")
        ok(MatchMath.leftoverTwinTint(pairCosine: 0.50) == nil, "fremd kein Twin-Tint")
        ok(abs(MatchMath.leftoverPrintFloor(yawAbs: 0.10) - 0.62) < 0.001, "frontal Genuine 0,62")
        ok(abs(MatchMath.leftoverPrintFloor(yawAbs: 0.30) - 0.62) < 0.001, "leichte Drehung 0,62")
        ok(abs(MatchMath.leftoverPrintFloor(yawAbs: 0.50) - 0.70) < 0.001, "Profil Genuine 0,70")
        ok(MatchMath.leftoverPrintOk(cosine: 0.62, sharpness: 0.30), "frontal 0,62 scharf")
        ok(MatchMath.leftoverPrintOk(cosine: 0.62, sharpness: 0.30, yawAbs: 0.30), "0,30 rad 0,62 scharf")
        ok(!MatchMath.leftoverPrintOk(cosine: 0.62, sharpness: 0.30, yawAbs: 0.50), "Profil 0,62 tot")
        ok(MatchMath.leftoverPrintOk(cosine: 0.71, sharpness: 0.30, yawAbs: 0.50), "Profil 0,71 scharf")
        ok(abs(MatchMath.leftoverTwinHardVetoNow(facesInFrame: 1) - 0.92) < 0.001, "ein Gesicht 0,92")
        ok(abs(MatchMath.leftoverTwinHardVetoNow(facesInFrame: 2) - 0.88) < 0.001, "zwei Gesichter 0,88")
        ok(MatchMath.leftoverTwinHardBlocks(pairCosine: 0.90, veto: MatchMath.leftoverTwinHardVetoNow(facesInFrame: 2)), "Same-shot 0,90 hart")
        ok(!MatchMath.leftoverTwinHardBlocks(pairCosine: 0.90), "ein Gesicht 0,90 weich")
        ok(MatchMath.leftoverEmptyKeepsStreak(liveEmpty: true), "leerer Frame hält Streak")
        ok(!MatchMath.leftoverEmptyKeepsStreak(liveEmpty: false), "Live wischt nicht über den Helfer")
        ok(MatchMath.leftoverEmptyKeepsOverlay(liveEmpty: true), "leerer Frame hält Overlay")
        ok(!MatchMath.leftoverEmptyKeepsOverlay(liveEmpty: false), "Live Overlay-Helfer tot")
        let twinPick = MatchMath.leftoverPick(
            candidates: [(index: 0, iou: 0.50, cosine: 0.82)],
            sharpness: [0: 0.40],
            twinPair: 0.90,
            facesInFrame: 2
        )
        ok(twinPick == nil, "zwei Gesichter TWIN? 0,90 kein Adopt")

        ok(MatchMath.leftoverUnknownHard(cosine: 0.55), "0,55 UNBEKANNT hart")
        ok(!MatchMath.leftoverUnknownHard(cosine: 0.45), "0,45 unter Open-Set")
        ok(!MatchMath.leftoverUnknownHard(cosine: 0.70), "0,70 Hold kein UNBEKANNT")
        ok(MatchMath.leftoverUnknownNote() == "UNBEKANNT", "UNBEKANNT-Chip")
        ok(MatchMath.leftoverUnknownKeepsStreak(cosine: 0.55), "UNBEKANNT hält Streak")
        ok(!MatchMath.leftoverUnknownKeepsStreak(cosine: 0.40), "fremd löscht Streak")
        ok(MatchMath.leftoverStreakKeepsLive(transferred: true), "Taufe hält Streak")
        ok(!MatchMath.leftoverStreakKeepsLive(transferred: false), "Gast löscht Streak")
        ok(MatchMath.leftoverBaptizeStillBlocks(stillFor: 0.10, cosine: 0.82, holdPrev: nil), "erste Begegnung 0,10 s tot")
        ok(!MatchMath.leftoverBaptizeStillBlocks(stillFor: 0.50, cosine: 0.82, holdPrev: nil), "0,45 s still tauft")
        ok(!MatchMath.leftoverBaptizeStillBlocks(stillFor: 0.10, cosine: 0.82, holdPrev: 0.64), "Hold skippt Still")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.82, stillFor: 0.10), "Still sperrt Taufe")
        ok(MatchMath.leftoverHoldsTrack(cosine: 0.82, stillFor: 0.10), "Still: Overlay halten")
        ok(MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.80, stillFor: 0.50), "nach Still darf Taufe")
        let kStreak = MatchMath.leftoverStreakBoxWrite(kalmanX: 0.50, kalmanY: 0.50, kalmanW: 0.40, kalmanH: 0.40, fallback: rawBox)
        ok(abs(kStreak.x - 0.50) < 0.001, "Streak-Box Kalman")
        let rawStreak = MatchMath.leftoverStreakBoxWrite(kalmanX: nil, kalmanY: nil, kalmanW: nil, kalmanH: nil, fallback: rawBox)
        ok(rawStreak == rawBox, "Streak-Box Fallback")
        ok(MatchMath.leftoverTwinPairLabel(pairCosine: 0.93) == "TWIN 0,93", "TWIN 0,93 Overlay")
        ok(MatchMath.leftoverTwinPairLabel(pairCosine: 0.90) == "TWIN? 0,90", "TWIN? 0,90 weich")
        ok(MatchMath.leftoverTwinPairLabel(pairCosine: 0.50) == nil, "fremd kein TWIN-Zahl")
        ok(MatchMath.lampGlyph(.green) == "●", "Grün Kreis")
        ok(MatchMath.lampGlyph(.amber) == "◐", "Amber halb")
        ok(MatchMath.lampGlyph(.red) == "✕", "Rot Kreuz")
        ok(MatchMath.lampPattern(.red) == "cross", "Rot Pattern")
        ok(MatchMath.claheNeeded(luma: 0.10, continuity: true), "Continuity-Nacht CLAHE")
        ok(!MatchMath.claheNeeded(luma: 0.10, continuity: false), "Built-in kein CLAHE-Banner")
        ok(!MatchMath.claheNeeded(luma: 0.40, continuity: true), "hell kein CLAHE")
        ok(MatchMath.claheBanner(true) == "CLAHE", "CLAHE-Banner")
        let roi = MatchMath.liveROI(FaceBox(x: 0.40, y: 0.40, width: 0.20, height: 0.20))
        ok(roi.width > 0.20 && roi.x < 0.40, "ROI pad")
        let edge = MatchMath.liveROI(FaceBox(x: 0, y: 0, width: 0.20, height: 0.20))
        ok(edge.x == 0 && edge.y == 0, "ROI clamp")

        let fixture = "1\t2\nAlice\t1\t2\nBob\t1\t3\nAlice\t1\tBob\t1\nAlice\t2\tCarol\t1\n"
        let parsed = BenchProtocol.parsePairs(fixture)
        ok(parsed.count == 4, "Fixture 4 Paare (ist \(parsed.count))")
        ok(parsed.filter(\.same).count == 2, "2 Genuine")
        ok(!parsed[2].same && parsed[2].aName == "Alice" && parsed[2].bName == "Bob", "Impostor Alice/Bob")
        ok(parsed[0].relativePath("a") == "Alice/Alice_0001.jpg", "LFW-Pfad")
        let devTest = "2\nAlice\t1\t2\nBob\t1\t3\nAlice\t1\tCarol\t1\nBob\t1\tDave\t1\n"
        let devParsed = BenchProtocol.parsePairs(devTest)
        ok(devParsed.count == 4, "DevTest-Header 1 Zahl → 2+2 Paare (ist \(devParsed.count))")
        ok(devParsed.filter(\.same).count == 2, "DevTest 2 Genuine")
        near(BenchProtocol.accuracy(scores: [90, 40], same: [true, false], threshold: 78), 1, 0.01, "Accuracy 2/2")
        near(BenchProtocol.accuracy(scores: [90, 80], same: [true, false], threshold: 78), 0.5, 0.01, "Accuracy 1/2")
        if FileManager.default.fileExists(atPath: "bench/pairs.txt"),
           let txt = try? String(contentsOfFile: "bench/pairs.txt", encoding: .utf8)
        {
            let lfw = BenchProtocol.parsePairs(txt)
            ok(lfw.count == 6000, "LFW View-2 hat 6000 Paare (ist \(lfw.count))")
            ok(lfw.filter(\.same).count == 3000, "3000 Genuine")
            ok(lfw.filter { !$0.same }.count == 3000, "3000 Impostor")
            ok(Set(lfw.map(\.fold)).count == 10, "10 Folds")
        } else {
            ok(false, "bench/pairs.txt fehlt")
        }
        let tiny = BenchProtocol.identificationCut(counts: [6, 6, 6, 6], cap: 200)
        ok(tiny.minPhotos == 2 && tiny.kept == 4, "kleine Mappe min 2")
        let lfwLike = Array(repeating: 1, count: 5500) + Array(repeating: 12, count: 96) + Array(repeating: 25, count: 62)
        let cut10 = BenchProtocol.identificationCut(counts: lfwLike, cap: 200)
        ok(cut10.minPhotos == 10, "volle LFW → min 10 (ist \(cut10.minPhotos))")
        ok(cut10.kept == 158, "158 Personen mit ≥10 (ist \(cut10.kept))")
        let crowded = Array(repeating: 12, count: 300)
        let cutCrowd = BenchProtocol.identificationCut(counts: crowded, cap: 200)
        ok(cutCrowd.minPhotos == 10 && cutCrowd.kept == 200, "300×12 → top 200 mit min 10")
        let dense = Array(repeating: 25, count: 250)
        let cutDense = BenchProtocol.identificationCut(counts: dense, cap: 200)
        ok(cutDense.minPhotos == 20 && cutDense.kept == 200, "250×25 → min 20, Cap 200")

        ok(MatchMath.leftoverAdoptKeepsKalman(), "Adopt hält Kalman")
        ok(MatchMath.leftoverPredictOnEmptyLike(true), "emptyLike predict")
        ok(!MatchMath.leftoverPredictOnEmptyLike(false), "Anna zurück kein extra Predict")
        let blended = MatchMath.leftoverAdoptBlend(
            live: (x: 0.80, y: 0.20, w: 0.20, h: 0.20),
            kalman: (x: 0.20, y: 0.20, w: 0.20, h: 0.20)
        )
        near(blended.x, 0.80 * 0.55 + 0.20 * 0.45, 0.002, "Adopt-Blend x")
        let rawLive = MatchMath.leftoverAdoptBlend(
            live: (x: 0.80, y: 0.20, w: 0.20, h: 0.20),
            kalman: nil
        )
        near(rawLive.x, 0.80, 0.001, "ohne Kalman Live")
        ok(MatchMath.leftoverTrailWriteOk(sharpness: 0.40), "scharf Trail")
        ok(!MatchMath.leftoverTrailWriteOk(sharpness: 0.10), "Blur kein Trail")
        ok(MatchMath.kalmanNmsDrops(iou: 0.50, bestIou: 0.80), "Walker-Twin drop")
        ok(!MatchMath.kalmanNmsDrops(iou: 0.80, bestIou: 0.80), "beste Kiste bleibt")
        ok(!MatchMath.kalmanNmsDrops(iou: 0.20, bestIou: 0.80), "fremd kein NMS")
        ok(MatchMath.kalmanNmsKeeps(iou: 0.80, bestIou: 0.80), "Keep beste")
        let roiPx = MatchMath.liveRoiBox(
            kalman: [(x: 200, y: 150, w: 80, h: 100)],
            imageW: 1280,
            imageH: 720
        )
        ok(roiPx != nil && (roiPx?.w ?? 0) > 80, "Live-ROI um Kalman")
        ok(MatchMath.liveRoiBox(kalman: [], imageW: 1280, imageH: 720) == nil, "ohne Kalman kein ROI")
        let full = MatchMath.liveRoiBox(
            kalman: [(x: 10, y: 10, w: 1260, h: 700)],
            imageW: 1280,
            imageH: 720
        )
        ok(full == nil, "fast volles Bild kein Crop")
        near(MatchMath.exposureLockHold(dt: 0.125, reconnect: true), 0.80, 0.001, "8 fps Reconnect AE 0,80")
        near(MatchMath.exposureLockHold(dt: 0.016, reconnect: true), 0.40, 0.001, "24 fps Reconnect AE 0,40")
        near(MatchMath.exposureLockHold(dt: 0.125), 0.40, 0.001, "8 fps AE bleibt 0,40")
        ok(MatchMath.printBankWeight(sharpness: 0.40) > 0, "scharf Bank-Gewicht")
        ok(MatchMath.printBankWeight(sharpness: 0.10) == 0, "Blur Bank 0")
        let bank = MatchMath.printBankBlend([
            (vec: [1, 0, 0, 0] + Array(repeating: 0, count: 28), w: 1),
            (vec: [0, 1, 0, 0] + Array(repeating: 0, count: 28), w: 0)
        ])
        ok(!bank.isEmpty && abs(bank[0] - 1) < 0.001, "Bank ignoriert Gewicht 0")

        ok(MatchMath.leftoverBoxHashBins(imageW: 1280) == 12, "HD 12 Bins")
        ok(MatchMath.leftoverBoxHashBins(imageW: 1920) == 16, "FHD 16 Bins")
        ok(MatchMath.leftoverBoxHashBins(imageW: 3840) == 24, "4K 24 Bins")
        let k4a = FaceBox(x: 1000, y: 400, width: 180, height: 220)
        let k4b = FaceBox(x: 1180, y: 400, width: 180, height: 220)
        ok(
            MatchMath.leftoverBoxHash(k4a, bins: 12, imageW: 3840, imageH: 2160)
                == MatchMath.leftoverBoxHash(k4b, bins: 12, imageW: 3840, imageH: 2160),
            "12 Bins 4K Kollision"
        )
        ok(
            MatchMath.leftoverBoxHash(k4a, imageW: 3840, imageH: 2160)
                != MatchMath.leftoverBoxHash(k4b, imageW: 3840, imageH: 2160),
            "24 Bins 4K getrennt"
        )
        var twoHold: [String: (cosine: Double, at: TimeInterval)] = [:]
        twoHold = MatchMath.leftoverHoldPut(hash: "1.2.3.4", cosine: 0.64, onto: twoHold, now: 10)
        twoHold = MatchMath.leftoverHoldPut(hash: "1.3.3.4", cosine: 0.90, onto: twoHold, now: 10.4)
        ok(abs((MatchMath.leftoverHoldLookup(hash: "1.2.3.4", table: twoHold, now: 10.5) ?? -1) - 0.64) < 0.001, "Exact vor jüngerem Nachbar")
        ok(abs((MatchMath.leftoverHoldLookup(hash: "1.3.3.4", table: twoHold, now: 10.5) ?? -1) - 0.90) < 0.001, "Nachbar Exact eigen")
        var twoTrail: [String: (samples: [Double], at: TimeInterval)] = [:]
        twoTrail = MatchMath.leftoverTrailPut(hash: "1.2.3.4", sample: 0.64, onto: twoTrail, now: 10, sharpness: 0.40)
        twoTrail = MatchMath.leftoverTrailPut(hash: "1.3.3.4", sample: 0.90, onto: twoTrail, now: 10.4, sharpness: 0.40)
        ok(abs((MatchMath.leftoverTrailLookup(hash: "1.2.3.4", table: twoTrail, now: 10.5).last ?? -1) - 0.64) < 0.001, "Trail Exact vor Nachbar")
        ok(twoTrail["1.2.3.4"]?.samples.last == 0.64, "Put schreibt nicht den Nachbar-Trail")
        ok(MatchMath.liveRoiMissRetries(hadROI: true, empty: true), "ROI-Miss retry")
        ok(!MatchMath.liveRoiMissRetries(hadROI: false, empty: true), "ohne ROI kein retry")
        ok(MatchMath.liveRoiMissGoesFull(dt: 0.125), "8 fps ROI direkt voll")
        ok(!MatchMath.liveRoiMissGoesFull(dt: 0.016), "24 fps erst expand")
        let roi0 = MatchMath.liveRoiBox(kalman: [(x: 200, y: 150, w: 80, h: 100)], imageW: 1280, imageH: 720)!
        let roiE = MatchMath.liveRoiExpand(roi0, imageW: 1280, imageH: 720)
        ok(roiE.w > roi0.w, "ROI 1,4×")
        ok(MatchMath.liveRoiPeriodicFull(tick: 8), "Tick 8 voll")
        ok(!MatchMath.liveRoiPeriodicFull(tick: 7), "Tick 7 Crop")
        ok(MatchMath.liveRoiSkipsForStranger(foundCount: 2, kalmanCount: 1), "Gast → Full")
        ok(!MatchMath.liveRoiSkipsForStranger(foundCount: 1, kalmanCount: 1), "gleiche Zahl Crop")
        let ghost = MatchMath.leftoverGhostAspectLock(predX: 400, predY: 200, lastW: 80, lastH: 100)
        ok(abs(ghost.x - 400) < 0.001 && abs(ghost.w - 80) < 0.001, "Ghost cx, w bleibt")
        ok(abs(MatchMath.boxKalmanQ(captureJump: true) - 0.020) < 0.001, "AE mehr Q")
        ok(abs(MatchMath.boxKalmanQ(captureJump: false) - 0.008) < 0.001, "ruhig Q 0,008")
        let jumped = MatchMath.boxKalman(prev: 200, meas: 400, p: 0.04, dt: 0.125, q: MatchMath.boxKalmanQ(captureJump: true))
        let calm = MatchMath.boxKalman(prev: 200, meas: 400, p: 0.04, dt: 0.125, q: MatchMath.boxKalmanQ(captureJump: false))
        ok(abs(jumped.x - 400) < abs(calm.x - 400), "AE folgt stärker")

        ok(
            MatchMath.leftoverBoxOrderKeeps(prevX: 100, candX: 110, others: [400]),
            "Anna links bleibt links"
        )
        ok(
            !MatchMath.leftoverBoxOrderKeeps(prevX: 100, candX: 410, others: [400]),
            "Gast rechts stiehlt nicht"
        )
        ok(
            MatchMath.leftoverBoxOrderKeeps(prevX: 200, candX: 210, others: [220], minGap: 40),
            "Überlapp kein Order"
        )
        let leftPick = MatchMath.leftoverPick(
            candidates: [(0, 0.50, 0.66), (1, 0.50, 0.66)],
            boxX: [0: 110, 1: 410],
            leftoverX: 100,
            otherX: [400]
        )
        ok(leftPick == 0, "Twin-Order nimmt links")
        let detHi = MatchMath.leftoverScore(cosine: 0.70, sharpness: 0.40, yawAbs: 0, detScore: 0.95)
        let detLo = MatchMath.leftoverScore(cosine: 0.70, sharpness: 0.40, yawAbs: 0, detScore: 0.20)
        ok(detHi > detLo, "Detector-Score hebt leftover")
        let detPick = MatchMath.leftoverPick(
            candidates: [(0, 0.50, 0.67), (1, 0.50, 0.66)],
            sharpness: [0: 0.40, 1: 0.40],
            detScore: [0: 0.20, 1: 0.95]
        )
        ok(detPick == 1, "höherer Detector dreht bei 0,01 Spread")
        ok(MatchMath.leftoverSessionLumaLow(0.18), "Nacht Capture")
        ok(!MatchMath.leftoverSessionLumaLow(0.70), "Tag Capture")
        near(MatchMath.leftoverSessionFloor(yawAbs: 0, capture: 0.18), MatchMath.leftoverPrintGenuine - 0.02, 0.001, "Session Floor −0,02")
        near(MatchMath.leftoverSessionFloor(yawAbs: 0, capture: 0.70), MatchMath.leftoverPrintGenuine, 0.001, "Tag Floor bleibt")
        ok(
            MatchMath.leftoverPrintOk(cosine: 0.61, sharpness: 0.40, yawAbs: 0, capture: 0.18),
            "Nacht 0,61 darf Hold"
        )
        ok(
            !MatchMath.leftoverPrintOk(cosine: 0.61, sharpness: 0.40, yawAbs: 0, capture: 0.70),
            "Tag 0,61 tot"
        )
        let spark = MatchMath.leftoverCosineSparkPut(0.90, onto: [0.64, 0.66, 0.70])
        ok(spark.last == 0.90 && spark.count == 4, "Cosine-Spark append")
        let fullSpark = MatchMath.leftoverCosineSparkPut(0.91, onto: Array(repeating: 0.70, count: 8))
        ok(fullSpark.count == 8 && fullSpark.last == 0.91, "Spark Cap 8")
        ok(
            MatchMath.leftoverLiveWeight(sharpness: 0.50, frontal: 1, yawAbs: 0)
                > MatchMath.leftoverLiveWeight(sharpness: 0.50, frontal: 0.20, yawAbs: 0.40),
            "Live-Gewicht frontal vor Profil"
        )
        ok(
            MatchMath.centroidWeight(capture: 1, sharpness: 1, frontal: 1, yawAbs: 0)
                > MatchMath.centroidWeight(capture: 1, sharpness: 1, frontal: 0.2, yawAbs: 0.45),
            "Centroid Profil weniger Gewicht"
        )
        let hashEdge = "11.11.3.2"
        let hashNeigh = MatchMath.leftoverBoxHashNeighbors(hashEdge)
        ok(hashNeigh.contains("12.11.3.2"), "4K Bin 11 Nachbar 12 nicht geclippt")
        ok(MatchMath.leftoverBoxHashNeighbors("5.4.3.2").contains("6.4.3.2"), "HD Nachbar bleibt")
        ok(MatchMath.unknownCentroid(bestCosine: 0.61), "Tag 0,61 unbekannt")
        ok(!MatchMath.unknownCentroid(bestCosine: 0.61, capture: 0.18), "Nacht 0,61 bekannt")

        let nightLive = MatchMath.leftoverSessionCapture(old: 0.70, live: [0.18, 0.22])
        near(nightLive ?? -1, 0.18, 0.001, "Session-Capture Live-Nacht")
        let dayLive = MatchMath.leftoverSessionCapture(old: 0.18, live: [0.70])
        near(dayLive ?? -1, 0.70, 0.001, "Live-Tag schlägt Ghost-Nacht")
        let ghostOnly = MatchMath.leftoverSessionCapture(old: 0.18, live: [])
        near(ghostOnly ?? -1, 0.18, 0.001, "leeres Live hält Ghost")
        ok(
            MatchMath.leftoverPrintOk(
                cosine: 0.61,
                sharpness: 0.40,
                yawAbs: 0,
                capture: MatchMath.leftoverSessionCapture(old: 0.70, live: [0.18])
            ),
            "Nacht-Live 0,61 trotz Ghost 0,70"
        )
        ok(MatchMath.leftoverHoldWriteOk(sharpness: 0.40, yawAbs: 0.10), "frontal Hold")
        ok(!MatchMath.leftoverHoldWriteOk(sharpness: 0.40, yawAbs: 0.50), "Profil kein Hold-EMA")
        ok(!MatchMath.leftoverHoldWriteOk(sharpness: 0.40, yawAbs: 0.35), "¾ kein Hold-EMA")
        ok(MatchMath.leftoverTrailWriteOk(sharpness: 0.40, yawAbs: 0.35), "¾ Hash-Bin Trail")
        let sparkLbl = MatchMath.leftoverCosineSparkLabel([0.64, 0.66, 0.90])
        ok(sparkLbl == "0,64→0,90", "Spark 0,64→0,90")
        ok(MatchMath.leftoverCosineSparkLabel([0.70]) == nil, "ein Sample kein Spark")
        let frontW = MatchMath.leftoverLiveWeight(sharpness: 0.50, frontal: 1, yawAbs: 0)
        let profileW = MatchMath.leftoverLiveWeight(sharpness: 0.50, frontal: 0.20, yawAbs: 0.45)
        ok(MatchMath.liveCentroidKeepsPrint(weight: frontW, best: frontW), "Frontal bleibt")
        ok(!MatchMath.liveCentroidKeepsPrint(weight: profileW, best: frontW), "Profil raus aus Mean")
        ok(MatchMath.liveCentroidKeepsPrint(weight: 0.05, best: 0.05), "nur Profil bleibt")
        ok(MatchMath.leftoverBoxOrderGap(imageW: 3840) > 100, "4K Gap > 100")
        ok(abs(MatchMath.leftoverBoxOrderGap(imageW: 0) - 40) < 0.001, "ohne Bild 40")
        ok(
            MatchMath.leftoverBoxOrderKeeps(prevX: 100, candX: 180, others: [170], minGap: 40) == false,
            "80 px Jitter stiehlt bei Gap 40"
        )
        ok(
            MatchMath.leftoverBoxOrderKeeps(
                prevX: 100, candX: 180, others: [170],
                minGap: MatchMath.leftoverBoxOrderGap(imageW: 3840)
            ),
            "4K 80 px kein Order"
        )
        let nightPick = MatchMath.leftoverPick(
            candidates: [(0, 0.50, 0.61)],
            sharpness: [0: 0.40],
            sessionCapture: MatchMath.leftoverSessionCapture(old: 0.70, live: [0.18])
        )
        ok(nightPick == 0, "Nacht-Pick 0,61 mit Live-Capture")
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.50)],
                sharpness: [0: 0.40],
                holdPrev: 0.80
            ) == nil,
            "Impostor 0,50 trotz Hold 0,80"
        )
        ok(MatchMath.leftoverPickPrint(raw: 0.50, smoothed: 0.70) == 0.50, "Floor roh")
        ok(MatchMath.leftoverPickPrint(raw: nil, smoothed: 0.70) == 0.70, "Coast-Print Hold")
        ok(MatchMath.leftoverPickPrint(raw: nil, smoothed: nil) == nil, "Coast-Print tot")
        ok(MatchMath.leftoverHoldClimb(prev: 0.61), "Nacht-Hold Climb")
        ok(!MatchMath.leftoverHoldClimb(prev: 0.80), "Tag-Hold kein Climb")
        ok(!MatchMath.leftoverHoldBlocks(raw: 0.66, prev: 0.61), "Nacht 0,61→0,66 kein Spike")
        ok(MatchMath.leftoverHoldBlocks(raw: 0.70, prev: 0.64), "Twin 0,64→0,70 Spike")
        ok(
            !MatchMath.unknownCentroid(bestCosine: 0.61, capture: 0.18),
            "FaceEngine Nacht-Capture 0,61 bekannt"
        )
        ok(
            MatchMath.unknownCentroid(bestCosine: 0.65, yawAbs: 0.50),
            "Profil 0,65 unbekannt"
        )
        ok(
            !MatchMath.unknownCentroid(bestCosine: 0.65, yawAbs: 0.10),
            "Frontal 0,65 bekannt"
        )
        near(MatchMath.leftoverSessionCaptureBox(old: 0.70, live: 0.70) ?? -1, 0.70, 0.001, "Anna-Box Tag")
        near(MatchMath.leftoverSessionCaptureBox(old: 0.70, live: 0.18) ?? -1, 0.18, 0.001, "Gast-Box Nacht")
        near(MatchMath.leftoverSessionCaptureBox(old: 0.70, live: nil) ?? -1, 0.70, 0.001, "ohne Live Ghost")
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.61)],
                sharpness: [0: 0.40],
                sessionCapture: MatchMath.leftoverSessionCapture(old: 0.70, live: [0.70, 0.18]),
                capture: [0: 0.70]
            ) == nil,
            "Anna-Box Tag: 0,61 trotz Gast-Nacht unbekannt"
        )
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.61)],
                sharpness: [0: 0.40],
                sessionCapture: 0.70,
                capture: [0: 0.18]
            ) == 0,
            "diese Box Nacht: 0,61 bleibt"
        )
        ok(MatchMath.leftoverHoldAlphaJump(0.25), "AE-Sprung")
        ok(!MatchMath.leftoverHoldAlphaJump(0.05), "kein Sprung")
        near(MatchMath.leftoverHoldAlpha(dt: 0.016, captureJump: 0.25), 0.08, 0.001, "AE-EMA 0,08")
        near(MatchMath.leftoverCaptureJump(prev: 0.70, next: 0.18), 0.52, 0.001, "Jump-Delta")
        near(
            MatchMath.leftoverHoldSmooth(raw: 0.70, prev: 0.64, captureJump: 0.25) ?? -1,
            0.08 * 0.70 + 0.92 * 0.64,
            0.002,
            "Pick-EMA AE träge"
        )
        ok(
            MatchMath.leftoverScore(cosine: 0.72, sharpness: 0.40, twinPair: 0.92)
                < MatchMath.leftoverScore(cosine: 0.72, sharpness: 0.40),
            "Twin-Paar senkt Score"
        )
        ok(
            MatchMath.leftoverCentroidOk(sharpness: 0.40, yawAbs: 0.10, frontal: 0.90),
            "Frontal scharf in Galerie"
        )
        ok(
            !MatchMath.leftoverCentroidOk(sharpness: 0.40, yawAbs: 0.40, frontal: 0.90),
            "¾ raus aus Centroid"
        )
        ok(
            !MatchMath.leftoverCentroidOk(sharpness: 0.40, yawAbs: 0.10, frontal: 0.50),
            "frontal < 0,70 raus"
        )
        near(MatchMath.leftoverSessionCaptureMedian([0.70, 0.70, 0.70, 0.18]) ?? -1, 0.70, 0.001, "Flash-Median")
        near(
            MatchMath.leftoverSessionCaptureBox(old: 0.70, live: 0.18, hist: [0.70, 0.70, 0.70]) ?? -1,
            0.70,
            0.001,
            "Flash 1 Tick Floor bleibt"
        )
        near(MatchMath.leftoverSessionCaptureBox(old: 0.70, live: 0.18) ?? -1, 0.18, 0.001, "ohne Hist Live")
        ok(MatchMath.leftoverHoldBin(yawAbs: 0.10) == 0, "frontal Bin")
        ok(MatchMath.leftoverHoldBin(yawAbs: 0.35) == 1, "¾ Bin")
        ok(MatchMath.leftoverHoldBin(yawAbs: 0.50) == 2, "Profil Bin")
        let holdAnna = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
        ok(MatchMath.leftoverHoldPrevOf(frontal: 0.80, yawAbs: 0.10) == 0.80, "frontal Prev")
        ok(MatchMath.leftoverHoldPrevOf(frontal: 0.80, yawAbs: 0.35) == nil, "¾ erbt nicht Frontal")
        let binKey = MatchMath.leftoverHoldKey(id: holdAnna, bin: 1)
        ok(
            MatchMath.leftoverHoldPrevOf(frontal: 0.80, yawAbs: 0.35, bins: [binKey: 0.66], id: holdAnna) == 0.66,
            "¾ liest eigenen Bin"
        )
        ok(MatchMath.leftoverHoldBinWriteOk(sharpness: 0.40, yawAbs: 0.35), "¾ schreibt Bin")
        ok(!MatchMath.leftoverHoldBinWriteOk(sharpness: 0.10, yawAbs: 0.10), "Blur kein Bin")
        ok(MatchMath.leftoverHoldId(from: binKey) == holdAnna, "Key → UUID")
        let dropped = MatchMath.leftoverHoldBinDrop(bins: [binKey: 0.66], id: holdAnna)
        ok(dropped.isEmpty, "Drop alle Bins der UUID")
        let flashPick = MatchMath.leftoverPick(
            candidates: [(0, 0.50, 0.61)],
            sharpness: [0: 0.40],
            sessionCapture: 0.70,
            capture: [0: 0.18],
            captureHist: [0.70, 0.70, 0.70]
        )
        ok(flashPick == nil, "Flash-Hist: 0,61 gegen Tag-Floor tot")
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.68)],
                sharpness: [0: 0.40],
                yawAbs: [0: 0.35],
                holdPrev: 0.80
            ) == 0,
            "¾ roh 0,68, nicht Smooth 0,76"
        )
        let histPut = MatchMath.leftoverCaptureHistPut(0.18, onto: [0.70, 0.70, 0.70])
        ok(histPut.count == 4, "Capture-Hist wächst")
        near(
            MatchMath.leftoverSessionCaptureBox(old: 0.70, live: 0.18, hist: histPut) ?? -1,
            0.70,
            0.001,
            "Median nach Put bleibt Tag"
        )
        ok(MatchMath.leftoverHoldBinChip(0) == "BIN 0", "frontal Chip")
        ok(MatchMath.leftoverHoldBinChip(1) == "BIN 1", "¾ Chip")
        ok(MatchMath.leftoverHoldLabel(cosine: 0.64, yawAbs: 0.35) == "gehalten 0,64 · BIN 1", "Hold + BIN")
        near(MatchMath.leftoverSessionCapturePrefersFrame(frame: 0.70, box: 0.18) ?? -1, 0.70, 0.001, "Center Stage Box tot, Frame bleibt")
        near(MatchMath.leftoverSessionCapturePrefersFrame(frame: 0.70, box: 0.68) ?? -1, 0.68, 0.001, "einig Box")
        ok(MatchMath.leftoverSessionCapturePrefersFrame(frame: nil, box: 0.40) == 0.40, "ohne Frame Box")
        let cropPick = MatchMath.leftoverPick(
            candidates: [(0, 0.50, 0.61)],
            sharpness: [0: 0.40],
            sessionCapture: 0.18,
            capture: [0: 0.18],
            frameCapture: 0.70
        )
        ok(cropPick == nil, "Frame 0,70: 0,61 gegen Tag-Floor tot")
        let hashKey = MatchMath.leftoverHoldHashKey(hash: "1.2.3.4", bin: 1)
        ok(hashKey == "1.2.3.4#1", "Hash-Bin Key")
        var hashTab: [String: (cosine: Double, at: TimeInterval)] = [:]
        hashTab = MatchMath.leftoverHoldPut(hash: "1.2.3.4", cosine: 0.66, onto: hashTab, now: 10, bin: 1)
        ok(MatchMath.leftoverHoldLookup(hash: "1.2.3.4", table: hashTab, now: 10.1, bin: 1) == 0.66, "¾ Hash-Hold")
        ok(MatchMath.leftoverHoldLookup(hash: "1.2.3.4", table: hashTab, now: 10.1, bin: 0) == nil, "frontal erbt nicht ¾-Hash")
        ok(MatchMath.leftoverHoldLookup(hash: "1.2.3.4", table: hashTab, now: 10.1) == nil, "unbinned leer bei ¾")
        hashTab = MatchMath.leftoverHoldPut(hash: "1.2.3.4", cosine: 0.80, onto: hashTab, now: 10, bin: 0)
        ok(MatchMath.leftoverHoldLookup(hash: "1.2.3.4", table: hashTab, now: 10.1) == 0.80, "frontal unbinned bleibt")
        let dropPrev = MatchMath.leftoverHoldPrevOf(
            frontal: 0.80,
            yawAbs: 0.35,
            bins: [:],
            id: nil,
            hash: "1.2.3.4",
            hashTable: hashTab,
            now: 10.1
        )
        ok(abs((dropPrev ?? -1) - 0.66) < 0.001, "Dropout: ¾ liest Hash-Bin, nicht Frontal")
        let dropPick = MatchMath.leftoverPick(
            candidates: [(0, 0.50, 0.70)],
            sharpness: [0: 0.40],
            yawAbs: [0: 0.35],
            holdPrev: 0.80,
            holdHash: "1.2.3.4",
            holdHashTable: hashTab,
            holdAt: 10.1
        )
        ok(dropPick == nil, "¾ roh 0,70 gegen Hash-Hold 0,66 Spike")
        ok(
            MatchMath.leftoverCaptureHistOf(box: [0.18, 0.18, 0.18], leftover: [0.70, 0.70, 0.70]) == [0.18, 0.18, 0.18],
            "Gast-Hist 3+ vor leftover"
        )
        ok(
            MatchMath.leftoverCaptureHistOf(box: [], leftover: [0.70, 0.70, 0.70]) == [0.70, 0.70, 0.70],
            "Flash ohne Box-Hist leftover"
        )
        let smClear = MatchMath.leftoverScoreSoftmax([0.80, 0.70])
        ok((smClear.max() ?? 0) > 0.70, "0,80 vs 0,70 Softmax klar")
        ok(!MatchMath.leftoverSoftmaxBlocks(smClear), "0,80 vs 0,70 kein Block")
        ok(MatchMath.leftoverSoftmaxBlocks(MatchMath.leftoverScoreSoftmax([0.72, 0.71])), "0,72 vs 0,71 Softmax Block")
        ok(MatchMath.leftoverScoreHeat(0.80) > MatchMath.leftoverScoreHeat(0.70), "Temp 16 steiler")
        ok(MatchMath.leftoverCaptureChip(0.18) == "CAP 0,18", "CAP-Chip Nacht")
        ok(MatchMath.leftoverCaptureChip(0.70) == nil, "kein CAP am Tag")
        ok(MatchMath.leftoverHoldLabel(cosine: 0.80, smooth: 0.64) == "gehalten 0,80 / 0,64", "HOLD roh/smooth")
        ok(MatchMath.leftoverHoldLabel(cosine: 0.64, smooth: 0.64) == "gehalten 0,64", "gleich eine Zahl")
        ok(
            MatchMath.leftoverHoldLabel(cosine: 0.80, yawAbs: 0.35, smooth: 0.64) == "gehalten 0,80 / 0,64 · BIN 1",
            "HOLD roh/smooth + BIN"
        )
        let nightBytes = [UInt8](repeating: 46, count: 64)
        near(MatchMath.leftoverFrameCaptureByte(nightBytes, width: 8, height: 8) ?? -1, 46.0 / 255.0, 0.001, "8×8 Nacht-Luma")
        let dayBytes = [UInt8](repeating: 178, count: 64)
        near(MatchMath.leftoverFrameCaptureByte(dayBytes, width: 8, height: 8) ?? -1, 178.0 / 255.0, 0.001, "8×8 Tag-Luma")
        ok(MatchMath.leftoverFrameCaptureByte([], width: 8, height: 8) == nil, "leerer Buffer kein Frame")
        var binTrail: [String: (samples: [Double], at: TimeInterval)] = [:]
        binTrail = MatchMath.leftoverTrailPut(
            hash: "1.2.3.4", sample: 0.80, onto: binTrail, now: 10, sharpness: 0.40, bin: 0
        )
        ok(
            abs((MatchMath.leftoverTrailLookup(hash: "1.2.3.4", table: binTrail, now: 10.2, bin: 0).last ?? -1) - 0.80) < 0.001,
            "frontal Trail Exact"
        )
        ok(
            MatchMath.leftoverTrailLookup(hash: "1.3.3.4", table: binTrail, now: 10.2, bin: 1).isEmpty,
            "¾ liest nicht Frontal-Nachbar"
        )
        ok(
            abs((MatchMath.leftoverTrailLookup(hash: "1.3.3.4", table: binTrail, now: 10.2, bin: 0).last ?? -1) - 0.80) < 0.001,
            "frontal Nachbar gleicher Bin"
        )
        binTrail = MatchMath.leftoverTrailPut(
            hash: "1.3.3.4", sample: 0.64, onto: binTrail, now: 10.1, sharpness: 0.40, bin: 1
        )
        ok(
            abs((MatchMath.leftoverTrailLookup(hash: "1.3.3.4", table: binTrail, now: 10.2, bin: 1).last ?? -1) - 0.64) < 0.001,
            "¾ Trail eigener Bin"
        )
        ok(
            abs((MatchMath.leftoverTrailLookup(hash: "1.3.3.4", table: binTrail, now: 10.2, bin: 0).last ?? -1) - 0.80) < 0.001,
            "frontal Lookup bleibt Frontal, nicht ¾"
        )
        let cropLive = MatchMath.leftoverPick(
            candidates: [(0, 0.50, 0.61)],
            sharpness: [0: 0.40],
            sessionCapture: 0.18,
            capture: [0: 0.18],
            frameCapture: MatchMath.leftoverFrameCaptureByte(dayBytes, width: 8, height: 8)
        )
        ok(cropLive == nil, "live Frame-Luma 0,70: 0,61 gegen Tag-Floor tot")
        var yawTab: [String: (cosine: Double, at: TimeInterval)] = [:]
        yawTab = MatchMath.leftoverHoldPut(hash: "1.2.3.4", cosine: 0.66, onto: yawTab, now: 10, bin: 1)
        ok(
            abs((MatchMath.leftoverHoldLookupYaw(hash: "1.2.3.4", table: yawTab, now: 10.1, yawAbs: 0.35) ?? -1) - 0.66) < 0.001,
            "Dropout ¾ LookupYaw"
        )
        ok(
            MatchMath.leftoverHoldLookupYaw(hash: "1.2.3.4", table: yawTab, now: 10.1, yawAbs: 0) == nil,
            "frontal LookupYaw erbt nicht ¾"
        )
        ok(
            MatchMath.leftoverHoldLookup(hash: "1.2.3.4", table: yawTab, now: 10.1) == nil,
            "unbinned Dropout verliert ¾"
        )
        ok(abs((MatchMath.leftoverHoldRawOf(trail: [0.80], hold: 0.64) ?? -1) - 0.80) < 0.001, "Trail roh")
        ok(abs((MatchMath.leftoverHoldRawOf(trail: [], hold: 0.64) ?? -1) - 0.64) < 0.001, "ohne Trail Hold")
        ok(
            MatchMath.leftoverHoldOverlayChip(hold: 0.64, trail: [0.80]) == "gehalten 0,80 / 0,64",
            "Overlay roh/smooth"
        )
        ok(
            MatchMath.leftoverHoldOverlayChip(hold: 0.64, trail: [0.64]) == "gehalten 0,64",
            "Overlay gleich eine Zahl"
        )
        ok(
            MatchMath.leftoverHoldOverlayChip(hold: 0.64, trail: [0.80], yawAbs: 0.35) == "gehalten 0,80 / 0,64 · BIN 1",
            "Overlay roh/smooth + BIN"
        )
        ok(MatchMath.leftoverBaptizeBoth(raw: 0.82, smooth: 0.80), "roh+smooth taufen")
        ok(!MatchMath.leftoverBaptizeBoth(raw: 0.82, smooth: 0.64), "Smooth 0,64 keine Taufe")
        ok(!MatchMath.leftoverBaptizeBoth(raw: 0.82, smooth: nil), "ohne Smooth keine Taufe")
        ok(
            MatchMath.leftoverHoldLookupYaw(hash: "1.2.3.4", table: yawTab, now: 10.1, yawAbs: nil) == nil,
            "ohne Yaw kein Frontal-Guess"
        )
        ok(
            !MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.64, trail: [0.81, 0.64, 0.82]),
            "Spike-Trail Mean < 0,80 keine Taufe"
        )
        ok(
            MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.80),
            "roh+smooth 0,80 tauft"
        )
        ok(
            !MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.64),
            "Smooth 0,64 ohne Trail keine Taufe"
        )
        ok(MatchMath.pinByPrint(cosine: 0.80), "0,80 klebt analog Taufe ≥")
        ok(MatchMath.leftoverBaptize(cosine: 0.80), "0,80 leftover tauft")
        ok(abs(MatchMath.leftoverPrintSharpOf() - 0.22) < 0.001, "Tag Sharp 0,22")
        ok(abs(MatchMath.leftoverPrintSharpOf(capture: 0.15) - 0.12) < 0.001, "Nacht Sharp 0,12")
        ok(abs(MatchMath.leftoverPrintSharpOf(continuity: true) - 0.12) < 0.001, "Continuity Sharp 0,12")
        ok(
            MatchMath.leftoverPrintOk(cosine: 0.62, sharpness: 0.14, capture: 0.15),
            "Genuine 0,62 nachts mit Laplacian 0,14"
        )
        ok(
            !MatchMath.leftoverPrintOk(cosine: 0.62, sharpness: 0.14),
            "Tag 0,14 unter leftoverPrintSharp 0,22"
        )
        ok(MatchMath.captureLockFrameRate(15) == 15, "Continuity 15 bleibt 15")
        ok(MatchMath.captureLockFrameRate(60) == 30, "60 auf 30")
        ok(MatchMath.captureLockFrameRate(8) == 8, "8 bleibt 8")
        ok(MatchMath.capturePixelBonus(osType: MatchMath.captureFourCC420f, fps: 24) > 0, "420f Bonus")
        ok(MatchMath.capturePixelBonus(osType: MatchMath.captureFourCCBGRA, fps: 8) < 0, "BGRA 8 Strafe")
        let cap720_15 = MatchMath.captureFormatScore(width: 1280, height: 720, fps: 15)
            + MatchMath.capturePixelBonus(osType: MatchMath.captureFourCC420f, fps: 15)
        let cap720_8 = MatchMath.captureFormatScore(width: 1280, height: 720, fps: 8)
            + MatchMath.capturePixelBonus(osType: MatchMath.captureFourCCBGRA, fps: 8)
        ok(cap720_15 > cap720_8, "720p 420f@15 vor BGRA@8")
        ok(
            MatchMath.leftoverHoldOverlayChip(hold: 0.66, trail: [0.64], yawAbs: 0.35) == "gehalten 0,64 / 0,66 · BIN 1",
            "Overlay ¾ roh/smooth BIN"
        )
        ok(
            MatchMath.leftoverHoldPrevOf(frontal: 0.80, yawAbs: 0.35) == nil,
            "Chip ¾ ohne Bin nicht Frontal-EMA"
        )
        ok(abs(MatchMath.captureLockFrameLo(30, rangeMin: 1) - 15) < 1e-9, "Continuity 1–30 Floor 15")
        ok(abs(MatchMath.captureLockFrameLo(30, rangeMin: 24) - 24) < 1e-9, "Built-in 24–30 bleibt 24")
        ok(abs(MatchMath.captureLockFrameLo(8, rangeMin: 1) - 8) < 1e-9, "8 fps kein 15-Floor")
        let nightMul14 = MatchMath.leftoverScore(cosine: 0.72, sharpness: 0.14, capture: 0.15)
        let dayMul14 = MatchMath.leftoverScore(cosine: 0.72, sharpness: 0.14)
        ok(nightMul14 > dayMul14, "Nacht Laplacian 0,14 ohne 0,88-Strafe")
        ok(
            MatchMath.leftoverHoldOverlayChip(hold: 0.64, trail: [0.80], compact: true) == "HOLD 80/64",
            "HOLD compact 80/64"
        )
        ok(
            MatchMath.leftoverHoldOverlayChip(hold: 0.66, trail: [0.64], yawAbs: 0.35, compact: true) == "HOLD 64/66 · BIN 1",
            "HOLD compact BIN"
        )
        ok(MatchMath.leftoverSharpChip(0.12) == "SHARP 0,12", "SHARP Chip")
        ok(MatchMath.captureBandChip(osType: MatchMath.captureFourCC420f, lo: 15, hi: 24) == "420f 15–24", "BAND 420f")
        ok(MatchMath.captureBandChip(osType: MatchMath.captureFourCCBGRA, lo: 8, hi: 8, fps: 8) == "BGRA 8", "BAND BGRA 8")
        ok(abs((MatchMath.leftoverSharpnessOf(0.12, videoRange: true) ?? 0) - (0.12 + 16.0 / 219.0)) < 0.001, "420v Sharp-Lift")
        ok(abs(MatchMath.leftoverScoreHeatMid(capture: 0.15) - 0.60) < 0.001, "Nacht Heat-Mid 0,60")
        ok(abs(MatchMath.leftoverScoreHeatMid() - 0.72) < 0.001, "Tag Heat-Mid 0,72")
        ok(abs(MatchMath.leftoverSoftmaxFloorOf(capture: 0.15) - 0.47) < 0.001, "Nacht Softmax-Floor 0,47")
        ok(MatchMath.leftoverHoldTrailOf(uuidTrail: [0.80], yawAbs: 0).count == 1, "Frontal-Trail")
        ok(MatchMath.leftoverHoldTrailOf(uuidTrail: [0.80], yawAbs: 0.35).isEmpty, "¾ kein UUID-Mix")
        ok(MatchMath.captureLockFrameRate(30, continuity: true) == 24, "Continuity 24 statt 30")
        ok(MatchMath.centerStageOff, "Center Stage aus")
        ok(MatchMath.centerStageNeedsAppControl(currentModeRaw: 0), "user-Mode muss .app nehmen")
        ok(!MatchMath.centerStageNeedsAppControl(currentModeRaw: 1), "schon .app")
        ok(MatchMath.leftoverHoldFrac(-0.64) == "-0,64", "negatives Vorzeichen")
        var oneHold: [String: (cosine: Double, at: TimeInterval)] = [:]
        oneHold = MatchMath.leftoverHoldPut(hash: "1.2.3.4", cosine: 0.80, onto: oneHold, now: 10, bin: 0)
        ok(oneHold["1.2.3.4"] == nil, "frontal nicht doppelt unbinned")
        ok(oneHold["1.2.3.4#0"] != nil, "frontal nur #0")
        ok(MatchMath.sessionPresetClampsContinuity(true), "Continuity Preset aus")
        ok(!MatchMath.leftoverBaptizeBoth(raw: 0.82, smooth: nil), "Dropout-nil keine Taufe")
        ok(!MatchMath.leftoverHoldsTrack(cosine: 0.82, holdPrev: 0.80), "0,82 nach Smooth 0,80 tauft")
        let poseChipId = UUID(uuidString: "00000000-0000-0000-0000-0000000000EA")!
        var poseChipBins: [String: Double] = [:]
        poseChipBins = MatchMath.leftoverHoldBinPut(bins: poseChipBins, id: poseChipId, yawAbs: 0.35, next: 0.64)
        ok(
            MatchMath.leftoverHoldPrevOf(frontal: 0.80, yawAbs: 0.35, bins: poseChipBins, id: poseChipId) == 0.64,
            "¾ Chip-Bin nicht Frontal"
        )
        ok(
            MatchMath.leftoverHoldOverlayChipOf(hold: 0.64, trail: [0.80], yawAbs: 0.35, compact: true) == "HOLD 64 · BIN 1",
            "¾ Overlay ohne Frontal-Trail"
        )
        ok(
            MatchMath.leftoverHoldOverlayChipOf(hold: nil, trail: [0.80], yawAbs: 0.35, compact: true) == nil,
            "¾ ohne Bin kein Frontal-Chip"
        )
        ok(
            MatchMath.leftoverHoldOverlayChipOf(hold: 0.80, trail: [0.82], yawAbs: 0.10, compact: true) == "HOLD 82/80 · BIN 0",
            "frontal Overlay compact"
        )
        ok(
            MatchMath.leftoverHoldOverlayChipOf(
                hold: 0.64, trail: [0.80], yawAbs: 0.35, compact: true, binTrail: [0.66]
            ) == "HOLD 66/64 · BIN 1",
            "¾ HOLD Bin-Trail roh"
        )
        ok(!MatchMath.leftoverNameFromHold(hasHold: true, hold: nil, yawAbs: 0.35), "¾ ohne Bin kein Name")
        ok(MatchMath.leftoverNameFromHold(hasHold: false, hold: nil, yawAbs: 0.35), "ohne leftover Live-Pin")
        ok(MatchMath.leftoverNameFromHold(hasHold: true, hold: 0.82, yawAbs: 0.35), "¾ Baptize-Bin Name")
        ok(!MatchMath.leftoverNameFromHold(hasHold: true, hold: 0.64, yawAbs: 0.35), "¾ Hold 0,64 Gast")
        ok(MatchMath.leftoverTrailNowOf(idTrail: [0.80], binTrail: [0.66], yawAbs: 0.35) == [0.66], "¾ Bin-Trail")
        ok(MatchMath.leftoverTrailNowOf(idTrail: [0.80], binTrail: [], yawAbs: 0.35).isEmpty, "¾ ohne Bin-Trail leer")
        ok(MatchMath.leftoverTrailNowOf(idTrail: [0.80], binTrail: [0.66], yawAbs: 0.10) == [0.80], "frontal UUID-Trail")
        ok(MatchMath.leftoverHoldTrailOf(uuidTrail: [0.80], yawAbs: 0.35, binTrail: [0.64]) == [0.64], "¾ Bin-Trail")
        ok(MatchMath.leftoverHoldTrailOf(uuidTrail: [0.80], yawAbs: 0.35).isEmpty, "¾ Spark ohne Bin leer")
        ok(abs(MatchMath.liveMinInterval(continuity: true, faces: false) - 0.10) < 0.001, "Hunt Continuity 10 fps")
        ok(abs(MatchMath.liveMinInterval(continuity: true, faces: true) - 1.0 / 15.0) < 0.001, "Lock Continuity 15 fps")
        ok(abs(MatchMath.liveMinInterval(continuity: false, faces: false) - 0.10) < 0.001, "Hunt Built-in 10 fps")
        ok(abs(MatchMath.liveMinInterval(continuity: false, faces: false, streak: 1) - 1.0 / 12.0) < 0.001, "Streak 1 Built-in Lock 12")
        ok(!MatchMath.physicalCaptureRotation(), "kein Coordinator")
        ok(MatchMath.videoRotationAngleFallback() == 0, "Capture 0°")
        ok(MatchMath.liveOrientationRaw(width: 720, height: 1280) == 6, "Portrait .right")
        ok(MatchMath.liveOrientationRaw(width: 1280, height: 720) == 1, "Landscape .up")
        ok(MatchMath.captureFormatScore(width: 1440, height: 1080, fps: 15) > 0, "Desk-View 4:3")
        ok(MatchMath.captureFormatScore(width: 1920, height: 1440, fps: 15) > 0, "Desk-View 1920×1440")
        ok(MatchMath.leftoverTrailWriteOk(sharpness: 0.50, yawAbs: 0.35), "¾ Trail-Write")
        ok(
            MatchMath.leftoverCosineSparkLabelOf(idTrail: [0.80, 0.82], binTrail: [0.64, 0.66], yawAbs: 0.35) == "0,64→0,66",
            "¾ Spark Bin nicht Frontal"
        )
        ok(
            MatchMath.leftoverCosineSparkLabelOf(idTrail: [0.80, 0.82], binTrail: [0.64, 0.66], yawAbs: 0.10) == "0,80→0,82",
            "frontal Spark UUID"
        )
        ok(MatchMath.leftoverBaptizeQuality(sharpness: 0.40, yawAbs: 0.10), "scharf frontal Qualität")
        ok(!MatchMath.leftoverBaptizeQuality(sharpness: 0.08, yawAbs: 0.10), "Blur keine Taufe")
        ok(!MatchMath.leftoverBaptizeQuality(sharpness: 0.40, yawAbs: 0.50), "Profil keine Taufe")
        ok(!MatchMath.leftoverBaptizeQuality(sharpness: 0.40, yawAbs: 0.10, blink: true), "Blink keine Taufe")
        ok(!MatchMath.leftoverBaptizeBoth(raw: 0.82, smooth: 0.80, sharpness: 0.08), "Blur leftoverBaptizeBoth")
        ok(MatchMath.leftoverBaptizeBoth(raw: 0.82, smooth: 0.80, sharpness: 0.40), "scharf leftoverBaptizeBoth")
        var ticks = MatchMath.leftoverScoreTickPut(0.70, onto: [])
        ticks = MatchMath.leftoverScoreTickPut(0.80, onto: ticks)
        ticks = MatchMath.leftoverScoreTickPut(0.90, onto: ticks)
        ticks = MatchMath.leftoverScoreTickPut(1.00, onto: ticks)
        ok(ticks.count == 3, "Score-EMA Cap 3")
        near(MatchMath.leftoverScoreTickMean(ticks) ?? -1, 0.90, 0.001, "Score-EMA Mean 0,80 0,90 1,00")
        ok(MatchMath.leftoverLiveNameHolds(["Anna", "Anna", "Anna"]) == "Anna", "Live-Name 3-Tick")
        ok(MatchMath.leftoverLiveNameHolds(["Anna", "Bert", "Anna"]) == nil, "Mix kein 3-Tick")
        ok(MatchMath.leftoverLiveNameHolds(["Anna", "Anna"]) == nil, "2 Ticks zu wenig")
        ok(!MatchMath.leftoverHoldWriteOk(sharpness: 0.50, yawAbs: 0.35), "¾ Hold-Write blockt")
        let spark0 = MatchMath.overlayChipPeakHold(current: "0,64→0,66", held: nil, remaining: 0, need: 2)
        ok(spark0.chip == "0,64→0,66" && spark0.remaining == 2, "Spark peak setzt 2")
        let spark1 = MatchMath.overlayChipPeakHold(current: nil, held: spark0.chip, remaining: spark0.remaining, need: 2)
        ok(spark1.chip == "0,64→0,66" && spark1.remaining == 1, "Spark Frame 1 halten")
        let spark2 = MatchMath.overlayChipPeakHold(current: nil, held: spark1.chip, remaining: spark1.remaining, need: 2)
        ok(spark2.chip == "0,64→0,66" && spark2.remaining == 0, "Spark Frame 2 halten")
        let spark3 = MatchMath.overlayChipPeakHold(current: nil, held: spark2.chip, remaining: spark2.remaining, need: 2)
        ok(spark3.chip == nil, "Spark nach Hold weg")
        ok(MatchMath.leftoverBaptizeJpeg(delta: 0.03), "JPEG 70 % Gesicht hält")
        ok(!MatchMath.leftoverBaptizeJpeg(delta: 0.12), "JPEG 70 % Poster tot")
        let blink0 = MatchMath.leftoverBlinkLiveness(open: true, openStreak: 0)
        ok(!blink0.ok && blink0.streak == 1, "Lid 1 Frame kein Liveness")
        let blink1 = MatchMath.leftoverBlinkLiveness(open: true, openStreak: blink0.streak)
        ok(blink1.ok && blink1.streak == 2, "Lid 2 Frames Liveness")
        ok(!MatchMath.leftoverBlinkLiveness(open: false, openStreak: 2).ok, "Lid zu kein Liveness")
        ok(MatchMath.liveThermalHolds(medianFps: 10, slowFor: 2.0), "Thermal hält 8 fps")
        ok(!MatchMath.liveThermalHolds(medianFps: 15, slowFor: 2.0), "15 fps kein Thermal")
        ok(MatchMath.reconnectCenterStageOff(continuity: true, enabled: true), "Continuity CS Reconnect aus")
        ok(!MatchMath.reconnectCenterStageOff(continuity: false, enabled: true), "Built-in CS egal")
        ok(abs(MatchMath.leftoverAdoptSecLock - 0.80) < 0.001, "Lock 0,80 s")
        ok(MatchMath.leftoverSparkTrailOf(uuidTrail: [0.80], hashTrail: [0.66], yawAbs: 0.35) == [0.66], "¾ Spark Hash")
        ok(MatchMath.leftoverSparkTrailOf(uuidTrail: [0.80], hashTrail: [], yawAbs: 0.35).isEmpty, "¾ Spark ohne Hash leer")
        ok(MatchMath.leftoverSparkTrailOf(uuidTrail: [0.80], hashTrail: [0.82], yawAbs: 0.10) == [0.82], "frontal Hash vor UUID")
        ok(MatchMath.leftoverLastHashKeeps(prev: "a", next: "b") == "b", "Hash Next")
        ok(MatchMath.leftoverLastHashKeeps(prev: "a", next: nil) == "a", "Hash Prev")
        ok(MatchMath.leftoverLastHashKeeps(prev: "a", next: "") == "a", "Hash leer hält")
        let hashHoldOn = MatchMath.leftoverSparkChipHold(prev: nil, now: "0,80→0,82", hold: 0)
        ok(hashHoldOn.chip == "0,80→0,82" && hashHoldOn.hold == 2, "Spark Hold setzt")
        ok(MatchMath.leftoverBaptizeGate(raw: 0.82, smooth: 0.81, sharpness: 0.50, yawAbs: 0.10), "Gate tauft")
        ok(!MatchMath.leftoverBaptizeGate(raw: 0.82, smooth: 0.81, sharpness: 0.50, yawAbs: 0.50), "Gate Profil tot")
        ok(MatchMath.leftoverPickLuma(frame: 0.40, capture: 0.10) == 0.40, "Frame-Luma vor Capture")
        ok(MatchMath.leftoverPickLuma(frame: nil, capture: 0.18) == 0.18, "Capture wenn Frame nil")
        ok(!MatchMath.videoStabilizationApplies(continuity: true), "Continuity Stabilizer aus")
        ok(MatchMath.videoStabilizationApplies(continuity: false), "Built-in Stabilizer darf")
        ok(MatchMath.leftoverLiveNameAnd(voted: "Anna", hist: ["Anna", "Anna", "Anna"]) == "Anna", "AND 3-Tick")
        ok(MatchMath.leftoverLiveNameAnd(voted: "Anna", hist: ["Anna", "Bert", "Anna"]) == nil, "AND Mix tot")
        ok(MatchMath.leftoverLiveNameAnd(voted: "Bert", hist: ["Anna", "Anna", "Anna"]) == nil, "AND Mehrheit≠3-Tick")
        ok(MatchMath.leftoverLiveNameAnd(voted: "Anna", hist: ["Anna", "Anna"]) == nil, "AND 2 Ticks tot")
        near(MatchMath.leftoverScoreTickOverlay(ema: 0.70, ticks: [0.80, 0.90, 1.00]), 0.90, 0.001, "Overlay 3-Tick")
        near(MatchMath.leftoverScoreTickOverlay(ema: 0.70, ticks: [0.80]), 0.70, 0.001, "Overlay EMA bis 3")
        ok(MatchMath.leftoverBaptizeJpegOk(nil), "ohne JPEG-Probe frei")
        ok(MatchMath.leftoverBaptizeJpegOk(0.03), "JPEG Gesicht")
        ok(!MatchMath.leftoverBaptizeJpegOk(0.12), "JPEG Poster tot")
        ok(!MatchMath.leftoverBaptizeJpegOk(nil, required: true), "JPEG required tot")
        ok(MatchMath.leftoverBaptizeJpegOk(0.03, required: true), "JPEG required Gesicht")
        ok(MatchMath.leftoverJpegProbeReuse(now: 1.2, last: 0.50), "JPEG Cache 0,80 s")
        ok(!MatchMath.leftoverJpegProbeReuse(now: 1.4, last: 0.50), "JPEG Cache abgelaufen")
        ok(!MatchMath.leftoverJpegProbeReuse(now: 1.0, last: nil), "JPEG Cache leer")
        ok(!MatchMath.leftoverJpegProbeReuse(now: 1.2, last: 0.50, hash: "b", cachedHash: "a"), "JPEG Hash-Sprung tot")
        ok(MatchMath.leftoverJpegProbeReuse(now: 1.2, last: 0.50, hash: "a", cachedHash: "a"), "JPEG Hash hält")
        ok(!MatchMath.leftoverJpegProbeReuse(now: 1.2, last: 0.50, cosine: 0.70, cachedCosine: 0.82), "JPEG Cosine-Sprung tot")
        ok(MatchMath.leftoverJpegProbePut(nil) < 0, "JPEG Miss −1")
        ok(MatchMath.leftoverJpegProbeGet(-1) == nil, "JPEG Miss Get nil")
        ok(abs((MatchMath.leftoverJpegProbeGet(0.03) ?? -1) - 0.03) < 0.001, "JPEG Hit Get")
        ok(!MatchMath.leftoverBaptizeGate(raw: 0.82, smooth: 0.81, jpegRequired: true), "Gate required ohne Probe tot")
        ok(MatchMath.leftoverBaptizeGate(raw: 0.82, smooth: 0.81, jpegDelta: 0.03, jpegRequired: true), "Gate required Gesicht")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.80, jpegRequired: true), "Print ohne Probe keine Taufe")
        ok(MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.80, jpegDelta: 0.03, jpegRequired: true), "JPEG Gesicht Taufe")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.80, jpegDelta: 0.12, jpegRequired: true), "JPEG Poster tot Taufe")
        near(MatchMath.liveMinIntervalThermal(base: 1.0 / 15.0, thermal: true), 0.125, 0.001, "Thermal Floor 8 fps")
        near(MatchMath.liveMinIntervalThermal(base: 1.0 / 15.0, thermal: false), 1.0 / 15.0, 0.001, "ohne Thermal Lock")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.80, blink: true), "Lid-Streak tot Taufe")
        ok(MatchMath.leftoverBaptizeGate(raw: 0.82, smooth: 0.81, jpegDelta: 0.03), "Gate JPEG hält")
        ok(!MatchMath.leftoverBaptizeGate(raw: 0.82, smooth: 0.81, jpegDelta: 0.12), "Gate JPEG tot")
        near(MatchMath.leftoverSessionCapturePrefersFrame(frame: nil, box: 0.40) ?? -1, 0.40, 0.001, "PickLuma in PrefersFrame")
        ok(MatchMath.liveMinInterval(continuity: true, faces: false, streak: 1) == 1.0 / 15.0, "Streak Lock 15")
        ok(MatchMath.liveMinInterval(continuity: true, faces: false, streak: 0) == 1.0 / 10.0, "Hunt 10")
        ok(MatchMath.leftoverIoUJumpBlocks(0.20), "IoU 0,20 Steal tot")
        ok(!MatchMath.leftoverIoUJumpBlocks(0.80), "IoU 0,80 hält")
        ok(!MatchMath.leftoverIoUJumpBlocks(nil), "IoU nil frei")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.80, iou: 0.20), "Box-Steal keine Taufe")
        ok(MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.80, iou: 0.90), "IoU 0,90 Taufe")
        near(MatchMath.leftoverAdoptNeedSec(dt: 0.067, yawAbs: 0.50), 1.20, 0.001, "¾ Lock 1,2 s")
        near(MatchMath.leftoverAdoptNeedSec(dt: 0.067, yawAbs: 0.10), 0.80, 0.001, "frontal Lock 0,80 s")
        near(MatchMath.leftoverJpegProbe(raw: Array(repeating: 1.0, count: 32), jpeg: Array(repeating: 1.0, count: 32)), 0, 0.001, "JPEG Gesicht 0")
        ok(MatchMath.leftoverJpegProbe(raw: Array(repeating: 1.0, count: 32), jpeg: Array(repeating: 0.0, count: 32)) > 0.5, "JPEG Poster drop")
        ok(MatchMath.leftoverHoldBinsEncode(["a": 0.80, "b": 0]).count == 1, "Bins Encode >0")
        ok(MatchMath.leftoverHoldTrailBinsEncode(["a": [0.80], "b": []]).count == 1, "Trail-Bins Encode")
        ok(MatchMath.leftoverHoldBinsDecode(nil).isEmpty, "Bins Decode nil")
        ok(MatchMath.liveBufferOrientation(width: 720, height: 1280) == 1, "0° Portrait up")
        ok(MatchMath.liveOrientationRaw(width: 720, height: 1280) == 6, "Math Portrait right")
        ok(!MatchMath.leftoverHoldsTrack(cosine: 0.82, holdPrev: 0.80, iou: 0.15), "HoldsTrack IoU tot")
        let hashEnc = MatchMath.leftoverHashHoldEncode(["ab#0": (cosine: 0.80, at: 1), "cd#0": (cosine: 0, at: 1)])
        ok(hashEnc["ab#0"] == 0.80 && hashEnc["cd#0"] == nil, "Hash-Hold Encode")
        let hashDec = MatchMath.leftoverHashHoldDecode(["ab#0": 0.80], now: 12)
        ok(hashDec["ab#0"]?.cosine == 0.80 && hashDec["ab#0"]?.at == 12, "Hash-Hold Decode now")
        ok(MatchMath.leftoverHashHoldDecode(nil, now: 1).isEmpty, "Hash-Hold nil")
        let trailEnc = MatchMath.leftoverHashTrailEncode(["ab#0": (samples: [0.80], at: 1), "x": (samples: [], at: 1)])
        ok(trailEnc["ab#0"] == [0.80] && trailEnc["x"] == nil, "Hash-Trail Encode")
        let trailDec = MatchMath.leftoverHashTrailDecode(["ab#0": [0.80, 0.82]], now: 9)
        ok(trailDec["ab#0"]?.samples == [0.80, 0.82] && trailDec["ab#0"]?.at == 9, "Hash-Trail Decode")
        ok(MatchMath.leftoverCaptureHistEncode(Array(0..<12).map(Double.init)).count == 8, "Capture-Hist 8")
        let rebased = MatchMath.leftoverHashHoldRebase(["ab#0": (cosine: 0.80, at: 1)], now: 50)
        ok(rebased["ab#0"]?.at == 50 && rebased["ab#0"]?.cosine == 0.80, "Hash Rebase at")
        ok(MatchMath.leftoverHashHoldKeeps(0.64), "Hash-Hold Floor 0,64 hält")
        ok(!MatchMath.leftoverHashHoldKeeps(0.50), "0,50 Hash-Hold tot")
        ok(MatchMath.leftoverHoldPruneSkips(rebased: true), "Prune skip Rebase")
        ok(!MatchMath.leftoverHoldPruneSkips(rebased: false), "ohne Rebase prune")
        let pruneSkip = MatchMath.leftoverHoldPrune(["ab#0": (cosine: 0.80, at: 1)], now: 50, ttl: 1.2, skip: true)
        ok(pruneSkip["ab#0"]?.cosine == 0.80, "Rebase-Tick Hold hält")
        let trailSkip = MatchMath.leftoverTrailPrune(["ab#0": (samples: [0.80], at: 1)], now: 50, ttl: 1.2, skip: true)
        ok(trailSkip["ab#0"]?.samples == [0.80], "Rebase-Tick Trail hält")
        let trailPrune = MatchMath.leftoverTrailPrune(["ab#0": (samples: [0.80], at: 1)], now: 50, ttl: 1.2)
        ok(trailPrune.isEmpty, "ohne Skip Trail tot")
        let pruneWeak = MatchMath.leftoverHoldPrune(["ab#0": (cosine: 0.50, at: 49)], now: 50, ttl: 1.2)
        ok(pruneWeak.isEmpty, "schwach Hold prune")
        var capSrc: [String: (cosine: Double, at: TimeInterval)] = [:]
        for i in 0..<70 { capSrc["k\(i)"] = (cosine: 0.80, at: TimeInterval(i)) }
        let capped = MatchMath.leftoverHashHoldCapped(capSrc)
        ok(capped.count == 64, "Hash-Hold Cap 64")
        let putWeak = MatchMath.leftoverHoldPut(hash: "zz", cosine: 0.50, onto: [:], now: 1)
        ok(putWeak.isEmpty, "schwach Put tot")
        ok(MatchMath.leftoverHashHoldChip(0.80) == "HASH 0,80", "HUD HASH")
        ok(MatchMath.leftoverHashHoldChip(0.50) == nil, "schwach kein HASH")
        ok(MatchMath.leftoverJpegChip(stored: -1, printReady: true) == "JPEG", "HUD JPEG Miss")
        ok(MatchMath.leftoverJpegChip(stored: 0.03, printReady: true) == nil, "JPEG Hit still")
        ok(MatchMath.leftoverJpegChip(stored: nil, printReady: true) == nil, "ohne Probe kein JPEG-Chip")
        ok(MatchMath.leftoverIoUJumpChip(0.20) == "JUMP", "HUD JUMP")
        ok(MatchMath.leftoverIoUJumpChip(0.90) == nil, "IoU hält kein JUMP")
        let histTab = MatchMath.leftoverCaptureHistTableEncode(["ab": [0.18, 0.19], "cd": []])
        ok(histTab["ab"]?.count == 2 && histTab["cd"] == nil, "Capture-Hist Table Encode")
        ok(MatchMath.leftoverCaptureHistTableDecode(nil).isEmpty, "Capture-Hist Table nil")
        let weakEnc = MatchMath.leftoverHashHoldEncode(["ab#0": (cosine: 0.50, at: 1)])
        ok(weakEnc.isEmpty, "Encode Floor 0,64")
        let agedHold = MatchMath.leftoverHoldPut(hash: "ab", cosine: 0.80, onto: [:], now: 10)
        ok(MatchMath.leftoverHoldPrune(agedHold, now: 12, ttl: 1.2).isEmpty, "Put+1,2 s drop")
        let indoorTTL = MatchMath.dropoutTTL(dt: 0.125)
        ok(abs(indoorTTL - 4) < 0.001, "Indoor TTL 4")
        let indoorHold = MatchMath.leftoverHoldPut(hash: "ab", cosine: 0.80, onto: [:], now: 10, ttl: indoorTTL)
        ok(MatchMath.leftoverHoldPrune(indoorHold, now: 12, ttl: indoorTTL)["ab#0"] != nil, "Put Indoor 4 s hält")
        ok(MatchMath.leftoverHoldPrune(indoorHold, now: 12)["ab#0"] == nil, "Default 1,2 s drop")
        ok(!MatchMath.dropoutSeenSlow(dt: 0.125, samples: 3), "Fallback kein Slow")
        ok(MatchMath.dropoutSeenSlow(dt: 0.125, samples: 8), "8 Samples Slow")
        ok(MatchMath.dropoutSeenSlow(dt: 0.04, samples: 8, prev: true), "Sticky hält")
        ok(!MatchMath.dropoutSeenSlow(dt: 0.04, samples: 8), "24 fps kein Slow")
        near(MatchMath.dropoutTTLSticky(dt: 0.04, seenSlow: false), 1.20, 0.001, "24 fps ohne Slow")
        near(MatchMath.dropoutTTLSticky(dt: 0.04, seenSlow: true), 4.0, 0.001, "Hop 8→24 4 s")
        let hopHold = MatchMath.leftoverHoldPut(hash: "ab", cosine: 0.80, onto: [:], now: 10, ttl: MatchMath.dropoutTTLSticky(dt: 0.04, seenSlow: true))
        ok(MatchMath.leftoverHoldPrune(hopHold, now: 12, ttl: MatchMath.dropoutTTLSticky(dt: 0.04, seenSlow: true))["ab#0"] != nil, "Hop Put+Prune 4 s")
        ok(!MatchMath.dropoutSeenSlow(dt: 0.04, samples: 8, prev: true, fastFor: 8.0), "8 s 24 fps Sticky tot")
        ok(MatchMath.dropoutSeenSlow(dt: 0.04, samples: 8, prev: true, fastFor: 7.0), "7 s 24 fps Sticky hält")
        ok(MatchMath.dropoutSeenSlow(dt: 0.125, samples: 8, prev: true, fastFor: 8.0), "8 fps Sticky trotz fastFor")
        ok(MatchMath.leftoverHoldNeighborOk(facesInFrame: 1, dist: 2), "ein Gesicht Hamming-2")
        ok(!MatchMath.leftoverHoldNeighborOk(facesInFrame: 2, dist: 2), "Twin Hamming-2 tot")
        ok(!MatchMath.leftoverHoldNeighborOk(facesInFrame: 2, dist: 1), "Twin Hamming-1 tot")
        ok(MatchMath.leftoverHoldNeighborOk(facesInFrame: 2, dist: 0), "exakt hält")
        let nbrTable = MatchMath.leftoverHoldPut(hash: "1.2.2.0", cosine: 0.80, onto: [:], now: 10)
        ok(MatchMath.leftoverHoldLookup(hash: "1.2.0.0", table: nbrTable, now: 10, facesInFrame: 1) != nil, "ein Gesicht Hamming-2 Hold")
        ok(MatchMath.leftoverHoldLookup(hash: "1.2.0.0", table: nbrTable, now: 10, facesInFrame: 2) == nil, "Twin Hamming-2 Hold tot")
        let nbr1 = MatchMath.leftoverHoldPut(hash: "1.2.1.0", cosine: 0.80, onto: [:], now: 10)
        ok(MatchMath.leftoverHoldLookup(hash: "1.2.0.0", table: nbr1, now: 10, facesInFrame: 2) == nil, "Twin Hamming-1 Hold tot")
        ok(MatchMath.leftoverHashOwnOccupied(live: ["5.5.4.6"], hash: "5.5.4.6"), "gleiche Bin occupied")
        ok(!MatchMath.leftoverHashOwnOccupied(live: ["6.5.4.6"], hash: "5.5.4.6"), "Nachbar nicht own")
        let sameHold = MatchMath.leftoverHoldPut(hash: "5.5.4.6", cosine: 0.80, onto: [:], now: 10)
        ok(MatchMath.leftoverHoldLookup(hash: "5.5.4.6", table: sameHold, now: 10, occupied: ["5.5.4.6"]) == nil, "gleiche Bin kein Hold")
        ok(MatchMath.leftoverHoldLookup(hash: "5.5.4.6", table: sameHold, now: 10) != nil, "ohne Twin Exact hält")
        ok(MatchMath.leftoverHoldPrevOf(
            frontal: nil,
            yawAbs: 0,
            hash: "5.5.4.6",
            hashTable: sameHold,
            now: 10,
            occupied: ["5.5.4.6"]
        ) == nil, "Prev occupied tot")
        ok(MatchMath.leftoverTrailLookup(
            hash: "5.5.4.6",
            table: ["5.5.4.6": (samples: [0.80], at: 10)],
            now: 10,
            occupied: ["5.5.4.6"]
        ).isEmpty, "Trail occupied tot")
        let lockUntil = MatchMath.leftoverNameLockArm(jump: true, now: 10)
        ok(abs((lockUntil ?? 0) - 11.2) < 0.001, "LOCK 1,2 s")
        ok(MatchMath.leftoverNameLockBlocks(until: 11.2, now: 11), "LOCK hält")
        ok(!MatchMath.leftoverNameLockBlocks(until: 11.2, now: 11.2), "LOCK tot")
        ok(MatchMath.leftoverNameLockChip(until: 11.2, now: 11) == "LOCK", "HUD LOCK")
        ok(!MatchMath.leftoverTransfersId(cosine: 0.82, holdPrev: 0.80, now: 11, nameLockUntil: 11.2), "LOCK keine Taufe")
        ok(MatchMath.leftoverHoldsTrack(cosine: 0.82, holdPrev: 0.80, now: 11, nameLockUntil: 11.2), "LOCK Overlay halten")
        ok(!MatchMath.leftoverHoldsTrack(cosine: 0.82, holdPrev: 0.80, now: 11, iou: 0.15, nameLockUntil: 11.2), "JUMP Frame kein Hold")
        ok(abs(MatchMath.leftoverHoldTTLPref(0.5) - 1.2) < 0.001, "TTL Pref Floor 1,2")
        ok(abs(MatchMath.leftoverHoldTTLPref(8) - 4) < 0.001, "TTL Pref Cap 4")
        ok(abs(MatchMath.leftoverHoldTTLPref(2) - 2) < 0.001, "TTL Pref 2")
        let lockKeep = MatchMath.leftoverHoldSurvive(
            hold: [idHoldA: 0.70],
            ghosts: [],
            live: [],
            locked: [idHoldA]
        )
        ok(lockKeep[idHoldA] == 0.70, "LOCK Hold überlebt")
        ok(MatchMath.leftoverNameLockLive(until: [idHoldA: 11.2], now: 11) == [idHoldA], "LOCK live")
        ok(MatchMath.leftoverNameLockLive(until: [idHoldA: 11.2], now: 12).isEmpty, "LOCK tot live")
        let lockedMaj = MatchMath.leftoverAssignMajority(
            committed: nil,
            proposed: idHoldA,
            lastProposed: idHoldA,
            streak: 2,
            locked: true
        )
        ok(!lockedMaj.ready && lockedMaj.streak == 0, "LOCK Majority tot")
        let freeMaj = MatchMath.leftoverAssignMajority(
            committed: nil,
            proposed: idHoldA,
            lastProposed: idHoldA,
            streak: 2
        )
        ok(freeMaj.ready, "ohne LOCK Majority ready")
        ok(MatchMath.leftoverLiveNameAnd(voted: "Anna", hist: ["Anna", "Anna", "Anna"]) == "Anna", "AND ohne LOCK")
        ok(MatchMath.leftoverLiveNameAnd(voted: "Bert", hist: ["Bert", "Bert", "Bert"], locked: true, held: "Anna") == "Anna", "LOCK hält Anna")
        ok(MatchMath.leftoverLiveNameAnd(voted: "Bert", hist: ["Bert", "Bert", "Bert"], locked: true) == nil, "LOCK ohne Hold tot")
        ok(MatchMath.leftoverHoldNeighborChip(facesInFrame: 2, dist: 2) == "NBR", "HUD NBR")
        ok(MatchMath.leftoverHoldNeighborChip(facesInFrame: 1, dist: 2) == nil, "ein Gesicht kein NBR")
        ok(MatchMath.leftoverHoldNeighborChip(facesInFrame: 2, dist: 1) == "NBR", "Hamming-1 NBR")
        ok(MatchMath.leftoverNameLockKeeps(until: 11.2, now: 11.0, name: "Anna") == "Anna", "Name hält")
        ok(MatchMath.leftoverNameLockKeeps(until: 11.2, now: 11.0, name: nil) == nil, "ohne Name tot")
        ok(MatchMath.leftoverNameLockKeeps(until: 11.2, now: 12, name: "Anna") == nil, "Lock abgelaufen")
        ok(MatchMath.leftoverHoldHashBare("1.2.3.4#1") == "1.2.3.4", "Hash Bare")
        ok(MatchMath.leftoverHoldHashBare("1.2.3.4") == "1.2.3.4", "Hash ohne Bin")
        let nbrNow: TimeInterval = 10
        let nbrDist: [String: (cosine: Double, at: TimeInterval)] = [
            "1.2.3.4#0": (0.80, nbrNow),
            "3.2.3.4#0": (0.70, nbrNow)
        ]
        ok(MatchMath.leftoverHoldNeighborDist(hash: "1.2.3.4", table: nbrDist, now: nbrNow) == 2, "Lookup Hamming-2")
        ok(MatchMath.leftoverHoldNeighborDist(hash: "1.2.3.4", table: ["1.2.3.4#0": (0.80, nbrNow)], now: nbrNow) == 0, "ohne Nachbar 0")
        ok(MatchMath.leftoverHoldNeighborChip(
            facesInFrame: 2,
            dist: MatchMath.leftoverHoldNeighborDist(hash: "1.2.3.4", table: nbrDist, now: nbrNow)
        ) == "NBR", "Lookup NBR")
        ok(MatchMath.leftoverHoldFastChip(seenSlow: true, dt: 0.04) == "FAST", "HUD FAST")
        ok(MatchMath.leftoverHoldFastChip(seenSlow: true, dt: 0.125) == nil, "8 fps kein FAST")
        ok(MatchMath.leftoverHoldFastChip(seenSlow: false, dt: 0.04) == nil, "ohne Slow kein FAST")
        ok(abs(MatchMath.leftoverNameLockSecPref(0.2) - 0.6) < 0.001, "LOCK Pref Floor 0,6")
        ok(abs(MatchMath.leftoverNameLockSecPref(3) - 2) < 0.001, "LOCK Pref Cap 2")
        ok(abs(MatchMath.leftoverAdoptSecLockPref(0.2) - 0.6) < 0.001, "Adopt Pref Floor 0,6")
        ok(abs(MatchMath.leftoverAdoptSecLockPref(2) - 1.4) < 0.001, "Adopt Pref Cap 1,4")
        near(MatchMath.leftoverHoldTTLOf(seenSlow: true, pref: 1.2), 4.0, 0.001, "Indoor TTL 4")
        near(MatchMath.leftoverHoldTTLOf(seenSlow: false, pref: 2.4), 2.4, 0.001, "24 fps Pref 2,4")
        near(MatchMath.leftoverHoldTTLOf(seenSlow: false, pref: 0.5), 1.2, 0.001, "24 fps Pref Floor")
        ok(MatchMath.leftoverOccupiedMerge(stored: [], live: ["1.2.0.0"]) == ["1.2.0.0"], "Live Tick Occupied")
        ok(MatchMath.leftoverOccupiedMerge(stored: ["1.2.0.0"], live: ["1.2.0.0"]) == ["1.2.0.0"], "Merge unique")
        ok(MatchMath.leftoverOccupiedMerge(stored: ["1.2.0.0"], live: ["9.9.9.9"]).sorted() == ["1.2.0.0", "9.9.9.9"].sorted(), "Merge beide")
        ok(MatchMath.leftoverHashOwnOccupied(
            live: MatchMath.leftoverOccupiedMerge(stored: [], live: ["5.5.4.6"]),
            hash: "5.5.4.6"
        ), "erster Twin-Frame occupied")
        let firstTwin = MatchMath.leftoverHoldPut(hash: "5.5.4.6", cosine: 0.80, onto: [:], now: 10)
        ok(MatchMath.leftoverHoldLookup(
            hash: "5.5.4.6",
            table: firstTwin,
            now: 10,
            occupied: MatchMath.leftoverOccupiedMerge(stored: [], live: ["5.5.4.6"])
        ) == nil, "erster Twin Exact tot")
        ok(MatchMath.leftoverHashTwinLeft(x: 0.20, others: [0.70]), "links vor rechts")
        ok(!MatchMath.leftoverHashTwinLeft(x: 0.70, others: [0.20]), "rechts nicht links")
        let twinOcc = MatchMath.leftoverHashTwinOccupied(
            occupied: ["5.5.4.6"],
            hash: "5.5.4.6",
            x: 0.20,
            others: [(hash: "5.5.4.6", x: 0.70)]
        )
        ok(twinOcc.isEmpty, "Twin L Exact frei")
        let twinRight = MatchMath.leftoverHashTwinOccupied(
            occupied: ["5.5.4.6"],
            hash: "5.5.4.6",
            x: 0.70,
            others: [(hash: "5.5.4.6", x: 0.20)]
        )
        ok(twinRight == ["5.5.4.6"], "Twin R Occupied")
        ok(MatchMath.leftoverHoldLookup(hash: "5.5.4.6", table: firstTwin, now: 10, occupied: twinOcc) != nil, "Twin L Exact hält")
        ok(MatchMath.leftoverHoldLookup(hash: "5.5.4.6", table: firstTwin, now: 10, occupied: twinRight) == nil, "Twin R Exact tot")
        ok(!MatchMath.leftoverHashTwinLeft(x: 0.50, others: [0.50]), "Gleichstand kein links")
        let twinTie = MatchMath.leftoverHashTwinOccupied(
            occupied: ["5.5.4.6"],
            hash: "5.5.4.6",
            x: 0.50,
            others: [(hash: "5.5.4.6", x: 0.50)]
        )
        ok(twinTie == ["5.5.4.6"], "Gleichstand Occupied")
        ok(MatchMath.leftoverHoldNeighborScans(facesInFrame: 1), "ein Gesicht scannt Nachbarn")
        ok(!MatchMath.leftoverHoldNeighborScans(facesInFrame: 2), "Twin kein Nachbar-Walk")
        var histCap: [String: [Double]] = [:]
        for i in 0..<70 { histCap["k\(i)"] = [0.18] }
        ok(MatchMath.leftoverCaptureHistTableEncode(histCap).count == 64, "Capture-Hist Table Cap 64")
        histCap["zz"] = [0.22]
        let histKeep = MatchMath.leftoverCaptureHistTableEncode(histCap, keep: ["zz"])
        ok(histKeep["zz"] == [0.22] && histKeep.count == 64, "Capture-Hist Keep vor Cap")
        var histTable: [String: [Double]] = histCap
        histTable = MatchMath.leftoverCaptureHistTablePut(hash: "keep", hist: [0.19], onto: histTable)
        ok(histTable["keep"] == [0.19] && histTable.count == 64, "Capture-Hist Put hält Key")
        var trailCap: [String: (samples: [Double], at: TimeInterval)] = [:]
        for i in 0..<70 {
            trailCap = MatchMath.leftoverTrailPut(hash: "t\(i)", sample: 0.80, onto: trailCap, now: TimeInterval(i), sharpness: 0.40, ttl: 1000)
        }
        ok(trailCap.count == 64, "Hash-Trail Cap 64")
        ok(trailCap["t69"]?.samples.last == 0.80, "jüngster Trail hält")
        ok(MatchMath.leftoverHashTwinChip(x: 0.20, others: [0.70]) == "TWIN L", "HUD TWIN L")
        ok(MatchMath.leftoverHashTwinChip(x: 0.70, others: [0.20]) == "TWIN R", "HUD TWIN R")
        ok(MatchMath.leftoverHashTwinChip(x: 0.20, others: []) == nil, "allein kein TWIN")
        ok(MatchMath.leftoverHashTwinRank(x: 0.20, others: [0.70]) == 0, "Twin L Rank 0")
        ok(MatchMath.leftoverHashTwinRank(x: 0.70, others: [0.20]) == 1, "Twin R Rank 1")
        ok(MatchMath.leftoverHoldHashTwinKey(hash: "5.5.4.6", rank: 0) == "5.5.4.6", "Rank 0 Bare")
        ok(MatchMath.leftoverHoldHashTwinKey(hash: "5.5.4.6", rank: 1) == "5.5.4.6#101", "Rank 1 Key")
        ok(MatchMath.leftoverHashTwinRanked(hash: "5.5.4.6", x: 0.20, others: [(hash: "5.5.4.6", x: 0.70)]) == "5.5.4.6", "Twin L persist Bare")
        ok(MatchMath.leftoverHashTwinRanked(hash: "5.5.4.6", x: 0.70, others: [(hash: "5.5.4.6", x: 0.20)]) == "5.5.4.6#101", "Twin R persist 101")
        ok(MatchMath.leftoverHashTwinRanked(hash: "5.5.4.6", x: 0.20, others: []) == "5.5.4.6", "allein kein Rank")
        let rankedR = MatchMath.leftoverHashTwinRanked(hash: "5.5.4.6", x: 0.70, others: [(hash: "5.5.4.6", x: 0.20)])
        let putRanked = MatchMath.leftoverHoldPut(hash: rankedR, cosine: 0.80, onto: [:], now: 10)
        ok(MatchMath.leftoverHoldLookup(hash: rankedR, table: putRanked, now: 10, occupied: ["5.5.4.6"]) != nil, "Twin R Exact hält")
        ok(MatchMath.leftoverHoldLookup(hash: rankedR, table: putRanked, now: 10, occupied: [rankedR]) == nil, "Twin R Occupied tot")
        let twinIdL = UUID()
        let twinIdR = UUID()
        let occOthers = MatchMath.leftoverOccupiedOthers(
            live: [(id: twinIdL, hash: "5.5.4.6", x: 0.20)],
            stored: [(id: twinIdR, hash: "5.5.4.6#101", x: 0.70)],
            except: twinIdL
        )
        ok(occOthers.count == 1, "Occupied others stored")
        ok(occOthers.first?.hash == "5.5.4.6#101", "Occupied others Twin R")
        let occLiveFirst = MatchMath.leftoverOccupiedOthers(
            live: [(id: twinIdL, hash: "5.5.4.6", x: 0.20)],
            stored: [(id: twinIdL, hash: "old", x: 0.20)],
            except: twinIdR
        )
        ok(occLiveFirst.count == 1, "Occupied others live vor stored")
        ok(occLiveFirst.first?.hash == "5.5.4.6", "Occupied others live gewinnt")
        ok(MatchMath.leftoverLastHashWipes(empty: true), "empty wischt Last-Hash")
        ok(!MatchMath.leftoverLastHashWipes(empty: true, overlayKeep: true), "Overlay hält Last-Hash")
        ok(!MatchMath.leftoverLastHashWipes(empty: false), "live hält Last-Hash")
        ok(MatchMath.leftoverRankedHashOf(tick: "5.5.4.6#101", last: "5.5.4.6", fallback: "x") == "5.5.4.6#101", "Tick vor Last")
        ok(MatchMath.leftoverRankedHashOf(tick: nil, last: "5.5.4.6#101", fallback: "x") == "5.5.4.6#101", "Last vor Spatial")
        ok(MatchMath.leftoverRankedHashOf(tick: "", last: nil, fallback: "5.5.4.6") == "5.5.4.6", "Spatial Fallback")
        ok(MatchMath.leftoverHoldHashSpatial("5.5.4.6#101#0") == "5.5.4.6", "Spatial strip Rank+Bin")
        ok(MatchMath.leftoverHoldHashSpatial("5.5.4.6") == "5.5.4.6", "Spatial nackt")
        let nbrTwin: [String: (cosine: Double, at: TimeInterval)] = [
            "5.5.4.6#0": (0.80, nbrNow),
            "5.5.4.6#101#0": (0.80, nbrNow)
        ]
        ok(MatchMath.leftoverHoldNeighborDist(hash: "5.5.4.6#101", table: nbrTwin, now: nbrNow) == 0, "Twin R kein NBR")
        ok(MatchMath.leftoverHoldNeighborDist(hash: "5.5.4.6", table: nbrTwin, now: nbrNow) == 0, "Twin L kein NBR")
        ok(MatchMath.leftoverLiveHashTickWipes(empty: true), "empty wischt Live-Hash")
        ok(!MatchMath.leftoverLiveHashTickWipes(empty: false), "live hält Hash")
        ok(MatchMath.leftoverHoldIndoorChip(seenSlow: true, ttl: 4) == "INDOOR 4s", "HUD INDOOR")
        ok(MatchMath.leftoverHoldIndoorChip(seenSlow: false, ttl: 1.2) == nil, "24 fps kein INDOOR")
        let lockArm = MatchMath.leftoverNameLockArm(jump: true, now: 10, sec: 0.6)
        ok(abs((lockArm ?? 0) - 10.6) < 0.001, "LOCK Pref 0,6")
        near(MatchMath.leftoverAdoptNeedSec(dt: 0.016, lockPref: 1.0), 1.0, 0.001, "Adopt Pref 1,0")
        near(MatchMath.leftoverAdoptNeedSec(dt: 0.016), 0.80, 0.001, "Adopt Default 0,80")
        let xa = UUID(), xb = UUID()
        ok(MatchMath.leftoverHoldXMatch(liveX: 0.70, holds: [(id: xa, x: 0.20), (id: xb, x: 0.72)]) == xb, "x-order nächster Hold")
        ok(MatchMath.leftoverHoldXMatch(liveX: 0.10, holds: []) == nil, "ohne Holds nil")
        let fillX = MatchMath.leftoverAssignFillX(assigned: [nil, nil], liveX: [0.20, 0.80], holdX: [0.22, 0.78])
        ok(fillX[0] == 0 && fillX[1] == 1, "FillX x-order")
        let fillKeep = MatchMath.leftoverAssignFillX(assigned: [1, 0], liveX: [0.20, 0.80], holdX: [0.22, 0.78])
        ok(fillKeep[0] == 1 && fillKeep[1] == 0, "FillX hält Print-Assign")
        ok(MatchMath.leftoverAssignFillX(assigned: [nil], liveX: [], holdX: [0.5])[0] == nil, "ohne liveX nil")
        ok(MatchMath.leftoverHoldXMatch(liveX: 0.90, holds: [(id: xa, x: 0.10)]) == nil, "FillX Pad 0,12 Far tot")
        let fillFar = MatchMath.leftoverAssignFillX(assigned: [nil], liveX: [0.90], holdX: [0.10])
        ok(fillFar[0] == nil, "FillX Pad hält Far")
        let restartFar: [[Double?]] = [[nil, nil]]
        ok(MatchMath.leftoverAssignLive(scores: restartFar, liveX: [0.90], holdX: [0.10])[0] == nil, "AssignLive Far tot")
        ok(MatchMath.leftoverHashTwinChip(x: 0.20, others: [0.50, 0.80]) == "TWIN 1", "Crowd TWIN 1")
        ok(MatchMath.leftoverHashTwinChip(x: 0.50, others: [0.20, 0.80]) == "TWIN 2", "Crowd TWIN 2")
        ok(MatchMath.leftoverHashTwinChip(x: 0.80, others: [0.20, 0.50]) == "TWIN 3", "Crowd TWIN 3")
        let gateKeep = MatchMath.overlayChipCap(["HASH", "JPEG", "FAST", "INDOOR", "X", "Y", "TWIN L", "NBR"])
        ok(gateKeep.contains(where: { $0.hasPrefix("TWIN") }) && gateKeep.contains("NBR"), "TWIN/NBR überleben Cap")
        ok(MatchMath.overlayChipCap(["LOCK", "LOCK", "NBR"]).count == 2, "Gate unique")
        let twinScores: [[Double?]] = [[0.70, 0.69], [0.88, 0.40]]
        let liveFill = MatchMath.leftoverAssignLive(scores: twinScores, liveX: [0.20, 0.80], holdX: [0.22, 0.78])
        ok(liveFill[0] == nil, "FillX hebt Twin-Veto nicht")
        ok(liveFill[1] != nil, "klare Zeile nach FillX")
        let noPrint: [[Double?]] = [[nil, nil], [nil, nil]]
        let restartFill = MatchMath.leftoverAssignLive(scores: noPrint, liveX: [0.20, 0.80], holdX: [0.22, 0.78])
        ok(restartFill[0] == 0 && restartFill[1] == 1, "ohne Print x-order")
        let rankedHist: [String: [Double]] = ["5.5.4.6#101": [0.18, 0.19]]
        ok(MatchMath.leftoverCaptureHistLookup(hash: "5.5.4.6#101", fallback: "5.5.4.6", table: rankedHist) == [0.18, 0.19], "Hist Rank-Key")
        ok(MatchMath.leftoverCaptureHistLookup(hash: "5.5.4.6#101", fallback: "5.5.4.6", table: ["5.5.4.6": [0.20]]) == [0.20], "Hist Spatial-Fallback")
        ok(MatchMath.overlayChipCap(["HASH", "LOCK", "NBR", "FAST", "INDOOR", "TWIN", "JPEG"]).count == 6, "Gate Chip Cap 6")
        ok(MatchMath.overlayChipCap(["", "LOCK"]).count == 1, "leere Chips raus")
        let steal = MatchMath.leftoverAssignFillX(assigned: [nil, nil], liveX: [0.22], holdX: [0.30, 0.20])
        ok(steal[0] == nil && steal[1] == 0, "FillX greedy näherer Hold")
        let xa2 = UUID(), xb2 = UUID()
        ok(MatchMath.leftoverHoldXMatch(liveX: 0.22, holds: [(id: xa2, x: 0.30), (id: xb2, x: 0.20)]) == xb2, "HoldX näherer")
        ok(MatchMath.leftoverHoldXMatch(liveX: 0.22, holds: [(id: xa2, x: 0.90), (id: xb2, x: 0.20)], occupied: [xb2]) == nil, "HoldX Occupied Far tot")
        ok(MatchMath.leftoverHoldXMatch(liveX: 0.50, holds: [(id: xa2, x: 0.45), (id: xb2, x: 0.55)]) == nil, "HoldX Spread Twin tot")
        let gateOrder = MatchMath.overlayChipCap(["HASH", "JPEG", "FAST", "INDOOR", "X", "Y", "TWIN L", "NBR"])
        ok(gateOrder.first == "HASH" || gateOrder.contains("TWIN L"), "Gate Keep Original-Lage")
        ok(gateOrder.contains(where: { $0.hasPrefix("TWIN") }), "TWIN bleibt")
        ok(!MatchMath.leftoverXAmbiguous(d: 0.02, d2: 0.08), "0,02 vs 0,08 eindeutig")
        ok(MatchMath.leftoverXAmbiguous(d: 0.05, d2: 0.05), "Twin-Mitte d=d2")
        ok(!MatchMath.leftoverXAmbiguous(d: 0.02, d2: 0.58), "Far kein Spread")
        let twinMid = MatchMath.leftoverAssignFillX(assigned: [nil, nil], liveX: [0.50], holdX: [0.45, 0.55])
        ok(twinMid[0] == nil && twinMid[1] == nil, "FillX Spread Twin-Mitte tot")
        let liveTwin = MatchMath.leftoverAssignLive(scores: [[nil], [nil]], liveX: [0.50], holdX: [0.45, 0.55])
        ok(liveTwin[0] == nil && liveTwin[1] == nil, "AssignLive Spread Twin tot")
        ok(MatchMath.leftoverHoldXMatch(liveX: 0.22, holds: [(id: xa2, x: 0.30), (id: xb2, x: 0.20)]) == xb2, "HoldX näherer nach relativem Spread")
        let reminted = MatchMath.leftoverAssignRemint(liveX: [0.20, 0.80], holdX: [0.22, 0.78])
        ok(reminted[0] == 0 && reminted[1] == 1, "Remint x-order")
        let idOld = UUID(), idNew = UUID(), idStale = UUID()
        let remint = MatchMath.leftoverHoldRemint(
            hold: [idOld: 0.72],
            live: [(id: idNew, x: 0.20)],
            stored: [(id: idStale, x: 0.205), (id: idOld, x: 0.22)]
        )
        ok(remint[idNew] == 0.72 && remint[idOld] == 0.72, "Hold Remint skippt Stale")
        let binOld = MatchMath.leftoverHoldKey(id: idOld, bin: 1)
        let remintBins = MatchMath.leftoverHoldRemintBins(
            hold: [binOld: 0.68],
            live: [(id: idNew, x: 0.21)],
            stored: [(id: idOld, x: 0.20)]
        )
        ok(remintBins[MatchMath.leftoverHoldKey(id: idNew, bin: 1)] == 0.68, "Remint Bins ¾")
        ok(MatchMath.leftoverHoldBinFromKey(binOld) == 1, "BinFromKey")
        ok(MatchMath.leftoverAssignLiveGate(unnamed: 1, unused: 1), "1+1 Gate")
        ok(!MatchMath.leftoverAssignLiveGate(unnamed: 0, unused: 1), "ohne Live tot")
        ok(!MatchMath.leftoverAssignLiveGate(unnamed: 1, unused: 0), "ohne Hold tot")
        let one = MatchMath.leftoverAssignLive(scores: [[nil]], liveX: [0.21], holdX: [0.22])
        ok(one[0] == 0, "1 Hold 1 Live x-Fill")
        let pairOld = UUID(), pairNew = UUID()
        let pairRemint = MatchMath.leftoverHoldRemint(
            hold: [pairOld: pairOld],
            live: [(id: pairNew, x: 0.21)],
            stored: [(id: pairOld, x: 0.22)]
        )
        ok(pairRemint[pairNew] == pairOld, "Pair-Commit Remint auf Live-UUID")
        let liveBox = FaceBox(x: 0.25, y: 0.4, width: 0.1, height: 0.1)
        let streakLive = MatchMath.leftoverStreakBoxLive(
            boxes: [pairOld: FaceBox(x: 0.22, y: 0.4, width: 0.1, height: 0.1)],
            live: [(id: pairNew, box: liveBox)],
            holdIds: [pairNew]
        )
        ok(abs((streakLive[pairNew]?.x ?? 0) - 0.25) < 1e-9, "StreakBox Live nach Remint")
        let hashOld = UUID(), hashNew = UUID()
        ok(
            MatchMath.leftoverHoldHashRescue(
                liveHash: "5.5.4.6",
                stored: [(id: hashOld, hash: "5.5.4.6")]
            ) == hashOld,
            "Hash-Rescue Exact"
        )
        ok(
            MatchMath.leftoverHoldHashRescue(
                liveHash: "5.5.4.6",
                stored: [(id: hashOld, hash: "5.5.4.6")],
                occupied: [hashOld]
            ) == nil,
            "Hash-Rescue Occupied tot"
        )
        ok(
            MatchMath.leftoverHoldHashRescue(
                liveHash: "5.5.4.6",
                stored: [(id: hashOld, hash: "5.5.4.6"), (id: hashNew, hash: "5.5.4.6")]
            ) == nil,
            "Hash-Rescue Twin tot"
        )
        let farRemint = MatchMath.leftoverHoldRemint(
            hold: [hashOld: 0.72],
            live: [(id: hashNew, x: 0.90)],
            stored: [(id: hashOld, x: 0.20)],
            liveHash: [hashNew: "5.5.4.6"],
            storedHash: [hashOld: "5.5.4.6"]
        )
        ok(farRemint[hashNew] == 0.72, "Remint Hash-Rescue wenn x > Pad")
        let farX = MatchMath.leftoverHoldRemint(
            hold: [hashOld: 0.72],
            live: [(id: hashNew, x: 0.90)],
            stored: [(id: hashOld, x: 0.20)]
        )
        ok(farX[hashNew] == nil, "ohne Hash Far tot")
        let tickFrom = UUID(), tickTo = UUID()
        let copied = MatchMath.leftoverLiveHashTickCopy(
            tick: [tickFrom: "5.5.4.6#101"],
            from: tickFrom,
            to: tickTo
        )
        ok(copied[tickTo] == "5.5.4.6#101" && copied[tickFrom] == nil, "Tick Copy Transfer")
        let over = MatchMath.leftoverLiveHashTickCopy(
            tick: [tickFrom: "5.5.4.6#101", tickTo: "1.1.1.1"],
            from: tickFrom,
            to: tickTo
        )
        ok(over[tickTo] == "5.5.4.6#101" && over[tickFrom] == nil, "Tick Copy überschreibt Live")
        ok(MatchMath.leftoverAssignLiveGate(unnamed: 1, unused: 1, need: 2) == false, "Gate Pref 2 Solo tot")
        ok(MatchMath.leftoverAssignLiveGateNeed(0) == 1 && MatchMath.leftoverAssignLiveGateNeed(9) == 3, "Gate Need Clamp 3")
        let binRescueOld = MatchMath.leftoverHoldKey(id: hashOld, bin: 0)
        let binRescue = MatchMath.leftoverHoldRemintBins(
            hold: [binRescueOld: 0.66],
            live: [(id: hashNew, x: 0.90)],
            stored: [(id: hashOld, x: 0.20)],
            liveHash: [hashNew: "4.4.3.5"],
            storedHash: [hashOld: "4.4.3.5"]
        )
        ok(binRescue[MatchMath.leftoverHoldKey(id: hashNew, bin: 0)] == 0.66, "RemintBins Hash-Rescue")
        let walkOld = UUID(), walkNew = UUID()
        let walked = MatchMath.leftoverHoldRemint(
            hold: [walkOld: 0.81],
            live: [(id: walkNew, x: 0.40)],
            stored: [(id: walkOld, x: 0.22)]
        )
        ok(walked[walkNew] == 0.81, "x-Rescue 0,28 ohne Hash")
        ok(MatchMath.leftoverHoldXMatch(liveX: 0.40, holds: [(id: walkOld, x: 0.22)]) == nil, "Pad 0,12 Far tot")
        let pairMoved = MatchMath.leftoverHoldMove(hold: [walkOld: walkOld], from: walkOld, to: walkNew)
        ok(pairMoved[walkNew] == walkOld && pairMoved[walkOld] == nil, "Pair HoldMove")
        let pairVal = MatchMath.leftoverHoldMoveId(hold: [walkOld: walkOld], from: walkOld, to: walkNew)
        ok(pairVal[walkNew] == walkNew && pairVal[walkOld] == nil, "Pair Value-Remint")
        ok(!MatchMath.leftoverClearDropsPair(transferred: true), "Transfer hält Pair")
        ok(MatchMath.leftoverClearDropsPair(transferred: false), "ohne Transfer Pair tot")
        let pairId = MatchMath.leftoverHoldRemintId(
            hold: [walkOld: walkOld],
            live: [(id: walkNew, x: 0.40)],
            stored: [(id: walkOld, x: 0.22)]
        )
        ok(pairId[walkNew] == walkNew, "Pair Value-Remint nach x-Rescue")
        let twinDest = UUID()
        let pairTwin = MatchMath.leftoverHoldRemintId(
            hold: [walkOld: twinDest],
            live: [(id: walkNew, x: 0.40)],
            stored: [(id: walkOld, x: 0.22)]
        )
        ok(pairTwin[walkNew] == twinDest, "Remint Dest Twin hält")
        ok(pairTwin[walkNew] != walkNew, "Remint Dest nicht self")
        let destMap = MatchMath.leftoverUUIDUUIDMapRemintDest([walkOld: twinDest], remap: [walkOld: walkNew])
        ok(destMap[walkNew] == twinDest, "RemintDest Map Twin")
        let rescueLive = MatchMath.leftoverAssignLive(scores: [[nil]], liveX: [0.40], holdX: [0.22])
        ok(rescueLive[0] == 0, "AssignLive x-Rescue 0,28")
        ok(
            MatchMath.leftoverAssignLive(scores: [[nil]], liveX: [0.90], holdX: [0.10])[0] == nil,
            "AssignLive Far 0,80 tot"
        )
        let hashSoloOld = UUID(), hashSoloNew = UUID()
        ok(
            MatchMath.leftoverHoldByHashSolo(
                liveHash: "5.5.4.6",
                holdIDs: [hashSoloOld],
                tableKeys: ["5.5.4.6#0"]
            ) == hashSoloOld,
            "HoldByHash Solo Spatial"
        )
        ok(
            MatchMath.leftoverHoldByHashSolo(
                liveHash: "5.5.4.6",
                holdIDs: [hashSoloOld, UUID()],
                tableKeys: ["5.5.4.6#0"]
            ) == nil,
            "HoldByHash Twin tot"
        )
        let byHash = MatchMath.leftoverHoldRemint(
            hold: [hashSoloOld: 0.77],
            live: [(id: hashSoloNew, x: 0.90)],
            stored: [(id: hashSoloOld, x: 0.20)],
            liveHash: [hashSoloNew: "5.5.4.6"],
            hashTableKeys: ["5.5.4.6#0"]
        )
        ok(byHash[hashSoloNew] == 0.77, "HoldByHash Solo Rescue ohne LastHash")
        let byHashFar = MatchMath.leftoverHoldRemint(
            hold: [hashSoloOld: 0.77],
            live: [(id: hashSoloNew, x: 0.90)],
            stored: [(id: hashSoloOld, x: 0.20)],
            liveHash: [hashSoloNew: "5.5.4.6"]
        )
        ok(byHashFar[hashSoloNew] == nil, "ohne Table Far tot")
        ok(MatchMath.leftoverAssignLiveGate(unnamed: 2, unused: 2, need: 2), "Crowd Gate 2")
        ok(!MatchMath.leftoverAssignLiveGate(unnamed: 1, unused: 2, need: 2), "Crowd Gate Solo tot")
        ok(MatchMath.leftoverAssignLiveGate(unnamed: 3, unused: 3, need: 3), "Crowd Gate 3")
        ok(!MatchMath.leftoverAssignLiveGate(unnamed: 2, unused: 3, need: 3), "Crowd 3 bei 2 tot")
        let mergeKeep = UUID(), mergeFill = UUID()
        let merged = MatchMath.leftoverStoredHashMerge(
            last: [mergeKeep: "5.5.4.6", mergeFill: ""],
            tick: [mergeKeep: "1.1.1.1", mergeFill: "2.2.2.2"]
        )
        ok(merged[mergeKeep] == "5.5.4.6", "Merge Last nicht überschreiben")
        ok(merged[mergeFill] == "2.2.2.2", "Merge Tick füllt Last-Loch")
        let byOld = UUID(), byNew = UUID(), stealBob = UUID()
        let byKeys = ["5.5.4.6#0", "5.5.4.6#1"]
        ok(
            MatchMath.leftoverHoldByHashRescue(
                liveHash: "5.5.4.6",
                stored: [(id: byOld, hash: "")],
                tableKeys: byKeys
            ) == byOld,
            "ByHash Bins zählen als eins, Last leer, 1 Hold"
        )
        ok(
            MatchMath.leftoverHoldByHashRescue(
                liveHash: "5.5.4.6",
                stored: [(id: byOld, hash: ""), (id: stealBob, hash: "")],
                tableKeys: byKeys
            ) == nil,
            "ByHash Twin tot"
        )
        ok(
            MatchMath.leftoverHoldByHashRescue(
                liveHash: "5.5.4.6",
                stored: [(id: stealBob, hash: "1.1.1.1")],
                tableKeys: byKeys
            ) == nil,
            "ByHash stiehlt nicht den Nachbarn"
        )
        ok(
            MatchMath.leftoverHoldByHashRescue(
                liveHash: "5.5.4.6",
                stored: [(id: stealBob, hash: "")],
                tableKeys: ["5.5.4.6#0", "1.1.1.1#0"]
            ) == nil,
            "ByHash Crowd 1-open tot"
        )
        ok(
            MatchMath.leftoverHoldByHashRescue(
                liveHash: "5.5.4.6",
                stored: [(id: byOld, hash: "5.5.4.6"), (id: stealBob, hash: "1.1.1.1")],
                tableKeys: byKeys
            ) == byOld,
            "ByHash Unique Hash-Match trotz 2 Holds"
        )
        let hashedRemint = MatchMath.leftoverHoldRemint(
            hold: [byOld: 0.81, stealBob: 0.70],
            live: [(id: byNew, x: 0.90)],
            stored: [(id: byOld, x: 0.10), (id: stealBob, x: 0.50)],
            liveHash: [byNew: "5.5.4.6"],
            storedHash: [byOld: "5.5.4.6", stealBob: "1.1.1.1"],
            hashTableKeys: byKeys
        )
        ok(hashedRemint[byNew] == 0.81, "Remint ByHash Unique trotz 2 Holds")
        let tickFill = MatchMath.leftoverStoredHashMerge(
            last: [:],
            tick: [byOld: "5.5.4.6"]
        )
        let tickRemint = MatchMath.leftoverHoldRemint(
            hold: [byOld: 0.81],
            live: [(id: byNew, x: 0.90)],
            stored: [(id: byOld, x: 0.10)],
            liveHash: [byNew: "5.5.4.6"],
            storedHash: tickFill
        )
        ok(tickRemint[byNew] == 0.81, "Merge Tick → Hash-Rescue ohne Last")
        let destOld = UUID(), destNew = UUID()
        let destClash = MatchMath.leftoverHoldMove(hold: [destOld: 0.81, destNew: 0.10], from: destOld, to: destNew)
        ok(destClash[destNew] == 0.81 && destClash[destOld] == nil, "HoldMove überschreibt Dest")
        ok(MatchMath.leftoverHashTwinLeft(x: 0.50, others: [0.50], yawAbs: 0.05, otherYaws: [0.40]), "Center-Stage kleiner Yaw Exact")
        ok(!MatchMath.leftoverHashTwinLeft(x: 0.50, others: [0.50], yawAbs: 0.40, otherYaws: [0.05]), "Center-Stage großer Yaw Occupied")
        ok(MatchMath.leftoverHashTwinRank(x: 0.50, others: [0.50], yawAbs: 0.40, otherYaws: [0.05]) == 1, "Yaw-Tie Rank 1")
        ok(MatchMath.leftoverHashTwinRank(x: 0.50, others: [0.50], yawAbs: 0.05, otherYaws: [0.40]) == 0, "Yaw-Tie Rank 0")
        let yawTwinL = MatchMath.leftoverHashTwinOccupied(
            occupied: ["5.5.4.6"],
            hash: "5.5.4.6",
            x: 0.50,
            others: [(hash: "5.5.4.6", x: 0.50)],
            yawAbs: 0.05,
            otherYaws: [0.40]
        )
        ok(yawTwinL.isEmpty, "Center-Stage kleiner Yaw Exact frei")
        let yawRankedR = MatchMath.leftoverHashTwinRanked(
            hash: "5.5.4.6",
            x: 0.50,
            others: [(hash: "5.5.4.6", x: 0.50)],
            yawAbs: 0.40,
            otherYaws: [0.05]
        )
        ok(yawRankedR == "5.5.4.6#101", "Center-Stage Twin R persist 101")
        let persistId = UUID()
        let encodedHash = MatchMath.leftoverUUIDStringMapEncode([persistId: "5.5.4.6"])
        let decodedHash = MatchMath.leftoverUUIDStringMapDecode(encodedHash)
        ok(decodedHash[persistId] == "5.5.4.6", "LastHash persist UUID")
        let until = MatchMath.leftoverNameLockUntilRestore(held: [persistId: "Anna"], now: 10, arm: 1.2)
        ok(abs((until[persistId] ?? 0) - 11.2) < 0.001, "NameLock Until Restore Arm")
        let encodedHold = MatchMath.leftoverStreakSinceEncode([persistId: 0.81])
        ok(abs((MatchMath.leftoverStreakSinceDecode(encodedHold)[persistId] ?? 0) - 0.81) < 0.001, "Hold cosine persist")
        let pairA = UUID(), pairB = UUID()
        let pairEnc = MatchMath.leftoverUUIDUUIDMapEncode([pairA: pairB])
        ok(MatchMath.leftoverUUIDUUIDMapDecode(pairEnc)[pairA] == pairB, "PairLast persist UUID")
        let leftEnc = MatchMath.leftoverNameLockUntilEncode(until: [persistId: 12], now: 10)
        ok(abs((leftEnc[persistId.uuidString] ?? 0) - 2) < 0.001, "NameLock remaining Encode")
        let leftDec = MatchMath.leftoverNameLockUntilDecode(leftEnc, now: 0)
        ok(abs((leftDec[persistId] ?? 0) - 2) < 0.001, "NameLock remaining Decode now 0")
        let leftRest = MatchMath.leftoverNameLockUntilRestore(
            held: [persistId: "Anna"],
            remaining: leftDec,
            now: 100,
            arm: 1.2
        )
        ok(abs((leftRest[persistId] ?? 0) - 102) < 0.001, "NameLock remaining-first")
        let armOnly = MatchMath.leftoverNameLockUntilRestore(
            held: [persistId: "Anna"],
            remaining: [:],
            now: 100,
            arm: 1.2
        )
        ok(abs((armOnly[persistId] ?? 0) - 101.2) < 0.001, "NameLock Arm ohne remaining")
        let trailEnc = MatchMath.leftoverUUIDTrailEncode([persistId: [0.20, 0.22]])
        let trailDec = MatchMath.leftoverUUIDTrailDecode(trailEnc)
        ok(trailDec[persistId] == [0.20, 0.22], "HoldTrail UUID persist")
        let atomicOld = UUID(), atomicNew = UUID()
        let atomic = MatchMath.leftoverAssignAtomic(
            hold: [atomicOld: 0.81, atomicNew: 0.10],
            from: atomicOld,
            to: atomicNew
        )
        ok(atomic[atomicNew] == 0.81 && atomic[atomicOld] == nil, "AssignAtomic überschreibt Dest")
        let binOld = MatchMath.leftoverHoldKey(id: atomicOld, bin: 0)
        let binMoved = MatchMath.leftoverHoldMoveBins(
            hold: [binOld: 0.66, MatchMath.leftoverHoldKey(id: atomicNew, bin: 0): 0.10],
            from: atomicOld,
            to: atomicNew
        )
        ok(binMoved[MatchMath.leftoverHoldKey(id: atomicNew, bin: 0)] == 0.66, "HoldMoveBins überschreibt Dest")
        ok(binMoved[binOld] == nil, "HoldMoveBins from tot")
        near(MatchMath.leftoverFillXRescuePref(0.10), 0.16, 0.001, "FillX Floor 0,16")
        near(MatchMath.leftoverFillXRescuePref(0.50), 0.36, 0.001, "FillX Cap 0,36")
        near(MatchMath.leftoverFillXRescuePref(0.28), 0.28, 0.001, "FillX Default 0,28")
        near(MatchMath.leftoverFillXPadPref(0.02), 0.06, 0.001, "FillX Pad Floor")
        near(MatchMath.leftoverFillXPadPref(0.40), 0.20, 0.001, "FillX Pad Cap")
        ok(
            MatchMath.leftoverAssignLive(scores: [[nil]], liveX: [0.40], holdX: [0.22], pad: 0.16)[0] == nil,
            "AssignLive pad 0,16 Far tot"
        )
        ok(
            MatchMath.leftoverAssignLive(scores: [[nil]], liveX: [0.40], holdX: [0.22], pad: 0.36)[0] == 0,
            "AssignLive pad 0,36 Rescue"
        )
        let padTight = MatchMath.leftoverHoldRemint(
            hold: [atomicOld: 0.81],
            live: [(id: atomicNew, x: 0.40)],
            stored: [(id: atomicOld, x: 0.22)],
            padRescue: 0.16
        )
        ok(padTight[atomicNew] == nil, "Remint padRescue 0,16 tot")
        let padWide = MatchMath.leftoverHoldRemint(
            hold: [atomicOld: 0.81],
            live: [(id: atomicNew, x: 0.40)],
            stored: [(id: atomicOld, x: 0.22)],
            padRescue: 0.28
        )
        ok(padWide[atomicNew] == 0.81, "Remint padRescue 0,28")
        ok(
            MatchMath.leftoverHoldHashRescue(
                liveHash: "5.5.4.6#101",
                stored: [(id: hashOld, hash: "5.5.4.6")],
                facesInFrame: 2
            ) == nil,
            "Twin Hash Spatial tot"
        )
        ok(
            MatchMath.leftoverHoldHashRescue(
                liveHash: "5.5.4.6#101",
                stored: [(id: hashOld, hash: "5.5.4.6#101")],
                facesInFrame: 2
            ) == hashOld,
            "Twin Hash Exact"
        )
        ok(
            MatchMath.leftoverHoldHashRescue(
                liveHash: "5.5.4.6#101",
                stored: [(id: hashOld, hash: "5.5.4.6")],
                facesInFrame: 1
            ) == hashOld,
            "Solo Hash Spatial"
        )
        let hun2 = MatchMath.leftoverAssignHungarian(scores: [
            [0.40, 0.90],
            [0.85, 0.30]
        ])
        ok(hun2[0] == 1 && hun2[1] == 0, "Hungarian 2×2 = leftoverAssign")
        let hun3 = MatchMath.leftoverAssignHungarian(scores: [
            [0.10, 0.90, 0.10],
            [0.10, 0.10, 0.90],
            [0.90, 0.10, 0.10]
        ])
        ok(hun3[0] == 1 && hun3[1] == 2 && hun3[2] == 0, "Hungarian 3-Zyklus")
        ok(Set(hun3.compactMap { $0 }).count == 3, "Hungarian keine Doppel-Spalte")
        ok(MatchMath.leftoverHoldTrailCap([1, 2, 3, 4, 5]) == [2.0, 3.0, 4.0, 5.0], "Trail Cap 4")
        ok(MatchMath.leftoverHoldTrailCap([1, 2]) == [1.0, 2.0], "Trail Cap unter 4")
        let trailLong = MatchMath.leftoverUUIDTrailEncode([persistId: [0.1, 0.2, 0.3, 0.4, 0.5]])
        ok(MatchMath.leftoverUUIDTrailDecode(trailLong)[persistId] == [0.2, 0.3, 0.4, 0.5], "Trail Encode Cap")
        let dangA = UUID(), dangB = UUID(), dangC = UUID()
        let dang = MatchMath.leftoverUUIDUUIDMapDropDangling([dangA: dangB, dangC: dangA], keep: [dangB])
        ok(dang[dangA] == dangB && dang[dangC] == nil, "Pair dest tot nach Restart")
        ok(MatchMath.leftoverUUIDUUIDMapDecode([dangA.uuidString: dangA.uuidString])[dangA] == dangA, "Pair dest==key persist")
        let streakEnc = MatchMath.leftoverUUIDIntMapEncode([persistId: 3])
        ok(MatchMath.leftoverUUIDIntMapDecode(streakEnc)[persistId] == 3, "Streak persist")
        let seenNow: TimeInterval = 1000
        let seenRem = MatchMath.leftoverSeenRemainingEncode(
            since: [persistId: seenNow - 0.4],
            now: seenNow,
            ttl: 1.2
        )
        ok(abs((seenRem[persistId.uuidString] ?? 0) - 0.8) < 0.02, "Seen remaining Encode")
        let seenRest = MatchMath.leftoverSeenRestore(seenRem, now: 2000, ttl: 1.2)
        ok(abs((seenRest[persistId] ?? 0) - 1999.6) < 0.02, "Seen remaining Restore")
        let seenEpoch = MatchMath.leftoverSeenRestore(
            [persistId.uuidString: 1_700_000_000],
            now: 1000,
            ttl: 1.2
        )
        ok(abs((seenEpoch[persistId] ?? 0) - 1000) < 0.01, "Schema 8 Epoch rebase now")
        ok(MatchMath.leftoverBoxHashDistance("6.6.4.6#101", "6.6.4.6") == 0, "Rank-Key Dist 0")
        ok(MatchMath.leftoverBoxHashDistance("6.6.4.6#101", "6.6.4.7") == 1, "Rank-Key Hamming 1")
        ok(MatchMath.leftoverBoxHashDistance("6#101", "6.6.4.6") == 99, "Rank-Key ohne Spatial Dist 99")
        let rankOnly = MatchMath.leftoverHashRankRebase(["6.6.4.6#101": 0.81])
        ok(rankOnly["6.6.4.6"] == 0.81 && rankOnly["6.6.4.6#101"] == nil, "Rebase Rank → Spatial")
        let rankClash = MatchMath.leftoverHashRankRebase(["6.6.4.6": 0.70, "6.6.4.6#101": 0.81])
        ok(rankClash["6.6.4.6"] == 0.70, "Rebase Spatial-first")
        let rebasedHold: [String: (cosine: Double, at: TimeInterval)] = MatchMath.leftoverHashRankRebase([
            "6.6.4.6#101": (cosine: 0.81, at: 1.0)
        ])
        ok(
            abs((MatchMath.leftoverHoldLookup(hash: "6.6.4.6", table: rebasedHold, now: 1.0) ?? 0) - 0.81) < 0.001,
            "Lookup nach Rebase Spatial"
        )
        ok(
            MatchMath.leftoverHoldSpatialOccupied(live: ["6.6.4.6", "6.6.4.6#101"], hash: "6.6.4.6#101"),
            "Twin Spatial occupied"
        )
        ok(
            !MatchMath.leftoverHoldHashLookupKeys(
                hash: "6.6.4.6#101",
                occupied: ["6.6.4.6", "6.6.4.6#101"]
            ).contains("6.6.4.6"),
            "Twin Lookup kein Spatial-Steal"
        )
        ok(
            MatchMath.leftoverHoldHashHammingRescue(
                liveHash: "6.6.4.7",
                stored: [(id: persistId, hash: "6.6.4.6")],
                facesInFrame: 1
            ) == persistId,
            "Hamming-1 Solo"
        )
        ok(
            MatchMath.leftoverHoldHashHammingRescue(
                liveHash: "6.6.4.7",
                stored: [(id: persistId, hash: "6.6.4.6")],
                facesInFrame: 2
            ) == nil,
            "Hamming Twin tot"
        )
        let hamOld = UUID(), hamNew = UUID()
        let hamFar = MatchMath.leftoverHoldRemint(
            hold: [hamOld: 0.81],
            live: [(id: hamNew, x: 0.90)],
            stored: [(id: hamOld, x: 0.10)],
            liveHash: [hamNew: "6.6.4.7"],
            storedHash: [hamOld: "6.6.4.6"],
            padRescue: 0.16
        )
        ok(hamFar[hamNew] == 0.81, "Remint Hamming Far Solo")
        let hamTwin = MatchMath.leftoverHoldRemint(
            hold: [hamOld: 0.81],
            live: [(id: hamNew, x: 0.90), (id: persistId, x: 0.40)],
            stored: [(id: hamOld, x: 0.10)],
            liveHash: [hamNew: "6.6.4.7", persistId: "5.5.4.6"],
            storedHash: [hamOld: "6.6.4.6"],
            padRescue: 0.16
        )
        ok(hamTwin[hamNew] == nil, "Remint Hamming Far Twin tot")
        let ema = MatchMath.leftoverHoldTrailEMA([0.80], sample: 1.0, cap: 4, alpha: 0.4)
        ok(ema.count == 2, "Trail EMA wächst")
        near(ema.last ?? 0, 0.88, 0.001, "Trail EMA 0,4")
        let emaCap = MatchMath.leftoverHoldTrailEMA([0.1, 0.2, 0.3, 0.4], sample: 0.5, cap: 4)
        ok(emaCap.count == 4, "Trail EMA Cap 4")
        near(MatchMath.leftoverJpegProbeTTLPref(0.10), 0.25, 0.001, "JPEG TTL Floor")
        near(MatchMath.leftoverJpegProbeTTLPref(2.0), 1.2, 0.001, "JPEG TTL Cap")
        near(MatchMath.leftoverJpegProbeTTLPref(0.80), 0.80, 0.001, "JPEG TTL Default")
        ok(!MatchMath.leftoverJpegProbeReuse(now: 1.2, last: 0.50, ttl: 0.25), "JPEG TTL 0,25 tot")
        ok(MatchMath.leftoverJpegProbeReuse(now: 1.2, last: 0.50, ttl: 1.2), "JPEG TTL 1,2 hält")
        near(MatchMath.leftoverHoldRemintPad(faces: 1), 0.28, 0.001, "RemintPad Solo Rescue")
        near(MatchMath.leftoverHoldRemintPad(faces: 2), 0.12, 0.001, "RemintPad Twin Pad")
        let greedyX = MatchMath.leftoverAssignFillX(
            assigned: [nil, nil],
            liveX: [0.09, 0.20],
            holdX: [0.00, 0.10],
            pad: 0.12
        )
        ok(greedyX[0] == nil && greedyX[1] == 0, "FillX greedy Hold 0 tot")
        let hunX = MatchMath.leftoverAssignHungarianX(
            assigned: [nil, nil],
            liveX: [0.09, 0.20],
            holdX: [0.00, 0.10],
            pad: 0.12
        )
        ok(hunX[0] == 0 && hunX[1] == 1, "HungarianX n=2 beide")
        let remX = MatchMath.leftoverAssignRemint(liveX: [0.09, 0.20], holdX: [0.00, 0.10])
        ok(remX[0] == 0 && remX[1] == 1, "AssignRemint HungarianX")
        let movedRank = MatchMath.leftoverHoldMoveRankKey(
            hold: ["6.6.4.6": 0.70],
            hash: "6.6.4.6",
            fromRank: 0,
            toRank: 1
        )
        ok(movedRank["6.6.4.6#101"] == 0.70 && movedRank["6.6.4.6"] == nil, "Rank-Key Move")
        let boxId = UUID()
        let boxEnc = MatchMath.leftoverStreakBoxEncode([
            boxId: FaceBox(x: 0.20, y: 0.30, width: 0.10, height: 0.15)
        ])
        let boxDec = MatchMath.leftoverStreakBoxDecode(boxEnc)
        near(boxDec[boxId]?.x ?? 0, 0.20, 0.001, "StreakBox persist x")
        near(boxDec[boxId]?.height ?? 0, 0.15, 0.001, "StreakBox persist h")
        ok(MatchMath.leftoverStreakBoxDecode(nil).isEmpty, "StreakBox nil")
        ok(MatchMath.leftoverHoldKalmanResets(iou: 0.20), "Kalman Reset JUMP")
        ok(!MatchMath.leftoverHoldKalmanResets(iou: 0.80), "Kalman Reset hält")
        ok(!MatchMath.leftoverHoldKalmanResets(iou: nil), "Kalman Reset nil tot")
        let kOld = UUID(), kNew = UUID()
        let kRem = MatchMath.leftoverHoldRemint(
            hold: [kOld: 1.0],
            live: [(id: kNew, x: 0.11)],
            stored: [(id: kOld, x: 0.10)]
        )
        ok(kRem[kNew] == 1.0, "Kalman Remint Value")
        let kKeep = MatchMath.leftoverHoldKalmanKeep(kalman: [kOld: 1, kNew: 2], live: [kNew])
        ok(kKeep[kNew] == 2 && kKeep[kOld] == nil, "Kalman Keep live")
        var jpegTab: [String: (delta: Double, at: TimeInterval, cosine: Double)] = [:]
        jpegTab = MatchMath.leftoverJpegProbeStore(
            table: jpegTab, hash: "6.6.4.6#101", delta: 0.02, at: 1.0, cosine: 0.90
        )
        let jpegHit = MatchMath.leftoverJpegProbeLookup(table: jpegTab, hash: "6.6.4.6")
        near(jpegHit?.delta ?? 1, 0.02, 0.001, "JPEG per Hash Spatial")
        ok(MatchMath.leftoverJpegProbeLookup(table: jpegTab, hash: "5.5.4.6") == nil, "JPEG Twin teilt nicht")
        ok(MatchMath.leftoverJpegProbeKey("6.6.4.6#101") == "6.6.4.6", "JPEG Key strip Rank")
        let hun4 = MatchMath.leftoverAssignHungarianX(
            assigned: [nil, nil, nil, nil],
            liveX: [0.05, 0.25, 0.45, 0.65],
            holdX: [0.00, 0.20, 0.40, 0.60],
            pad: 0.12
        )
        ok(hun4[0] == 0 && hun4[1] == 1 && hun4[2] == 2 && hun4[3] == 3, "HungarianX n=4")
        ok(MatchMath.leftoverOccupiedMerge(stored: ["5.5.4.6#101"], live: ["5.5.4.6"]) == ["5.5.4.6"], "Occupied Rank+Spatial unique")
        ok(MatchMath.leftoverOccupiedMerge(stored: ["5.5.4.6"], live: ["5.5.4.6#101"]) == ["5.5.4.6"], "Occupied live Rank Spatial")
        ok(MatchMath.leftoverHashOwnOccupied(live: ["5.5.4.6#101"], hash: "5.5.4.6#101"), "Own Occupied Ranked Exact")
        ok(!MatchMath.leftoverOccupiedRankBlocks(live: ["5.5.4.6#101"], hash: "5.5.4.6"), "Ranked nicht Exact")
        ok(MatchMath.leftoverOccupiedRankBlocks(live: ["5.5.4.6"], hash: "5.5.4.6"), "Exact Occupied Exact")
        let hunMid = MatchMath.leftoverAssignHungarianX(
            assigned: [nil, nil],
            liveX: [0.50],
            holdX: [0.45, 0.55],
            pad: 0.12
        )
        ok(hunMid[0] == nil && hunMid[1] == nil, "HungarianX Twin-Mitte tot")
        let spreadKeep = MatchMath.leftoverAssignSpreadVeto(
            assigned: [0, 1],
            liveX: [0.09, 0.20],
            holdX: [0.00, 0.10],
            pad: 0.12
        )
        ok(spreadKeep[0] == 0 && spreadKeep[1] == 1, "SpreadVeto n=2 Unique hält")
        ok(MatchMath.leftoverHoldRemintBeforeSurvive(), "Remint vor Survive")
        near(MatchMath.leftoverHoldRemintXUnknown(), -1, 0.001, "Remint x unbekannt")
        let persistOld = UUID(), persistLive = UUID()
        let persistHold = [persistOld: 0.80]
        let tooLate = MatchMath.leftoverHoldSurvive(hold: persistHold, ghosts: [], live: [persistLive])
        let remintLate = MatchMath.leftoverHoldRemint(
            hold: tooLate,
            live: [(id: persistLive, x: 0.20)],
            stored: [(id: persistOld, x: 0.21)]
        )
        ok(remintLate[persistLive] == nil, "Survive vor Remint tot")
        let remintFirst = MatchMath.leftoverHoldRemint(
            hold: persistHold,
            live: [(id: persistLive, x: 0.20)],
            stored: MatchMath.leftoverHoldRemintRows(
                streak: [(id: persistOld, x: 0.21)],
                holdIds: [persistOld]
            )
        )
        let afterRemint = MatchMath.leftoverHoldSurvive(hold: remintFirst, ghosts: [], live: [persistLive])
        ok(afterRemint[persistLive] == 0.80, "Remint vor Survive hält")
        let rowsHold = MatchMath.leftoverHoldRemintRows(
            streak: [],
            holdIds: [persistOld],
            ghosts: []
        )
        ok(rowsHold.contains(where: { $0.id == persistOld && $0.x == MatchMath.leftoverHoldRemintXUnknown() }), "RemintRows Hold ohne Box")
        let hashRank = MatchMath.leftoverLastHashRankRebase([persistOld: "6.6.4.6#101"])
        ok(hashRank[persistOld] == "6.6.4.6", "LastHash Rank strip")
        var jpegEncTab: [String: (delta: Double, at: TimeInterval, cosine: Double)] = [:]
        jpegEncTab = MatchMath.leftoverJpegProbeStore(
            table: jpegEncTab, hash: "6.6.4.6#101", delta: 0.03, at: 1.0, cosine: 0.88
        )
        let jpegEnc = MatchMath.leftoverJpegByHashEncode(jpegEncTab)
        let jpegDec = MatchMath.leftoverJpegByHashDecode(jpegEnc, now: 9.0)
        near(jpegDec["6.6.4.6"]?.delta ?? 1, 0.03, 0.001, "JPEG persist Spatial")
        near(jpegDec["6.6.4.6"]?.at ?? 0, 9.0, 0.001, "JPEG persist at=now")
        ok(MatchMath.leftoverJpegByHashDecode(nil, now: 1).isEmpty, "JPEG persist nil")
        ok(MatchMath.gallerySchema == 15, "Schema 15")
        ok(MatchMath.leftoverHoldMissAdvance(prev: 0, hit: true) == 0, "Miss Hit reset")
        ok(MatchMath.leftoverHoldMissAdvance(prev: 0, hit: false) == 1, "Miss +1")
        ok(MatchMath.leftoverHoldMissCoast(miss: 1), "Miss Coast Tick 1")
        ok(!MatchMath.leftoverHoldMissCoast(miss: 0), "Miss Hit tot")
        ok(MatchMath.leftoverHoldMissCoast(miss: 2), "Miss Coast Tick 2 Default")
        ok(!MatchMath.leftoverHoldMissCoast(miss: 3), "Miss Tick 3 tot")
        ok(MatchMath.leftoverHoldMissNeedPref(0) == 1, "Miss Need Floor 1")
        ok(MatchMath.leftoverHoldMissNeedPref(9) == 3, "Miss Need Cap 3")
        ok(MatchMath.leftoverHoldMissNeedAuto(dt: 0.25, pref: 2) == 3, "Miss Need Auto 4 fps")
        ok(MatchMath.leftoverHoldMissNeedAuto(dt: 0.12, pref: 2) == 2, "Miss Need Auto 8 fps Pref")
        let missKeep = MatchMath.leftoverHoldSurvive(hold: persistHold, ghosts: [], live: [], missCoast: true)
        ok(missKeep[persistOld] == 0.80, "Miss-Coast 1 Frame hält")
        let missWipe = MatchMath.leftoverHoldSurvive(hold: persistHold, ghosts: [], live: [], missCoast: false)
        ok(missWipe.isEmpty, "Miss ohne Coast tot")
        ok(MatchMath.leftoverPredictOnMissCoast(true), "Predict Miss-Coast")
        ok(!MatchMath.leftoverLastHashWipes(empty: true, missCoast: true), "LastHash Miss hält")
        ok(MatchMath.leftoverLastHashWipes(empty: true, missCoast: false), "LastHash leer wischt")
        ok(!MatchMath.leftoverLiveHashTickWipes(empty: true, missCoast: true), "Tick Miss hält")
        ok(MatchMath.leftoverLiveHashTickWipes(empty: true), "Tick leer wischt")
        let hun5 = MatchMath.leftoverAssignHungarianX(
            assigned: [nil, nil, nil, nil, nil],
            liveX: [0.05, 0.25, 0.45, 0.65, 0.85],
            holdX: [0.00, 0.20, 0.40, 0.60, 0.80],
            pad: 0.12
        )
        ok(hun5[0] == 0 && hun5[1] == 1 && hun5[2] == 2 && hun5[3] == 3 && hun5[4] == 4, "HungarianX n=5")
        var jpegCapTab: [String: (delta: Double, at: TimeInterval, cosine: Double)] = [:]
        for i in 0..<70 {
            jpegCapTab["6.6.4.\(i)"] = (delta: 0.01, at: Double(i), cosine: 0.80)
        }
        ok(MatchMath.leftoverJpegByHashCapped(jpegCapTab).count == MatchMath.leftoverHashHoldCapN, "JPEG Cap 64")
        let jpegCapEnc = MatchMath.leftoverJpegByHashEncode(jpegCapTab)
        ok(jpegCapEnc.count == MatchMath.leftoverHashHoldCapN, "JPEG persist Cap 64")
        let kEncId = persistOld
        let kEnc = MatchMath.leftoverHoldKalmanEncode(
            [kEncId: (x: 0.20, y: 0.30, w: 0.10, h: 0.12, px: 0.04, py: 0.04, pw: 0.04, ph: 0.04)],
            vel: [kEncId: (vx: 0.08, vy: -0.02)]
        )
        let kDec = MatchMath.leftoverHoldKalmanDecode(kEnc)
        near(kDec.kalman[kEncId]?.x ?? 0, 0.20, 0.001, "Kalman persist x")
        near(kDec.kalman[kEncId]?.h ?? 0, 0.12, 0.001, "Kalman persist h")
        near(kDec.vel[kEncId]?.vx ?? 0, 0.08, 0.001, "Kalman persist vx")
        ok(MatchMath.leftoverHoldKalmanDecode(nil).kalman.isEmpty, "Kalman persist nil")
        ok(!MatchMath.leftoverHoldMissHit(live: 0, adopted: 0), "Miss Hit tot")
        ok(MatchMath.leftoverHoldMissHit(live: 1, adopted: 0), "Miss Hit live")
        ok(MatchMath.leftoverHoldMissHit(live: 0, adopted: 1), "Miss Hit adopted")
        ok(MatchMath.leftoverHoldKalmanKeep(kalman: [kEncId: 1], live: [], missCoast: true)[kEncId] == 1, "Kalman Miss hält")
        ok(MatchMath.leftoverHoldKalmanKeep(kalman: [kEncId: 1], live: []).isEmpty, "Kalman leer wischt")
        ok(!MatchMath.leftoverEmptyWipesMaps(emptyLatch: false, missCoast: true), "Maps Miss hält")
        ok(MatchMath.leftoverEmptyWipesMaps(emptyLatch: false, missCoast: false), "Maps leer wischt")
        ok(!MatchMath.leftoverEmptyWipesMaps(emptyLatch: true, missCoast: false), "Maps Latch hält")
        ok(!MatchMath.leftoverEmptyWipesOverlay(emptyChip: false, missCoast: true), "Overlay Miss hält")
        ok(MatchMath.leftoverEmptyWipesOverlay(emptyChip: false, missCoast: false), "Overlay leer wischt")
        ok(!MatchMath.leftoverEmptyWipesOverlay(emptyChip: true, missCoast: false), "Overlay Chip hält")
        near(MatchMath.leftoverJpegRemaining(at: 1.0, now: 1.5, ttl: 0.80), 0.30, 0.001, "JPEG remaining 0,30")
        near(MatchMath.leftoverJpegAtFromRemaining(remaining: 0.30, now: 9.0, ttl: 0.80), 8.50, 0.001, "JPEG remaining at")
        let jpegRemTab: [String: (delta: Double, at: TimeInterval, cosine: Double)] = [
            "6.6.4.6": (delta: 0.03, at: 1.0, cosine: 0.88)
        ]
        let jpegRemEnc = MatchMath.leftoverJpegByHashEncode(jpegRemTab, now: 1.5, ttl: 0.80)
        near(jpegRemEnc["6.6.4.6"]?[2] ?? -1, 0.30, 0.001, "JPEG persist remaining")
        let jpegRemDec = MatchMath.leftoverJpegByHashDecode(jpegRemEnc, now: 9.0, ttl: 0.80)
        near(jpegRemDec["6.6.4.6"]?.at ?? 0, 8.50, 0.001, "JPEG remaining restore")
        let jpegStale = MatchMath.leftoverJpegByHashDecode(["6.6.4.6": [0.03, 0.88]], now: 9.0, ttl: 0.80)
        near(jpegStale["6.6.4.6"]?.at ?? 0, 8.20, 0.001, "JPEG Schema 11 stale")
        ok(MatchMath.leftoverHoldKalmanSkipReset(ago: 0), "Kalman Restore Skip Tick 0")
        ok(MatchMath.leftoverHoldKalmanSkipReset(ago: 1), "Kalman Restore Skip Tick 1")
        ok(!MatchMath.leftoverHoldKalmanSkipReset(ago: 2), "Kalman Restore Tick 2 Reset")
        ok(MatchMath.leftoverHoldKalmanRestoredAdvance(prev: 0, restored: true) == 0, "Kalman Restore ago 0")
        ok(MatchMath.leftoverHoldKalmanRestoredAdvance(prev: 0, restored: false) == 1, "Kalman Restore +1")
        let vel1 = MatchMath.leftoverHoldKalmanVelDecay(vx: 0.10, vy: 0, miss: 1)
        near(vel1.vx, 0.10, 0.001, "Kalman Vel Miss 1 voll")
        let vel2 = MatchMath.leftoverHoldKalmanVelDecay(vx: 0.10, vy: 0, miss: 2)
        near(vel2.vx, 0.082, 0.001, "Kalman Vel Decay 0,82")
        let yawMerge = MatchMath.leftoverOccupiedMergeYaw(
            stored: [],
            live: [(hash: "5.5.4.6", yawAbs: 0.30), (hash: "5.5.4.6", yawAbs: 0.10)]
        )
        ok(yawMerge.contains("5.5.4.6") && yawMerge.contains("5.5.4.6#101"), "Occupied Yaw Exact+#101")
        let hun6 = MatchMath.leftoverAssignHungarianX(
            assigned: [nil, nil, nil, nil, nil, nil],
            liveX: [0.05, 0.20, 0.35, 0.50, 0.65, 0.80],
            holdX: [0.00, 0.18, 0.33, 0.48, 0.63, 0.78],
            pad: 0.12
        )
        ok(hun6[0] == 0 && hun6[5] == 5, "HungarianX n=6")
        let hun8 = MatchMath.leftoverAssignHungarianX(
            assigned: [nil, nil, nil, nil, nil, nil, nil, nil],
            liveX: [0.05, 0.18, 0.31, 0.44, 0.57, 0.70, 0.83, 0.96],
            holdX: [0.00, 0.16, 0.29, 0.42, 0.55, 0.68, 0.81, 0.94],
            pad: 0.12
        )
        ok(hun8[0] == 0 && hun8[7] == 7, "HungarianX n=8")
        ok(MatchMath.leftoverAssignHungarianN == 8, "HungarianN 8")
        let kid = persistOld
        let keepMiss = MatchMath.leftoverKeepBoxes(
            used: [], dropped: [], ghosts: [], hold: [], missCoast: true, kalman: [kid]
        )
        ok(keepMiss.contains(kid), "KeepBoxes Miss Kalman")
        let keepWipe = MatchMath.leftoverKeepBoxes(
            used: [], dropped: [], ghosts: [], hold: [], missCoast: false, kalman: [kid]
        )
        ok(!keepWipe.contains(kid), "KeepBoxes ohne Miss tot")
        let storedRank = MatchMath.leftoverOccupiedMergeYaw(
            stored: ["5.5.4.6#101"],
            live: [(hash: "5.5.4.6", yawAbs: 0.10)]
        )
        ok(storedRank.contains("5.5.4.6") && !storedRank.contains("5.5.4.6#101"), "Occupied Twin-weg Rank tot")
        let keepAt = MatchMath.leftoverHashHoldRebase(["ab#0": (cosine: 0.80, at: 12)], now: 50, keepAt: true)
        ok(keepAt["ab#0"]?.at == 12, "Hash Rebase keepAt")
        let hashRem = MatchMath.leftoverHashHoldRemainingEncode(
            ["ab#0": (cosine: 0.80, at: 1.0)], now: 1.5, ttl: 1.2
        )
        near(hashRem["ab#0"] ?? -1, 0.70, 0.001, "Hash remaining 0,70")
        let hashRemDec = MatchMath.leftoverHashHoldDecode(
            ["ab#0": 0.80], now: 9.0, remaining: hashRem, ttl: 1.2
        )
        near(hashRemDec["ab#0"]?.at ?? 0, 8.50, 0.001, "Hash remaining restore")
        let hashStale = MatchMath.leftoverHashHoldDecode(["ab#0": 0.80], now: 9.0)
        near(hashStale["ab#0"]?.at ?? 0, 9.0, 0.001, "Hash Schema 13 at=now")
        ok(MatchMath.leftoverAssignHungarianWide(0.40), "Hungarian wide 0,40")
        ok(!MatchMath.leftoverAssignHungarianWide(0.12), "Hungarian pad 0,12")
        let hunWide = MatchMath.leftoverAssignHungarianX(
            assigned: [nil, nil, nil, nil, nil, nil, nil, nil],
            liveX: [0.05, 0.18, 0.31, 0.44, 0.57, 0.70, 0.83, 0.96],
            holdX: [0.00, 0.16, 0.29, 0.42, 0.55, 0.68, 0.81, 0.94],
            pad: 0.40
        )
        ok(hunWide[0] == 0 && hunWide[7] == 7, "HungarianX wide FillX n=8")
        let keepAfter = MatchMath.leftoverKeepHoldIds(hold: [kid], bins: [])
        ok(keepAfter.contains(kid), "KeepHold after Survive")
        let trailRem = MatchMath.leftoverHashTrailRemainingEncode(
            ["ab#0": (samples: [0.80], at: 1.0)], now: 1.5, ttl: 1.2
        )
        near(trailRem["ab#0"] ?? -1, 0.70, 0.001, "Trail remaining 0,70")
        let trailRemDec = MatchMath.leftoverHashTrailDecode(
            ["ab#0": [0.80]], now: 9.0, remaining: trailRem, ttl: 1.2
        )
        near(trailRemDec["ab#0"]?.at ?? 0, 8.50, 0.001, "Trail remaining restore")
        let trailStale = MatchMath.leftoverHashTrailDecode(["ab#0": [0.80]], now: 9.0)
        near(trailStale["ab#0"]?.at ?? 0, 9.0, 0.001, "Trail Schema 14 at=now")
        let majKeep = UUID()
        ok(MatchMath.leftoverPairCommitKeeps(committed: majKeep, proposed: majKeep), "PairCommit Keeps")
        ok(!MatchMath.leftoverPairCommitKeeps(committed: majKeep, proposed: UUID()), "PairCommit Remint tot")
        ok(!MatchMath.leftoverPairCommitKeeps(committed: nil, proposed: majKeep), "PairCommit nil tot")
        let keepSame = MatchMath.leftoverAssignMajority(committed: majKeep, proposed: majKeep, lastProposed: nil, streak: 2)
        ok(keepSame.commit == majKeep && !keepSame.ready, "PairCommit Majority hält")
        ok(MatchMath.leftoverHoldKalmanPredictOnly(ago: 0, liveEmpty: true), "PredictOnly Restore")
        ok(MatchMath.leftoverHoldKalmanPredictOnly(ago: 9, liveEmpty: true, ghostHeld: true), "PredictOnly Ghost")
        ok(MatchMath.leftoverHoldKalmanPredictOnly(ago: 9, liveEmpty: true, missCoast: true), "PredictOnly Miss")
        ok(!MatchMath.leftoverHoldKalmanPredictOnly(ago: 9, liveEmpty: true), "PredictOnly Empty tot")
        ok(!MatchMath.leftoverHoldKalmanPredictOnly(ago: 9, liveEmpty: false, ghostHeld: true), "PredictOnly Live tot")
        near(MatchMath.leftoverHoldKalmanJumpPref(0.22), 0.30, 0.001, "Kalman Jump Floor")
        near(MatchMath.leftoverHoldKalmanJumpPref(0.66), 0.50, 0.001, "Kalman Jump Cap")
        near(MatchMath.leftoverHoldKalmanJumpPref(0.40), 0.40, 0.001, "Kalman Jump 0,40")
        ok(MatchMath.leftoverHoldKalmanResets(iou: 0.20, jump: 0.22), "Kalman Reset Floor 0,30")
        ok(!MatchMath.leftoverHoldKalmanResets(iou: 0.45), "Kalman 0,45 kein Reset")
        let keepGhost = MatchMath.leftoverKeepBoxes(
            used: [], dropped: [], ghosts: [kid], hold: [], missCoast: false, kalman: [kid]
        )
        ok(keepGhost.contains(kid), "KeepBoxes Ghost Kalman")
        let keepGhostMiss = MatchMath.leftoverKeepBoxes(
            used: [], dropped: [], ghosts: [], hold: [], missCoast: false, kalman: [kid]
        )
        ok(!keepGhostMiss.contains(kid), "KeepBoxes ohne Ghost tot")
        ok(MatchMath.leftoverOccupiedTwinGone(liveOfSpatial: 1, storedRanked: true), "Twin-weg Rank")
        ok(!MatchMath.leftoverOccupiedTwinGone(liveOfSpatial: 0, storedRanked: true), "Restore Rank hält")
        ok(!MatchMath.leftoverOccupiedTwinGone(liveOfSpatial: 2, storedRanked: true), "Twin live Rank tot")
        let keepHoldK = MatchMath.leftoverKeepBoxes(
            used: [], dropped: [], ghosts: [], hold: [kid], missCoast: false, kalman: [kid]
        )
        ok(keepHoldK.contains(kid), "KeepBoxes Hold Kalman")
        let keepPred = MatchMath.leftoverKeepBoxes(
            used: [], dropped: [], ghosts: [], hold: [], missCoast: false, kalman: [kid], predictOnly: true
        )
        ok(keepPred.contains(kid), "KeepBoxes PredictOnly Kalman")
        let emptyLiveOcc = MatchMath.leftoverOccupiedMergeYaw(
            stored: ["5.5.4.6#101"],
            live: []
        )
        ok(emptyLiveOcc.contains("5.5.4.6#101"), "Occupied stored Rank Restore")
        let pairId = UUID()
        ok(MatchMath.leftoverUUIDUUIDMapDecode(
            MatchMath.leftoverUUIDUUIDMapEncode([pairId: pairId])
        )[pairId] == pairId, "PairCommit dest==key roundtrip")
        ok(MatchMath.leftoverPairCommitHold(committed: majKeep, proposed: UUID(), miss: 0), "Hold miss 0")
        ok(MatchMath.leftoverPairCommitHold(committed: majKeep, proposed: UUID(), miss: 2), "Hold miss 2")
        ok(!MatchMath.leftoverPairCommitHold(committed: majKeep, proposed: UUID(), miss: 3), "Hold miss 3 tot")
        ok(!MatchMath.leftoverPairCommitHold(committed: majKeep, proposed: majKeep, miss: 0), "Keeps kein Hold")
        ok(MatchMath.leftoverPairCommitMissAdvance(prev: 0, keeps: false, hold: true) == 1, "Miss Advance")
        ok(MatchMath.leftoverPairCommitMissAdvance(prev: 0, keeps: true, hold: false) == 0, "Miss Keeps reset")
        ok(MatchMath.leftoverPairCommitMissAdvance(prev: 3, keeps: false, hold: false) == 4, "Miss Latch")
        let majHoldB = UUID()
        let holdMaj = MatchMath.leftoverAssignMajority(
            committed: majKeep, proposed: majHoldB, lastProposed: majHoldB, streak: 2, commitMiss: 1
        )
        ok(holdMaj.commit == majKeep && !holdMaj.ready, "Remint-Miss Majority hält")
        let afterHold = MatchMath.leftoverAssignMajority(
            committed: majKeep, proposed: majHoldB, lastProposed: majHoldB, streak: 2, commitMiss: 3
        )
        ok(afterHold.ready && afterHold.commit == majHoldB, "nach 3 Miss Majority")
        ok(MatchMath.leftoverPairCommitHoldLabel(miss: 1) == "HOLD 1/3", "HOLD-Label")
        ok(MatchMath.leftoverPairCommitHoldLabel(miss: 0) == nil, "HOLD 0 tot")
        ok(MatchMath.leftoverPairCommitHoldLabel(miss: 3) == nil, "HOLD ready tot")
        let binKey = MatchMath.leftoverHoldKey(id: kid, bin: 0)
        ok(MatchMath.leftoverHoldBinsDecode([binKey: 0.70])[binKey] == 0.70, "Bins UUID.bin hält")
        ok(MatchMath.leftoverHoldBinsDecode(["6.6.4.6#101": 0.81])["6.6.4.6"] == 0.81, "Bins Rank Rebase")
        ok(MatchMath.leftoverHoldBinsDecode(["6.6.4.6#101": 0.81])["6.6.4.6#101"] == nil, "Bins Rank tot")
        let trailBin = MatchMath.leftoverHoldTrailBinsDecode(["6.6.4.6#101": [0.80]])
        ok(trailBin["6.6.4.6"] == [0.80] && trailBin["6.6.4.6#101"] == nil, "TrailBins Rank Rebase")
        ok(MatchMath.leftoverHashIsTwinRank("6.6.4.6#101"), "Twin Rank #101")
        ok(!MatchMath.leftoverHashIsTwinRank("6.6.4.6#0"), "Yaw Bin #0 kein Twin")
        ok(!MatchMath.leftoverHashIsTwinRank("6.6.4.6"), "Spatial kein Twin")
        let yawKeep = MatchMath.leftoverHashRankRebase(["6.6.4.6#0": 0.70, "6.6.4.6#101": 0.81])
        ok(yawKeep["6.6.4.6#0"] == 0.70, "Rebase Yaw #0 hält")
        ok(yawKeep["6.6.4.6"] == 0.81 && yawKeep["6.6.4.6#101"] == nil, "Rebase Twin füllt Spatial")
        ok(MatchMath.leftoverHoldBinsDecode(["6.6.4.6#0": 0.66])["6.6.4.6#0"] == 0.66, "Bins Yaw #0 hält")
        let keyLive = UUID(), destGone = UUID()
        let holdPair = MatchMath.leftoverUUIDUUIDMapDropDangling([keyLive: destGone], keep: [keyLive])
        ok(holdPair[keyLive] == destGone, "DropDangling Key live Dest tot hält")
        let holdKey = UUID(), holdGone = UUID(), holdLive = UUID()
        let holdOnly = MatchMath.leftoverUUIDUUIDMapDropDangling(
            [holdKey: holdGone], keep: [holdLive], hold: [holdKey]
        )
        ok(holdOnly[holdKey] == holdGone, "DropDangling Hold-Key dest tot hält")
        let ghostTwin = UUID(), ghostKey = UUID(), liveOther = UUID()
        let ghostHold = MatchMath.leftoverUUIDUUIDMapDropHold(hold: [], ghosts: [ghostTwin])
        let ghostDrop = MatchMath.leftoverUUIDUUIDMapDropDangling(
            [ghostKey: ghostTwin], keep: [liveOther], hold: ghostHold
        )
        ok(ghostDrop[ghostKey] == ghostTwin, "DropDangling Ghost-Dest hält")
        let missHold = MatchMath.leftoverUUIDUUIDMapDropHold(
            hold: [holdKey], ghosts: [], missKeys: [ghostKey]
        )
        ok(missHold.contains(ghostKey) && missHold.contains(holdKey), "DropHold Miss-Keys")
        let missDrop = MatchMath.leftoverUUIDUUIDMapDropDangling(
            [ghostKey: destGone], keep: [liveOther], hold: missHold
        )
        ok(missDrop[ghostKey] == destGone, "DropDangling Miss-Coast Key hält")
        near(MatchMath.leftoverHoldKalmanJumpCam(dt: 0.125, pref: 0.40), 0.34, 0.001, "Jump Cam Continuity")
        near(MatchMath.leftoverHoldKalmanJumpCam(dt: 0.04, pref: 0.40), 0.40, 0.001, "Jump Cam Webcam")
        near(MatchMath.leftoverHoldKalmanJumpCam(dt: 0.125, pref: 0.30), 0.30, 0.001, "Jump Cam Floor")
        let missEnc = MatchMath.leftoverUUIDIntMapEncode([kid: 2])
        ok(MatchMath.leftoverUUIDIntMapDecode(missEnc)[kid] == 2, "PairCommitMiss persist")
        let yawLast = MatchMath.leftoverLastHashRankRebase([kid: "6.6.4.6#0"])
        ok(yawLast[kid] == "6.6.4.6#0", "LastHash Yaw #0 hält")
        ok(!MatchMath.leftoverIoUJumpBlocks(0.36, jump: MatchMath.leftoverHoldKalmanJumpCam(dt: 0.125, pref: 0.40)), "Jump Cam Hold 0,36")
        ok(MatchMath.leftoverIoUJumpBlocks(0.32, jump: MatchMath.leftoverHoldKalmanJumpCam(dt: 0.125, pref: 0.40)), "Jump Cam Steal 0,32")
        ok(MatchMath.leftoverIoUJumpChip(0.36) == "JUMP", "JUMP Chip Default 0,40")
        ok(MatchMath.leftoverIoUJumpChip(0.36, jump: 0.34) == nil, "JUMP Chip Cam tot")
        let dangHold = UUID(), dangOther = UUID(), dangKeep = UUID()
        let emptyKeep = MatchMath.leftoverUUIDUUIDMapDropDangling(
            [dangHold: dangOther, dangOther: dangKeep], keep: [], hold: [dangHold]
        )
        ok(emptyKeep[dangHold] == dangOther, "DropDangling keep leer Hold hält")
        ok(emptyKeep[dangOther] == nil, "DropDangling keep leer Dangling tot")
        let sparkId = UUID()
        let sparkEnc = MatchMath.leftoverSparkChipEncode([sparkId: (chip: "ANNA 92", hold: 1)])
        let sparkDec = MatchMath.leftoverSparkChipDecode(sparkEnc)
        ok(sparkDec[sparkId]?.chip == "ANNA 92", "Spark Chip persist")
        ok(sparkDec[sparkId]?.hold == MatchMath.leftoverSparkChipHoldNeed, "Spark Chip Hold need")
        ok(MatchMath.leftoverSparkChipDecode(nil).isEmpty, "Spark Chip nil")
        ok(MatchMath.leftoverCaptureHistKeeps(remaining: 1.2), "Hist remaining hält")
        ok(!MatchMath.leftoverCaptureHistKeeps(remaining: 0), "Hist remaining 0 tot")
        ok(MatchMath.leftoverCaptureHistKeeps(remaining: nil), "Hist remaining nil hält")
        let histMiss = MatchMath.leftoverCaptureHistTableDecodeFresh(
            ["ab": [0.18], "zz": [0.19]],
            remaining: ["ab": 2.0]
        )
        ok(histMiss["zz"] == [0.19], "Hist Key ohne remaining hält")
        let histFresh = MatchMath.leftoverCaptureHistTableDecodeFresh(
            ["ab": [0.18, 0.19], "cd": [0.70]],
            remaining: ["ab": 2.0, "cd": 0]
        )
        ok(histFresh["ab"] == [0.18, 0.19], "Hist Fresh hält")
        ok(histFresh["cd"] == nil, "Hist Fresh expired tot")
        let histOld = MatchMath.leftoverCaptureHistTableDecodeFresh(["ab": [0.18]], remaining: nil)
        ok(histOld["ab"] == [0.18], "Hist Schema 15 ohne remaining")
        let histRem = MatchMath.leftoverCaptureHistRemainingEncode(
            ["ab": [0.18]],
            at: ["ab": 10],
            now: 12,
            ttl: 4
        )
        ok((histRem["ab"] ?? 0) > 1.9 && (histRem["ab"] ?? 0) < 2.1, "Hist remaining 2 s")
        let histAt = MatchMath.leftoverCaptureHistAtDecode(remaining: ["ab": 2], now: 12, ttl: 4)
        ok(abs((histAt["ab"] ?? 0) - 10) < 0.01, "Hist at from remaining")
        let histAtPut = MatchMath.leftoverCaptureHistAtPut(hash: "zz", now: 5, onto: [:])
        ok(histAtPut["zz"] == 5, "Hist at put")
        let tickLive = UUID(), tickHold = UUID()
        ok(MatchMath.leftoverSparkChipTickKeeps(id: tickLive, live: [tickLive], hold: []), "Spark tick live")
        ok(MatchMath.leftoverSparkChipTickKeeps(id: tickHold, live: [], hold: [tickHold]), "Spark tick lastHash")
        ok(!MatchMath.leftoverSparkChipTickKeeps(id: UUID(), live: [tickLive], hold: [tickHold]), "Spark tick dangling tot")
        near(MatchMath.leftoverAssignCost(iou: 1, printCos: 1), 0, 0.001, "Cost Perfect")
        near(MatchMath.leftoverAssignCost(iou: 0, printCos: 0), 1.3, 0.001, "Cost tot")
        near(MatchMath.leftoverAssignCost(iou: 0.70, printCos: 0.80), 0.36, 0.001, "Cost Mix")
        ok(
            MatchMath.leftoverAssignPrintSteals(
                remintCol: 1, printCol: 0, remintPrint: 0.40, printPrint: 0.82
            ),
            "Print stiehlt Remint"
        )
        ok(
            !MatchMath.leftoverAssignPrintSteals(
                remintCol: 0, printCol: 0, remintPrint: 0.70, printPrint: 0.72
            ),
            "Print gleiche Spalte tot"
        )
        ok(
            !MatchMath.leftoverAssignPrintSteals(
                remintCol: 1, printCol: 0, remintPrint: 0.70, printPrint: 0.72
            ),
            "Print Gap tot"
        )
        ok(
            !MatchMath.leftoverAssignPrintSteals(
                remintCol: 1, printCol: 0, remintPrint: 0.10, printPrint: 0.50
            ),
            "Print unter Floor tot"
        )
        let stealScores: [[Double?]] = [[0.40, 0.82], [0.80, 0.41]]
        let stolen = MatchMath.leftoverAssignPrintStealApply(
            assigned: [0, 1],
            printed: [1, 0],
            scores: stealScores
        )
        ok(stolen[0] == 1 && stolen[1] == 0, "Steal Apply Swap")
        let sib = MatchMath.leftoverAssignLive(
            scores: [[0.40, 0.82], [0.80, 0.41]],
            liveX: [0.20, 0.80],
            holdX: [0.22, 0.78]
        )
        ok(sib[0] == 1, "AssignLive Print stiehlt Geschwister")
        near(MatchMath.leftoverAssignCostIoU(dx: 0, pad: 0.12), 1, 0.001, "CostIoU dx0")
        near(MatchMath.leftoverAssignCostIoU(dx: 0.12, pad: 0.12), 0, 0.001, "CostIoU Pad")
        near(MatchMath.leftoverAssignCostIoU(dx: 0.06, pad: 0.12), 0.5, 0.001, "CostIoU halb")
        let cycScores: [[Double?]] = [
            [0.40, 0.82, 0.41],
            [0.41, 0.40, 0.83],
            [0.84, 0.42, 0.40]
        ]
        let cyc = MatchMath.leftoverAssignPrintSteal2opt(
            assigned: [0, 1, 2],
            printed: [1, 2, 0],
            scores: cycScores
        )
        ok(cyc[0] == 1 && cyc[1] == 2 && cyc[2] == 0, "Steal 2opt 3-Zyklus")
        ok(MatchMath.leftoverGhostHoldsCommit(miss: 1), "Ghost HOLD 1")
        ok(MatchMath.leftoverGhostHoldsCommit(miss: 2), "Ghost HOLD 2")
        ok(!MatchMath.leftoverGhostHoldsCommit(miss: 0), "Ghost HOLD 0 tot")
        ok(!MatchMath.leftoverGhostHoldsCommit(miss: 3), "Ghost HOLD ready tot")
        let commitId = UUID()
        let commitHold = MatchMath.leftoverUUIDUUIDMapDropHold(
            hold: [],
            ghosts: [],
            missKeys: [],
            commitMiss: [commitId: 1]
        )
        ok(commitHold.contains(commitId), "DropHold Commit-Miss hält")
        let commitReady = MatchMath.leftoverUUIDUUIDMapDropHold(
            hold: [],
            ghosts: [],
            missKeys: [],
            commitMiss: [commitId: 3]
        )
        ok(!commitReady.contains(commitId), "DropHold Commit ready tot")
        let heldId = UUID()
        let heldKeep = MatchMath.leftoverNameLockHeldSurvive(
            held: [heldId: "Anna"],
            until: [:]
        )
        ok(heldKeep[heldId] == "Anna", "Held Survive Until leer")
        let heldDrop = MatchMath.leftoverNameLockHeldSurvive(
            held: [heldId: "Anna", UUID(): "Bert"],
            until: [heldId: 10]
        )
        ok(heldDrop[heldId] == "Anna" && heldDrop.count == 1, "Held Survive Until filter")
        let heldLive = MatchMath.leftoverNameLockHeldSurvive(
            held: [heldId: "Anna"],
            until: [:],
            emptyKeeps: false
        )
        ok(heldLive.isEmpty, "Held Live Until leer wischt")
        ok(MatchMath.leftoverHoldMissCoast(miss: 1, need: 2), "Miss-Coast 1")
        ok(MatchMath.leftoverHoldMissCoast(miss: 2, need: 2), "Miss-Coast 2")
        ok(!MatchMath.leftoverHoldMissCoast(miss: 3, need: 2), "Miss-Coast 3 tot")
        let hashLive = UUID(), hashOld = UUID()
        ok(
            MatchMath.leftoverSparkChipTickKeeps(
                id: hashOld,
                live: [hashLive],
                hold: [],
                lastHash: "ab12",
                liveHash: ["ab12"]
            ),
            "Spark tick lastHash"
        )
        ok(
            !MatchMath.leftoverSparkChipTickKeeps(
                id: hashOld,
                live: [hashLive],
                hold: [],
                lastHash: "ab12",
                liveHash: ["zz99"]
            ),
            "Spark tick Hash mismatch tot"
        )
        ok(
            MatchMath.leftoverSparkChipTickDest(
                id: hashOld,
                live: [hashLive],
                lastHash: "ab12",
                liveByHash: ["ab12": hashLive]
            ) == hashLive,
            "Spark dest remint"
        )
        ok(
            MatchMath.leftoverSparkChipTickDest(
                id: hashLive,
                live: [hashLive],
                lastHash: "ab12",
                liveByHash: ["ab12": hashLive]
            ) == hashLive,
            "Spark dest live"
        )
        ok(
            MatchMath.leftoverSparkChipTickDest(
                id: hashOld,
                live: [hashLive],
                lastHash: "ab12",
                liveByHash: ["zz99": hashLive]
            ) == hashOld,
            "Spark dest mismatch hält alt"
        )
        let oldId = UUID()
        let liveId = UUID()
        let remap = [oldId: liveId]
        let hold = [oldId: 0.72]
        let applied = MatchMath.leftoverHoldRemintApply(hold: hold, remap: remap)
        ok(applied[liveId] == 0.72, "RemintApply kopiert Value")
        ok(applied[oldId] == 0.72, "RemintApply hält Source")
        let pairHold = [oldId: oldId]
        let pairOut = MatchMath.leftoverHoldRemintApplyId(hold: pairHold, remap: remap)
        ok(pairOut[liveId] == liveId, "RemintApplyId Value+Key")
        var hashTab: [String: String] = [:]
        hashTab = MatchMath.leftoverSparkChipHashPut(table: hashTab, hash: "ab12", chip: "BIN 3")
        ok(MatchMath.leftoverSparkChipHashGet(table: hashTab, hash: "ab12") == "BIN 3", "Spark Hash persist")
        ok(
            MatchMath.leftoverSparkChipTickKeeps(
                id: UUID(), live: [liveId], hold: [], lastHash: "ab12", liveHash: ["ab12"], hashTable: hashTab
            ),
            "Spark tick hashTable"
        )
        ok(MatchMath.leftoverBaptizeQualityProduct(sharpness: 0.40, yawAbs: 0.10) > 0.25, "Quality-Produkt frontal")
        ok(MatchMath.leftoverBaptizeQualityProduct(sharpness: 0.40, yawAbs: 0.10, blink: true) == 0, "Quality Blink 0")
        ok(MatchMath.leftoverBaptizeFloor(continuity: true) == 0.76, "Taufe Continuity 0,76")
        ok(MatchMath.leftoverBaptizeFloor(continuity: false) == 0.80, "Taufe Webcam 0,80")
        ok(MatchMath.leftoverBaptize(cosine: 0.77, continuity: true), "Continuity 0,77 tauft")
        ok(!MatchMath.leftoverBaptize(cosine: 0.77, continuity: false), "Webcam 0,77 tot")
        ok(MatchMath.leftoverUnsureChip(voted: "Ada", hist: ["Ada", "Ada"], need: 3) == "?", "Unsure Chip")
        ok(MatchMath.leftoverUnsureChip(voted: "Ada", hist: ["Ada", "Ada", "Ada"], need: 3) == nil, "Unsure tot nach Need")
        ok(MatchMath.leftoverUnsureChip(voted: nil, hist: ["", ""], need: 3) == nil, "Unsure Mute leer")
        let lockLine = MatchMath.cameraMutexLine(owner: "helios", pid: 9, now: 50)
        ok(MatchMath.cameraMutexParse(lockLine, now: 51) == "helios", "Mutex Helios")
        ok(MatchMath.cameraMutexParse(lockLine, now: 60, stale: 3) == nil, "Mutex stale 3")
        ok(MatchMath.cameraMutexParse(lockLine, now: 61) == "helios", "Mutex 12 s hält")
        ok(MatchMath.cameraMutexYieldsContinuity(holder: "helios", owner: "aegis"), "Aegis weicht")
        ok(!MatchMath.cameraMutexYieldsContinuity(holder: "aegis", owner: "helios"), "Helios weicht nicht")
        ok(MatchMath.cameraMutexPid(lockLine) == 9, "Mutex PID")
        ok(lockLine.contains("50.000"), "Mutex Stamp ms")
        ok(MatchMath.cameraMutexParse(lockLine, now: 51, pidLive: false) == nil, "Mutex tot PID")
        ok(MatchMath.cameraMutexParse(lockLine, now: 51, pidLive: true) == "helios", "Mutex live PID")
        ok(MatchMath.cameraMutexPidDead(0), "PID 0 tot")
        ok(!MatchMath.cameraMutexPidDead(9), "PID 9 lebend")
        ok(MatchMath.cameraMutexClaimWrites(holder: "aegis", owner: "helios"), "Helios überschreibt")
        ok(!MatchMath.cameraMutexClaimWrites(holder: "helios", owner: "aegis"), "Aegis nicht über Helios")
        ok(MatchMath.cameraMutexClaimWrites(holder: nil, owner: "aegis"), "Aegis frei")
        ok(MatchMath.cameraMutexYieldsNow(holder: "helios", owner: "aegis", wasYielded: false), "Yield live")
        ok(MatchMath.cameraMutexYieldsNow(holder: nil, owner: "aegis", wasYielded: true), "Yield hält")
        ok(!MatchMath.cameraMutexYieldsNow(holder: nil, owner: "aegis", wasYielded: false), "Yield tot")
        let mapA = UUID()
        let mapC = UUID()
        let remapPlan = MatchMath.leftoverHoldRemintMap(
            live: [(id: mapC, x: 0.20)],
            stored: [(id: mapA, x: 0.20)],
            holdKeys: [mapA]
        )
        ok(remapPlan[mapA] == mapC, "RemintMap stored→live")
        ok(remapPlan[mapC] == nil, "RemintMap skip identity")
        let binKey = MatchMath.leftoverHoldKey(id: oldId, bin: 0)
        let binsApplied = MatchMath.leftoverHoldRemintApplyBins(hold: [binKey: 0.64], remap: remap)
        ok(binsApplied[MatchMath.leftoverHoldKey(id: liveId, bin: 0)] == 0.64, "RemintApplyBins")
        ok(MatchMath.leftoverBaptizeQuality(sharpness: 0.10, yawAbs: 0, continuity: true), "Continuity quality 0,10")
        ok(!MatchMath.leftoverBaptizeQuality(sharpness: 0.10, yawAbs: 0, continuity: false), "Webcam quality 0,10 tot")
        ok(MatchMath.leftoverBaptize(cosine: 0.77, continuity: true), "Continuity Transfer-Floor")
        let hunPrint = MatchMath.leftoverAssignHungarianX(
            assigned: [nil, nil],
            liveX: [0.21, 0.23],
            holdX: [0.20, 0.24],
            pad: 0.12,
            scores: [[0.40, 0.90], [0.88, 0.41]]
        )
        ok(hunPrint[0] == 1 && hunPrint[1] == 0, "HungarianX Print Twin")
        let hunXOnly = MatchMath.leftoverAssignHungarianX(
            assigned: [nil, nil],
            liveX: [0.09, 0.20],
            holdX: [0.00, 0.10],
            pad: 0.12
        )
        ok(hunXOnly[0] == 0 && hunXOnly[1] == 1, "HungarianX ohne Print hält X")
        near(
            MatchMath.leftoverAssignHungarianXCost(dx: 0.02, pad: 0.12, printCos: 0.40),
            MatchMath.leftoverAssignCost(
                iou: MatchMath.leftoverAssignCostIoU(dx: 0.02, pad: 0.12),
                printCos: 0.40,
                printW: 0.8
            ),
            0.001,
            "HungarianX Cost PrintW 0,8"
        )
        let packed = MatchMath.leftoverSparkChipPack(
            uuid: [hashLive: (chip: "ANNA 92", hold: 2)],
            hash: ["6.6.4.6": "ANNA 92"]
        )
        let unpacked = MatchMath.leftoverSparkChipUnpack(packed)
        ok(unpacked.uuid[hashLive]?.chip == "ANNA 92", "Spark Pack UUID")
        ok(unpacked.hash["6.6.4.6"] == "ANNA 92", "Spark Pack Hash")
        ok(MatchMath.leftoverSparkChipHashGet(table: unpacked.hash, hash: "6.6.4.6") == "ANNA 92", "Spark Hash Lookup")
        ok(MatchMath.leftoverSparkChipHashEncode(["\(hashLive)": "x"]).isEmpty, "Spark Hash skip UUID")
        let hashSkip = MatchMath.leftoverSparkChipHashPut(
            table: [:], hash: hashLive.uuidString, chip: "NO"
        )
        ok(hashSkip.isEmpty, "Spark Hash Put skip UUID")
        let liveTwin = MatchMath.leftoverAssignLive(
            scores: [[0.40, 0.90], [0.88, 0.41]],
            liveX: [0.21, 0.23],
            holdX: [0.20, 0.24]
        )
        ok(liveTwin[0] == 1 && liveTwin[1] == 0, "AssignLive Print Twin")
        ok(MatchMath.leftoverAssignHungarianXHasPrint([[0.40, 0.90]]), "Print da")
        ok(!MatchMath.leftoverAssignHungarianXHasPrint([[nil, nil]]), "Print leer tot")
        ok(!MatchMath.leftoverAssignHungarianXHasPrint(nil), "Print nil tot")
        var crowdScores: [[Double?]] = (0..<9).map { r in
            (0..<9).map { c -> Double? in
                if r == 0 && c == 1 { return 0.90 }
                if r == 1 && c == 0 { return 0.88 }
                if r == c { return 0.90 }
                return 0.20
            }
        }
        crowdScores[0][0] = 0.20
        crowdScores[1][1] = 0.20
        let crowdX: [Double] = [0.10, 0.12, 0.26, 0.34, 0.42, 0.50, 0.58, 0.66, 0.74]
        let crowd = MatchMath.leftoverAssignHungarianX(
            assigned: Array(repeating: Optional<Int>.none, count: 9),
            liveX: crowdX,
            holdX: crowdX,
            pad: 0.12,
            scores: crowdScores
        )
        ok(crowd[0] == 1 && crowd[1] == 0, "HungarianX n=9 Print-Greedy Twin")
        ok(crowd[2] == 2 && crowd[8] == 8, "HungarianX n=9 Rest Diagonale")
        ok(MatchMath.leftoverDetectSkip(iou: 0.95), "Detect-Skip 0,95")
        ok(!MatchMath.leftoverDetectSkip(iou: 0.80), "Detect-Skip 0,80 tot")
        ok(!MatchMath.leftoverDetectSkip(iou: nil), "Detect-Skip nil tot")
        ok(MatchMath.leftoverDetectSkipAll(ious: [0.94, 0.93], need: 2), "Detect-Skip alle")
        ok(!MatchMath.leftoverDetectSkipAll(ious: [0.94, 0.40], need: 2), "Detect-Skip Misch tot")
        ok(MatchMath.leftoverDetectSkipTick(skip: true, tick: 1, every: 8), "Skip Tick 1")
        ok(!MatchMath.leftoverDetectSkipTick(skip: true, tick: 8, every: 8), "Skip Tick 8 voll")
        ok(!MatchMath.leftoverDetectSkipTick(skip: false, tick: 1), "Skip tot")
        ok(!MatchMath.cameraMutexYieldsNow(holder: "aegis", owner: "aegis", wasYielded: true), "Yield löst wenn wir halten")
        ok(MatchMath.cameraMutexYieldReconfigure(yielded: true, isContinuity: true), "Yield → Built-in")
        ok(!MatchMath.cameraMutexYieldReconfigure(yielded: true, isContinuity: false), "Yield Built-in bleibt")
        ok(MatchMath.cameraMutexCacheFolder() == "HeliosAegis", "Mutex Caches-Ordner")
        ok(MatchMath.cameraMutexRelPath().hasSuffix("/helios.aegis.camera.lock"), "Mutex RelPath")
        ok(MatchMath.cameraMutexReadOrder() == ["caches", "tmp"], "Mutex Read Caches zuerst")
        ok(MatchMath.cameraMutexFlockExclusive(), "Mutex flock")
        ok(MatchMath.cameraMutexPickText(caches: "helios 1 1.000", tmp: "aegis 2 2.000") == "helios 1 1.000", "Pick Caches")
        ok(MatchMath.cameraMutexPickText(caches: nil, tmp: "aegis 2 2.000") == "aegis 2 2.000", "Pick Legacy tmp")
        let genLine = MatchMath.cameraMutexLine(owner: "aegis", pid: 9, now: 50, gen: 3)
        ok(MatchMath.cameraMutexGen(genLine) == 3, "Mutex Gen")
        ok(MatchMath.cameraMutexParse(genLine, now: 51) == "aegis", "Mutex Gen Parse")
        let munkres = MatchMath.leftoverAssignHungarianMunkres(cost: [
            [4, 1, 3],
            [2, 0, 5],
            [3, 2, 2]
        ])
        ok(munkres == [1, 0, 2], "Munkres 3×3 min-cost")
        var cycleScores: [[Double?]] = [
            [0.55, 0.95, 0.05, 0.05],
            [0.05, 0.55, 0.95, 0.05],
            [0.05, 0.05, 0.55, 0.95],
            [0.95, 0.05, 0.05, 0.55]
        ]
        let cycleX: [Double] = [0.10, 0.11, 0.12, 0.13]
        let cycle = MatchMath.leftoverAssignHungarianX(
            assigned: [nil, nil, nil, nil],
            liveX: cycleX,
            holdX: cycleX,
            pad: 0.40,
            scores: cycleScores
        )
        ok(cycle[0] == 1 && cycle[1] == 2 && cycle[2] == 3 && cycle[3] == 0, "HungarianX 4-Zyklus Print")
        let oldId = UUID()
        let liveId = UUID()
        let packed = MatchMath.leftoverFaceTrackPack(
            hold: [oldId: 0.72],
            pending: [oldId: "Ada"],
            streak: [oldId: 3],
            lastHash: [oldId: "ab12"],
            lastIoU: [oldId: 0.91],
            nameHeld: [oldId: "Ada"],
            nameUntil: [oldId: 9],
            miss: [:]
        )
        ok(packed[oldId]?.pending == "Ada" && packed[oldId]?.streak == 3, "FaceTrack Pack")
        let reminted = MatchMath.leftoverFaceTrackRemint(packed, remap: [oldId: liveId])
        ok(reminted[liveId]?.hold == 0.72, "FaceTrack Remint kopiert")
        ok(reminted[oldId]?.hold == 0.72, "FaceTrack Remint hält Source")
        let dropped = MatchMath.leftoverHoldRemintDrop(hold: [oldId: 0.72], remap: [oldId: liveId])
        ok(dropped[liveId] == 0.72, "RemintDrop kopiert")
        ok(dropped[oldId] == nil, "RemintDrop räumt Source")
        let faceDrop = MatchMath.leftoverFaceTrackRemintDrop(packed, remap: [oldId: liveId])
        ok(faceDrop[liveId]?.hold == 0.72 && faceDrop[oldId] == nil, "FaceTrack Drop")
        let z1 = UUID()
        let z2 = UUID()
        let liveIous = MatchMath.leftoverDetectSkipLiveIous(
            stored: [z1: 0.95, z2: 0.40],
            live: [z1]
        )
        ok(liveIous == [0.95], "Skip IoU nur live")
        ok(MatchMath.leftoverDetectSkipAll(ious: liveIous, need: 1), "Skip live hoch")
        ok(!MatchMath.leftoverDetectSkipAll(ious: [0.95, 0.40], need: 1), "Skip Zombie tot")
        ok(MatchMath.leftoverDetectSkipVision(skipDetect: true), "Skip Vision")
        ok(!MatchMath.leftoverDetectSkipVision(skipDetect: false), "Skip Vision tot")
        ok(MatchMath.leftoverOpenSetGapNow(top: 0.80, second: 0.72), "OpenSet Gap 0,08")
        ok(!MatchMath.leftoverOpenSetGapNow(top: 0.90, second: 0.70), "OpenSet Gap tot")
        ok(MatchMath.leftoverOpenSetUnsure(scores: [0.80, 0.72]), "OpenSet Unsure Gap")
        ok(!MatchMath.leftoverOpenSetUnsure(scores: [0.92, 0.40]), "OpenSet klar")
        ok(MatchMath.leftoverOpenSetGalleryFloor([0.50, 0.40]), "Gallery Floor Unsure")
        ok(!MatchMath.leftoverOpenSetGalleryFloor([0.70, 0.40]), "Gallery Floor Genuine")
        ok(MatchMath.leftoverOpenSetGalleryFloor([0.61]), "Gallery Floor Solo 0,61")
        ok(!MatchMath.leftoverOpenSetGalleryFloor([0.62]), "Gallery Floor 0,62 hält")
        ok(MatchMath.leftoverOpenSetGalleryFloor([]), "Gallery Floor leer Unsure")
        let smHold = MatchMath.leftoverHoldSmooth(raw: 0.70, prev: 0.50) ?? 0
        ok(smHold < MatchMath.leftoverPrintGenuine, "Smooth 0,70/0,50 unter Genuine")
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.50, 0.70)], holdPrev: 0.50) == 0,
            "Gallery-Floor auf Roh, nicht Smooth"
        )
        ok(
            MatchMath.leftoverOpenSetGalleryFloor(
                [0.65],
                floor: MatchMath.leftoverSessionFloor(yawAbs: 0.50, capture: nil)
            ),
            "Gallery Floor Profil 0,65"
        )
        ok(!MatchMath.cameraMutexWriteTmp(), "Mutex tmp-Write tot")
        ok(MatchMath.cameraMutexSkipClaim(readBusy: true), "Mutex Skip Claim busy")
        ok(!MatchMath.cameraMutexSkipClaim(readBusy: false), "Mutex Skip Claim frei")
        ok(
            MatchMath.cameraMutexWriteAllowed(
                existing: MatchMath.cameraMutexLine(owner: "helios", pid: 1, now: 1_000, gen: 3),
                owner: "aegis",
                now: 1_001
            ) == false,
            "Aegis CAS tot über Helios"
        )
        ok(
            MatchMath.cameraMutexWriteAllowed(
                existing: MatchMath.cameraMutexLine(owner: "aegis", pid: 2, now: 1_000),
                owner: "helios",
                now: 1_001
            ),
            "Helios CAS überschreibt Aegis"
        )
        ok(MatchMath.cameraMutexBumpGen(nil) == 1, "Mutex Gen 1")
        let casLine = MatchMath.cameraMutexLockedLine(
            existing: MatchMath.cameraMutexLine(owner: "aegis", pid: 2, now: 1_000, gen: 4),
            owner: "helios",
            pid: 9,
            now: 1_001
        )
        ok(MatchMath.cameraMutexGen(casLine ?? "") == 5, "Mutex CAS gen++")
        ok(
            MatchMath.cameraMutexLockedLine(
                existing: MatchMath.cameraMutexLine(owner: "helios", pid: 1, now: 1_000, gen: 2),
                owner: "aegis",
                pid: 3,
                now: 1_001
            ) == nil,
            "Aegis LockedLine tot"
        )
        let binKey = MatchMath.leftoverHoldKey(id: oldId, bin: 0)
        let binsDropped = MatchMath.leftoverHoldRemintDropBins(hold: [binKey: 0.64], remap: [oldId: liveId])
        ok(binsDropped[MatchMath.leftoverHoldKey(id: liveId, bin: 0)] == 0.64, "DropBins kopiert")
        ok(binsDropped[binKey] == nil, "DropBins räumt Source")
        let pairHold: [UUID: UUID] = [oldId: oldId]
        let pairDrop = MatchMath.leftoverHoldRemintDropId(hold: pairHold, remap: [oldId: liveId])
        ok(pairDrop[liveId] == liveId, "DropId Value")
        ok(pairDrop[oldId] == nil, "DropId Source tot")
        let unpacked = MatchMath.leftoverFaceTrackUnpack(faceDrop)
        ok(unpacked.hold[liveId] == 0.72 && unpacked.pending[liveId] == "Ada", "FaceTrack Unpack")
        ok(unpacked.hold[oldId] == nil, "FaceTrack Unpack drop")
        let box = MatchMath.FaceTrackBox(x: 0.10, y: 0.20, w: 0.30, h: 0.40)
        let kal = MatchMath.FaceTrackBox(x: 0.11, y: 0.21, w: 0.31, h: 0.41)
        let packedLive = MatchMath.leftoverFaceTrackPack(
            hold: [oldId: 0.72],
            pending: [oldId: "Ada"],
            streak: [oldId: 3],
            lastHash: [oldId: "ab12"],
            lastIoU: [oldId: 0.91],
            nameHeld: [oldId: "Ada"],
            nameUntil: [oldId: 9],
            miss: [:],
            streakBox: [oldId: box],
            kalman: [oldId: kal],
            pairLast: [oldId: liveId],
            pairStreak: [oldId: 2]
        )
        ok(packedLive[oldId]?.streakBox?.x == 0.10, "FaceTrack StreakBox")
        ok(packedLive[oldId]?.kalman?.y == 0.21, "FaceTrack Kalman")
        ok(packedLive[oldId]?.pairLast == liveId && packedLive[oldId]?.pairStreak == 2, "FaceTrack Pair")
        let liveDrop = MatchMath.leftoverFaceTrackRemintDrop(packedLive, remap: [oldId: liveId])
        let liveMaps = MatchMath.leftoverFaceTrackUnpack(liveDrop)
        ok(liveMaps.streakBox[liveId]?.w == 0.30 && liveMaps.streakBox[oldId] == nil, "FaceTrack StreakBox Drop")
        ok(liveMaps.kalman[liveId]?.h == 0.41, "FaceTrack Kalman Drop")
        ok(liveMaps.pairLast[liveId] == liveId && liveMaps.pairStreak[liveId] == 2, "FaceTrack Pair Drop")
        let packedSelf = MatchMath.leftoverFaceTrackPack(
            hold: [oldId: 0.72],
            pending: [:],
            streak: [:],
            lastHash: [:],
            lastIoU: [:],
            nameHeld: [:],
            nameUntil: [:],
            miss: [:],
            pairLast: [oldId: oldId]
        )
        let selfDrop = MatchMath.leftoverFaceTrackRemintDrop(packedSelf, remap: [oldId: liveId])
        ok(selfDrop[liveId]?.pairLast == liveId, "FaceTrack PairLast Value Remint")
        ok(selfDrop[oldId] == nil, "FaceTrack PairLast Source tot")
        ok(MatchMath.galleryBakRotate() == 3, "gallery.bak rotate 3")
        ok(MatchMath.galleryBakName(0) == "gallery.json.bak", "bak 0")
        ok(MatchMath.galleryBakName(2) == "gallery.json.bak.2", "bak 2")
        ok(MatchMath.cameraMutexFlockNonblock(), "Mutex flock NB")
        ok(MatchMath.cameraMutexFlockReadShared(), "Mutex flock SH")
        ok(!MatchMath.cameraMutexWriteTmp(), "Mutex tmp-Write tot")
        ok(MatchMath.leftoverOverlayUnsureFirst(voted: nil, hist: [], need: 3, guest: "Gast 1") == "?", "Overlay Unsure leer")
        ok(MatchMath.leftoverOverlayUnsureFirst(voted: "Ada", hist: ["Ada", "Ada", "Ada"], need: 3, guest: "Gast 1") == "Ada", "Overlay Mehrheit")
        ok(abs(MatchMath.cameraMutexYieldGrace() - 4) < 0.01, "Yield Grace 4 s")
        ok(
            MatchMath.cameraMutexYieldAutoReturn(
                yielded: true, holder: nil, owner: "aegis", since: 0, now: 5
            ),
            "Auto-Return nach Grace"
        )
        ok(
            !MatchMath.cameraMutexYieldAutoReturn(
                yielded: true, holder: "helios", owner: "aegis", since: 0, now: 9
            ),
            "Auto-Return tot solange Helios hält"
        )
        ok(
            !MatchMath.cameraMutexYieldAutoReturn(
                yielded: true, holder: nil, owner: "aegis", since: 0, now: 2
            ),
            "Auto-Return vor Grace tot"
        )
        ok(MatchMath.cameraMutexChip(holder: nil, yielded: true) == "YIELD", "Mutex Chip YIELD")
        ok(MatchMath.cameraMutexChip(holder: "helios", yielded: false) == "helios", "Mutex Chip Holder")
        ok(MatchMath.cameraMutexPickText(caches: "", tmp: "aegis 1 1.000", cachesEmpty: true) == nil, "Pick empty Caches tot")
        ok(MatchMath.cameraMutexPickText(caches: "", tmp: "aegis 1 1.000") == "aegis 1 1.000", "Pick Legacy ohne empty-Flag")
        ok(MatchMath.leftoverPickArgmax(raw: [0.70, 0.50], scored: [0.55, 0.80]) == 0, "Argmax Roh trotz Score-Inflation")
        ok(MatchMath.leftoverPickArgmax(raw: [0.73, 0.72], scored: [0.60, 0.80]) == 1, "Argmax Tie-Break Schärfe")
        ok(MatchMath.leftoverPickArgmax(raw: [0.67, 0.66], scored: [0.70, 0.78]) == 1, "Argmax Tie-Break Detector")
        ok(MatchMath.leftoverPickArgmax(raw: [], scored: []) == nil, "Argmax leer")
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.50, 0.80), (1, 0.50, 0.65)],
                sharpness: [0: 0.14, 1: 0.50],
                detScore: [0: 0.20, 1: 0.99]
            ) == 0,
            "Nachbar 0,65 trotz Score-Inflation tot"
        )
        ok(MatchMath.leftoverCoastPrintKeeps(skipDetect: true), "Coast-Print Skip")
        ok(!MatchMath.leftoverCoastPrintKeeps(skipDetect: false), "Coast-Print Voll tot")
        ok(MatchMath.leftoverCoastPrintKeeps(skipDetect: false, skipPrints: true), "Coast-Print skipPrints")
        ok(MatchMath.leftoverCoastCosine(skipDetect: true, live: nil, stored: 0.70) == 0.70, "Coast nimmt Hold")
        ok(MatchMath.leftoverCoastCosine(skipDetect: true, live: 0.80, stored: 0.70) == 0.80, "Coast live vor Hold")
        ok(MatchMath.leftoverCoastCosine(skipDetect: false, live: nil, stored: 0.70) == nil, "Voll ohne Print tot")
        ok(MatchMath.leftoverCoastCosine(skipDetect: false, skipPrints: true, live: nil, stored: 0.70) == 0.70, "skipPrints nimmt Hold")
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.80, nil)], holdPrev: 0.70) == 0,
            "Coast-Hold ohne Live-Print"
        )
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.80, nil)], holdPrev: nil) == nil,
            "ohne Print ohne Hold tot"
        )
        ok(MatchMath.cameraMutexClaimBackoffFails() == 3, "ClaimBackoff 3")
        ok(abs(MatchMath.cameraMutexClaimBackoffDt() - 0.40) < 0.01, "ClaimBackoff 400 ms")
        ok(!MatchMath.cameraMutexClaimDue(last: 0, now: 0.08, fails: 3), "ClaimBackoff vor 400 ms tot")
        ok(MatchMath.cameraMutexClaimDue(last: 0, now: 0.40, fails: 3), "ClaimBackoff 400 ms fällig")
        ok(MatchMath.cameraMutexClaimDue(last: 0, now: 0.08, fails: 2), "ClaimBackoff vor 3 frei")
        ok(MatchMath.cameraMutexFsyncBeforeUnlock(), "Mutex fsync")
        ok(MatchMath.cameraMutexClaimDue(last: 0, now: 0.08), "ClaimDue 80 ms")
        ok(!MatchMath.cameraMutexClaimDue(last: 0, now: 0.07), "ClaimDue vor 80 ms tot")
        ok(abs(MatchMath.cameraMutexYieldGracePref(1) - 2) < 0.01, "Yield Grace Floor 2")
        ok(abs(MatchMath.cameraMutexYieldGracePref(9) - 8) < 0.01, "Yield Grace Cap 8")
        ok(!MatchMath.cameraMutexYieldAutoReturnPref(false), "Yield Auto-Return aus")
        ok(MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016, minIoU: 0.95, yawAbs: 0.05), "Print skip stabil")
        ok(!MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016, minIoU: 0.50, yawAbs: 0.05), "Print bleibt IoU 0,50")
        ok(!MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016, minIoU: 0.95, yawAbs: 0.20), "Print bleibt Yaw 11°")
        ok(abs(MatchMath.printBudgetYawRad - 8.0 * Double.pi / 180) < 1e-9, "Print-Budget 8°")
        ok(MatchMath.cameraMutexExpectedGen(nil) == 0, "Expected Gen 0")
        let aegisGen = MatchMath.cameraMutexLine(owner: "aegis", pid: 2, now: 1_000, gen: 4)
        ok(
            MatchMath.cameraMutexLockedLine(
                existing: aegisGen, owner: "aegis", pid: 2, now: 1_001, expectedGen: 4
            ) != nil,
            "Aegis CAS Gen match"
        )
        ok(
            MatchMath.cameraMutexLockedLine(
                existing: aegisGen, owner: "aegis", pid: 2, now: 1_001, expectedGen: 3
            ) == nil,
            "Aegis CAS Gen mismatch tot"
        )
        ok(
            MatchMath.cameraMutexLockedLine(
                existing: aegisGen, owner: "helios", pid: 9, now: 1_001, expectedGen: 3
            ) != nil,
            "Helios CAS trotz Gen mismatch"
        )
        ok(MatchMath.cameraMutexCasAllows(existing: aegisGen, owner: "aegis", expectedGen: 4), "CAS Aegis match")
        ok(!MatchMath.cameraMutexCasAllows(existing: aegisGen, owner: "aegis", expectedGen: 3), "CAS Aegis mismatch")
        ok(MatchMath.cameraMutexCasAllows(existing: aegisGen, owner: "helios", expectedGen: 3), "CAS Helios Vorrang")
        ok(MatchMath.cameraMutexClaimChip(holder: "helios", yielded: false) == "helios", "Claim Chip Holder")
        ok(MatchMath.cameraMutexClaimChip(holder: "helios", yielded: true, fails: 3) == "YIELD", "Claim Chip YIELD")
        ok(MatchMath.cameraMutexClaimChip(holder: "helios", yielded: false, fails: 3) == "helios · backoff", "Claim Chip backoff")
        ok(MatchMath.cameraMutexClaimChip(holder: "aegis", yielded: false, fails: 1) == "aegis · 1nb", "Claim Chip 1nb")
        let trackOld = UUID()
        let trackLive = UUID()
        let mapsDrop = MatchMath.leftoverFaceTrackRemintDropMaps(
            hold: [trackOld: 0.72],
            pending: [trackOld: "Ada"],
            streak: [trackOld: 3],
            lastHash: [trackOld: "ab12"],
            lastIoU: [trackOld: 0.91],
            nameHeld: [trackOld: "Ada"],
            nameUntil: [trackOld: 9],
            miss: [:],
            pairLast: [trackOld: trackOld],
            remap: [trackOld: trackLive]
        )
        ok(mapsDrop.hold[trackLive] == 0.72 && mapsDrop.hold[trackOld] == nil, "FaceTrack Maps Drop Hold")
        ok(mapsDrop.pending[trackLive] == "Ada" && mapsDrop.pairLast[trackLive] == trackLive, "FaceTrack Maps Drop Pair")
        ok(mapsDrop.miss[trackLive] == nil, "FaceTrack Unpack Default tot")
        let boxConv = MatchMath.leftoverFaceBox(MatchMath.leftoverFaceTrackBox(FaceBox(x: 1, y: 2, width: 3, height: 4)))
        ok(boxConv.x == 1 && boxConv.height == 4, "FaceTrack Box roundtrip")
        ok(
            MatchMath.leftoverCoastCosine(
                skipDetect: true, live: 0.90, stored: 0.70, livePrintEmpty: true
            ) == 0.70,
            "Coast leerer Print nimmt Hold"
        )
        ok(
            MatchMath.leftoverCoastCosine(
                skipDetect: false, skipPrints: true, live: 0.90, stored: 0.70, livePrintEmpty: true
            ) == 0.70,
            "skipPrints leerer Print nimmt Hold"
        )
        ok(
            MatchMath.leftoverCoastCosine(
                skipDetect: false, skipPrints: true, live: 0.90, stored: 0.70, livePrintEmpty: false
            ) == 0.90,
            "skipPrints mit Print live"
        )
        ok(!MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016, minIoU: 0.95, yawAbs: 0.05, continuity: true), "Continuity nie Print-Skip")
        ok(MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016, minIoU: 0.95, yawAbs: 0.05, continuity: false), "Built-in Print-Skip")
        let liveOld = UUID()
        let liveNew = UUID()
        let extraDrop = MatchMath.leftoverFaceTrackRemintDropMaps(
            hold: [liveOld: 0.72],
            pending: [:],
            streak: [:],
            lastHash: [:],
            lastIoU: [:],
            nameHeld: [:],
            nameUntil: [:],
            miss: [:],
            yaw: [liveOld: 0.20],
            stillFor: [liveOld: 0.40],
            scoreEma: [liveOld: 82],
            blinkSeen: [liveOld: true],
            openStreak: [liveOld: 3],
            voteAt: [liveOld: 9],
            remap: [liveOld: liveNew]
        )
        ok(extraDrop.yaw[liveNew] == 0.20 && extraDrop.yaw[liveOld] == nil, "FaceTrack Yaw Drop")
        ok(extraDrop.stillFor[liveNew] == 0.40, "FaceTrack Still Drop")
        ok(extraDrop.scoreEma[liveNew] == 82, "FaceTrack EMA Drop")
        ok(extraDrop.blinkSeen[liveNew] == true && extraDrop.openStreak[liveNew] == 3, "FaceTrack Blink Drop")
        ok(extraDrop.voteAt[liveNew] == 9, "FaceTrack Vote Drop")
        let histDrop = MatchMath.leftoverHoldRemintDrop(
            hold: [liveOld: ["Ada", "Ada"]], remap: [liveOld: liveNew]
        )
        ok(histDrop[liveNew] == ["Ada", "Ada"] && histDrop[liveOld] == nil, "Name-Hist RemintDrop")
        let trailDrop = MatchMath.leftoverHoldRemintDrop(
            hold: [liveOld: [[0.1, 0.2]]], remap: [liveOld: liveNew]
        )
        ok(trailDrop[liveNew]?.first?.first == 0.1 && trailDrop[liveOld] == nil, "Print-Trail RemintDrop")
        let vecA = [Double](repeating: 1, count: 32)
        var vecB = vecA; vecB[0] = 0.2
        ok(MatchMath.leftoverCoastPrintVecOf(live: vecA, stored: []).count == 32, "Coast Vec live")
        ok(MatchMath.leftoverCoastPrintVecOf(live: [], stored: vecA).count == 32, "Coast Vec stored")
        ok((MatchMath.leftoverCoastPrintSkipCosine(live: vecA, liveStored: [], old: vecA, oldStored: []) ?? 0) > 0.99, "Coast Skip Live self")
        ok((MatchMath.leftoverCoastPrintSkipCosine(live: [], liveStored: vecA, old: [], oldStored: vecB) ?? 1) < 0.99, "Coast Skip Cache Twin")
        ok(MatchMath.leftoverCoastPrintSkipCosine(live: [], liveStored: [], old: [], oldStored: vecA) == nil, "Coast Skip leer tot")
        ok(MatchMath.leftoverPrintBudgetYawDelta(printed: [liveOld: 0], live: [liveOld: 0]) == 0, "Yaw still Δ 0")
        ok((MatchMath.leftoverPrintBudgetYawDelta(printed: [liveOld: 0], live: [liveOld: 0.30]) ?? 0) > 0.2, "Yaw dreh")
        ok(MatchMath.leftoverPrintBudgetYawDelta(printed: [:], live: [liveOld: 0.10]) == nil, "Yaw ohne Print tot")
        ok(
            MatchMath.leftoverPrintYawMerge(printed: [liveOld: 0], live: [liveOld: 0.30], skipPrints: true)[liveOld] == 0,
            "PrintYaw skip hält"
        )
        ok(
            abs((MatchMath.leftoverPrintYawMerge(printed: [liveOld: 0], live: [liveOld: 0.30], skipPrints: false)[liveOld] ?? -1) - 0.30) < 1e-9,
            "PrintYaw nach Print"
        )
        ok(
            !MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016, minIoU: 0.95, yawAbs: 0.05, yawDelta: 0.30),
            "Print bleibt Yaw-Δ 17°"
        )
        ok(
            MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016, minIoU: 0.95, yawAbs: 0.05, yawDelta: 0.05),
            "Print skip Yaw-Δ still"
        )
        ok(MatchMath.leftoverCoastPrintMerge(stored: [:], live: [liveOld: vecA], skipPrints: true)[liveOld] == nil, "Coast Merge skip tot")
        ok(MatchMath.leftoverCoastPrintMerge(stored: [:], live: [liveOld: vecA], skipPrints: false)[liveOld]?.count == 32, "Coast Merge nach Print")
        let totHold = MatchMath.cameraMutexLine(owner: "helios", pid: 1, now: 1_000, gen: 3)
        ok(
            MatchMath.cameraMutexWriteAllowed(
                existing: totHold, owner: "aegis", now: 1_001, pidLive: false
            ),
            "Write tot PID frei"
        )
        ok(
            MatchMath.cameraMutexWriteAllowed(
                existing: totHold, owner: "aegis", now: 1_001, pidLive: true
            ) == false,
            "Write live PID tot"
        )
        ok(
            MatchMath.cameraMutexLockedLine(
                existing: totHold, owner: "aegis", pid: 3, now: 1_001, pidLive: false
            ) != nil,
            "LockedLine tot PID frei"
        )
        let lookupHold = MatchMath.leftoverHoldRemintDrop(
            hold: [liveOld: 0.72], remap: [liveOld: liveNew]
        )
        ok(
            MatchMath.leftoverHoldRemintLookup(
                hold: lookupHold, id: liveOld, remap: [liveOld: liveNew]
            ) == 0.72,
            "Lookup Source nach Drop"
        )
        ok(MatchMath.leftoverHoldRemintLookup(hold: lookupHold, id: liveNew) == 0.72, "Lookup live")
        ok(MatchMath.leftoverHoldRemintLookup(hold: lookupHold, id: UUID()) == nil, "Lookup tot")
        let coastLookup = MatchMath.leftoverHoldRemintDrop(
            hold: [liveOld: vecA], remap: [liveOld: liveNew]
        )

        ok(MatchMath.leftoverHoldViaLookup(hold: lookupHold, id: liveOld, remap: [liveOld: liveNew]), "Hold via Lookup")
        ok(!MatchMath.leftoverHoldViaLookup(hold: lookupHold, id: liveNew, remap: [liveOld: liveNew]), "Hold live kein Lookup")
        ok(MatchMath.leftoverHoldLookupUnsure(skipCosine: nil, holdViaLookup: true), "Unsure Skip nil + Lookup")
        ok(!MatchMath.leftoverHoldLookupUnsure(skipCosine: 0.91, holdViaLookup: true), "Unsure tot mit Print")
        ok(!MatchMath.leftoverHoldLookupUnsure(skipCosine: nil, holdViaLookup: false), "Unsure tot ohne Lookup")
        ok(MatchMath.leftoverHoldLookupUnsureNote() == "?", "Unsure Note")
        ok(MatchMath.leftoverPickPrint(raw: nil, smoothed: 0.70, holdOnlyUnsure: true) == nil, "PickPrint Unsure kein Hold")
        ok(MatchMath.leftoverPickPrint(raw: 0.82, smoothed: 0.70, holdOnlyUnsure: true) == 0.82, "PickPrint Unsure Roh")
        ok(MatchMath.leftoverPickPrint(raw: nil, smoothed: 0.70) == 0.70, "PickPrint Coast Hold")
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.50, nil)], holdPrev: 0.70, holdOnlyUnsure: true) == nil,
            "Pick Unsure Twin tot"
        )
        ok(
            MatchMath.leftoverPick(candidates: [(0, 0.50, 0.82)], holdPrev: 0.70, holdOnlyUnsure: true) == 0,
            "Pick Unsure mit Print"
        )
        ok(MatchMath.leftoverDetectSkipIoUOnly(skipCosine: nil, skipDetect: true, skipPrints: false, holdViaLookup: false), "Detect-Skip IoU")
        ok(!MatchMath.leftoverDetectSkipIoUOnly(skipCosine: nil, skipDetect: true, skipPrints: false, holdViaLookup: true), "Detect-Skip Lookup kein IoU")
        ok(!MatchMath.leftoverDetectSkipIoUOnly(skipCosine: 0.91, skipDetect: true, skipPrints: false, holdViaLookup: false), "Detect-Skip mit Vec tot")
        ok(
            MatchMath.leftoverCoastCosineMeasured(
                skipCosine: nil, skipDetect: true, skipPrints: true, live: nil, stored: 0.70,
                livePrintEmpty: true, holdViaLookup: true
            ) == nil,
            "Coast Measured Lookup Unsure"
        )
        ok(
            MatchMath.leftoverCoastCosineMeasured(
                skipCosine: 0.91, skipDetect: true, skipPrints: true, live: nil, stored: 0.70,
                livePrintEmpty: true, holdViaLookup: true
            ) == 0.91,
            "Coast Measured Print"
        )
        ok(
            MatchMath.leftoverCoastCosineMeasured(
                skipCosine: nil, skipDetect: true, skipPrints: true, live: nil, stored: 0.70,
                livePrintEmpty: true, holdViaLookup: false
            ) == nil,
            "Coast Measured Detect-Skip IoU"
        )
        ok(MatchMath.leftoverPickArgmaxIou([0.40, 0.90, 0.55]) == 1, "Argmax IoU")
        ok(MatchMath.leftoverPickArgmaxIou([]) == nil, "Argmax IoU leer")
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.40, nil), (1, 0.88, nil)],
                holdPrev: 0.70,
                iouOnly: true
            ) == 1,
            "Pick IoU-only nicht Hold"
        )
        let prevBox = MatchMath.FaceTrackBox(x: 0.10, y: 0.20, w: 0.30, h: 0.40)
        let liveBox = MatchMath.FaceTrackBox(x: 0.12, y: 0.20, w: 0.30, h: 0.40)
        let vel = MatchMath.leftoverFaceTrackKalmanVel(prev: prevBox, live: liveBox, dt: 0.10)
        ok(abs(vel.px - 0.20) < 1e-9 && abs(vel.py) < 1e-9, "Kalman Vel px")
        let pred = MatchMath.leftoverFaceTrackKalmanPredict(box: liveBox, px: vel.px, py: vel.py, dt: 0.10)
        ok(abs(pred.x - 0.14) < 1e-9, "Kalman Predict")
        let sleepVel = MatchMath.leftoverFaceTrackKalmanVel(prev: prevBox, live: liveBox, dt: 3)
        ok(sleepVel.px == 0 && sleepVel.py == 0, "Kalman Vel Sleep tot")
        let packVel = MatchMath.leftoverFaceTrackPack(
            hold: [liveNew: 0.72],
            pending: [:],
            streak: [:],
            lastHash: [:],
            lastIoU: [:],
            nameHeld: [:],
            nameUntil: [:],
            miss: [:],
            px: [liveNew: 0.20],
            py: [liveNew: -0.10]
        )
        ok(packVel[liveNew]?.px == 0.20 && packVel[liveNew]?.py == -0.10, "FaceTrack Vel Pack")
        let dropVel = MatchMath.leftoverFaceTrackRemintDrop(packVel, remap: [liveNew: liveOld])
        ok(dropVel[liveOld]?.px == 0.20 && dropVel[liveNew] == nil, "FaceTrack Vel RemintDrop")
        let killLine = MatchMath.cameraMutexLine(owner: "helios", pid: 9, now: 1_000, gen: 4)
        ok(MatchMath.cameraMutexStamp(killLine) == 1_000, "Mutex Stamp")
        ok(
            MatchMath.cameraMutexHeartbeatKillPid(pid: 9, live: false, now: 1_001, stamped: 1_000) == 9,
            "Heartbeat tot-PID"
        )
        ok(
            MatchMath.cameraMutexHeartbeatKillPid(pid: 9, live: true, now: 1_020, stamped: 1_000) == 9,
            "Heartbeat hung-live 20 s"
        )
        ok(
            MatchMath.cameraMutexHeartbeatKillPid(pid: 9, live: true, now: 1_005, stamped: 1_000) == nil,
            "Heartbeat live frisch"
        )
        ok(
            MatchMath.cameraMutexHeartbeatKillPid(pid: 9, live: nil, now: 1_007, stamped: 1_000) == 9,
            "Heartbeat 6 s hung"
        )
        ok(
            MatchMath.cameraMutexHeartbeatKillPid(pid: 9, live: nil, now: 1_003, stamped: 1_000) == nil,
            "Heartbeat vor 6 s tot"
        )
        ok(MatchMath.cameraMutexHeartbeatKillAllowed(target: 9, selfPid: 3) == 9, "Kill fremd")
        ok(MatchMath.cameraMutexHeartbeatKillAllowed(target: 3, selfPid: 3) == nil, "Kill self tot")

        ok(!MatchMath.leftoverTriedInserts(unsure: true), "Tried Unsure tot")
        ok(MatchMath.leftoverTriedInserts(unsure: false), "Tried Pin")
        ok(!MatchMath.leftoverTriedInserts(unsure: false, lookaway: true), "Tried Lookaway tot")
        ok(!MatchMath.leftoverPinCounts(unsure: true), "Pin Unsure tot")
        ok(MatchMath.leftoverPinCounts(unsure: false), "Pin zählt")
        ok(MatchMath.leftoverUnsureStreakAdvance(prev: 0, unsure: true) == 1, "Unsure 1")
        ok(MatchMath.leftoverUnsureStreakAdvance(prev: 2, unsure: true) == 3, "Unsure 3")
        ok(MatchMath.leftoverUnsureStreakAdvance(prev: 2, unsure: false) == 0, "Unsure Reset")
        ok(!MatchMath.leftoverUnsureStreakClears(ticks: 2), "Unsure 2 hält")
        ok(MatchMath.leftoverUnsureStreakClears(ticks: 3), "Unsure 3 clear")
        ok(
            MatchMath.leftoverCoastPrintFresh(vec: vecA, stamped: 1_000, now: 1_001).count == 32,
            "Coast TTL frisch"
        )
        ok(
            MatchMath.leftoverCoastPrintFresh(vec: vecA, stamped: 1_000, now: 1_003).isEmpty,
            "Coast TTL 2 s tot"
        )
        ok(
            MatchMath.leftoverCoastPrintFresh(vec: vecA, stamped: nil, now: 1_001).isEmpty,
            "Coast TTL ohne Stamp tot"
        )
        let stamp = MatchMath.leftoverCoastPrintStampMerge(
            stamped: [:], live: [liveOld: vecA], skipPrints: false, now: 1_000
        )
        ok(stamp[liveOld] == 1_000, "Coast Stamp nach Print")
        ok(
            MatchMath.leftoverCoastPrintStampMerge(
                stamped: stamp, live: [liveOld: vecA], skipPrints: true, now: 1_002
            )[liveOld] == 1_000,
            "Coast Stamp skip hält"
        )
        let histAda = MatchMath.leftoverNameHistRemintTrim(
            hist: [liveNew: ["Ada", "Ada", "Ada"]],
            remap: [liveOld: liveNew]
        )
        ok(histAda[liveNew] == ["Ada"], "Name-Hist Remint keep 1")
        ok(
            MatchMath.leftoverNameHistRemintTrim(
                hist: [liveNew: ["Ada", "Ada", "Ada"]],
                remap: [:]
            )[liveNew] == ["Ada", "Ada", "Ada"],
            "Name-Hist ohne Remint hält"
        )
        ok(
            !MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016, minIoU: 0.95, yawAbs: 0.05, stillFor: 0.10),
            "Print bleibt Still 0,10 s"
        )
        ok(
            MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016, minIoU: 0.95, yawAbs: 0.05, stillFor: 0.80),
            "Print skip Still 0,80 s"
        )
        ok(
            MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016, minIoU: 0.95, yawAbs: 0.05),
            "Print skip ohne stillFor"
        )
        ok(MatchMath.leftoverUnsureChip(voted: "Ada", hist: ["Ada"], need: 3, streak: 1) == "?", "Unsure Chip 1")
        ok(MatchMath.leftoverUnsureChip(voted: "Ada", hist: ["Ada"], need: 3, streak: 2) == "??", "Unsure Chip 2")
        ok(
            MatchMath.leftoverOverlayUnsureFirst(voted: "Ada", hist: ["Ada"], need: 3, guest: "Gast 1", streak: 2) == "??",
            "Overlay Streak 2"
        )
        ok(
            MatchMath.leftoverCoastPrintSame(vecA, vecA),
            "Coast Same"
        )
        ok(
            !MatchMath.leftoverCoastPrintSame(vecA, vecB),
            "Coast Diff"
        )
        let restamp = MatchMath.leftoverCoastPrintStampMerge(
            stamped: [liveOld: 1_000],
            live: [liveOld: vecA],
            skipPrints: false,
            now: 1_005,
            stored: [liveOld: vecA]
        )
        ok(restamp[liveOld] == 1_000, "Coast Stamp identisch tot")
        let freshStamp = MatchMath.leftoverCoastPrintStampMerge(
            stamped: [liveOld: 1_000],
            live: [liveOld: vecB],
            skipPrints: false,
            now: 1_005,
            stored: [liveOld: vecA]
        )
        ok(freshStamp[liveOld] == 1_005, "Coast Stamp neuer Print")

        let held = MatchMath.leftoverFaceTrackPredictHeld(
            box: liveBox, px: 0.20, py: 0, dt: 0.10, miss: 1
        )
        ok(abs(held.box.x - 0.14) < 1e-9 && held.px == 0.20, "PredictHeld Miss 1")
        let decayed = MatchMath.leftoverFaceTrackPredictHeld(
            box: liveBox, px: 1, py: 0, dt: 0.10, miss: 2
        )
        ok(abs(decayed.px - 0.82) < 1e-9, "PredictHeld Decay")
        let fromV = MatchMath.leftoverFaceTrackVelFromKalman([liveOld: (vx: 0.20, vy: -0.10)])
        ok(fromV.px[liveOld] == 0.20 && fromV.py[liveOld] == -0.10, "VelFromKalman")
        let merged = MatchMath.leftoverFaceTrackVelMerge(
            vel: [liveOld: (vx: 0, vy: 0)], px: [liveNew: 0.30], py: [liveNew: 0.05]
        )
        ok(merged[liveNew]?.vx == 0.30 && merged[liveNew]?.vy == 0.05, "VelMerge Remint")
        let packCoast = MatchMath.leftoverFaceTrackPack(
            hold: [liveNew: 0.72],
            pending: [:],
            streak: [:],
            lastHash: [:],
            lastIoU: [:],
            nameHeld: [:],
            nameUntil: [:],
            miss: [:],
            px: [liveNew: 0.20],
            coastAt: [liveNew: 1_000],
            unsureTicks: [liveNew: 2]
        )
        ok(packCoast[liveNew]?.coastAt == 1_000 && packCoast[liveNew]?.unsureTicks == 2, "FaceTrack Coast Pack")
        let dropCoast = MatchMath.leftoverFaceTrackRemintDrop(packCoast, remap: [liveNew: liveOld])
        ok(dropCoast[liveOld]?.coastAt == 1_000 && dropCoast[liveNew] == nil, "FaceTrack Coast RemintDrop")
        let encoded = MatchMath.leftoverCoastPrintVecEncode([liveOld: vecA])
        ok(encoded[liveOld.uuidString]?.count == 32, "Coast Vec Encode")
        let aged = MatchMath.leftoverCoastPrintAgeEncode(
            vecs: [liveOld: vecA], stamped: [liveOld: 1_000], now: 1_000.5
        )
        ok(aged[liveOld.uuidString]! > 1.4 && aged[liveOld.uuidString]! <= 2, "Coast Age frisch")
        let restored = MatchMath.leftoverCoastPrintAgeDecode(
            vecs: encoded, remaining: aged, now: 2_000
        )
        ok(restored.print[liveOld]?.count == 32, "Coast Age Decode Vec")
        ok(abs((restored.at[liveOld] ?? 0) - (2_000 - (2 - aged[liveOld.uuidString]!))) < 1e-6, "Coast Age Decode At")
        let stale = MatchMath.leftoverCoastPrintAgeEncode(
            vecs: [liveOld: vecA], stamped: [liveOld: 1_000], now: 1_003
        )
        ok(stale[liveOld.uuidString] == nil, "Coast Age 2 s tot")
        ok(
            MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016, minIoU: 0.95, yawAbs: 0.05, stillFor: 0.90),
            "Print skip still 0,8 s"
        )
        ok(
            !MatchMath.printBudgetSkip(visionMs: 19, dt: 0.016, minIoU: 0.95, yawAbs: 0.05, stillFor: 0.20),
            "Print bleibt still tot"
        )
        let twin = UUID()
        let ada = UUID()
        let skipMix = MatchMath.printBudgetSkipIds(
            ids: [twin, ada],
            lastIoU: [twin: 0.50, ada: 0.95],
            yaw: [twin: 0.20, ada: 0.05],
            printedYaw: [twin: 0.05, ada: 0.05],
            stillFor: [twin: 0.10, ada: 0.90],
            visionMs: 19,
            dt: 0.016,
            continuity: false
        )
        ok(skipMix.contains(ada) && !skipMix.contains(twin), "Print skip Ada still, Twin bleibt")
        let skipNew = MatchMath.printBudgetSkipIds(
            ids: [twin],
            lastIoU: [:],
            yaw: [:],
            printedYaw: [:],
            stillFor: [:],
            visionMs: 19,
            dt: 0.016,
            continuity: false
        )
        ok(skipNew.isEmpty, "Print skip ohne Still tot — Neu-Gesicht druckt")
        ok(
            !MatchMath.printBudgetSkipAll(skipIds: skipMix, liveIds: [twin, ada]),
            "Print skip nicht global bei Mix"
        )
        let skipBoth = MatchMath.printBudgetSkipIds(
            ids: [twin, ada],
            lastIoU: [twin: 0.95, ada: 0.95],
            yaw: [twin: 0.05, ada: 0.05],
            printedYaw: [twin: 0.05, ada: 0.05],
            stillFor: [twin: 0.90, ada: 0.90],
            visionMs: 19,
            dt: 0.016,
            continuity: false
        )
        ok(MatchMath.printBudgetSkipAll(skipIds: skipBoth, liveIds: [twin, ada]), "Print skip beide still")
        let adaBox = FaceBox(x: 0.10, y: 0.10, width: 0.20, height: 0.20)
        let twinBox = FaceBox(x: 0.60, y: 0.10, width: 0.20, height: 0.20)
        ok(
            MatchMath.leftoverPrintSkipHits(face: adaBox, skipBoxes: [adaBox]),
            "Skip-Box Ada trifft"
        )
        ok(
            !MatchMath.leftoverPrintSkipHits(face: twinBox, skipBoxes: [adaBox]),
            "Skip-Box Twin tot"
        )
        let skipBoxes = MatchMath.leftoverPrintSkipBoxes(
            tracks: [(id: ada, x: 0.10, y: 0.10, w: 0.20, h: 0.20), (id: twin, x: 0.60, y: 0.10, w: 0.20, h: 0.20)],
            skipIds: [ada]
        )
        ok(skipBoxes.count == 1 && abs(skipBoxes[0].x - 0.10) < 1e-9, "Skip-Boxes nur Ada")
        ok(
            MatchMath.leftoverPrintYawMerge(
                printed: [ada: 0.05],
                live: [ada: 0.06, twin: 0.30],
                skipPrints: false,
                printedIds: [twin]
            )[ada] == 0.05,
            "Yaw Merge Ada ohne Print hält"
        )
        ok(
            abs((MatchMath.leftoverPrintYawMerge(
                printed: [twin: 0.05],
                live: [twin: 0.30],
                skipPrints: false,
                printedIds: [twin]
            )[twin] ?? -1) - 0.30) < 1e-9,
            "Yaw Merge Twin mit Print"
        )
        ok(
            abs((MatchMath.leftoverPrintBudgetYawDeltaOf(printed: [ada: 0.05], live: 0.05, id: ada) ?? -1)) < 1e-9,
            "Yaw-Δ Ada 0"
        )
        ok(MatchMath.leftoverPrintSkipChip(skipped: true) == "still", "Skip Chip still")
        ok(MatchMath.leftoverPrintSkipChip(skipped: false) == nil, "Skip Chip tot")
        ok(
            MatchMath.leftoverPrintSkipSummary(still: ["Ada"], printing: ["Twin"]) == "Ada still · Twin print",
            "Skip Summary Mix"
        )
        ok(
            MatchMath.leftoverPrintSkipSummary(still: ["Ada"], printing: []) == "Ada still",
            "Skip Summary nur still"
        )
        let roiNeed = MatchMath.liveRoiTracks(
            tracks: [(id: ada, x: 0.10, y: 0.10, w: 0.20, h: 0.20), (id: twin, x: 0.60, y: 0.10, w: 0.20, h: 0.20)],
            skipIds: [ada]
        )
        ok(roiNeed.count == 1 && abs(roiNeed[0].x - 0.60) < 1e-9, "ROI nur Twin — Ada still raus")
        let roiAllSkip = MatchMath.liveRoiTracks(
            tracks: [(id: ada, x: 0.10, y: 0.10, w: 0.20, h: 0.20)],
            skipIds: [ada]
        )
        ok(roiAllSkip.count == 1 && abs(roiAllSkip[0].x - 0.10) < 1e-9, "ROI alle skip = Kalman bleibt")
        let roiBox = MatchMath.liveRoiBox(kalman: roiNeed, imageW: 1280, imageH: 720)
        ok(roiBox != nil, "ROI Twin Crop lebt")
        ok(
            MatchMath.leftoverEnrollSlotChip(haveFrontal: true, haveLeft: true, haveRight: false) == "enroll ¾R",
            "Enroll ¾R fehlt"
        )
        ok(
            MatchMath.leftoverEnrollSlotChip(haveFrontal: true, haveLeft: true, haveRight: true) == nil,
            "Enroll voll tot"
        )
        ok(
            MatchMath.leftoverEnrollSlotHave(yaw: -0.40, haveFrontal: true, haveLeft: false, haveRight: false).left,
            "Enroll ¾L aus Yaw"
        )
        ok(
            MatchMath.leftoverEnrollSlotHave(yaw: 0.40, haveFrontal: true, haveLeft: false, haveRight: false).right,
            "Enroll ¾R aus Yaw"
        )
        let trackId = UUID()
        let packed = MatchMath.leftoverFaceTrackPack(
            hold: [trackId: 0.80],
            pending: [:],
            streak: [:],
            lastHash: [:],
            lastIoU: [:],
            nameHeld: [trackId: "Ada"],
            nameUntil: [trackId: 1_010],
            miss: [:]
        )
        ok(MatchMath.leftoverFaceTrackLookup(tracks: packed, id: trackId)?.nameHeld == "Ada", "FaceTrack Lookup")
        ok(MatchMath.leftoverFaceTrackHolds(track: packed[trackId], now: 1_005), "FaceTrack Hold")
        ok(!MatchMath.leftoverFaceTrackHolds(track: packed[trackId], now: 1_011), "FaceTrack TTL tot")
        ok(MatchMath.leftoverFaceTrackHoldChip(track: packed[trackId], now: 1_005) == "hold", "FaceTrack Chip")
        ok(MatchMath.leftoverPrintPruneDup(cosine: 0.99), "Prune 0,99")
        ok(!MatchMath.leftoverPrintPruneDup(cosine: 0.90), "Prune 0,90 tot")
        ok(MatchMath.leftoverPairCommitWALFresh(stamped: 1_000, now: 1_001), "WAL frisch")
        ok(!MatchMath.leftoverPairCommitWALFresh(stamped: 1_000, now: 1_003), "WAL 2 s tot")
        ok(MatchMath.leftoverPairCommitWALStamp(prev: nil, commit: true, now: 5) == 5, "WAL Stamp")
        ok(
            MatchMath.leftoverHashTwinLeft(
                x: 0.50, others: [0.50], yawAbs: 0.20, otherYaws: [0.20],
                tieKey: "aaa", otherTieKeys: ["bbb"]
            ),
            "Twin Yaw-Tie Key Exact"
        )
        ok(
            !MatchMath.leftoverHashTwinLeft(
                x: 0.50, others: [0.50], yawAbs: 0.20, otherYaws: [0.20],
                tieKey: "bbb", otherTieKeys: ["aaa"]
            ),
            "Twin Yaw-Tie Key Occupied"
        )
        let twinTieKeyL = MatchMath.leftoverHashTwinOccupied(
            occupied: ["5.5.4.6"],
            hash: "5.5.4.6",
            x: 0.50,
            others: [(hash: "5.5.4.6", x: 0.50)],
            yawAbs: 0.20,
            otherYaws: [0.20],
            tieKey: "aaa",
            otherTieKeys: ["bbb"]
        )
        ok(twinTieKeyL.isEmpty, "Occupied tieKey Exact frei")
        let twinTieKeyR = MatchMath.leftoverHashTwinOccupied(
            occupied: ["5.5.4.6"],
            hash: "5.5.4.6",
            x: 0.50,
            others: [(hash: "5.5.4.6", x: 0.50)],
            yawAbs: 0.20,
            otherYaws: [0.20],
            tieKey: "bbb",
            otherTieKeys: ["aaa"]
        )
        ok(twinTieKeyR == ["5.5.4.6"], "Occupied tieKey Occupied")
        let aId = UUID(uuidString: "00000000-0000-0000-0000-00000000000a")!
        let bId = UUID(uuidString: "00000000-0000-0000-0000-00000000000b")!
        let occRows = MatchMath.leftoverOccupiedOtherRows(
            live: [(id: aId, hash: "5.5.4.6", x: 0.20)],
            stored: [(id: bId, hash: "5.5.4.6", x: 0.70)],
            except: aId
        )
        ok(occRows.count == 1 && occRows[0].key == bId.uuidString, "OtherRows UUID")
        let ones = Array(repeating: 1.0, count: 32)
        var near = ones
        near[0] = 0.999
        let pruned = MatchMath.leftoverPrintBankPrune([
            (vec: ones, w: 1),
            (vec: near, w: 1)
        ])
        ok(pruned.count == 1, "Print-Bank Prune Burst")
        let wal = MatchMath.leftoverPairCommitWALBytes(pairs: ["a": "b"])
        ok(wal != nil, "WAL Bytes")
        ok(MatchMath.leftoverPairCommitWALName() == "gallery.pair.wal", "WAL Name")
        ok(
            MatchMath.leftoverPairCommitWALRestore(
                data: wal, stamped: 1_000, now: 1_001
            )?["a"] == "b",
            "WAL Restore frisch"
        )
        ok(
            MatchMath.leftoverPairCommitWALRestore(
                data: wal, stamped: 1_000, now: 1_003
            ) == nil,
            "WAL Restore tot"
        )
        ok(MatchMath.cameraMutexHeartbeatKillSignal(termSentAt: nil, now: 10) == 15, "Kill SIGTERM zuerst")
        ok(MatchMath.cameraMutexHeartbeatKillSignal(termSentAt: 10, now: 12.1) == 9, "Kill SIGKILL nach 2 s")
        ok(MatchMath.cameraMutexHeartbeatKillChip(signal: 15) == "SIGTERM", "Chip TERM")
        let trackHold = MatchMath.leftoverFaceTrackStoreGet(
            tracks: packed, id: trackId, now: 1_005
        )
        ok(trackHold?.nameHeld == "Ada", "FaceTrack Store Get")
        ok(MatchMath.leftoverFaceTrackStoreGet(tracks: packed, id: trackId, now: 1_011) == nil, "FaceTrack Store TTL")
        ok(MatchMath.leftoverFaceTrackStoreName(tracks: packed, id: trackId, now: 1_005) == "Ada", "FaceTrack Store Name")
        ok(MatchMath.leftoverFaceTrackStoreName(tracks: packed, id: trackId, now: 1_011) == nil, "Store Name TTL tot")
        ok(
            MatchMath.leftoverFaceTrackHolds(
                track: MatchMath.FaceTrack(
                    hold: 0.80, nameHeld: "Ada", nameUntil: 1_001, poseAt: 1_000
                ),
                now: 1_002
            ),
            "Store poseAt hält nach Jump-Lock"
        )
        ok(
            !MatchMath.leftoverFaceTrackHolds(
                track: MatchMath.FaceTrack(
                    hold: 0.80, nameHeld: "Ada", nameUntil: 9_999, poseAt: 1_000
                ),
                now: 1_005
            ),
            "Store poseAt TTL 4 s"
        )
        ok(
            MatchMath.leftoverFaceTrackStoreNameOf(
                hold: 0.80, nameHeld: "Ada", nameUntil: 1_001, now: 1_002, poseAt: 1_000
            ) == "Ada",
            "StoreNameOf poseAt"
        )
        ok(
            MatchMath.leftoverFaceTrackStoreNameOf(
                hold: 0.80, nameHeld: "Ada", nameUntil: 0, now: 1_000
            ) == "Ada",
            "StoreNameOf ohne Until"
        )
        ok(
            MatchMath.leftoverOverlayGuestOf(
                storeName: "Ada", voted: nil, hist: [], need: 3, guest: "Gast 1"
            ) == "Ada",
            "Overlay StoreName vor Gast"
        )
        ok(
            MatchMath.leftoverOverlayGuestOf(
                storeName: nil, voted: nil, hist: [], need: 3, guest: "Gast 1"
            ) == "?",
            "Overlay ohne Store ?"
        )
        ok(MatchMath.leftoverOverlayStickyName(held: "Ada", streak: 0) == "Ada", "Sticky Ada")
        ok(MatchMath.leftoverOverlayStickyName(held: "Ada", streak: 2) == "Ada?", "Sticky Ada?")
        ok(
            MatchMath.leftoverOverlayGuestOf(
                storeName: nil, voted: nil, hist: ["Ada"], need: 3, guest: "Gast 1", streak: 0, sticky: "Ada"
            ) == "Ada",
            "Guest Sticky vor Unsure"
        )
        ok(
            MatchMath.leftoverOverlayGuestOf(
                storeName: nil, voted: nil, hist: ["Ada"], need: 3, guest: "Gast 1", streak: 0
            ) == "Ada",
            "Guest Hist keep 1 nach Remint"
        )
        ok(
            MatchMath.leftoverOverlayGuestOf(
                storeName: nil, voted: nil, hist: ["Ada"], need: 3, guest: "Gast 1", streak: 2
            ) == "Ada?",
            "Guest Hist Streak Ada?"
        )
        ok(MatchMath.leftoverOverlayGuestStickyOf(sticky: nil, hist: ["Ada"]) == "Ada", "StickyOf Hist")
        ok(MatchMath.leftoverOverlayGuestStickyOf(sticky: "Ada", hist: ["Twin"]) == "Ada", "StickyOf Held")
        let coastId = UUID(), deadId = UUID()
        let coast = MatchMath.leftoverNameLockHeldCoast(
            held: [coastId: "Ada", deadId: "Bert"],
            live: [coastId],
            locked: [],
            ghosts: []
        )
        ok(coast[coastId] == "Ada" && coast[deadId] == nil, "Held Coast nach TTL live")
        ok(
            MatchMath.leftoverNameLockHeldCoast(
                held: [coastId: "Ada"], live: [], locked: [], ghosts: []
            ).isEmpty,
            "Held Coast leer tot"
        )
        ok(
            MatchMath.leftoverNameLockHeldCoast(
                held: [coastId: "Ada"], live: [], locked: [], ghosts: [coastId]
            )[coastId] == "Ada",
            "Held Coast Ghost"
        )
        let holdBinId = UUID()
        let holdBinKey = MatchMath.leftoverHoldKey(id: holdBinId, bin: 1)
        ok(
            abs(MatchMath.leftoverHoldMaxOf(frontal: 0.80, bins: [:], id: holdBinId) - 0.80) < 1e-9,
            "HoldMax Frontal"
        )
        ok(
            abs(MatchMath.leftoverHoldMaxOf(frontal: nil, bins: [holdBinKey: 0.77], id: holdBinId) - 0.77) < 1e-9,
            "HoldMax ¾ Bin"
        )
        ok(
            MatchMath.leftoverHasHoldOf(
                hold: 0.80, bins: [:], id: holdBinId, poseAt: 1_000, now: 1_002
            ),
            "HasHold poseAt"
        )
        ok(
            !MatchMath.leftoverHasHoldOf(
                hold: 0.80, bins: [:], id: holdBinId, poseAt: 1_000, now: 1_005
            ),
            "HasHold TTL tot"
        )
        ok(
            MatchMath.leftoverHasHoldOf(
                hold: nil, bins: [holdBinKey: 0.77], id: holdBinId, poseAt: 1_000, now: 1_002
            ),
            "HasHold Bins"
        )
        ok(
            !MatchMath.leftoverHasHoldOf(
                hold: nil, bins: [:], id: holdBinId, poseAt: 1_000, now: 1_002
            ),
            "HasHold leer"
        )
        ok(MatchMath.leftoverStoreChip(name: "Ada") == "store Ada", "Store Chip")
        ok(MatchMath.leftoverStoreChip(name: nil) == nil, "Store Chip tot")
        ok(
            MatchMath.leftoverFaceTrackStoreNameOf(
                hold: 0.77, nameHeld: "Ada", nameUntil: 1_001, now: 1_002, poseAt: 1_000
            ) == "Ada",
            "StoreName ¾"
        )
        ok(MatchMath.cameraMutexTermBlocksWrite(signal: 15, pidLive: true), "TERM live blockt Write")
        ok(!MatchMath.cameraMutexTermBlocksWrite(signal: 15, pidLive: false), "TERM tot Write")
        ok(!MatchMath.cameraMutexTermBlocksWrite(signal: 9, pidLive: true), "KILL Write")
        ok(MatchMath.cameraMutexTermChip(signal: 15, remain: 1.4) == "TERM 1,4", "Chip TERM 1,4")
        ok(MatchMath.cameraMutexClaimChip(holder: "aegis", yielded: false, term: "TERM 1,4") == "aegis · TERM 1,4", "Claim TERM")
        let disk = MatchMath.leftoverPairCommitWALRestoreDisk(data: wal)
        ok(disk?["a"] == "b", "WAL Restore Disk")
        ok(
            MatchMath.leftoverPairCommitWALApply(
                gallery: nil, wal: ["x": "y"], galleryMtime: 10, walMtime: 12, now: 20
            )?["x"] == "y",
            "WAL Apply gallery leer"
        )
        ok(
            MatchMath.leftoverPairCommitWALApply(
                gallery: ["g": "old"], wal: ["w": "new"], galleryMtime: 10, walMtime: 12, now: 20
            )?["w"] == "new",
            "WAL Apply neuer als gallery"
        )
        ok(
            MatchMath.leftoverPairCommitWALApply(
                gallery: ["g": "ok"], wal: ["w": "stale"], galleryMtime: 20, walMtime: 12, now: 21
            )?["g"] == "ok",
            "WAL Apply gallery neuer"
        )
        ok(
            MatchMath.leftoverPairCommitWALApply(
                gallery: nil, wal: ["x": "y"], galleryMtime: nil, walMtime: 1, now: 90_000
            ) == nil,
            "WAL Apply 24 h tot"
        )
        ok(MatchMath.leftoverPairCommitWALShouldClear(saved: true), "WAL Clear nach Save")
        ok(!MatchMath.leftoverPairCommitWALShouldClear(saved: false), "WAL Clear ohne Save tot")
        ok(MatchMath.leftoverPairCommitWALAgeOk(age: 10), "WAL Age 10 s")
        ok(!MatchMath.leftoverPairCommitWALAgeOk(age: 90_000), "WAL Age 24 h tot")

        ok(MatchMath.leftoverOverlayPeakIsUnsure("?"), "Peak Unsure ?")
        ok(MatchMath.leftoverOverlayPeakIsUnsure("??"), "Peak Unsure ??")
        ok(MatchMath.leftoverOverlayPeakIsUnsure("Gast 1"), "Peak Unsure Gast")
        ok(!MatchMath.leftoverOverlayPeakIsUnsure("Ada"), "Peak Ada tot")
        ok(!MatchMath.leftoverOverlayPeakIsUnsure("Ada?"), "Peak Ada? tot")
        ok(MatchMath.leftoverOverlayPeakBare("Ada?") == "Ada", "Peak Bare Ada?")
        ok(MatchMath.leftoverOverlayPeakBare("?") == "?", "Peak Bare ?")
        let pg0 = MatchMath.leftoverOverlayPeakGuest(guest: "Ada", held: nil, remaining: 0)
        ok(pg0.name == "Ada" && pg0.remaining == 3, "Peak Guest Ada reset")
        let pg1 = MatchMath.leftoverOverlayPeakGuest(guest: "?", held: "Ada", remaining: 3)
        ok(pg1.name == "Ada" && pg1.remaining == 2, "Peak Guest hält Ada")
        let pg2 = MatchMath.leftoverOverlayPeakGuest(guest: "?", held: "Ada", remaining: 1)
        ok(pg2.name == "Ada" && pg2.remaining == 0, "Peak Guest last")
        let pg3 = MatchMath.leftoverOverlayPeakGuest(guest: "?", held: "Ada", remaining: 0)
        ok(pg3.name == "?" && pg3.remaining == 0, "Peak Guest tot")
        let pid = UUID()
        let dead = UUID()
        let adv = MatchMath.leftoverOverlayPeakAdvance(
            guest: [pid: "?"],
            held: [pid: "Ada", dead: "Bert"],
            remain: [pid: 3, dead: 3],
            live: [pid]
        )
        ok(adv.held[pid] == "Ada" && adv.remain[pid] == 2, "Peak Advance Ada")
        ok(adv.held[dead] == nil, "Peak Advance tot-UUID")
        let adv2 = MatchMath.leftoverOverlayPeakAdvance(
            guest: [pid: "Ada"],
            held: [:],
            remain: [:],
            live: [pid]
        )
        ok(adv2.held[pid] == "Ada" && adv2.remain[pid] == 3, "Peak Advance live reset")
        ok(MatchMath.leftoverOverlayPeakName(guest: "?", held: "Ada") == "Ada", "Peak Name hält")
        ok(MatchMath.leftoverOverlayPeakName(guest: "Ada", held: "Bert") == "Ada", "Peak Name live")
        ok(MatchMath.leftoverOverlayPeakName(guest: "?", held: nil) == "?", "Peak Name tot")
        ok(MatchMath.leftoverOverlayPeakName(guest: "??", held: "Ada") == "Ada", "Peak Name ??")
        let fromId = UUID(), toId = UUID()
        let peakMoved = MatchMath.leftoverAssignAtomic(hold: [fromId: "Ada"], from: fromId, to: toId)
        ok(peakMoved[toId] == "Ada" && peakMoved[fromId] == nil, "Peak Assign remint")
        let remainMoved = MatchMath.leftoverAssignAtomic(hold: [fromId: 2], from: fromId, to: toId)
        ok(remainMoved[toId] == 2 && remainMoved[fromId] == nil, "Peak Remain remint")
        let iouHit = MatchMath.leftoverBoxIoU(
            ax: 0.10, ay: 0.10, aw: 0.20, ah: 0.20,
            bx: 0.12, by: 0.12, bw: 0.20, bh: 0.20
        )
        ok(iouHit > 0.40, "Box IoU Overlap")
        ok(
            MatchMath.leftoverBoxIoU(
                ax: 0, ay: 0, aw: 0.10, ah: 0.10,
                bx: 0.90, by: 0.90, bw: 0.10, bh: 0.10
            ) < 1e-9,
            "Box IoU tot"
        )
        let oldPeak = UUID(), livePeak = UUID(), twinPeak = UUID()
        let storedPeak = MatchMath.leftoverOverlayPeakStoredBoxes(
            streak: [(id: oldPeak, x: 0.20, y: 0.20, w: 0.20, h: 0.20)],
            kalman: [(id: oldPeak, x: 0.21, y: 0.21, w: 0.20, h: 0.20)]
        )
        ok(storedPeak.count == 1 && storedPeak[0].id == oldPeak, "Peak Stored Streak vor Kalman")
        let adopted = MatchMath.leftoverOverlayPeakIoUAdopt(
            held: [oldPeak: "Ada"],
            remain: [oldPeak: 3],
            live: [(id: livePeak, x: 0.21, y: 0.21, w: 0.20, h: 0.20)],
            stored: storedPeak
        )
        ok(adopted.held[livePeak] == "Ada" && adopted.held[oldPeak] == nil, "Peak IoU-Adopt Ada")
        ok(adopted.remain[livePeak] == 3 && adopted.remain[oldPeak] == nil, "Peak IoU-Adopt Remain")
        let tied = MatchMath.leftoverOverlayPeakIoUAdopt(
            held: [oldPeak: "Ada"],
            remain: [oldPeak: 2],
            live: [
                (id: livePeak, x: 0.21, y: 0.21, w: 0.20, h: 0.20),
                (id: twinPeak, x: 0.22, y: 0.22, w: 0.20, h: 0.20)
            ],
            stored: [(id: oldPeak, x: 0.20, y: 0.20, w: 0.20, h: 0.20)]
        )
        ok(tied.held[oldPeak] == "Ada" && tied.held[livePeak] == nil, "Peak IoU-Adopt Twin tot")
        let liveKeep = MatchMath.leftoverOverlayPeakIoUAdopt(
            held: [livePeak: "Ada"],
            remain: [livePeak: 2],
            live: [(id: livePeak, x: 0.20, y: 0.20, w: 0.20, h: 0.20)],
            stored: [(id: livePeak, x: 0.20, y: 0.20, w: 0.20, h: 0.20)]
        )
        ok(liveKeep.held[livePeak] == "Ada", "Peak IoU-Adopt Live hält")
        near(MatchMath.leftoverOverlayPeakIoUFloor(fps: 8), 0.32, 0.001, "IoU-Floor 8 fps")
        near(MatchMath.leftoverOverlayPeakIoUFloor(fps: 60), 0.50, 0.001, "IoU-Floor 60 fps")
        near(MatchMath.leftoverOverlayPeakIoUFloorDt(0.125), 0.32, 0.001, "IoU-Floor dt 8 fps")
        near(MatchMath.leftoverOverlayPeakIoUFloor(fps: 0), 0.40, 0.001, "IoU-Floor tot → 0,40")
        let oldLock = UUID(), liveLock = UUID(), twinLock = UUID()
        let lockAdopt = MatchMath.leftoverNameLockHeldIoUAdopt(
            held: [oldLock: "Ada"],
            until: [oldLock: 10],
            live: [(id: liveLock, x: 0.21, y: 0.21, w: 0.20, h: 0.20)],
            stored: [(id: oldLock, x: 0.20, y: 0.20, w: 0.20, h: 0.20)],
            floor: MatchMath.leftoverOverlayPeakIoUFloor(fps: 8)
        )
        ok(lockAdopt.held[liveLock] == "Ada" && lockAdopt.held[oldLock] == nil, "NameLock IoU-Adopt Ada")
        ok(lockAdopt.until[liveLock] == 10 && lockAdopt.until[oldLock] == nil, "NameLock IoU-Adopt Until")
        let lockTied = MatchMath.leftoverNameLockHeldIoUAdopt(
            held: [oldLock: "Ada"],
            until: [oldLock: 10],
            live: [
                (id: liveLock, x: 0.21, y: 0.21, w: 0.20, h: 0.20),
                (id: twinLock, x: 0.22, y: 0.22, w: 0.20, h: 0.20)
            ],
            stored: [(id: oldLock, x: 0.20, y: 0.20, w: 0.20, h: 0.20)]
        )
        ok(lockTied.held[oldLock] == "Ada" && lockTied.held[liveLock] == nil, "NameLock IoU-Adopt Twin tot")
        let lockEmpty = MatchMath.leftoverNameLockHeldIoUAdopt(
            held: [oldLock: ""],
            until: [:],
            live: [(id: liveLock, x: 0.21, y: 0.21, w: 0.20, h: 0.20)],
            stored: [(id: oldLock, x: 0.20, y: 0.20, w: 0.20, h: 0.20)]
        )
        ok(lockEmpty.held[oldLock] == "" && lockEmpty.held[liveLock] == nil, "NameLock IoU-Adopt leer tot")
        let lockLive = MatchMath.leftoverNameLockHeldIoUAdopt(
            held: [liveLock: "Ada"],
            until: [liveLock: 9],
            live: [(id: liveLock, x: 0.20, y: 0.20, w: 0.20, h: 0.20)],
            stored: [(id: liveLock, x: 0.20, y: 0.20, w: 0.20, h: 0.20)]
        )
        ok(lockLive.held[liveLock] == "Ada", "NameLock IoU-Adopt Live hält")
        ok(MatchMath.leftoverNameLockAdoptChip(did: true, name: "Ada") == "iou Ada", "NameLock Adopt Chip")
        ok(MatchMath.leftoverNameLockAdoptChip(did: false, name: "Ada") == nil, "NameLock Adopt Chip tot")
        near(MatchMath.leftoverOverlayPeakIoUFloorArea(area: 0.01, fps: 8), 0.32, 0.001, "IoU-Area weit 8 fps")
        near(MatchMath.leftoverOverlayPeakIoUFloorArea(area: 0.215, fps: 8), 0.46, 0.001, "IoU-Area nah 8 fps")
        near(MatchMath.leftoverOverlayPeakIoUFloorArea(area: 0.215, fps: 60), 0.64, 0.001, "IoU-Area nah 60 fps")
        near(MatchMath.leftoverOverlayPeakIoUFloorBoxes(live: [(w: 0.50, h: 0.50)], dt: 0.125), 0.46, 0.02, "IoU-Boxes nah")
        let pts1 = MatchMath.ptsWallStamp(pts: 1.125, wall: 100.125, prevPts: 1.000, prevWall: 100.000)
        near(pts1, 100.125, 1e-9, "PTS-Wall +0,125")
        let ptsJump = MatchMath.ptsWallStamp(pts: 4.0, wall: 101.0, prevPts: 1.000, prevWall: 100.000)
        near(ptsJump, 101.0, 1e-9, "PTS-Wall Sprung")
        let fillId = UUID()
        let filled = MatchMath.leftoverNameLockUntilFillHeld(
            held: [fillId: "Ada"],
            until: [:],
            now: 50,
            arm: 1.20
        )
        near(filled[fillId] ?? 0, 51.20, 0.01, "Until-Fill Ada")
        let keepId = UUID()
        let kept = MatchMath.leftoverNameLockUntilFillHeld(
            held: [keepId: "Ada"],
            until: [keepId: 90],
            now: 50,
            arm: 1.20
        )
        near(kept[keepId] ?? 0, 90, 0.01, "Until-Fill hält")
        let emptyFill = MatchMath.leftoverNameLockUntilFillHeld(
            held: [fillId: ""],
            until: [:],
            now: 50,
            arm: 1.20
        )
        ok(emptyFill[fillId] == nil, "Until-Fill leer tot")

        if fails > 0 {
            fputs("\(fails) MatchMathTests fehlgeschlagen\n", stderr)
            exit(1)
        }
        print("MatchMathTests OK")
    }
}
