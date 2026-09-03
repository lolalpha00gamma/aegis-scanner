import CoreGraphics
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
                candidates: [(0, 0.40, 0.75), (1, 0.40, 0.70)],
                sharpness: [0: 0.20, 1: 0.20],
                sameSlot: [:]
            ) == 0,
            "ohne Slot-Hint bleibt höherer Print"
        )
        ok(
            MatchMath.leftoverPick(
                candidates: [(0, 0.40, 0.75), (1, 0.40, 0.70)],
                sharpness: [0: 0.20, 1: 0.20],
                sameSlot: [0: false, 1: false]
            ) == nil,
            "sameSlot gesetzt, kein Slot-Treffer → ¾-Ghost pinnt nicht"
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
        ok(MatchMath.gallerySchema == 2, "gallery.json Schema 2")

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
            MatchMath.geoVetoYawSkipped(geoAgrees: false, geoMix: 15, printPercent: 82, yawAbs: 0.30),
            "Yaw-Skip sichtbar wenn ¾ ein Veto verhindert"
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
        ok(MatchMath.restoreNeedsConfirm(ageDays: 1, schemaVersion: 1, printRevision: MatchMath.printRevision), "Schema <2")
        ok(MatchMath.restoreNote(ageDays: 1, schemaVersion: nil, printRevision: nil).contains("<2"), "Schema <2 erwähnt")
        ok(MatchMath.boxEuroResetOnHysteresis(iou: 0.50, cosine: 0.90), "Print-Pin gewinnt gegen Hysterese-Box")
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
        let greedyTrap = MatchMath.leftoverAssign(scores: [
            [0.70, 0.68],
            [0.69, 0.40]
        ])
        ok(greedyTrap[0] == 1 && greedyTrap[1] == 0, "2-opt schlägt greedy 0,70+0,40")
        ok(MatchMath.leftoverAssign(scores: []).isEmpty, "Assign leer")
        ok(MatchMath.leftoverAdoptNeed(dt: 0.125) == 4, "8 fps leftover 4 Frames")
        ok(MatchMath.leftoverAdoptNeed(dt: 0.016) == 24, "24 fps leftover ~380 ms")
        ok(MatchMath.leftoverAdoptNeed(dt: 0) == 4, "ohne dt Continuity-Takt")
        ok(!MatchMath.leftoverAdoptReady(streak: 3, need: 4), "3/4 noch nicht")
        ok(MatchMath.leftoverAdoptReady(streak: 4, need: 4), "4/4 Adopt")
        ok(MatchMath.leftoverStreakLabel(streak: 1, need: 4) == "1/4", "Streak Overlay")
        ok(MatchMath.leftoverStreakLabel(streak: 4, need: 4) == nil, "ready kein Overlay")
        ok(MatchMath.leftoverSameTarget(iou: 0.50), "gleiche Box Streak")
        ok(!MatchMath.leftoverSameTarget(iou: 0.10), "andere Box Reset")
        ok(MatchMath.leftoverStreakAdvance(prev: 2, sameTarget: true) == 3, "gleiche Box +1")
        ok(MatchMath.leftoverStreakAdvance(prev: 2, sameTarget: false) == 1, "andere Box 1")
        ok(MatchMath.motionBlurDrops(aligned: true, sharpness: 0.08), "Deskew-Blur drop")
        ok(!MatchMath.motionBlurDrops(aligned: true, sharpness: 0.18), "scharf nach Roll bleibt")
        ok(!MatchMath.motionBlurDrops(aligned: false, sharpness: 0.08), "ohne Align kein extra Drop")
        near(MatchMath.swapFlashHold(), 0.45, 0.001, "Swap-Blitz 0,45 s")

        if fails > 0 {
            fputs("\(fails) MatchMathTests fehlgeschlagen\n", stderr)
            exit(1)
        }
        print("MatchMathTests OK")
    }
}
