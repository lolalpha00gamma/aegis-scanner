import CoreGraphics
import Foundation

/// Schwellen und Kurven an einer Stelle. Engine, Labor, Tests, Slider.
enum MatchMath {
    static let embedMargin = 12.0
    static let landmarkMargin = 14.0
    static let zFloor = 1.5
    static let printSigmoidMid = 0.55
    static let printSigmoidSlope = 14.0
    static let printRevision = "VNGenerateFacePrint/1"
    static let familyCosineLo = 0.80
    static let familyFloorBump = 4.0
    static let rejectCosine = 0.90
    static let sharpnessFloor = 0.12
    /// Continuity/Desk-View: Laplacian oft 0,10–0,14. Nur dort 0,08.
    static let continuitySharpnessFloor = 0.08
    /// Live-Box: IoU unter dem Wert hält die alte Kiste ein Frame.
    static let boxJumpIoU = 0.35
    /// Burst-/Tile-Kopie, nicht neue Pose.
    static let ingestDuplicateCosine = 0.95
    /// Live-Track nach Verlust: unter 0,80 erben Geschwister die UUID.
    static let pinPrintCosine = 0.80
    /// Leftover-Pin: enrolled Track ohne IoU-Treffer darf die ID nicht unter diesem Wert stehlen.
    static let leftoverIoU = 0.28
    /// Genuine-Print oft 0,62–0,85. 0,80 hat leftover tot gemacht. 0,72 hat 0,62–0,71 noch fallen lassen.
    static let leftoverPrintCosine = 0.64
    /// Scharfer Genuine. Profil braucht mehr — sonst Twin im ¾ tauft.
    static let leftoverPrintGenuine = 0.62
    static let leftoverPrintProfile = 0.70
    /// 0,28 rad (~16°) war Lookaway UND Profil-Floor — leichte Drehung 0,62 tot.
    static let leftoverPrintProfileYaw = 0.45
    static let leftoverPrintSharp = 0.22
    /// Enrolled-Track klebt nur bei echter Überlappung. 0,12 hat Nachbarn die UUID geklaut.
    static let trackPinIoU = 0.28
    /// Overlay „andere Person“ erst unter diesem Cosine (Genuine typisch 0,62–0,92).
    static let hintCosineFloor = 0.50
    /// Live-Centroid: 72 % Frontal-Mittel, 28 % alle Refs.
    static let liveCentroidFront = 0.72
    static let liveBlendBuiltIn = 0.35
    static let liveBlendContinuity = 0.20
    /// Burst derselben Pose in der Galerie, nicht zweite Aufnahme.
    static let pruneCosine = 0.98
    static let nameVoteFrames = 5
    static let liveScoreAlpha = 0.35
    /// Ein Look=Print-Tick tauft nicht. Zwei agreeing Stimmen. Geschwister: fünf.
    static let nameAgreeNeed = 2
    static let nameFamilyNeed = 5
    /// 8 fps × 2 = 0,25 s ist zu knapp gegen Rauschen. Zeit, nicht nur Ticks.
    static let nameAgreeSec: TimeInterval = 0.28
    static let nameFamilySec: TimeInterval = 0.80

    static func nameAgreeNeed(family: Bool) -> Int {
        family ? nameFamilyNeed : nameAgreeNeed
    }

    /// dt aus dem Live-Takt. 8 fps: Fremde 3, Familie 7. 24 fps: nicht nach 80 ms taufen.
    static func nameAgreeNeed(family: Bool, dt: TimeInterval) -> Int {
        let sec = family ? nameFamilySec : nameAgreeSec
        let step = max(0.04, min(0.20, dt <= 0 ? 0.125 : dt))
        let frames = Int(ceil(sec / step))
        let lo = family ? nameFamilyNeed : nameAgreeNeed
        let hi = family ? 16 : 10
        return max(lo, min(hi, frames))
    }

    /// Look-Scores enger als 8 Punkte: Geschwister oder Unsicher — länger halten.
    /// Ohne pairCosine bleibt das Look-Delta (Tests). Mit Cosine: nur echte Nähe.
    static func nameClosePair(best: Double, second: Double?, pairCosine: Double? = nil) -> Bool {
        guard let second else { return false }
        if best - second >= 8 { return false }
        if let pairCosine { return pairCosine >= familyCosineLo }
        return true
    }

    /// Leere Look≠Print-Tokens dürfen die Familien-Taufe nicht aushungern.
    static func nameHistCap(need: Int) -> Int {
        max(nameVoteFrames, need + 3)
    }
    /// Rename-Confirm klebt sonst an der nächsten Person.
    static let renameConfirmHold: TimeInterval = 8
    /// Starker Print ist Identität. Geo unter 35 darf ihn nicht auf 60 kappen.
    static let strongPrintFloor = 84.0
    /// Ab diesem Print-Wert vetoiert Kleidung/Haar nicht mehr. lookOf kappt ≥ 80 nie — Veto muss dasselbe tun.
    static let geoVetoSkipPrint = 80.0
    /// ¾/Profil: Maße vs. Frontal-Centroid lügen. Print ≥ 80 nicht vetoen.
    static let geoVetoYawSkip = 0.28
    static let geoVetoYawPrint = 80.0
    /// gallery.json Schema neben printRevision. 6 = Hash-Hold über App-Neustart.
    static let gallerySchema = 6
    /// Box-IoU unter dem Wert: Bewegung. Mit Schärfe: kleines Nicken darf den Print.
    static let holdStillIoU = 0.70
    static let holdStillSharp = 0.18

    static func activeSharpnessFloor(continuity: Bool) -> Double {
        continuity ? continuitySharpnessFloor : sharpnessFloor
    }

    static func liveBlendAlpha(continuity: Bool) -> Double {
        continuity ? liveBlendContinuity : liveBlendBuiltIn
    }

    /// Unscharfe Leave-one-out-Paare sind keine Identitätsfrage.
    static func laborIncludesProbe(qualityRejected: Bool) -> Bool {
        !qualityRejected
    }

    static func laborIncludesRef(qualityRejected: Bool) -> Bool {
        laborIncludesProbe(qualityRejected: qualityRejected)
    }

    static func laborPairKind(probeMasked: Bool) -> String {
        probeMasked ? "genuine-mask" : "genuine-full"
    }

    /// Live-Box: IoU unter 0,35 hält die alte Kiste ein Frame.
    static func boxHysteresisHold(iou: Double, floor: Double = boxJumpIoU) -> Bool {
        iou < floor
    }

    /// Zweites Frame bestätigt den Sprung, wenn es an der pending-Box klebt.
    static func boxHysteresisConfirm(iouToPending: Double, floor: Double = boxJumpIoU) -> Bool {
        iouToPending >= floor
    }

    /// Nahezu identischer Print — Burst-Kopie, nicht neue Pose.
    static func ingestDuplicate(cosine: Double, floor: Double = ingestDuplicateCosine) -> Bool {
        cosine > floor
    }

    /// Zwei Refs derselben Person, Cosine > 0,98 — Burst, nicht zweite Pose.
    static func isNearDuplicate(cosine: Double, floor: Double = pruneCosine) -> Bool {
        cosine > floor
    }

    /// nil = behalte beide. true = Incoming schärfer (alte raus). false = alte schärfer.
    static func pruneKeepIncoming(
        cosine: Double,
        incomingSharp: Double,
        existingSharp: Double,
        floor: Double = pruneCosine
    ) -> Bool? {
        guard cosine > floor else { return nil }
        return incomingSharp >= existingSharp
    }

    /// Mehrheit der letzten Namen. Gleichstand → der ältere (erster im Fenster).
    static func nameMajority(_ history: [String], window: Int = nameVoteFrames) -> String? {
        let slice = Array(history.suffix(max(1, window)))
        guard !slice.isEmpty else { return nil }
        var counts: [String: Int] = [:]
        for n in slice { counts[n, default: 0] += 1 }
        let ranked = counts.sorted { lhs, rhs in
            if lhs.value != rhs.value { return lhs.value > rhs.value }
            let i = slice.firstIndex(of: lhs.key) ?? 0
            let j = slice.firstIndex(of: rhs.key) ?? 0
            return i < j
        }
        return ranked.first?.key
    }

    /// Leere Tokens (Look≠Print) zählen nicht. Sieger braucht `need` Stimmen.
    /// Fenster mindestens `need` — sonst Familie bei 8 fps (need 7, window 5) nie.
    static func nameMajorityAgreeing(
        _ history: [String],
        window: Int = nameVoteFrames,
        need: Int = nameAgreeNeed
    ) -> String? {
        let agreeing = history.filter { !$0.isEmpty }
        let win = max(window, need)
        let slice = Array(agreeing.suffix(max(1, win)))
        guard slice.count >= need else { return nil }
        guard let winner = nameMajority(slice, window: win) else { return nil }
        return slice.filter { $0 == winner }.count >= need ? winner : nil
    }

    /// Confirm nach 8 s tot — sonst gilt Return der nächsten Person.
    static func renameConfirmExpired(
        since: TimeInterval?,
        now: TimeInterval,
        hold: TimeInterval = renameConfirmHold
    ) -> Bool {
        guard let since else { return true }
        return now - since >= hold
    }

    /// Confirm gilt nur derselben UUID — Return in einer anderen Zeile ist tot.
    static func renameConfirmSameId(pending: UUID?, target: UUID) -> Bool {
        pending == target
    }

    /// Live-Percent: erster Tick roh, danach EMA. Sonst flackert der Badge.
    static func liveScoreEMA(prev: Double?, next: Double, alpha: Double = liveScoreAlpha) -> Double {
        guard let prev else { return next }
        let a = min(1, max(0, alpha))
        return a * next + (1 - a) * prev
    }

    /// Nach Namensmehrheit: Prozent der gewählten Identität, nicht der Roh-Besten.
    static func votedPercent(versus: [(id: UUID, percent: Double)], identityId: UUID?, fallback: Double) -> Double {
        guard let identityId else { return fallback }
        return versus.first { $0.id == identityId }?.percent ?? fallback
    }

    /// Geo darf einen starken Print nicht kippen. Kleidung/Haare sind nicht Identität.
    /// true = Zuordnung blocken.
    /// yawAbs ≥ 0,28 (¾/Profil): Landmark-Median der Frontals lügt — nicht vetoen.
    static func geoVetoBlocks(geoAgrees: Bool, geoMix: Double, printPercent: Double, yawAbs: Double = 0) -> Bool {
        if geoAgrees { return false }
        if printPercent >= geoVetoSkipPrint { return false }
        if yawAbs >= geoVetoYawSkip, printPercent >= geoVetoYawPrint { return false }
        if printPercent >= strongPrintFloor { return geoMix < 22 }
        return geoMix < 42 && printPercent < 94
    }

    static func pinByPrint(cosine: Double, floor: Double = pinPrintCosine) -> Bool {
        cosine >= floor
    }

    static func leftoverPin(iou: Double, floor: Double = leftoverIoU) -> Bool {
        iou > floor
    }

    /// Leftover darf keine schon eingeschriebene adopted-Box überschreiben.
    static func leftoverAdoptAllowed(adoptedEnrolled: Bool) -> Bool {
        !adoptedEnrolled
    }

    /// Live-Track mit Namen. Galerie-UUIDs sind nach Snapshot nicht der Track.
    static func leftoverNamedTrack(hadName: Bool) -> Bool {
        hadName
    }

    /// Leftover ohne Print stiehlt die UUID. nil = nicht pinning.
    static func leftoverNeedsPrint(cosine: Double?) -> Bool {
        cosine == nil
    }

    /// Unter den IoU-Kandidaten den nächsten Print, nicht first-in-order.
    static func leftoverPick(
        candidates: [(index: Int, iou: Double, cosine: Double?)],
        sharpness: [Int: Double] = [:],
        sameSlot: [Int: Bool] = [:],
        yawAbs: [Int: Double] = [:],
        aspectOk: [Int: Bool] = [:],
        floor: Double = leftoverIoU,
        twinPair: Double? = nil,
        holdPrev: Double? = nil,
        liveIds: [Int: UUID] = [:],
        leftoverId: UUID? = nil,
        printId: UUID? = nil,
        geoId: UUID? = nil,
        lockId: UUID? = nil,
        geoMix: Double? = nil,
        dt: TimeInterval = 0.016,
        lookawayEnrolled: Bool = false,
        lookawayYaw: Double? = nil,
        facesInFrame: Int = 1,
        detScore: [Int: Double] = [:],
        boxX: [Int: Double] = [:],
        leftoverX: Double? = nil,
        otherX: [Double] = [],
        sessionCapture: Double? = nil,
        capture: [Int: Double] = [:],
        imageW: Double = 0,
        captureHist: [Double] = [],
        captureBoxHist: [Int: [Double]] = [:],
        holdBins: [String: Double] = [:],
        holdHash: String? = nil,
        holdHashTable: [String: (cosine: Double, at: TimeInterval)] = [:],
        holdAt: TimeInterval = 0,
        holdTTL: TimeInterval = leftoverAdoptSec,
        frameCapture: Double? = nil,
        holdOccupied: [String] = []
    ) -> Int? {
        if leftoverLookawayBlocks(yawAbs: lookawayYaw, enrolled: lookawayEnrolled) {
            return nil
        }
        if leftoverTwinHardBlocks(pairCosine: twinPair, veto: leftoverTwinHardVetoNow(facesInFrame: facesInFrame)) {
            return nil
        }
        let session = leftoverSessionCapturePrefersFrame(frame: frameCapture, box: sessionCapture)
        func liveCap(_ i: Int) -> Double? {
            leftoverSessionCapturePrefersFrame(frame: frameCapture, box: capture[i])
        }
        var ok = candidates.filter { leftoverPin(iou: $0.iou, floor: floor) }
        ok = ok.filter {
            !leftoverHoldBlocks(
                raw: $0.cosine,
                prev: leftoverHoldPrevOf(
                    frontal: holdPrev,
                    yawAbs: yawAbs[$0.index],
                    bins: holdBins,
                    id: leftoverId,
                    hash: holdHash,
                    hashTable: holdHashTable,
                    now: holdAt,
                    ttl: holdTTL,
                    facesInFrame: facesInFrame,
                    occupied: holdOccupied
                )
            )
        }
        ok = ok.filter {
            leftoverPrintOk(
                cosine: leftoverPickPrint(raw: $0.cosine, smoothed: nil),
                sharpness: sharpness[$0.index],
                yawAbs: yawAbs[$0.index],
                capture: leftoverSessionCaptureBox(
                    old: session,
                    live: liveCap($0.index),
                    hist: leftoverCaptureHistOf(
                        box: captureBoxHist[$0.index],
                        leftover: captureHist
                    )
                )
            )
        }
        let smoothed: [(index: Int, iou: Double, cosine: Double?)] = ok.map {
            (
                index: $0.index,
                iou: $0.iou,
                cosine: leftoverHoldSmooth(
                    raw: $0.cosine,
                    prev: leftoverHoldPrevOf(
                        frontal: holdPrev,
                        yawAbs: yawAbs[$0.index],
                        bins: holdBins,
                        id: leftoverId,
                        hash: holdHash,
                        hashTable: holdHashTable,
                        now: holdAt,
                        ttl: holdTTL,
                        facesInFrame: facesInFrame,
                        occupied: holdOccupied
                    ),
                    dt: dt,
                    captureJump: leftoverCaptureJump(prev: session, next: liveCap($0.index))
                )
            )
        }
        var printable = smoothed
        if leftoverTwinBlocksBox(pairCosine: twinPair, printCosine: nil) {
            printable = printable.filter { leftoverBaptize(cosine: $0.cosine) }
        }
        if leftoverTwinSuggest(pairCosine: twinPair),
           !printable.contains(where: { leftoverBaptize(cosine: $0.cosine) })
        {
            return nil
        }
        if let leftoverId, !liveIds.isEmpty {
            printable = printable.filter {
                !leftoverYieldsToLive(liveId: liveIds[$0.index], leftoverId: leftoverId)
            }
        }
        if !aspectOk.isEmpty {
            printable = printable.filter {
                leftoverPickAspect(ok: aspectOk[$0.index], cosine: $0.cosine)
            }
        }
        guard !printable.isEmpty else { return nil }
        if printable.allSatisfy({
            unknownCentroid(
                bestCosine: $0.cosine,
                capture: leftoverSessionCaptureBox(
                    old: session,
                    live: liveCap($0.index),
                    hist: leftoverCaptureHistOf(
                        box: captureBoxHist[$0.index],
                        leftover: captureHist
                    )
                ),
                yawAbs: yawAbs[$0.index]
            )
        }) {
            return nil
        }
        let slotted = printable.filter { sameSlot[$0.index] == true }
        var pool: [(index: Int, iou: Double, cosine: Double?)]
        if !slotted.isEmpty {
            pool = slotted
        } else if sameSlot.isEmpty {
            pool = printable
        } else {
            let cross = printable.filter {
                leftoverAllowsCrossSlot(sameSlot: sameSlot[$0.index], cosine: $0.cosine)
            }
            if cross.isEmpty { return nil }
            pool = cross
        }
        if let leftoverX {
            let gap = leftoverBoxOrderGap(imageW: imageW)
            let ordered = pool.filter { cand in
                leftoverBoxOrderKeeps(
                    prevX: leftoverX,
                    candX: boxX[cand.index] ?? leftoverX,
                    others: otherX,
                    minGap: gap
                )
            }
            if !ordered.isEmpty { pool = ordered }
        }
        let scored = pool.map {
            leftoverScore(
                cosine: $0.cosine ?? -1,
                sharpness: sharpness[$0.index],
                yawAbs: yawAbs[$0.index] ?? 0,
                detScore: detScore[$0.index],
                twinPair: twinPair,
                capture: leftoverSessionCaptureBox(
                    old: session,
                    live: liveCap($0.index),
                    hist: leftoverCaptureHistOf(
                        box: captureBoxHist[$0.index],
                        leftover: captureHist
                    )
                )
            )
        }
        let raw = pool.map { $0.cosine ?? -1 }
        if leftoverAmbiguousBlocks(raw: raw, scored: scored) { return nil }
        if leftoverSoftmaxBlocks(leftoverScoreSoftmax(scored), capture: session) { return nil }
        if let i = scored.enumerated().max(by: { $0.element < $1.element })?.offset {
            let idx = pool[i].index
            if !conflictTickAgrees(
                boxId: nil,
                printId: printId,
                geoId: geoId,
                lockId: liveIds[idx] ?? lockId,
                geoMix: geoMix
            ) {
                return nil
            }
            return idx
        }
        return nil
    }

    /// Zwillinge: Top-2 Print < 0,08 Spread — kein Adopt, Overlay statt still taufen.
    static let leftoverAmbiguousSpread = 0.08

    static func leftoverAmbiguous(scores: [Double], spread: Double = leftoverAmbiguousSpread) -> Bool {
        let ok = scores.filter { $0.isFinite }
        guard ok.count >= 2 else { return false }
        let sorted = ok.sorted(by: >)
        return sorted[0] - sorted[1] < spread
    }

    /// Spread < 0,08 blockt, außer Schärfe dreht den Sieger (0,72 scharf > 0,73 blur).
    static func leftoverAmbiguousBlocks(raw: [Double], scored: [Double]) -> Bool {
        guard leftoverAmbiguous(scores: raw) else { return false }
        guard raw.count == scored.count, raw.count >= 2 else { return true }
        let rawBest = raw.enumerated().max(by: { $0.element < $1.element })?.offset
        let scoreBest = scored.enumerated().max(by: { $0.element < $1.element })?.offset
        return rawBest == scoreBest
    }

    static let twinPairCosine = 0.90
    /// pairCosine ≥ 0,92: Hard-Veto, auch Baptize 0,80 stiehlt nicht.
    static let leftoverTwinHardVeto = 0.92
    /// Zwei Gesichter im Frame: 0,92 lässt 0,90 durch. Same-shot schon bei 0,88 hart.
    static let leftoverTwinSameShot = 0.88

    static func leftoverTwinHardVetoNow(facesInFrame: Int, veto: Double = leftoverTwinHardVeto) -> Double {
        facesInFrame >= 2 ? leftoverTwinSameShot : veto
    }

    static func leftoverTwinHardBlocks(pairCosine: Double?, veto: Double = leftoverTwinHardVeto) -> Bool {
        guard let pair = pairCosine else { return false }
        return pair >= veto
    }

    /// Enrolled wegsieht (¾/Profil): leftover freeze, nicht taufen.
    static let leftoverLookawayYaw = 0.28
    /// Lookaway-Pin weicher als leftover IoU — sonst WEG tot sobald die Kiste atmet.
    static let leftoverLookawayIoU = 0.12

    static func leftoverLookawayBlocks(
        yawAbs: Double?,
        enrolled: Bool,
        floor: Double = leftoverLookawayYaw
    ) -> Bool {
        enrolled && (yawAbs ?? 0) >= floor
    }

    /// Lookaway freeze: Hold/Streak behalten, nicht leftoverClear.
    static func leftoverLookawayHolds(yawAbs: Double?, enrolled: Bool) -> Bool {
        leftoverLookawayBlocks(yawAbs: yawAbs, enrolled: enrolled)
    }

    static func leftoverLookawayLabel(until: TimeInterval? = nil, now: TimeInterval = 0) -> String {
        guard let until else { return "WEG" }
        let left = until - now
        guard left > 0, left < 10 else { return "WEG" }
        return "WEG in \(commaTenths(left)) s"
    }

    /// Live-Yaw sticht Ghost-Yaw: Blick zurück hebt den Freeze, Blick weg setzt ihn.
    static func leftoverLookawayYawOf(oldYaw: Double?, liveYaw: Double?) -> Double {
        liveYaw ?? oldYaw ?? 0
    }

    /// WEG muss auf die Live-Kiste. old.id wird nachher aus leftoverPending gefiltert.
    static func leftoverLookawayPin(
        candidates: [(index: Int, iou: Double, cosine: Double?)],
        floor: Double = leftoverLookawayIoU
    ) -> Int? {
        candidates.filter { leftoverPin(iou: $0.iou, floor: floor) }
            .max(by: { $0.iou < $1.iou })?.index
    }

    /// max-IoU ohne Floor pinnt WEG auf den Fremden.
    static func leftoverLookawayPinsStranger(iou: Double, floor: Double = leftoverLookawayIoU) -> Bool {
        iou < floor
    }

    /// EMA nicht mit Profil-Print überschreiben.
    static func leftoverHoldSkipLookaway(enrolled: Bool, yawAbs: Double?) -> Bool {
        leftoverLookawayHolds(yawAbs: yawAbs, enrolled: enrolled)
    }

    /// Open-Set 0,50–0,62: hart UNBEKANNT, kein Gast-Index-Sprung.
    static let leftoverUnknownLo = 0.50

    static func leftoverUnknownHard(cosine: Double?) -> Bool {
        guard let c = cosine else { return false }
        return c >= leftoverUnknownLo && unknownCentroid(bestCosine: c)
    }

    static func leftoverUnknownNote() -> String { "UNBEKANNT" }

    /// Open-Set-Band: Streak halten, sonst jeder Re-Entry = Gast n+1.
    static func leftoverUnknownKeepsStreak(cosine: Double?) -> Bool {
        leftoverUnknownHard(cosine: cosine)
    }

    /// Nach Taufe bleibt Streak auf der Live-UUID — Blink darf sofort re-adoptieren.
    static func leftoverStreakKeepsLive(transferred: Bool) -> Bool { transferred }

    /// TWIN? 0,90 hält Streak. Hartes TWIN 0,93 löscht — sonst jeder Twin-Frame = Gast n+1.
    static func leftoverTwinKeepsStreak(pairCosine: Double?) -> Bool {
        leftoverTwinSuggest(pairCosine: pairCosine) && !leftoverTwinHardBlocks(pairCosine: pairCosine)
    }

    /// pairCosine ≥ 0,90: leftover nie über Box, nur Print ≥ 0,80.
    static func leftoverTwinBlocksBox(
        pairCosine: Double?,
        printCosine: Double?,
        twin: Double = twinPairCosine,
        printNeed: Double = pinPrintCosine
    ) -> Bool {
        guard let pair = pairCosine, pair >= twin else { return false }
        return (printCosine ?? -1) < printNeed
    }

    /// Leftover-Tracks: höchster Print zuerst, nicht die ältere UUID.
    static func leftoverRank(_ items: [(id: UUID, cosine: Double?)]) -> [UUID] {
        items.sorted { a, b in
            let ca = a.cosine ?? -1
            let cb = b.cosine ?? -1
            if ca != cb { return ca > cb }
            return a.id.uuidString < b.id.uuidString
        }.map(\.id)
    }

    static func leftoverPinStatus(count: Int, cosine: Double? = nil) -> String? {
        guard count > 0 else { return nil }
        let base = count == 1 ? "Leftover-Pin 1 Track" : "Leftover-Pin \(count) Tracks"
        if let hold = leftoverHoldLabel(cosine: cosine) {
            return "\(base) · \(hold)"
        }
        return base
    }

    /// Overlay: leftover-Print sichtbar, sonst wirkt 0,64 „tot“. Komma wie die restliche UI.
    /// 0,62 scharf hält den Track — Label muss dieselbe Bandbreite zeigen, nicht nil.
    /// Smooth neben Roh: Taufe 0,80 bei EMA 0,64 sonst unsichtbar.
    static func leftoverHoldLabel(cosine: Double?, sharpness: Double? = nil, yawAbs: Double? = nil, smooth: Double? = nil, compact: Bool = false) -> String? {
        guard let cosine else { return nil }
        let ok = leftoverPrintOk(cosine: cosine, sharpness: sharpness) || cosine >= leftoverPrintGenuine
        guard ok else { return nil }
        let raw = leftoverHoldFrac(cosine)
        let hold: String
        if compact {
            hold = leftoverHoldCompactFrac(raw: cosine, smooth: smooth)
        } else if let smooth, leftoverHoldFrac(smooth) != raw {
            hold = "gehalten \(raw) / \(leftoverHoldFrac(smooth))"
        } else {
            hold = "gehalten \(raw)"
        }
        if let yawAbs {
            return "\(hold) · \(leftoverHoldBinChip(leftoverHoldBin(yawAbs: yawAbs)))"
        }
        return hold
    }

    /// Trail-letzter Cosine ist roh, leftoverHold[id] EMA. Overlay sonst nur Smooth.
    static func leftoverHoldRawOf(trail: [Double], hold: Double?) -> Double? {
        trail.last ?? hold
    }

    /// Overlay roh/smooth. leftoverHoldLabel(smooth:) sitzt, Store reicht oft nur EMA.
    static func leftoverHoldOverlayChip(
        hold: Double?,
        trail: [Double] = [],
        yawAbs: Double? = nil,
        sharpness: Double? = nil,
        compact: Bool = false
    ) -> String? {
        leftoverHoldLabel(
            cosine: leftoverHoldRawOf(trail: trail, hold: hold),
            sharpness: sharpness,
            yawAbs: yawAbs,
            smooth: hold,
            compact: compact
        )
    }

    /// Overlay compact `HOLD 80/64` neben `gehalten 0,80 / 0,64`.
    static func leftoverHoldCompactFrac(raw: Double, smooth: Double?) -> String {
        let r = Int((raw * 100).rounded())
        if let s = smooth {
            let sv = Int((s * 100).rounded())
            if sv != r { return "HOLD \(r)/\(sv)" }
        }
        return "HOLD \(r)"
    }

    /// ¾-Trail nicht mit Frontal-UUID mischen. Hash-Bin sitzt, UUID-Trail bleibt frontal.
    static func leftoverHoldTrailOf(uuidTrail: [Double], yawAbs: Double? = nil, binTrail: [Double] = []) -> [Double] {
        leftoverHoldBin(yawAbs: yawAbs ?? 0) == 0 ? uuidTrail : binTrail
    }

    /// Spark: Hash-Trail überlebt UUID-Steal. ¾ nur Hash, frontal Hash vor UUID.
    static func leftoverSparkTrailOf(uuidTrail: [Double], hashTrail: [Double] = [], yawAbs: Double? = nil) -> [Double] {
        if leftoverHoldBin(yawAbs: yawAbs ?? 0) != 0 { return hashTrail }
        return hashTrail.isEmpty ? uuidTrail : hashTrail
    }

    static func leftoverLastHashKeeps(prev: String?, next: String?) -> String? {
        if let next, !next.isEmpty { return next }
        return prev
    }

    /// 8 fps Overlay sonst flackert Spark. Wrapper um overlayChipPeakHold.
    static func leftoverSparkChipHold(prev: String?, now: String?, hold: Int, need: Int = 2) -> (chip: String?, hold: Int) {
        let r = overlayChipPeakHold(current: now, held: prev, remaining: hold, need: need)
        return (r.chip, r.remaining)
    }

    /// Frame-Luma nil: Capture-Luma, sonst Indoor 420v Nacht-Softmax.
    static func leftoverPickLuma(frame: Double?, capture: Double?) -> Double? {
        frame ?? capture
    }

    /// JPEG-Probe optional. nil = kein Block, außer required (Print da, Probe tot = Poster).
    static func leftoverBaptizeJpegOk(_ delta: Double?, required: Bool = false) -> Bool {
        if let delta { return leftoverBaptizeJpeg(delta: delta) }
        return !required
    }

    /// Probe 0,80 s cachen. FaceEngine JPEG+Print auf Main sonst 15 fps Jank.
    /// Hash- oder Cosine-Sprung: Poster in derselben Box, Cache tot.
    static func leftoverJpegProbeReuse(
        now: TimeInterval,
        last: TimeInterval?,
        ttl: TimeInterval = 0.80,
        hash: String? = nil,
        cachedHash: String? = nil,
        cosine: Double? = nil,
        cachedCosine: Double? = nil,
        cosineJump: Double = 0.04
    ) -> Bool {
        if let hash, let cachedHash, hash != cachedHash { return false }
        if let c = cosine, let p = cachedCosine, abs(c - p) >= cosineJump { return false }
        guard let last else { return false }
        return now - last >= 0 && now - last < ttl
    }

    /// Crop-Fail als −1 merken. Sonst jede Frame reextract.
    static func leftoverJpegProbePut(_ delta: Double?) -> Double { delta ?? -1 }

    static func leftoverJpegProbeGet(_ stored: Double?) -> Double? {
        guard let stored, stored >= 0 else { return nil }
        return stored
    }

    /// Mehrheit UND 3 gleiche Ticks. Mehrheit allein springt Geschwister.
    /// JUMP-LOCK: neue Majority tot, Overlay hält `held` — nil wischt sonst den Namen.
    static func leftoverLiveNameAnd(voted: String?, hist: [String], need: Int = 3, locked: Bool = false, held: String? = nil) -> String? {
        if locked { return held }
        guard let voted, leftoverLiveNameHolds(hist, need: need) == voted else { return nil }
        return voted
    }

    /// Overlay: 3-Tick-Mittel wenn voll, sonst EMA.
    static func leftoverScoreTickOverlay(ema: Double, ticks: [Double]) -> Double {
        guard ticks.count >= 3, let mean = leftoverScoreTickMean(ticks) else { return ema }
        return mean
    }

    /// Thermal: nicht über 8 fps jagen. Hunt/Lock-Interval bleibt Floor.
    static func liveMinIntervalThermal(base: TimeInterval, thermal: Bool) -> TimeInterval {
        thermal ? max(base, 1.0 / 8.0) : base
    }

    /// ¾: UUID-Trail ist Frontal. Chip sonst „HOLD 80/64 · BIN 1“.
    /// binTrail: ¾ roh aus Pose-Bin, nicht leftoverHold EMA allein.
    static func leftoverHoldOverlayChipOf(
        hold: Double?,
        trail: [Double] = [],
        yawAbs: Double? = nil,
        sharpness: Double? = nil,
        compact: Bool = false,
        binTrail: [Double] = []
    ) -> String? {
        leftoverHoldOverlayChip(
            hold: hold,
            trail: leftoverTrailNowOf(idTrail: trail, binTrail: binTrail, yawAbs: yawAbs),
            yawAbs: yawAbs,
            sharpness: sharpness,
            compact: compact
        )
    }

    /// Overlay darf den Track halten. Taufe erst ab Pin-Print 0,80 — sonst erbt der Nachbar den Namen.
    static func leftoverBaptize(cosine: Double?) -> Bool {
        guard let cosine else { return false }
        return cosine >= pinPrintCosine
    }

    /// Taufe roh ≥ 0,80 UND smooth ≥ 0,80. nil Smooth ist Dropout, nicht Taufe.
    /// Qualität: Blur / Blink / Profil sperren — Poster und Lid-Schluss taufen sonst den Nachbarn.
    static func leftoverBaptizeQuality(sharpness: Double? = nil, yawAbs: Double? = nil, blink: Bool = false) -> Bool {
        if blink { return false }
        if let y = yawAbs, y >= leftoverPrintProfileYaw { return false }
        if let s = sharpness, s < sharpnessFloor { return false }
        return true
    }

    static func leftoverBaptizeBoth(
        raw: Double?,
        smooth: Double?,
        sharpness: Double? = nil,
        yawAbs: Double? = nil,
        blink: Bool = false
    ) -> Bool {
        leftoverBaptize(cosine: raw)
            && leftoverBaptize(cosine: smooth)
            && leftoverBaptizeQuality(sharpness: sharpness, yawAbs: yawAbs, blink: blink)
    }

    static func leftoverBaptizeGate(
        raw: Double?,
        smooth: Double?,
        sharpness: Double? = nil,
        yawAbs: Double? = nil,
        blink: Bool = false,
        jpegDelta: Double? = nil,
        jpegRequired: Bool = false
    ) -> Bool {
        leftoverBaptizeBoth(raw: raw, smooth: smooth, sharpness: sharpness, yawAbs: yawAbs, blink: blink)
            && leftoverBaptizeJpegOk(jpegDelta, required: jpegRequired)
    }

    /// Twin 0,80 nach Hold 0,64: Spike, kein Steal. 0,80 nach 0,80 bleibt Taufe.
    static func leftoverBaptizeSpike(
        raw: Double?,
        prev: Double?,
        spike: Double = leftoverHoldSpike
    ) -> Bool {
        guard leftoverBaptize(cosine: raw), let prev else { return false }
        if leftoverBaptize(cosine: prev) { return false }
        return raw! - prev + 1e-9 >= spike
    }

    /// UUID/Print nur bei Baptize 0,80 ohne Twin-Spike und ohne MAD.
    /// Spike + 3 Baptize-Samples = echter Anstieg, nicht ein Twin-Frame.
    /// Tap-Lock 3 s: manueller Name, leftover tauft nicht.
    /// Erste Begegnung: 0,45 s still, sonst Vorbeigehen tauft.
    static func leftoverTransfersId(
        cosine: Double?,
        holdPrev: Double? = nil,
        trail: [Double] = [],
        tapUntil: TimeInterval? = nil,
        now: TimeInterval = 0,
        stillFor: TimeInterval = 1,
        sharpness: Double? = nil,
        yawAbs: Double? = nil,
        blink: Bool = false,
        jpegDelta: Double? = nil,
        iou: Double? = nil,
        jpegRequired: Bool = false,
        nameLockUntil: TimeInterval? = nil
    ) -> Bool {
        if tapNameLockBlocks(until: tapUntil, now: now) { return false }
        if leftoverNameLockBlocks(until: nameLockUntil, now: now) { return false }
        if leftoverBaptizeStillBlocks(stillFor: stillFor, cosine: cosine, holdPrev: holdPrev) { return false }
        if leftoverIoUJumpBlocks(iou) { return false }
        guard leftoverBaptize(cosine: cosine) else { return false }
        if !leftoverBaptizeQuality(sharpness: sharpness, yawAbs: yawAbs, blink: blink) { return false }
        if !leftoverBaptizeJpegOk(jpegDelta, required: jpegRequired) { return false }
        if printMADBlocks(trail) { return false }
        let trailMean: Double? = trail.isEmpty ? nil : trail.reduce(0, +) / Double(trail.count)
        if leftoverBaptizeSpike(raw: cosine, prev: holdPrev) {
            let n = trail.filter { leftoverBaptize(cosine: $0) }.count
            return n >= 3 && leftoverBaptizeGate(raw: cosine, smooth: trailMean, sharpness: sharpness, yawAbs: yawAbs, blink: blink, jpegDelta: jpegDelta, jpegRequired: jpegRequired)
        }
        return leftoverBaptizeGate(raw: cosine, smooth: holdPrev, sharpness: sharpness, yawAbs: yawAbs, blink: blink, jpegDelta: jpegDelta, jpegRequired: jpegRequired)
    }

    static let leftoverBaptizeStillNeed: TimeInterval = 0.45

    /// Erste Begegnung ohne Hold: 0,45 s still bevor Taufe. Hold 0,64 skippt.
    static func leftoverBaptizeStillBlocks(
        stillFor: TimeInterval,
        cosine: Double?,
        holdPrev: Double?
    ) -> Bool {
        guard leftoverBaptize(cosine: cosine) else { return false }
        if leftoverPrintOk(cosine: holdPrev) { return false }
        return stillFor < leftoverBaptizeStillNeed
    }

    static func leftoverWipeHist(cosine: Double?) -> Bool {
        !leftoverBaptize(cosine: cosine)
    }

    /// Leftover darf Genuine 0,62–0,79 halten. Pin-Print 0,80 bleibt für enrolled IoU-Steal.
    /// Blur unter sharpnessFloor sperrt Hold-Pick, nicht Baptize 0,80.
    /// leftoverPrintSharp bleibt für Genuine 0,62. Continuity 0,12–0,14 darf 0,64 halten.
    /// Profil: Floor 0,70 — sonst Twin im ¾ mit 0,62 scharf.
    /// Schwelle 0,45 rad, nicht Lookaway 0,28 — sonst 16° schon Profil.
    static func leftoverPrintFloor(yawAbs: Double?) -> Double {
        (yawAbs ?? 0) >= leftoverPrintProfileYaw ? leftoverPrintProfile : leftoverPrintGenuine
    }

    /// Indoor/Nacht: Floor −0,02 Cosine für 30 s Session. Twin im Dunkeln sonst tot.
    static let leftoverSessionCaptureLow: Double = 0.28
    static let leftoverSessionFloorDrop: Double = 0.02

    static func leftoverSessionLumaLow(_ capture: Double?) -> Bool {
        guard let capture else { return false }
        return capture < leftoverSessionCaptureLow
    }

    static func leftoverSessionFloor(yawAbs: Double?, capture: Double?) -> Double {
        var f = leftoverPrintFloor(yawAbs: yawAbs)
        if leftoverSessionLumaLow(capture) { f -= leftoverSessionFloorDrop }
        return f
    }

    /// Ghost-Capture 0,70 + Live-Nacht 0,18: Floor aus dem dunklen Frame, nicht der alten Kiste.
    /// Ghost-Nacht 0,18 + Live-Tag 0,70: Live gewinnt — sonst Twin-Floor den ganzen Tag.
    static func leftoverSessionCapture(old: Double?, live: [Double]) -> Double? {
        let liveOk = live.filter { $0 > 0 }
        if !liveOk.isEmpty { return liveOk.min() }
        return old
    }

    /// Gast im Schatten 0,18 senkt nicht Annas Floor. Box behält ihren Capture.
    /// Flash 1 Tick: Median der Hist, nicht min.
    static func leftoverSessionCaptureBox(old: Double?, live: Double?, hist: [Double] = []) -> Double? {
        if hist.count >= 3 {
            var s = hist
            if let live, live > 0 { s.append(live) }
            if let med = leftoverSessionCaptureMedian(s) { return med }
        }
        if let live, live > 0 { return live }
        return old
    }

    static func leftoverSessionCaptureMedian(_ samples: [Double]) -> Double? {
        let ok = samples.filter { $0 > 0 }.sorted()
        guard !ok.isEmpty else { return nil }
        return ok[ok.count / 2]
    }

    static func leftoverSessionCaptureStable(old: Double?, live: Double?, hist: [Double] = []) -> Double? {
        leftoverSessionCaptureBox(old: old, live: live, hist: hist)
    }

    /// Center Stage croppt die Box. Frame-Luma bleibt, Box springt. Floor folgt dem Frame.
    static func leftoverSessionCapturePrefersFrame(frame: Double?, box: Double?, jump: Double = leftoverHoldCaptureJump) -> Double? {
        guard let frame, let box else { return leftoverPickLuma(frame: frame, capture: box) }
        if abs(frame - box) >= jump { return frame }
        return box
    }

    /// 8×8-Grid auf dem Byte-Buffer. Center Stage Box 0,18, Frame bleibt ~0,70.
    static func leftoverFrameCaptureByte(
        _ bytes: [UInt8],
        width: Int,
        height: Int,
        stride: Int? = nil,
        samples: Int = 8
    ) -> Double? {
        guard width > 0, height > 0, !bytes.isEmpty else { return nil }
        let row = max(width, stride ?? width)
        let n = min(max(1, samples), width, height)
        var sum = 0.0
        var count = 0
        for j in 0 ..< n {
            let y = min(height - 1, (j * height) / n)
            for i in 0 ..< n {
                let x = min(width - 1, (i * width) / n)
                let idx = y * row + x
                guard idx >= 0, idx < bytes.count else { continue }
                sum += Double(bytes[idx])
                count += 1
            }
        }
        guard count > 0 else { return nil }
        return sum / (Double(count) * 255.0)
    }

    /// Session-Luma aus dem ganzen Buffer, nicht der Face-Box.
    static func leftoverFrameCapture(_ image: CGImage, samples: Int = 8) -> Double? {
        let n = max(2, samples)
        guard image.width > 1, image.height > 1, let ctx = CGContext(
            data: nil,
            width: n,
            height: n,
            bitsPerComponent: 8,
            bytesPerRow: n,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return nil }
        ctx.interpolationQuality = .low
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: n, height: n))
        guard let data = ctx.data else { return nil }
        let buf = data.bindMemory(to: UInt8.self, capacity: n * n)
        let bytes = Array(UnsafeBufferPointer(start: buf, count: n * n))
        return leftoverFrameCaptureByte(bytes, width: n, height: n, samples: n)
    }

    static func leftoverHoldBinChip(_ bin: Int) -> String { "BIN \(bin)" }

    static func leftoverHoldFrac(_ cosine: Double) -> String {
        let hundredths = Int((cosine * 100).rounded())
        let sign = hundredths < 0 ? "-" : ""
        let mag = abs(hundredths)
        let whole = mag / 100
        let frac = mag % 100
        let fracStr = frac < 10 ? "0\(frac)" : "\(frac)"
        return "\(sign)\(whole),\(fracStr)"
    }

    static func leftoverCaptureChip(_ capture: Double?) -> String? {
        guard let c = capture, c > 0, leftoverSessionLumaLow(c) else { return nil }
        return "CAP \(leftoverHoldFrac(c))"
    }

    static func leftoverSharpChip(_ sharpness: Double?) -> String? {
        guard let s = sharpness, s > 0 else { return nil }
        return "SHARP \(leftoverHoldFrac(s))"
    }

    /// 420v VideoRange Offset 16. Laplacian wirkt 0,10 zu dunkel.
    static func leftoverSharpnessOf(_ sharpness: Double?, videoRange: Bool = false) -> Double? {
        guard let s = sharpness else { return nil }
        return videoRange ? min(1, s + 16.0 / 219.0) : s
    }

    static func captureFourCCName(_ osType: UInt32) -> String {
        if osType == captureFourCC420f { return "420f" }
        if osType == captureFourCC420v { return "420v" }
        if osType == captureFourCCBGRA { return "BGRA" }
        return "PIX"
    }

    static func captureBandChip(osType: UInt32, lo: Double, hi: Double, fps: Double? = nil) -> String {
        if let fps, fps > 0, fps < 12 {
            return String(format: "%@ %.0f", captureFourCCName(osType), fps)
        }
        return String(format: "%@ %.0f–%.0f", captureFourCCName(osType), lo, hi)
    }

    static func captureLockFrameRate(_ maxFps: Double, continuity: Bool = false) -> Double {
        if continuity, maxFps >= 24 { return min(24, maxFps) }
        if maxFps >= 30 { return 30 }
        if maxFps >= 24 { return max(24, min(30, maxFps)) }
        if maxFps >= 15 { return max(15, min(24, maxFps)) }
        return max(7, maxFps)
    }

    static func leftoverPrintOk(cosine: Double?, sharpness: Double? = nil, floor: Double = leftoverPrintCosine, yawAbs: Double? = nil, capture: Double? = nil) -> Bool {
        guard let cosine else { return false }
        if leftoverBaptize(cosine: cosine) { return true }
        if leftoverBlurBlocks(sharpness: sharpness, cosine: cosine) { return false }
        let genuine = leftoverSessionFloor(yawAbs: yawAbs, capture: capture)
        if cosine >= max(floor, genuine) { return true }
        if cosine >= genuine, let s = sharpness, s >= leftoverPrintSharpOf(capture: capture) { return true }
        return false
    }

    /// Nacht/Continuity Laplacian 0,12–0,14. leftoverPrintSharp 0,22 ließ Genuine 0,62 tot.
    static func leftoverPrintSharpOf(capture: Double? = nil, continuity: Bool = false) -> Double {
        if leftoverSessionLumaLow(capture) || continuity { return sharpnessFloor }
        return leftoverPrintSharp
    }

    /// Continuity 1–30 hart auf 30 droppt auf 8. Band Floor 15 atmet.
    static let captureLockFloor: Double = 15

    static func captureLockFrameLo(_ maxFps: Double, rangeMin: Double, continuity: Bool = false) -> Double {
        let hi = captureLockFrameRate(maxFps, continuity: continuity)
        if hi + 1e-9 < captureLockFloor { return hi }
        return min(hi, max(rangeMin, captureLockFloor))
    }

    /// Continuity Center Stage croppt der Box hinterher. Aus, sonst leftoverSteal.
    static let centerStageOff = true

    /// `.user` (0) wirft beim Setter. `.app` (1) darf Aegis abschalten.
    static func centerStageNeedsAppControl(currentModeRaw: Int) -> Bool {
        centerStageOff && currentModeRaw != 1
    }

    static func centerStageNeedsReassert(enabled: Bool) -> Bool {
        centerStageOff && enabled
    }

    static func sessionPresetClampsContinuity(_ continuity: Bool) -> Bool { continuity }

    /// Helios 1.5.58: Coordinator drehte jeden Frame. Box 90°, leftover stiehlt.
    static func physicalCaptureRotation() -> Bool { false }

    static func videoRotationAngleFallback() -> CGFloat { 0 }

    /// Continuity-Stabilizer warpt Box, leftover tanzt. Built-in darf. macOS-API fehlt.
    static func videoStabilizationApplies(continuity: Bool) -> Bool { !continuity }

    /// Hunt 10 fps bis leftoverStreak / Face sitzt. Built-in 8 hungerte erste Taufe.
    /// Lock Continuity 15, Built-in 12. streak ≥ 1 = erste Begegnung, nicht erst facesPresent.
    static func liveMinInterval(continuity: Bool, faces: Bool, streak: Int = 0) -> TimeInterval {
        if faces || streak >= 1 { return continuity ? 1.0 / 15.0 : 1.0 / 12.0 }
        return 1.0 / 10.0
    }

    /// Analog Helios thermalHoldsFormat. 2 s unter 12 fps Format halten.
    static func liveThermalHolds(medianFps: Double, slowFor: TimeInterval, need: TimeInterval = 2.0) -> Bool {
        medianFps > 0 && medianFps < 12 && slowFor >= need
    }

    /// Portrait-Buffer → .right (6), sonst .up (1). Kein Coordinator.
    static func liveOrientationRaw(width: Int, height: Int) -> UInt32 {
        height > width ? 6 : 1
    }

    /// 0° Capture: Pixel stehen. height>width nicht .right — sonst 90° Box nach Format-Hop.
    static func liveBufferOrientation(width: Int, height: Int) -> UInt32 {
        physicalCaptureRotation() ? liveOrientationRaw(width: width, height: height) : 1
    }

    /// Box-Steal: IoU-Sprung unter 0,40 keine Taufe. Analog Helios grabAbortHold.
    static let leftoverIoUJump = 0.40

    static func leftoverIoUJumpBlocks(_ iou: Double?) -> Bool {
        guard let iou else { return false }
        return iou + 1e-12 < leftoverIoUJump
    }

    /// JPEG 70 % Cosine-Drop. 1 − cos(raw, jpeg). Poster fällt > 0,06.
    static func leftoverJpegProbe(raw: [Double], jpeg: [Double]) -> Double {
        guard raw.count >= 32, raw.count == jpeg.count else { return 1 }
        return max(0, 1 - cosine(raw, jpeg))
    }

    static func leftoverHoldBinsEncode(_ bins: [String: Double]) -> [String: Double] {
        bins.filter { $0.value > 0 }
    }

    static func leftoverHoldTrailBinsEncode(_ bins: [String: [Double]]) -> [String: [Double]] {
        bins.filter { !$0.value.isEmpty }
    }

    static func leftoverHoldBinsDecode(_ raw: [String: Double]?) -> [String: Double] {
        raw ?? [:]
    }

    static func leftoverHoldTrailBinsDecode(_ raw: [String: [Double]]?) -> [String: [Double]] {
        raw ?? [:]
    }

    /// Hash-Hold überlebt UUID-Steal und App-Neustart. `at` = now beim Restore, TTL startet neu.
    static let leftoverHashHoldFloor: Double = 0.64
    static let leftoverHashHoldCapN = 64

    static func leftoverHashHoldKeeps(_ cosine: Double, floor: Double = leftoverHashHoldFloor) -> Bool {
        cosine + 1e-12 >= floor
    }

    static func leftoverHashHoldEncode(_ table: [String: (cosine: Double, at: TimeInterval)]) -> [String: Double] {
        Dictionary(uniqueKeysWithValues: table.filter { leftoverHashHoldKeeps($0.value.cosine) }.map { ($0.key, $0.value.cosine) })
    }

    static func leftoverHashHoldDecode(_ raw: [String: Double]?, now: TimeInterval) -> [String: (cosine: Double, at: TimeInterval)] {
        guard let raw else { return [:] }
        return Dictionary(uniqueKeysWithValues: raw.filter { leftoverHashHoldKeeps($0.value) }.map { ($0.key, (cosine: $0.value, at: now)) })
    }

    static func leftoverHoldPruneSkips(rebased: Bool) -> Bool { rebased }

    static func leftoverHashHoldCapped(
        _ table: [String: (cosine: Double, at: TimeInterval)],
        cap: Int = leftoverHashHoldCapN
    ) -> [String: (cosine: Double, at: TimeInterval)] {
        if table.count <= cap { return table }
        return Dictionary(uniqueKeysWithValues: table.sorted { $0.value.at > $1.value.at }.prefix(cap).map { ($0.key, $0.value) })
    }

    static func leftoverHashTrailCapped(
        _ table: [String: (samples: [Double], at: TimeInterval)],
        cap: Int = leftoverHashHoldCapN
    ) -> [String: (samples: [Double], at: TimeInterval)] {
        if table.count <= cap { return table }
        return Dictionary(uniqueKeysWithValues: table.sorted { $0.value.at > $1.value.at }.prefix(cap).map { ($0.key, $0.value) })
    }

    static func leftoverHashHoldChip(_ cosine: Double?) -> String? {
        guard let cosine, leftoverHashHoldKeeps(cosine) else { return nil }
        return "HASH \(leftoverHoldFrac(cosine))"
    }

    static func leftoverJpegChip(stored: Double?, printReady: Bool) -> String? {
        printReady && stored != nil && stored! < 0 ? "JPEG" : nil
    }

    static func leftoverIoUJumpChip(_ iou: Double?) -> String? {
        leftoverIoUJumpBlocks(iou) ? "JUMP" : nil
    }

    /// Twin stiehlt den Namen nach Box-JUMP. 1,2 s Lock, Chip sitzt.
    static let leftoverNameLockSec: TimeInterval = 1.20

    static func leftoverNameLockArm(jump: Bool, now: TimeInterval, prev: TimeInterval? = nil, sec: TimeInterval = leftoverNameLockSec) -> TimeInterval? {
        if jump { return now + leftoverNameLockSecPref(sec) }
        if let prev, now < prev { return prev }
        return nil
    }

    static func leftoverNameLockBlocks(until: TimeInterval?, now: TimeInterval) -> Bool {
        guard let until else { return false }
        return now < until
    }

    static func leftoverNameLockChip(until: TimeInterval?, now: TimeInterval) -> String? {
        leftoverNameLockBlocks(until: until, now: now) ? "LOCK" : nil
    }

    static func leftoverNameLockKeeps(until: TimeInterval?, now: TimeInterval, name: String?) -> String? {
        guard leftoverNameLockBlocks(until: until, now: now) else { return nil }
        guard let name, !name.isEmpty else { return nil }
        return name
    }

    static func leftoverNameLockLive(until: [UUID: TimeInterval], now: TimeInterval) -> [UUID] {
        until.compactMap { leftoverNameLockBlocks(until: $0.value, now: now) ? $0.key : nil }
    }

    /// Pref 1,2–4,0 statt nur Takt. Indoor-Sticky bleibt 4 s.
    static func leftoverHoldTTLPref(_ pref: TimeInterval) -> TimeInterval {
        min(leftoverLatch, max(leftoverAdoptSec, pref))
    }

    static func leftoverHoldTTLOf(seenSlow: Bool, pref: TimeInterval) -> TimeInterval {
        seenSlow ? leftoverLatch : leftoverHoldTTLPref(pref)
    }

    /// Hamming-1 Neighbor-Veto wenn zwei Gesichter live. Twin stiehlt sonst den Hash-Nachbar.
    /// dist 0 Exact hält. Ein Gesicht: Hamming-2 Nachbarn bleiben.
    static func leftoverHoldNeighborOk(facesInFrame: Int, dist: Int) -> Bool {
        if dist <= 0 { return true }
        if facesInFrame >= 2, dist >= 1 { return false }
        return dist < 99
    }

    /// Twin-Frame: Nachbar-Walk verworfen. Exact zuerst, Grid nicht bauen.
    static func leftoverHoldNeighborScans(facesInFrame: Int) -> Bool {
        leftoverHoldNeighborOk(facesInFrame: facesInFrame, dist: 1)
    }

    /// Hamming-1/2 Veto sichtbar. Twin-Steal ohne Chip tot.
    static func leftoverHoldNeighborChip(facesInFrame: Int, dist: Int) -> String? {
        leftoverHoldNeighborOk(facesInFrame: facesInFrame, dist: dist) ? nil : "NBR"
    }

    /// Gleiche Bin, zwei Live-Kisten: Exact-Hold tot. Twin liest sonst 0,80 vom selben Key.
    static func leftoverHashOwnOccupied(live: [String], hash: String) -> Bool {
        live.contains(hash)
    }

    /// leftoverLastHash ist Vor-Tick. Erster Twin-Frame: stored leer, Exact-Steal.
    static func leftoverOccupiedMerge(stored: [String], live: [String]) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        for h in stored + live where !h.isEmpty {
            if seen.insert(h).inserted { out.append(h) }
        }
        return out
    }

    /// Hamming-0 Twins: strikt links behält Exact, rechts Occupied. Gleichstand: beide tot.
    static func leftoverHashTwinLeft(x: Double, others: [Double]) -> Bool {
        others.allSatisfy { x + 1e-9 < $0 }
    }

    static func leftoverHashTwinOccupied(
        occupied: [String],
        hash: String,
        x: Double,
        others: [(hash: String, x: Double)]
    ) -> [String] {
        let bare = leftoverHoldHashBare(hash)
        guard !bare.isEmpty else { return occupied }
        let twins = others.filter { leftoverHoldHashBare($0.hash) == bare }
        guard !twins.isEmpty else { return occupied }
        if leftoverHashTwinLeft(x: x, others: twins.map(\.x)) {
            return occupied.filter { leftoverHoldHashBare($0) != bare }
        }
        return occupied
    }

    static func leftoverHashTwinChip(x: Double, others: [Double]) -> String? {
        guard !others.isEmpty else { return nil }
        if others.count == 1 {
            return leftoverHashTwinLeft(x: x, others: others) ? "TWIN L" : "TWIN R"
        }
        return "TWIN \(leftoverHashTwinRank(x: x, others: others) + 1)"
    }

    /// Twin R braucht einen eigenen Exact-Key. Hamming-0 sonst beide Occupied.
    static let leftoverHashTwinRankBase = 100

    static func leftoverHashTwinRank(x: Double, others: [Double]) -> Int {
        others.filter { $0 < x - 1e-9 }.count
    }

    static func leftoverHoldHashTwinKey(hash: String, rank: Int) -> String {
        let bare = leftoverHoldHashBare(hash)
        if rank <= 0 { return bare }
        return leftoverHoldHashKey(hash: bare, bin: leftoverHashTwinRankBase + rank)
    }

    static func leftoverHashTwinRanked(
        hash: String,
        x: Double,
        others: [(hash: String, x: Double)]
    ) -> String {
        let bare = leftoverHoldHashBare(hash)
        guard !bare.isEmpty else { return hash }
        let twins = others.filter { leftoverHoldHashBare($0.hash) == bare }
        guard !twins.isEmpty else { return hash }
        return leftoverHoldHashTwinKey(hash: bare, rank: leftoverHashTwinRank(x: x, others: twins.map(\.x)))
    }

    /// leftoverLiveHashTick allein: Twin aus leftoverLastHash unsichtbar, erster Frame steals.
    static func leftoverOccupiedOthers(
        live: [(id: UUID, hash: String, x: Double)],
        stored: [(id: UUID, hash: String, x: Double)],
        except: UUID?
    ) -> [(hash: String, x: Double)] {
        var seen = Set<UUID>()
        var out: [(hash: String, x: Double)] = []
        for row in live + stored {
            if row.id == except { continue }
            if seen.contains(row.id) { continue }
            seen.insert(row.id)
            if row.hash.isEmpty { continue }
            out.append((hash: row.hash, x: row.x))
        }
        return out
    }

    /// empty wischt leftoverLastHash. Ghost-Bins sonst blocken Re-Entry.
    static func leftoverLastHashWipes(empty: Bool, overlayKeep: Bool = false) -> Bool {
        empty && !overlayKeep
    }

    /// Tick vor Last vor Spatial. Twin R sonst leftoverHoldPut auf denselben Key.
    static func leftoverRankedHashOf(tick: String?, last: String?, fallback: String) -> String {
        if let tick, !tick.isEmpty { return tick }
        if let last, !last.isEmpty { return last }
        return fallback
    }

    /// Twin-Rank `#101` und Hold-Bin `#0` sind nicht Spatial. Dist sonst 99 = NBR.
    static func leftoverHoldHashSpatial(_ key: String) -> String {
        var s = key
        while let i = s.lastIndex(of: "#") {
            s = String(s[..<i])
        }
        return s
    }

    /// Nächster Hold nach x, nicht UUID. Restart mintet neue Vision-IDs.
    /// Ohne Pad tauft 0,90 den Hold bei 0,10.
    static let leftoverFillXPad = 0.12

    /// Twin-Mitte: d≈d2. Nächster Hold 4× näher bleibt (0,02 vs 0,08).
    /// `d2 - d <= spread` allein tötete leftoverHoldXMatch(0,22) trotz eindeutigem 0,20.
    static func leftoverXAmbiguous(
        d: Double,
        d2: Double,
        pad: Double = leftoverFillXPad,
        spread: Double = leftoverAmbiguousSpread
    ) -> Bool {
        d2 <= pad && d2 - d <= spread && d2 < max(d * 2, d + 0.02) - 1e-12
    }

    static func leftoverHoldXMatch(
        liveX: Double,
        holds: [(id: UUID, x: Double)],
        pad: Double = leftoverFillXPad,
        occupied: Set<UUID> = [],
        spread: Double = leftoverAmbiguousSpread
    ) -> UUID? {
        let open = holds.filter { !occupied.contains($0.id) }
        guard !open.isEmpty else { return nil }
        let sorted = open.sorted { abs($0.x - liveX) < abs($1.x - liveX) }
        guard let best = sorted.first else { return nil }
        let d = abs(best.x - liveX)
        if d > pad { return nil }
        if let second = sorted.dropFirst().first {
            let d2 = abs(second.x - liveX)
            if leftoverXAmbiguous(d: d, d2: d2, pad: pad, spread: spread) { return nil }
        }
        return best.id
    }

    /// leftoverAssign nil-Zeilen: x-order, nicht Print. Restart / Dropout ohne Embedding.
    /// Vor leftoverAssignDropAmbiguous aufrufen — sonst Twin-Spread 0,08 wieder zu.
    static func leftoverAssignFillX(
        assigned: [Int?],
        liveX: [Double],
        holdX: [Double],
        pad: Double = leftoverFillXPad,
        spread: Double = leftoverAmbiguousSpread
    ) -> [Int?] {
        var out = assigned
        if out.count < holdX.count {
            out += Array(repeating: Optional<Int>.none, count: holdX.count - out.count)
        }
        var used = Set(out.compactMap { $0 })
        var pairs: [(d: Double, r: Int, c: Int)] = []
        for r in 0..<holdX.count {
            if r < out.count, out[r] != nil { continue }
            for c in 0..<liveX.count where !used.contains(c) {
                let d = abs(liveX[c] - holdX[r])
                if d <= pad {
                    pairs.append((d, r, c))
                }
            }
        }
        pairs.sort { a, b in
            if abs(a.d - b.d) > 1e-12 { return a.d < b.d }
            if a.r != b.r { return a.r < b.r }
            return a.c < b.c
        }
        for p in pairs {
            if p.r < out.count, out[p.r] != nil { continue }
            if used.contains(p.c) { continue }
            var d2 = Double.infinity
            for h in 0..<holdX.count where h != p.r && (h >= out.count || out[h] == nil) {
                d2 = min(d2, abs(liveX[p.c] - holdX[h]))
            }
            if leftoverXAmbiguous(d: p.d, d2: d2, pad: pad, spread: spread) { continue }
            out[p.r] = p.c
            used.insert(p.c)
        }
        return out
    }

    /// Print-Assign, x-Fill nur für leere Zeilen, Twin-Spread danach.
    /// leftoverHoldXMatch-Logik sitzt in FillX (leftoverXAmbiguous).
    static func leftoverAssignLive(
        scores: [[Double?]],
        liveX: [Double],
        holdX: [Double]
    ) -> [Int?] {
        leftoverAssignDropAmbiguous(
            scores: scores,
            assigned: leftoverAssignFillX(
                assigned: leftoverAssign(scores: scores),
                liveX: liveX,
                holdX: holdX
            )
        )
    }

    static func overlayChipKeep(_ chip: String) -> Int {
        let u = chip.uppercased()
        if u.hasPrefix("JUMP") || u.hasPrefix("LOCK") || u.hasPrefix("TWIN") || u.hasPrefix("NBR") { return 0 }
        if u.hasPrefix("HASH") || u.hasPrefix("JPEG") { return 1 }
        return 2
    }

    static func overlayChipCap(_ chips: [String], cap: Int = 6) -> [String] {
        var seen = Set<String>()
        var unique: [String] = []
        for c in chips where !c.isEmpty {
            if seen.insert(c).inserted { unique.append(c) }
        }
        let n = max(0, cap)
        if unique.count <= n { return unique }
        let ranked = unique.enumerated().sorted { a, b in
            let pa = overlayChipKeep(a.element)
            let pb = overlayChipKeep(b.element)
            if pa != pb { return pa < pb }
            return a.offset < b.offset
        }
        let keep = Set(ranked.prefix(n).map(\.element))
        return unique.filter { keep.contains($0) }
    }

    static func leftoverLiveHashTickWipes(empty: Bool) -> Bool { empty }

    static func leftoverHoldIndoorChip(seenSlow: Bool, ttl: TimeInterval) -> String? {
        seenSlow ? String(format: "INDOOR %.0fs", ttl) : nil
    }

    /// Hash-Key ohne `#bin`. Lookup-Dist sonst 99.
    static func leftoverHoldHashBare(_ key: String) -> String {
        if let i = key.lastIndex(of: "#") { return String(key[..<i]) }
        return key
    }

    /// Nächste Hold-Dist ≠ self. HUD NBR sonst bei jedem Twin-Frame (faces≥2 → dist 2).
    static func leftoverHoldNeighborDist(
        hash: String,
        table: [String: (cosine: Double, at: TimeInterval)],
        now: TimeInterval,
        ttl: TimeInterval = leftoverAdoptSec
    ) -> Int {
        var best = 0
        let selfSpatial = leftoverHoldHashSpatial(hash)
        for (key, row) in table {
            guard now - row.at <= ttl else { continue }
            let other = leftoverHoldHashSpatial(key)
            if other == selfSpatial { continue }
            let d = leftoverBoxHashDistance(selfSpatial, other)
            if d > 0 && (best == 0 || d < best) { best = d }
        }
        return best
    }

    /// Sticky nach Hop: Overlay `FAST`. 8 s Reset sonst unsichtbar.
    static func leftoverHoldFastChip(seenSlow: Bool, dt: TimeInterval) -> String? {
        seenSlow && dt < 0.08 ? "FAST" : nil
    }

    static func leftoverNameLockSecPref(_ pref: TimeInterval) -> TimeInterval {
        min(2.0, max(0.6, pref))
    }

    static func leftoverAdoptSecLockPref(_ pref: TimeInterval) -> TimeInterval {
        min(1.4, max(0.6, pref))
    }

    static func leftoverCaptureHistTableEncode(_ table: [String: [Double]], keep: [String] = []) -> [String: [Double]] {
        leftoverCaptureHistTableCapped(Dictionary(uniqueKeysWithValues: table.compactMap { k, v -> (String, [Double])? in
            let e = leftoverCaptureHistEncode(v)
            return e.isEmpty ? nil : (k, e)
        }), keep: keep)
    }

    static func leftoverCaptureHistTableDecode(_ raw: [String: [Double]]?, keep: [String] = []) -> [String: [Double]] {
        leftoverCaptureHistTableEncode(raw ?? [:], keep: keep)
    }

    static func leftoverCaptureHistTableCapped(
        _ table: [String: [Double]],
        keep: [String] = [],
        cap: Int = leftoverHashHoldCapN
    ) -> [String: [Double]] {
        if table.count <= cap { return table }
        var out: [String: [Double]] = [:]
        out.reserveCapacity(cap)
        for k in keep {
            if out.count >= cap { break }
            if let v = table[k] { out[k] = v }
        }
        if out.count < cap {
            for k in table.keys.sorted() where out[k] == nil {
                out[k] = table[k]
                if out.count >= cap { break }
            }
        }
        return out
    }

    static func leftoverCaptureHistLookup(
        hash: String,
        fallback: String? = nil,
        table: [String: [Double]]
    ) -> [Double]? {
        if let v = table[hash], !v.isEmpty { return v }
        if let fallback, fallback != hash, let v = table[fallback], !v.isEmpty { return v }
        let spatial = leftoverHoldHashSpatial(hash)
        if spatial != hash, let v = table[spatial], !v.isEmpty { return v }
        return nil
    }

    static func leftoverCaptureHistTablePut(
        hash: String,
        hist: [Double],
        onto table: [String: [Double]],
        cap: Int = leftoverHashHoldCapN
    ) -> [String: [Double]] {
        var next = table
        let e = leftoverCaptureHistEncode(hist)
        if e.isEmpty {
            next.removeValue(forKey: hash)
            return leftoverCaptureHistTableCapped(next, cap: cap)
        }
        next[hash] = e
        return leftoverCaptureHistTableCapped(next, keep: [hash], cap: cap)
    }

    static func leftoverHashTrailEncode(_ table: [String: (samples: [Double], at: TimeInterval)]) -> [String: [Double]] {
        Dictionary(uniqueKeysWithValues: leftoverHashTrailCapped(table.filter { !$0.value.samples.isEmpty }).map { ($0.key, $0.value.samples) })
    }

    static func leftoverHashTrailDecode(_ raw: [String: [Double]]?, now: TimeInterval) -> [String: (samples: [Double], at: TimeInterval)] {
        guard let raw else { return [:] }
        return leftoverHashTrailCapped(Dictionary(uniqueKeysWithValues: raw.filter { !$0.value.isEmpty }.map { ($0.key, (samples: $0.value, at: now)) }))
    }

    /// Nach Restore: TTL darf nicht 1,2 s nach App-Start sterben. Erstes Live-Tick setzt `at`.
    static func leftoverHashHoldRebase(
        _ table: [String: (cosine: Double, at: TimeInterval)],
        now: TimeInterval
    ) -> [String: (cosine: Double, at: TimeInterval)] {
        Dictionary(uniqueKeysWithValues: table.map { ($0.key, (cosine: $0.value.cosine, at: now)) })
    }

    static func leftoverHashTrailRebase(
        _ table: [String: (samples: [Double], at: TimeInterval)],
        now: TimeInterval
    ) -> [String: (samples: [Double], at: TimeInterval)] {
        Dictionary(uniqueKeysWithValues: table.map { ($0.key, (samples: $0.value.samples, at: now)) })
    }

    static func leftoverCaptureHistEncode(_ hist: [Double]) -> [Double] {
        Array(hist.suffix(leftoverCaptureHistCap))
    }

    /// 720p @ 15–30 schlägt 360p @ 60 und 800p @ 8. Desk-View 4:3 bis 1920×1440.
    /// Analog Helios formatScore.
    static func captureFormatScore(width: Double, height: Double, fps: Double) -> Double {
        let long = max(width, height)
        let short = min(width, height)
        guard short >= 360, long >= 640, long <= 1920, short <= 1440, fps >= 7 else { return -1 }
        let near720 = 1.0 - min(abs(short - 720) / 720, 1)
        let res = near720 * 80 + min(long / 1280, 1.1) * 20
        let fpsTerm: Double
        if fps >= 24 {
            fpsTerm = 55 + min(fps, 30) - 24
        } else if fps >= 15 {
            fpsTerm = 38 + (fps - 15) * 1.5
        } else if fps >= 12 {
            fpsTerm = 22
        } else {
            fpsTerm = fps * 1.5
        }
        let lowFpsPenalty = fps < 12 ? 40.0 : 0
        let tinyPenalty = short < 480 ? 50.0 : 0
        let aspect = long / max(1, short)
        let deskBonus = (aspect > 1.20 && aspect < 1.45 && fps >= 15) ? 12.0 : 0
        return res + fpsTerm - lowFpsPenalty - tinyPenalty + deskBonus
    }

    static let captureFourCC420f: UInt32 = 0x34323066
    static let captureFourCC420v: UInt32 = 0x34323076
    static let captureFourCCBGRA: UInt32 = 0x42475241

    static func capturePixelBonus(osType: UInt32, fps: Double) -> Double {
        let is420 = osType == captureFourCC420f || osType == captureFourCC420v
        if is420 && fps >= 15 { return 25 }
        if osType == captureFourCCBGRA && fps < 12 { return -35 }
        return 0
    }

    static func leftoverBlurBlocks(sharpness: Double?, cosine: Double?) -> Bool {
        if leftoverBaptize(cosine: cosine) { return false }
        guard let s = sharpness else { return false }
        return s < sharpnessFloor
    }

    /// Scharfer Print gewinnt gegen leicht höheren unscharfen (0,72 scharf > 0,73 blur).
    /// Profil-Yaw zieht den Score — Twin im Profil tauft sonst den Frontal-Nachbarn.
    static let leftoverSharpBonus = 0.05
    static let leftoverYawPenalty = 0.12

    static func leftoverScore(cosine: Double, sharpness: Double?, yawAbs: Double = 0, detScore: Double? = nil, twinPair: Double? = nil, capture: Double? = nil) -> Double {
        var s: Double
        if let sh = sharpness {
            let floor = leftoverPrintSharpOf(capture: capture)
            let t = min(1, max(0, (sh - floor) / 0.20))
            s = cosine * (0.88 + leftoverSharpBonus * 2.4 * t)
        } else {
            s = cosine
        }
        s -= leftoverYawPenalty * min(1, max(0, yawAbs / 0.50))
        if let d = detScore {
            let n = d > 1 ? d / 100 : d
            s += leftoverDetBonus * min(1, max(0, n))
        }
        if let t = twinPair, t >= leftoverTwinSameShot {
            s -= leftoverTwinScorePenalty * min(1, max(0, (t - leftoverTwinSameShot) / 0.04))
        }
        s += leftoverScoreTempK * leftoverScoreHeat(cosine, mid: leftoverScoreHeatMid(capture: capture))
        return s
    }

    static let leftoverDetBonus = 0.04
    static let leftoverTwinScorePenalty = 0.06
    static let leftoverScoreTemp: Double = 16
    static let leftoverScoreTempK: Double = 0.10
    static let leftoverScoreTempMid: Double = 0.72

    /// Nacht Heat-Mid 0,60. Tag 0,72 ließ Genuine 0,62 tot.
    static func leftoverScoreHeatMid(capture: Double? = nil) -> Double {
        leftoverSessionLumaLow(capture) ? 0.60 : leftoverScoreTempMid
    }

    static func leftoverScoreHeat(_ cosine: Double, t: Double = leftoverScoreTemp, mid: Double = leftoverScoreTempMid) -> Double {
        let z = t * (cosine - mid)
        if z > 20 { return 1 }
        if z < -20 { return 0 }
        return 1 / (1 + exp(-z))
    }

    static func leftoverScoreSoftmax(_ scores: [Double], t: Double = leftoverScoreTemp) -> [Double] {
        guard !scores.isEmpty else { return [] }
        let m = scores.max() ?? 0
        let exps = scores.map { s -> Double in
            let z = t * (s - m)
            if z < -20 { return 0 }
            return exp(z)
        }
        let z = exps.reduce(0, +)
        guard z > 0 else { return scores.map { _ in 1 / Double(scores.count) } }
        return exps.map { $0 / z }
    }

    static let leftoverSoftmaxFloor: Double = 0.55

    static func leftoverSoftmaxFloorOf(capture: Double? = nil) -> Double {
        leftoverSessionLumaLow(capture) ? leftoverSoftmaxFloor - 0.08 : leftoverSoftmaxFloor
    }

    static func leftoverSoftmaxBlocks(_ p: [Double], floor: Double? = nil, capture: Double? = nil) -> Bool {
        guard p.count >= 2 else { return false }
        let f = floor ?? leftoverSoftmaxFloorOf(capture: capture)
        return (p.max() ?? 0) < f
    }

    /// Twin: Anna links bleibt links. Gast-Kiste rechts stiehlt nicht.
    static func leftoverBoxOrderKeeps(prevX: Double, candX: Double, others: [Double], minGap: Double = 40) -> Bool {
        guard let other = others.min(by: { abs($0 - prevX) < abs($1 - prevX) }) else { return true }
        if abs(prevX - other) < minGap { return true }
        let wasLeft = prevX < other
        return wasLeft ? candX <= other : candX >= other
    }

    /// 4K: 40 px ist Überlapp. 4 % Bildbreite, sonst Order bei 80 px Jitter.
    static func leftoverBoxOrderGap(imageW: Double, minGap: Double = 40) -> Double {
        imageW > 1 ? max(minGap, imageW * 0.04) : minGap
    }

    /// Overlay: Hold 0,64 → 0,90 als 8 Samples, nicht nur Label.
    static func leftoverCosineSparkPut(_ sample: Double, onto trail: [Double], cap: Int = 8) -> [Double] {
        var t = trail
        t.append(sample)
        if t.count > cap { t.removeFirst(t.count - cap) }
        return t
    }

    static func leftoverCosineSparkLabel(_ trail: [Double]) -> String? {
        guard trail.count >= 2 else { return nil }
        func fmt(_ x: Double) -> String {
            leftoverHoldFrac(x)
        }
        return "\(fmt(trail[0]))→\(fmt(trail[trail.count - 1]))"
    }

    /// ¾ Spark aus Bin-Trail, nicht Frontal-UUID.
    static func leftoverCosineSparkLabelOf(idTrail: [Double], binTrail: [Double] = [], yawAbs: Double? = nil) -> String? {
        leftoverCosineSparkLabel(leftoverTrailNowOf(idTrail: idTrail, binTrail: binTrail, yawAbs: yawAbs))
    }

    /// Score-EMA 3-Tick. bugfix 2.1.15, nicht den Branch mergen.
    static func leftoverScoreTickPut(_ sample: Double, onto ticks: [Double], cap: Int = 3) -> [Double] {
        leftoverCosineSparkPut(sample, onto: ticks, cap: cap)
    }

    static func leftoverScoreTickMean(_ ticks: [Double]) -> Double? {
        guard !ticks.isEmpty else { return nil }
        return ticks.reduce(0, +) / Double(ticks.count)
    }

    /// Live-Name 3 gleiche Ticks hintereinander. Mehrheit 5 bleibt für Look≠Print.
    static func leftoverLiveNameHolds(_ hist: [String], need: Int = 3) -> String? {
        guard hist.count >= need else { return nil }
        let tail = Array(hist.suffix(need))
        guard Set(tail).count == 1, let name = tail.last, !name.isEmpty else { return nil }
        return name
    }

    /// 8 fps Overlay flackert Spark. 2 Extra-Frames peak-hold.
    static func overlayChipPeakHold(current: String?, held: String?, remaining: Int, need: Int = 2) -> (chip: String?, remaining: Int) {
        if let c = current, !c.isEmpty { return (c, need) }
        if remaining > 0, let h = held, !h.isEmpty { return (h, remaining - 1) }
        return (nil, 0)
    }

    /// JPEG 70 % Probe: Cosine-Drop > 0,06 = Poster, keine Taufe.
    static func leftoverBaptizeJpeg(delta: Double, maxDelta: Double = 0.06) -> Bool {
        delta <= maxDelta
    }

    /// Lid-Gap 2 Frames offen vor Taufe. Poster/Foto blinzelt nicht.
    static func leftoverBlinkLiveness(open: Bool, openStreak: Int, need: Int = 2) -> (ok: Bool, streak: Int) {
        if !open { return (false, 0) }
        let n = openStreak + 1
        return (n >= need, n)
    }

    /// Continuity-Reconnect schaltet Center Stage wieder an.
    static func reconnectCenterStageOff(continuity: Bool, enabled: Bool) -> Bool {
        continuity && centerStageNeedsReassert(enabled: enabled)
    }

    static func leftoverLiveWeight(sharpness: Double?, frontal: Double?, yawAbs: Double?) -> Double {
        let s = max(0, sharpness ?? 0)
        let f = max(0.15, frontal ?? 1)
        let y = 1 - min(1, max(0, (yawAbs ?? 0) / 0.50))
        return s * f * max(0.15, y)
    }

    /// Profil-Print 0,05 zieht den Live-Mean nicht, solange Frontal 0,50 da ist.
    static func liveCentroidKeepsPrint(weight: Double, best: Double, floor: Double = 0.08) -> Bool {
        if best <= floor { return weight > 0 }
        return weight >= max(floor, best * 0.28)
    }

    /// Bewegung + Unschärfe: neuen Print nicht übernehmen. Scharfes Nicken (IoU 0,75) darf.
    static func holdStillSkip(iou: Double, sharpness: Double? = nil, floor: Double = holdStillIoU) -> Bool {
        if iou >= 0.82 { return false }
        if let s = sharpness {
            if s < holdStillSharp { return true }
            if iou < floor { return s < 0.28 }
            return false
        }
        return iou < floor
    }

    /// Yaw-Skip hat ein Geo-Veto verhindert — Overlay/Labor sollen das sehen.
    static func geoVetoYawSkipped(geoAgrees: Bool, geoMix: Double, printPercent: Double, yawAbs: Double) -> Bool {
        if geoAgrees { return false }
        if yawAbs < geoVetoYawSkip { return false }
        if printPercent < geoVetoYawPrint { return false }
        return geoVetoBlocks(geoAgrees: geoAgrees, geoMix: geoMix, printPercent: printPercent, yawAbs: 0)
    }

    static func yawSkipNote() -> String { "¾, Maße ignoriert" }

    static func poseMeterReady(frontal: Int, threeQuarter: Int) -> Bool {
        frontal >= 1 && threeQuarter >= 1
    }

    static func poseMeterLabel(frontal: Int, threeQuarter: Int, profile: Int, upper: Int) -> String {
        var miss: [String] = []
        if frontal == 0 { miss.append("Frontal") }
        if threeQuarter == 0 { miss.append("¾") }
        if miss.isEmpty {
            return "Pose fertig F\(frontal) · ¾\(threeQuarter) · P\(profile) · U\(upper)"
        }
        return "Pose fehlt \(miss.joined(separator: "+")) · F\(frontal) · ¾\(threeQuarter) · P\(profile) · U\(upper)"
    }

    /// Wohin den Kopf. Statuszeile „Pose fehlt ¾“ sagt nicht, was tun.
    /// yaw in Radiant (Vision: 0 = Kamera, |yaw| ≥ 0,28 = ¾, ≥ 0,70 = Profil).
    static func enrollmentCoach(haveFrontal: Bool, haveThreeQuarter: Bool, yaw: Double) -> String? {
        if haveFrontal && haveThreeQuarter { return nil }
        let absY = abs(yaw)
        if !haveFrontal {
            if absY < 0.28 { return "halten — Frontal sitzt" }
            if absY >= 0.70 { return "Blick zur Kamera — erste Referenz frontal" }
            return "Blick zur Kamera"
        }
        if absY >= 0.28 && absY < 0.70 { return "halten — ¾ sitzt" }
        if absY >= 0.70 { return "etwas zurück — ¾, nicht Profil" }
        return "Kopf nach links drehen (¾)"
    }

    /// Pose-Balken F/¾/P neben dem Namen. Coach sagt wohin, Balken sagt wie viel.
    static func poseMeter(frontal: Int, threeQuarter: Int, profile: Int, filled: Int = 2) -> String {
        func bar(_ n: Int) -> String {
            let f = min(filled, max(0, n))
            return String(repeating: "█", count: f) + String(repeating: "░", count: max(0, filled - f))
        }
        return "F \(bar(frontal)) ¾ \(bar(threeQuarter)) P \(bar(profile))"
    }

    /// Pfeil auf der Kiste. ‹ Blick links, › rechts, · halten.
    static func coachArrow(haveFrontal: Bool, haveThreeQuarter: Bool, yaw: Double) -> String? {
        if haveFrontal && haveThreeQuarter { return nil }
        let absY = abs(yaw)
        if !haveFrontal {
            if absY < 0.28 { return "·" }
            return yaw > 0 ? "‹" : "›"
        }
        if absY >= 0.28 && absY < 0.70 { return "·" }
        if absY >= 0.70 { return yaw > 0 ? "›" : "‹" }
        return "‹"
    }

    /// Hold-Still 0,8 s bevor ein neuer Print rausgeht. Overlay-Ring 0…1.
    static let holdStillNeed: TimeInterval = 0.80

    static func holdStillProgress(stillFor: TimeInterval, need: TimeInterval = holdStillNeed) -> Double {
        guard need > 0 else { return 1 }
        return min(1, max(0, stillFor / need))
    }

    static func holdStillReady(stillFor: TimeInterval, need: TimeInterval = holdStillNeed) -> Bool {
        stillFor >= need
    }

    /// SHA-256 der Galerie, 12 Hex. Sidecar, nicht im JSON (Henne-Ei).
    static func digestShort(_ hex: String, length: Int = 12) -> String {
        let clean = hex.lowercased().filter { $0.isHexDigit }
        guard !clean.isEmpty else { return "" }
        return String(clean.prefix(length))
    }

    /// Augen-Roll in Radiant. |roll| ≥ 8° → Crop drehen vor Face-Print.
    static func eyeRoll(left: CGPoint, right: CGPoint) -> Double {
        atan2(Double(right.y - left.y), Double(right.x - left.x))
    }

    static let cropAlignMinAbs = 8.0 * Double.pi / 180.0

    static func cropAligns(roll: Double, minAbs: Double = cropAlignMinAbs) -> Bool {
        abs(roll) >= minAbs
    }

    static func labCSVHeader() -> String {
        "face,strategy,identity,percent,note"
    }

    static func labCSVRow(face: String, strategy: String, identity: String, percent: Double, note: String = "") -> String {
        func field(_ raw: String) -> String {
            if raw.contains(",") || raw.contains("\"") || raw.contains("\n") {
                return "\"" + raw.replacingOccurrences(of: "\"", with: "\"\"") + "\""
            }
            return raw
        }
        return [
            field(face),
            field(strategy),
            field(identity),
            String(format: "%.1f", percent),
            field(note)
        ].joined(separator: ",")
    }

    static let printAgePaleDays = 90.0
    static let restoreAgeDays = 7.0

    static func printAgeDays(enrolledAt: Date?, now: Date = Date()) -> Double? {
        guard let enrolledAt else { return nil }
        return now.timeIntervalSince(enrolledAt) / 86_400
    }

    static func printAgePaler(enrolledAt: Date?, now: Date = Date(), days: Double = printAgePaleDays) -> Bool {
        guard let age = printAgeDays(enrolledAt: enrolledAt, now: now) else { return false }
        return age >= days
    }

    /// Live-Centroid: blasse Prints (≥ 90 d) raus, solange frische bleiben.
    static func palePrintDrops(enrolledAt: Date?, now: Date = Date(), days: Double = printAgePaleDays) -> Bool {
        printAgePaler(enrolledAt: enrolledAt, now: now, days: days)
    }

    static func palePrintDroppedCount<T>(_ items: [T], enrolledAt: (T) -> Date?, now: Date = Date()) -> Int {
        items.filter { palePrintDrops(enrolledAt: enrolledAt($0), now: now) }.count
    }

    /// Cache-Key am Identity-Modell. IDs sortiert, Slot, Pale-Count, Kamera — sonst Built-in-Centroid auf Continuity.
    static func liveCentroidCacheKey(ids: [UUID], slot: String, paleDropped: Int, camera: String? = nil) -> String {
        let sorted = ids.map(\.uuidString).sorted().joined(separator: ",")
        let cam = camera?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if cam.isEmpty { return "\(sorted)|\(slot)|\(paleDropped)" }
        return "\(sorted)|\(slot)|\(paleDropped)|\(cam)"
    }

    /// Kisten-Zahl springt: Overlay-Blitz. Erster Kopf (0→n) kein Flash.
    static let headCountFlashHold: TimeInterval = 0.45

    static func headCountJumped(prev: Int, next: Int) -> Bool {
        prev > 0 && next != prev
    }

    static func headCountFlashLabel(prev: Int, next: Int) -> String? {
        guard headCountJumped(prev: prev, next: next) else { return nil }
        return "KOPF \(prev)→\(next)"
    }

    /// Continuity-Floor: Schärfe würde Built-in ablehnen, Continuity nicht.
    static func sparkContinuityFloor(sharpness: Double, continuity: Bool) -> Bool {
        continuity && sharpness >= continuitySharpnessFloor && sharpness < sharpnessFloor
    }

    static func liveGeoSpark(_ geoMix: Double) -> String {
        String(format: "G%.0f", geoMix)
    }

    static func trackHoldLabel(held: Bool) -> String {
        held ? "gehalten" : "neu"
    }

    static func restoreNeedsConfirm(
        ageDays: Double,
        schemaVersion: Int?,
        printRevision: String?,
        currentRevision: String = MatchMath.printRevision
    ) -> Bool {
        if ageDays >= restoreAgeDays { return true }
        if (schemaVersion ?? 0) < gallerySchema { return true }
        if let printRevision, printRevision != currentRevision { return true }
        return false
    }

    static func restoreNote(ageDays: Double, schemaVersion: Int?, printRevision: String?) -> String {
        var bits: [String] = []
        if ageDays >= restoreAgeDays {
            bits.append(String(format: "Backup %.0f Tage alt", ageDays))
        }
        if (schemaVersion ?? 0) < gallerySchema {
            bits.append("Schema \(schemaVersion.map(String.init) ?? "<\(gallerySchema)")")
        }
        if let printRevision, printRevision != MatchMath.printRevision {
            bits.append("Print \(printRevision)")
        }
        if bits.isEmpty {
            return "Backup laden — aktuelle Galerie wird ersetzt."
        }
        return bits.joined(separator: " · ") + " — aktuelle Galerie wird ersetzt."
    }

    /// Hysterese hält die Vorperson-Box, Print-Pin sagt dieselbe Person → Euro reset, neue Box.
    static func boxEuroResetOnHysteresis(iou: Double, cosine: Double?) -> Bool {
        guard boxHysteresisHold(iou: iou) else { return false }
        guard let cosine else { return false }
        return pinByPrint(cosine: cosine)
    }

    static func identityRatios(_ identity: [Bool], _ values: [Double]) -> [Double] {
        zip(identity, values).compactMap { $0 ? $1 : nil }
    }

    /// TER-Fusion ist Diagnose, nicht Taufe.
    static var diagnoseOnly: Set<String> { ["terFusion"] }

    /// Slot-Centroid wenn der Slot Refs hat, sonst Frontal — nie Profil-Mix.
    static func preferSlotCentroid(slotCount: Int) -> Bool {
        slotCount >= 1
    }

    /// IoU darf eine UUID nicht setzen, wenn der Print gemessen und unter pinPrintCosine liegt.
    /// nil = kein Print → IoU darf (Hysterese).
    static func iouPrintBlocks(cosine: Double?, floor: Double = pinPrintCosine) -> Bool {
        guard let cosine else { return false }
        return cosine < floor
    }

    static func trackPin(iou: Double, enrolled: Bool) -> Bool {
        iou >= (enrolled ? trackPinIoU : leftoverIoU)
    }

    /// Overlay-Warnung „andere Person“ — Genuine-Cosine 0,62 darf nicht feuern.
    static func overlayAlienHint(cosine: Double, floor: Double = hintCosineFloor) -> Bool {
        cosine < floor
    }

    /// Overlay: erste Klausel der decide-Notiz. Volle Zeile bleibt in der Seitenliste.
    static func overlayNoteFirst(_ note: String) -> String {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }
        if let r = trimmed.range(of: " — ") {
            return String(trimmed[..<r.lowerBound])
        }
        if let r = trimmed.range(of: ". ") {
            return String(trimmed[..<r.lowerBound])
        }
        return trimmed
    }

    /// Landmark-Verhältnisse, nicht L2. 100 = identisch, 0 = tot.
    static func ratioPercent(_ a: [Double], _ b: [Double]) -> Double {
        let n = min(a.count, b.count)
        guard n > 0 else { return 0 }
        var s = 0.0
        for i in 0 ..< n {
            let denom = max(abs(a[i]), abs(b[i]), 0.08)
            s += abs(a[i] - b[i]) / denom
        }
        let mre = s / Double(n)
        return 100.0 / (1.0 + exp(28.0 * (mre - 0.18)))
    }

    /// Komponenten-Median ohne L2 — für ratioSheet, nicht Face-Print.
    static func medianComponents(_ vectors: [[Double]]) -> [Double] {
        let pool = vectors.filter { !$0.isEmpty }
        guard let dim = pool.first?.count else { return [] }
        let aligned = pool.filter { $0.count == dim }
        guard !aligned.isEmpty else { return [] }
        if aligned.count == 1 { return aligned[0] }
        var out = [Double](repeating: 0, count: dim)
        var col = [Double](repeating: 0, count: aligned.count)
        for i in 0 ..< dim {
            for (j, v) in aligned.enumerated() { col[j] = v[i] }
            col.sort()
            if col.count % 2 == 1 {
                out[i] = col[col.count / 2]
            } else {
                out[i] = (col[col.count / 2 - 1] + col[col.count / 2]) / 2
            }
        }
        return out
    }

    /// Fehlende Geo darf nicht vetoen. Sonst Print-Gewinner vs. Geo-Gewinner.
    static func liveGeoAgrees(printBest: UUID?, geoBest: UUID?, geoAvailable: Bool) -> Bool {
        if !geoAvailable { return true }
        return printBest != nil && printBest == geoBest
    }

    /// 8 fps vs 24 fps: höherer Cutoff bei großem dt, sonst hängt die Box einen Frame hinterher.
    static func oneEuroCutoff(base: Double, dt: Double, boxArea: Double = 1) -> Double {
        let dtMul = dt >= 0.10 ? 1.7 : 1.0
        let areaMul = boxArea > 0 && boxArea < 0.04 ? 1.45 : 1.0
        return base * dtMul * areaMul
    }

    /// Labor auf schon eingeschriebenen Refs: Continuity-Floor 0,08, nicht 0,12.
    static func laborQualityRejects(capture: Double, size: Double, sharpness: Double) -> Bool {
        qualityRejects(capture: capture, size: size, sharpness: sharpness, continuity: true)
    }

    /// ASCII-Spark 0…100, 10 Bins. Labor, nicht Live.
    static func scoreHistogram(_ xs: [Double], bins: Int = 10, lo: Double = 0, hi: Double = 100) -> String {
        let n = max(1, bins)
        guard !xs.isEmpty else { return String(repeating: "▁", count: n) }
        let width = max(1e-9, (hi - lo) / Double(n))
        var counts = [Int](repeating: 0, count: n)
        for x in xs {
            var i = Int(((x - lo) / width).rounded(.down))
            i = min(n - 1, max(0, i))
            counts[i] += 1
        }
        let maxC = max(1, counts.max() ?? 1)
        let bars = Array("▁▂▃▄▅▆▇█")
        return counts.map { c in
            let idx = min(bars.count - 1, Int((Double(c) / Double(maxC) * Double(bars.count - 1)).rounded()))
            return String(bars[idx])
        }.joined()
    }


    enum Lamp: String, Equatable {
        case green, amber, red
    }

    /// Live-Ampel, bevor ein Name kommt. Grün/Amber/Rot für Capture, Schärfe, Yaw.
    static func qualityLamps(capture: Double, sharpness: Double, yaw: Double, continuity: Bool = false) -> (capture: Lamp, sharpness: Lamp, yaw: Lamp) {
        func cap(_ v: Double, good: Double, ok: Double) -> Lamp {
            if v >= good { return .green }
            if v >= ok { return .amber }
            return .red
        }
        let ay = abs(yaw)
        let yawLamp: Lamp
        if ay < 0.28 { yawLamp = .green }
        else if ay < 0.70 { yawLamp = .amber }
        else { yawLamp = .red }
        return (
            cap(capture, good: 0.50, ok: 0.35),
            cap(sharpness, good: 0.22, ok: activeSharpnessFloor(continuity: continuity)),
            yawLamp
        )
    }

    /// Laplacian unter Floor: Print-Request lohnt nicht.
    /// Continuity/Desk-View oft 0,10–0,14 — dort 0,08 statt 0,12.
    static func skipPrint(sharpness: Double, continuity: Bool = false) -> Bool {
        sharpness < activeSharpnessFloor(continuity: continuity)
    }

    /// Ampel über bis zu 8 Frames: schlechteste Capture/Schärfe, größtes |Yaw|.
    static func sparkLamps(captures: [Double], sharps: [Double], yaws: [Double], continuity: Bool = false) -> (capture: Lamp, sharpness: Lamp, yaw: Lamp) {
        qualityLamps(
            capture: captures.min() ?? 0,
            sharpness: sharps.min() ?? 0,
            yaw: yaws.map { abs($0) }.max() ?? 0,
            continuity: continuity
        )
    }

    /// Continuity-Override. nil = Auto aus `videoRotationAngle`.
    static func orientOverride(_ stored: String) -> String? {
        switch stored {
        case "0": return "up"
        case "90": return "right"
        case "180": return "down"
        case "270": return "left"
        default: return nil
        }
    }

    struct Floors: Equatable {
        var match: Double
        var solo: Double
    }

    /// Slider ist Bias um 78. Kleine Galerien brauchen höhere Floors.
    /// Solo +2 (nicht +4): sonst landet ein echter 86er-Print unter der Linie.
    static func floors(gallery: Int, slider: Double, familyBump: Double = 0) -> Floors {
        let rec: Double
        if gallery <= 1 { rec = 84 }
        else if gallery <= 3 { rec = 80 }
        else { rec = 78 }
        let match = min(96, max(70, rec + (slider - 78) + familyBump))
        return Floors(match: match, solo: min(96, match + 2))
    }

    /// Genuine Apple-FacePrint-Cosine typisch 0,62–0,92; Impostoren 0,15–0,50.
    static func printSigmoid(cosine: Double) -> Double {
        100.0 / (1.0 + exp(-printSigmoidSlope * (cosine - printSigmoidMid)))
    }

    /// `printMeasured`: Face-Print wurde wirklich berechnet.
    /// Ein Impostor-Print von 0,4 % ist **nicht** „KI aus“ — sonst gewinnt Geometrie
    /// und tauft Fremde. Print *ist* der Score; Geo vetoiert oder gibt bis +4.
    /// ≥ 80 niemals auf 60 kappen. Nur schwache Prints (< 70) bei toter Geo.
    static func lookOf(geo: Double, embed: Double, pose: Double = 1, printMeasured: Bool) -> Double {
        if !printMeasured { return geo }
        if geo < 1 { return embed }
        if embed >= strongPrintFloor {
            let agree = clamp01((geo - 52) / 38) * clamp01(pose)
            return min(100, embed + 4.0 * agree)
        }
        if embed >= 80 {
            if geo < 35 { return embed }
            let agree = clamp01((geo - 52) / 38) * clamp01(pose)
            return min(100, embed + 4.0 * agree)
        }
        if embed < 70, geo < 35 { return min(embed, 60) }
        if geo < 35 { return embed }
        let agree = clamp01((geo - 52) / 38) * clamp01(pose)
        return min(100, embed + 4.0 * agree)
    }

    /// lookOf hat den Print unter 70 bei toter Geo auf 60 gekappt.
    static func lookOfCapped(geo: Double, embed: Double) -> Bool {
        embed < 70 && geo < 35 && embed > 60
    }

    static func lookOfCapNote() -> String { "Print gekappt" }

    static func lookOfCapNote(geo: Double, embed: Double) -> String? {
        lookOfCapped(geo: geo, embed: embed) ? lookOfCapNote() : nil
    }

    /// Overlay: Print vs Look, wenn Geo das Look nicht kippt.
    static func lookPrintLabel(printPercent: Double, look: Double) -> String {
        String(format: "P %.0f · L %.0f", printPercent, look)
    }

    /// lookOf-Sieger und Print-Sieger müssen dieselbe UUID sein, sonst keine Taufe.
    /// Ohne gemessenen Print darf Look (der dann 0 ist) nicht blocken.
    static func liveNameAgree(lookId: UUID?, printId: UUID?, printMeasured: Bool) -> Bool {
        if !printMeasured { return true }
        return lookId != nil && lookId == printId
    }

    /// Look≠Print: Print führt, wenn der Abstand zum Zweit-Print klar ist.
    /// Geo-Rauschen (Jacke/Haar) hebt oft den Look-Geschwister über den echten Print-Sieger —
    /// dann war Live tot, weil `liveNameAgree` jeden Tick blockte.
    static let liveNamePrintMargin = 8.0
    /// Fremde: Geo-Jacke hebt Look oft 4–7 Punkte. 8 hat Genuine tot gemacht.
    static let liveNamePrintClear = 4.0

    static func liveNamePrintLeads(
        lookId: UUID?,
        printId: UUID?,
        printMeasured: Bool,
        printMargin: Double,
        family: Bool = false
    ) -> Bool {
        guard printMeasured, let lookId, let printId, lookId != printId else { return false }
        return printMargin >= (family ? liveNamePrintMargin : liveNamePrintClear)
    }

    static func liveNamePrintLeadsNote() -> String { "Print führt" }

    /// leftover wischt die Hist der Vorperson **einmal am Pin**.
    /// Jeden Tick leere Tokens zu füttern hungert Genuine 0,64–0,79 aus — nie Taufe.
    static func leftoverStarvesVote() -> Bool { false }

    /// Leere Look≠Print-Tokens belegen den Cap nicht.
    /// Sonst wischen 10 Uneinig-Ticks die Familien-Taufe, obwohl agreeing sie filtert.
    static func nameHistAppend(_ history: [String], token: String, cap: Int) -> [String] {
        var hist = history
        if !token.isEmpty {
            hist.append(token)
        }
        let keep = max(1, cap)
        if hist.count > keep {
            hist.removeFirst(hist.count - keep)
        }
        return hist
    }

    /// Nach Mehrheit: Name bleibt, bis eine andere ID die Mehrheit hat
    /// **oder** der Print der Lock-ID unter 0,50 fällt.
    /// Kein Mehrheit ≠ nil — sonst ein Frame Uneinig = Overlay tot.
    static let nameLockPrintFloor = 0.50

    static func nameLockDrops(printCosine: Double?, missing: Bool = false, floor: Double = nameLockPrintFloor) -> Bool {
        if missing { return true }
        guard let printCosine else { return false }
        return printCosine < floor
    }

    static func nameLockHolds(
        voted: String?,
        locked: String?,
        lockedPrint: Double? = nil,
        lastVote: TimeInterval? = nil,
        now: TimeInterval = 0
    ) -> String? {
        if let voted, !voted.isEmpty { return voted }
        if lastVote != nil, now > 0, nameLockExpired(lastVote: lastVote, now: now) {
            return nil
        }
        if let locked, !locked.isEmpty {
            if nameLockDrops(printCosine: lockedPrint) { return nil }
            return locked
        }
        return nil
    }

    /// leftover 0,64–0,79: Lock der Vorperson nicht anwenden.
    /// Sonst nameLockHolds(voted:nil, locked:Anna) tauft ohne Vote.
    static func leftoverSkipsLock(holding: Bool) -> Bool { holding }

    /// Lock nur ohne leftover-Hold. Mehrheit (voted) bleibt der Tauf-Pfad.
    static func leftoverLocked(locked: String?, holding: Bool) -> String? {
        leftoverSkipsLock(holding: holding) ? nil : locked
    }

    static func liveNameDisagreeNote() -> String { "Look und Print uneinig" }

    /// IoU-Hysterese und Print-Pin uneinig → Print gewinnt im selben Pass (kein 2-Frame-Flackern).
    /// Namenlose IoU-Hold darf ein Print-Pin nicht stehlen.
    static func boxPinTakePrint(iouHold: Bool, printPinDifferent: Bool, printEnrolled: Bool = true) -> Bool {
        iouHold && printPinDifferent && printEnrolled
    }

    /// Median-Trail nur gleicher Pose-Slot. ¾ nicht mit Frontal mischen.
    static func printTrailAccepts(prevSlot: String?, nextSlot: String) -> Bool {
        guard let prev = prevSlot, !prev.isEmpty else { return true }
        return prev == nextSlot
    }

    static func slotCountLabel(frontal: Int, threeQuarter: Int, profile: Int, upper: Int) -> String {
        "F \(frontal) · ¾ \(threeQuarter) · P \(profile) · U \(upper)"
    }

    static func slotLetter(_ slot: String) -> String {
        switch slot {
        case "frontal": return "F"
        case "threeQuarter": return "¾"
        case "profile": return "P"
        case "upper": return "U"
        default: return "?"
        }
    }

    /// Overlay-Farbe analog Quality-Ampel. Tests als String.
    static func slotTone(_ slot: String) -> String {
        switch slot {
        case "frontal": return "green"
        case "threeQuarter": return "amber"
        case "profile": return "red"
        case "upper": return "violet"
        default: return "gray"
        }
    }

    enum OverlayBoxKind: String {
        case selected, enrolled, leftover, unmatched, ghost
    }

    /// Leftover-Kiste anders als enrolled — sonst wirkt 0,64 wie ein Name.
    /// Ghost/Leftover gestrichelt, sonst Gast-Sprung.
    static func overlayBoxKind(selected: Bool, pinned: Bool, leftover: Bool, ghost: Bool = false) -> OverlayBoxKind {
        if selected { return .selected }
        if ghost { return .ghost }
        if leftover { return .leftover }
        if pinned { return .enrolled }
        return .unmatched
    }

    static func overlayBoxDash(_ kind: OverlayBoxKind) -> [CGFloat] {
        switch kind {
        case .leftover, .ghost: return [5, 3]
        default: return []
        }
    }

    /// Taufe-Hold: „2/3“ bis Mehrheit sitzt. nil = getauft oder leer.
    static func nameVoteProgress(history: [String], need: Int) -> String? {
        let agreeing = history.filter { !$0.isEmpty }
        guard need > 0 else { return nil }
        let winner = nameMajority(agreeing, window: max(nameVoteFrames, need))
        let n = winner.map { w in agreeing.filter { $0 == w }.count } ?? 0
        if n >= need { return nil }
        return "\(n)/\(need)"
    }

    /// Overlay `hält` sobald Lock sitzt — Uneinig-Ticks wirken sonst tot.
    /// leftover hat eigenes Hold-Label, nicht den alten Namen halten.
    static func nameLockLabel(locked: Bool, leftover: Bool, progress: String?, ttl: String? = nil) -> String? {
        if leftover { return progress }
        if locked {
            if let ttl { return "hält · \(ttl)" }
            return "hält"
        }
        return progress
    }

    /// Kopf dreht: keine neue Stimme. |Δyaw| > 0,15 / Frame tauft sonst den Nachbarn.
    static let yawFreezePerFrame = 0.15

    static func yawVelocityFreeze(delta: Double, perFrame: Double = yawFreezePerFrame) -> Bool {
        abs(delta) > perFrame
    }

    /// Unscharfer Tick zählt nicht als Namensstimme. Trail skippt schon, Vote bisher nicht.
    static func nameVoteAccepts(
        sharpness: Double?,
        continuity: Bool,
        occluded: Bool = false,
        gazeAway: Bool = false,
        eyesClosed: Bool = false,
        mouthOpen: Bool = false
    ) -> Bool {
        if occluded || gazeAway || eyesClosed || mouthOpen { return false }
        guard let sharpness else { return true }
        return sharpness >= activeSharpnessFloor(continuity: continuity)
    }

    /// Gähnen / weites Mund: Mimik, keine Taufe. mouthH_iod.
    static let mouthOpenFloor = 0.42

    static func mouthOpen(heightIod: Double?, floor: Double = mouthOpenFloor) -> Bool {
        guard let heightIod else { return false }
        return heightIod >= floor
    }

    /// Lid / IOD unter Floor = zu. Gähnen/Blinzeln tauft nicht.
    static let eyesClosedFloor = 0.20

    static func eyesClosed(openIod: Double?, floor: Double = eyesClosedFloor) -> Bool {
        guard let openIod else { return false }
        return openIod < floor
    }

    /// Blick nicht zur Kamera: keine Taufe. Yaw 0,55 ≈ Profil, Pitch 0,40 ≈ Stirn/Kinn.
    static let gazeYawAbs = 0.55
    static let gazePitchAbs = 0.40

    static func gazeAway(yaw: Double, pitch: Double, yawLim: Double = gazeYawAbs, pitchLim: Double = gazePitchAbs) -> Bool {
        abs(yaw) > yawLim || abs(pitch) > pitchLim
    }

    /// leftover 1 Frame = Nachbar erbt UUID. 3 gleiche Picks, dann Zeit.
    /// 0,38 s war Vorbeigehen (8 fps 4 Frames). 1,2 s = Walk, nicht Taufe.
    static let leftoverAdoptFrames = 3
    static let leftoverAdoptSec: TimeInterval = 1.20
    static let leftoverAdoptCap = 80
    /// 15/24 fps Lock 0,80 s = 12 Frames bei 15 fps. Hart 1,2 s hungerte Taufe.
    static let leftoverAdoptSecLock: TimeInterval = 0.80
    /// 8 fps: 1,2 s = 9 Frames, Walker fällt durch. 1,6 s hält den Ghost.
    static let leftoverAdoptSecSlow: TimeInterval = 1.60
    /// Continuity-AE oft 2–3 s. 1,6 s Ghost = Gast n+1. Latch wie Helios 4 s.
    static let leftoverLatch: TimeInterval = 4.0

    /// Dropout-TTL folgt dem Takt. 8 fps Latch 4 s, 24 fps 1,2 s.
    static func dropoutTTL(dt: TimeInterval) -> TimeInterval {
        dt >= 0.08 ? leftoverLatch : leftoverAdoptSec
    }

    /// Fallback liveDt 0,125 darf nicht sticky machen. Erst 8 Samples.
    /// Sticky nach Licht-an nicht Session-ewig: 8 s nur-24-fps = Reset.
    static let dropoutSeenSlowReset: TimeInterval = 8.0

    static func dropoutSeenSlow(
        dt: TimeInterval,
        samples: Int,
        prev: Bool = false,
        fastFor: TimeInterval = 0,
        need: TimeInterval = dropoutSeenSlowReset
    ) -> Bool {
        if prev {
            if dt < 0.08, fastFor + 1e-9 >= need { return false }
            return true
        }
        guard samples >= 8 else { return false }
        return dt >= 0.08
    }

    /// Median-Hop 8→24: Latch nicht auf 1,2 s. Indoor-Holds sonst tot.
    static func dropoutTTLSticky(dt: TimeInterval, seenSlow: Bool) -> TimeInterval {
        seenSlow ? leftoverLatch : dropoutTTL(dt: dt)
    }

    static func liveGhostHold(dt: TimeInterval = 0.016) -> TimeInterval {
        dropoutTTL(dt: dt)
    }

    /// 8 fps: 1,2 s ist 10 Frames — Walker fällt durch. 15/24 fps Lock 0,80 s (12 Frames bei 15).
    /// ¾/Profil bleibt 1,2 s auch bei 15 fps — sonst Twin-Taufe in Pose.
    static func leftoverAdoptNeedSec(dt: TimeInterval, yawAbs: Double? = nil, lockPref: TimeInterval = leftoverAdoptSecLock) -> TimeInterval {
        if leftoverHoldBin(yawAbs: yawAbs ?? 0) != 0 { return leftoverAdoptSec }
        if dt <= 0 || dt >= 0.08 { return leftoverAdoptSec }
        return leftoverAdoptSecLockPref(lockPref)
    }

    static func leftoverAdoptNeed(dt: TimeInterval, yawAbs: Double? = nil, lockPref: TimeInterval = leftoverAdoptSecLock) -> Int {
        let step = max(0.008, min(0.20, dt <= 0 ? 0.125 : dt))
        let frames = Int(ceil(leftoverAdoptNeedSec(dt: dt, yawAbs: yawAbs, lockPref: lockPref) / step))
        return max(leftoverAdoptFrames, min(leftoverAdoptCap, frames))
    }

    static func leftoverAdoptReady(streak: Int, need: Int) -> Bool {
        streak >= need
    }

    /// dt-Sprung (2 fps → 8 fps) darf nicht nach 3 Frames taufen. Zeit + Mindestframes.
    static func leftoverAdoptReady(
        elapsed: TimeInterval,
        streak: Int,
        needSec: TimeInterval = leftoverAdoptSec,
        minFrames: Int = leftoverAdoptFrames,
        holdPrev: Double? = nil
    ) -> Bool {
        // Hash-Hold überlebte Dropout: die 1,2 s waren schon da. Nur echter Print, nicht 0,00.
        if leftoverPrintOk(cosine: holdPrev) { return streak >= 1 }
        return elapsed >= needSec && streak >= minFrames
    }

    /// Overlay während Streak: `1/10` in Zehnteln der 1,2 s, nicht Frames (24 fps wäre 1/75).
    static func leftoverStreakLabel(streak: Int, need: Int) -> String? {
        guard streak > 0, need > 0, streak < need else { return nil }
        return "\(streak)/\(need)"
    }

    static func leftoverStreakLabel(
        elapsed: TimeInterval,
        needSec: TimeInterval = leftoverAdoptSec,
        steps: Int = 10
    ) -> String? {
        guard elapsed > 0, needSec > 0, elapsed < needSec, steps > 1 else { return nil }
        let k = min(steps - 1, max(1, Int(floor(elapsed / needSec * Double(steps)))))
        return "\(k)/\(steps)"
    }

    static func leftoverSameTarget(iou: Double, floor: Double = leftoverIoU) -> Bool {
        iou > floor
    }

    static func leftoverStreakAdvance(prev: Int, sameTarget: Bool) -> Int {
        sameTarget ? prev + 1 : 1
    }

    /// Ein Twin-/Conflict-Tick löscht nicht. 3 Miss-Frames = Gast n+1.
    static let leftoverMissNeed = 3

    static func leftoverMissAdvance(prev: Int, hit: Bool) -> Int {
        hit ? 0 : prev + 1
    }

    static func leftoverMissClears(miss: Int, need: Int = leftoverMissNeed) -> Bool {
        miss >= need
    }

    /// Leerer Detector-Frame wischt Streak/Kalman nicht. 8 fps Dropout = Gast n+1 sonst.
    static func leftoverEmptyKeepsStreak(liveEmpty: Bool) -> Bool { liveEmpty }

    /// Overlay-Namen und Held-IDs bleiben am Ghost. 2.1.78 wischte leftoverPending — Kiste tot.
    static func leftoverEmptyKeepsOverlay(liveEmpty: Bool) -> Bool { liveEmpty }

    /// Tasche im Dunkeln: emptyKeeps nicht ewig. Latch wie Helios 4 s.
    static func leftoverLatchKeeps(emptyFor: TimeInterval, latch: TimeInterval = leftoverLatch) -> Bool {
        emptyFor >= 0 && emptyFor < latch
    }

    /// Overlay-Chip 0,4 s nach Latch-Ende, Kalman schon tot.
    static let leftoverHoldChip: TimeInterval = 0.40

    static func leftoverLatchChipKeeps(
        emptyFor: TimeInterval,
        latch: TimeInterval = leftoverLatch,
        chip: TimeInterval = leftoverHoldChip
    ) -> Bool {
        emptyFor >= 0 && emptyFor < latch + chip
    }

    /// Adopt-ID tot: Namen von der Ghost-UUID auf die Live-UUID.
    static func leftoverPendingMirror(pending: [UUID: String], from: UUID, to: UUID) -> [UUID: String] {
        guard from != to, let v = pending[from] else { return pending }
        var out = pending
        if out[to] == nil { out[to] = v }
        out.removeValue(forKey: from)
        return out
    }

    /// leftover Adopt hält Kalman+vx. Drop = Overlay-Sprung, Gast n+1.
    static func leftoverAdoptKeepsKalman() -> Bool { true }

    /// Adopt blendet die Live-Box durch den alten Kalman. Sonst erster Frame roh → Sprung.
    static func leftoverAdoptBlend(
        live: (x: Double, y: Double, w: Double, h: Double),
        kalman: (x: Double, y: Double, w: Double, h: Double)?,
        k: Double = 0.55
    ) -> (x: Double, y: Double, w: Double, h: Double) {
        guard let kalman else { return live }
        let a = min(1, max(0, k))
        return (
            x: a * live.x + (1 - a) * kalman.x,
            y: a * live.y + (1 - a) * kalman.y,
            w: a * live.w + (1 - a) * kalman.w,
            h: a * live.h + (1 - a) * kalman.h
        )
    }

    /// Predict nicht nur bei found.isEmpty — Poster/Gast ist emptyLike.
    static func leftoverPredictOnEmptyLike(_ emptyLike: Bool) -> Bool { emptyLike }

    /// Fremde Kiste (Poster, Gast) ist kein Reconnect. Latch bleibt.
    /// Nur gegen existing previous — erster Frame hat IoU 0, das ist kein Stranger.
    static func leftoverEmptyIgnoresStranger(foundIouMax: Double, floor: Double = 0.18) -> Bool {
        foundIouMax < floor
    }

    /// Blur darf Hold-EMA nicht schreiben — sonst Twin 0,70 klebt.
    /// sharpnessFloor 0,12, nicht leftoverPrintSharp 0,22 — Continuity Laplacian 0,12–0,14 sonst tot.
    /// ¾ 0,35 schreibt sonst den Frontal-Hold runter. Lookaway 0,28, nicht erst Profil 0,45.
    static func leftoverHoldWriteOk(sharpness: Double?, yawAbs: Double? = nil) -> Bool {
        if let y = yawAbs, y >= leftoverLookawayYaw { return false }
        guard let s = sharpness else { return true }
        return s >= sharpnessFloor
    }

    /// Galerie-Centroid: nur scharf + frontal. ¾ zieht Anna auf den Twin.
    static let leftoverCentroidFrontal = 0.70

    static func leftoverCentroidOk(sharpness: Double?, yawAbs: Double, frontal: Double = 1) -> Bool {
        leftoverHoldWriteOk(sharpness: sharpness, yawAbs: yawAbs) && frontal >= leftoverCentroidFrontal
    }

    /// front / ¾ / Profil. leftoverHold je Pose, nicht eine EMA für alle.
    static func leftoverHoldBin(yawAbs: Double) -> Int {
        if yawAbs >= leftoverPrintProfileYaw { return 2 }
        if yawAbs >= leftoverLookawayYaw { return 1 }
        return 0
    }

    static func leftoverHoldKey(id: UUID, bin: Int) -> String {
        "\(id.uuidString).\(bin)"
    }

    /// Hash-Bin, `#` damit Spatial-Dots nicht mit dem Bin kollidieren.
    static func leftoverHoldHashKey(hash: String, bin: Int) -> String {
        "\(hash)#\(bin)"
    }

    static func leftoverHoldId(from key: String) -> UUID? {
        guard let dot = key.lastIndex(of: ".") else { return UUID(uuidString: key) }
        return UUID(uuidString: String(key[..<dot]))
    }

    static func leftoverHoldBinRead(bins: [String: Double], id: UUID, bin: Int) -> Double? {
        bins[leftoverHoldKey(id: id, bin: bin)]
    }

    /// ¾/Profil erben nicht den Frontal-Hold. Sonst Smooth 0,68←0,80 tauft den Twin.
    static func leftoverHoldPrevOf(
        frontal: Double?,
        yawAbs: Double?,
        bins: [String: Double] = [:],
        id: UUID? = nil,
        hash: String? = nil,
        hashTable: [String: (cosine: Double, at: TimeInterval)] = [:],
        now: TimeInterval = 0,
        ttl: TimeInterval = leftoverAdoptSec,
        facesInFrame: Int = 1,
        occupied: [String] = []
    ) -> Double? {
        let bin = leftoverHoldBin(yawAbs: yawAbs ?? 0)
        if let id, let v = leftoverHoldBinRead(bins: bins, id: id, bin: bin) {
            return v
        }
        if let hash, !hashTable.isEmpty,
           let v = leftoverHoldLookup(hash: hash, table: hashTable, now: now, ttl: ttl, bin: bin, facesInFrame: facesInFrame, occupied: occupied)
        {
            return v
        }
        if bin == 0 { return frontal }
        return nil
    }

    /// ¾ liest nicht den Frontal-UUID-Trail. Sonst trailMean 0,81 tauft den Twin.
    static func leftoverTrailNowOf(idTrail: [Double], binTrail: [Double] = [], yawAbs: Double? = nil) -> [Double] {
        if leftoverHoldBin(yawAbs: yawAbs ?? 0) != 0 { return binTrail }
        return idTrail
    }

    static func leftoverHoldBinWriteOk(sharpness: Double?, yawAbs: Double = 0) -> Bool {
        leftoverHoldWriteOk(sharpness: sharpness)
    }

    static func leftoverHoldBinPut(
        bins: [String: Double],
        id: UUID,
        yawAbs: Double,
        next: Double,
        prev: Double? = nil,
        dt: TimeInterval = 0.016,
        captureJump: Double = 0
    ) -> [String: Double] {
        var out = bins
        let key = leftoverHoldKey(id: id, bin: leftoverHoldBin(yawAbs: yawAbs))
        out[key] = leftoverHoldEMA(
            prev: prev ?? out[key],
            next: next,
            alpha: leftoverHoldAlpha(dt: dt, captureJump: captureJump)
        )
        return out
    }

    static func leftoverHoldBinDrop(bins: [String: Double], id: UUID) -> [String: Double] {
        bins.filter { leftoverHoldId(from: $0.key) != id }
    }

    static func leftoverHoldIds(_ bins: [String: Double]) -> [UUID] {
        Array(Set(bins.keys.compactMap { leftoverHoldId(from: $0) }))
    }

    static func leftoverHoldSurviveBins(
        hold: [String: Double],
        ghosts: [UUID],
        live: [UUID] = [],
        emptyKeeps: Bool = false,
        emptyFor: TimeInterval = 0,
        locked: [UUID] = []
    ) -> [String: Double] {
        leftoverHoldSurviveBinMap(hold: hold, ghosts: ghosts, live: live, emptyKeeps: emptyKeeps, emptyFor: emptyFor, locked: locked)
    }

    static func leftoverHoldSurviveBinMap<Value>(
        hold: [String: Value],
        ghosts: [UUID],
        live: [UUID] = [],
        emptyKeeps: Bool = false,
        emptyFor: TimeInterval = 0,
        locked: [UUID] = []
    ) -> [String: Value] {
        let keep = Set(ghosts + live + locked)
        if keep.isEmpty {
            if emptyKeeps && leftoverLatchKeeps(emptyFor: emptyFor) { return hold }
            return [:]
        }
        return hold.filter { row in
            leftoverHoldId(from: row.key).map { keep.contains($0) } ?? false
        }
    }

    static let leftoverCaptureHistCap = 8

    static func leftoverCaptureHistPut(_ sample: Double, onto trail: [Double], cap: Int = leftoverCaptureHistCap) -> [Double] {
        leftoverCosineSparkPut(sample, onto: trail, cap: cap)
    }

    /// Gast mit eigener Hist (3+) erbt Annas Median nicht. Flash ohne Box-Hist: leftover bleibt.
    static func leftoverCaptureHistOf(box: [Double]?, leftover: [Double]?) -> [Double] {
        if let box, box.count >= 3 { return box }
        return leftover ?? []
    }

    /// Trail-Append dieselbe Schwelle. Roh 0,70 blur pollutet MAD.
    static func leftoverTrailWriteOk(sharpness: Double?, yawAbs: Double? = nil) -> Bool {
        leftoverHoldBinWriteOk(sharpness: sharpness, yawAbs: yawAbs ?? 0)
    }

    /// Zweiter leerer Frame: previous schon []. used∪dropped wischt Kalman. Ghosts+Hold halten.
    static func leftoverKeepBoxes(
        used: Set<UUID>,
        dropped: Set<UUID>,
        ghosts: [UUID] = [],
        hold: [UUID] = []
    ) -> Set<UUID> {
        var keep = used.union(dropped)
        keep.formUnion(ghosts)
        keep.formUnion(hold)
        return keep
    }

    /// Slot leer: Frontal-only, nie 72/28 mit Profil. ¾-Sonde vs All-Mean war weich.
    static func slotCentroidFallsBackToFrontal(slotCount: Int) -> Bool {
        slotCount == 0
    }

    static func boxIoU(
        ax: Double, ay: Double, aw: Double, ah: Double,
        bx: Double, by: Double, bw: Double, bh: Double
    ) -> Double {
        let x1 = max(ax, bx)
        let y1 = max(ay, by)
        let x2 = min(ax + aw, bx + bw)
        let y2 = min(ay + ah, by + bh)
        let inter = max(0, x2 - x1) * max(0, y2 - y1)
        let union = aw * ah + bw * bh - inter
        return union <= 0 ? 0 : inter / union
    }

    /// IoU-Kreuz: A und B tauschen die Box — UUIDs tauschen, nicht leftover-Adopt.
    /// 2.1.43: nur keep < pin. IoU-Hold klebt schon bei 0,30 — Swap war tot, Nachbar erbte.
    static func boxesCrossed(
        iouSameA: Double,
        iouSameB: Double,
        iouCrossAB: Double,
        iouCrossBA: Double,
        pin: Double = trackPinIoU,
        better: Double = 0.15
    ) -> Bool {
        let swap = iouCrossAB >= pin && iouCrossBA >= pin
        let lost = iouSameA < pin && iouSameB < pin
        let clearly = iouCrossAB >= iouSameA + better && iouCrossBA >= iouSameB + better
        return swap && (lost || clearly)
    }

    /// Nicken ist Yaw-Drehung: |Δ| / dt. 2.1.45 hat Pitch+Roll mit 0,15/Frame
    /// ohne Takt: Continuity 8 fps (Rauschen 0,12) fror jede Stimme.
    /// 8 fps: Yaw 0,15 / Pitch-Roll 0,18. 24 fps: 0,06 / 0,10.
    static func poseVelocityFreeze(
        yawDelta: Double,
        pitchDelta: Double,
        rollDelta: Double = 0,
        dt: TimeInterval = 0.125,
        perFrame: Double = yawFreezePerFrame
    ) -> Bool {
        let step = max(0.04, min(0.20, dt <= 0 ? 0.125 : dt))
        let yawLim = max(0.06, perFrame * (step / 0.125))
        let prLim = max(0.10, 0.18 * (step / 0.125))
        return abs(yawDelta) >= yawLim
            || abs(pitchDelta) >= prLim
            || abs(rollDelta) >= prLim
    }

    /// Overlay-Track unabhängig von der Snapshot-UUID.
    static func trackLabel(_ id: UUID?) -> String {
        guard let id else { return "T—" }
        let hex = id.uuidString.replacingOccurrences(of: "-", with: "")
        return "T" + String(hex.prefix(3)).uppercased()
    }

    /// Print zum Centroid über 8 Frames. Continuity-Drop ohne Konsole.
    static func printDriftSpark(_ samples: [Double], lo: Double = 50, hi: Double = 95) -> String {
        guard !samples.isEmpty else { return "" }
        let bars = Array("▁▂▃▄▅▆▇█")
        return samples.suffix(8).map { v -> String in
            let t = (v - lo) / max(1, hi - lo)
            let i = min(bars.count - 1, max(0, Int((t * Double(bars.count - 1)).rounded())))
            return String(bars[i])
        }.joined()
    }

    /// 3+ Köpfe: jedes Paar, nicht nur adopted.count == 2.
    static func pairSwapIndices(count: Int) -> [(Int, Int)] {
        guard count >= 2 else { return [] }
        var out: [(Int, Int)] = []
        for i in 0..<count {
            for j in (i + 1)..<count { out.append((i, j)) }
        }
        return out
    }

    /// IoU-Zuweisung klebt die UUID an die *Stelle*. Zwei Leute tauschen die Plätze:
    /// Keep-Print niedrig, Kreuz-Print hoch — IDs tauschen, nicht leftover.
    static func identitiesCrossed(
        keepA: Double,
        keepB: Double,
        crossAB: Double,
        crossBA: Double,
        floor: Double = leftoverPrintCosine,
        margin: Double = 0.08
    ) -> Bool {
        let swap = crossAB >= floor && crossBA >= floor
        let clearly = crossAB >= keepA + margin && crossBA >= keepB + margin
        return swap && clearly
    }

    /// Dropout: Lücke >> Kamera-dt → Pose neu, nicht Freeze aller Tracks.
    static func poseDropoutResets(gap: TimeInterval, cameraDt: TimeInterval) -> Bool {
        let step = max(0.04, cameraDt <= 0 ? 0.125 : cameraDt)
        return gap > step * 2.6
    }

    static func trackDt(now: TimeInterval, last: TimeInterval?, cameraDt: TimeInterval) -> TimeInterval {
        let cam = max(0.04, min(0.50, cameraDt <= 0 ? 0.125 : cameraDt))
        guard let last, last > 0, now > last else { return cam }
        let gap = now - last
        if poseDropoutResets(gap: gap, cameraDt: cam) { return cam }
        return min(0.50, max(0.04, gap))
    }

    /// Welche Achse freeze. nil = läuft.
    static func poseFreezeAxis(
        yawDelta: Double,
        pitchDelta: Double,
        rollDelta: Double = 0,
        dt: TimeInterval = 0.125
    ) -> String? {
        guard poseVelocityFreeze(
            yawDelta: yawDelta,
            pitchDelta: pitchDelta,
            rollDelta: rollDelta,
            dt: dt
        ) else { return nil }
        let step = max(0.04, min(0.20, dt <= 0 ? 0.125 : dt))
        let yawLim = max(0.06, yawFreezePerFrame * (step / 0.125))
        let prLim = max(0.10, 0.18 * (step / 0.125))
        var parts: [String] = []
        if abs(yawDelta) >= yawLim { parts.append("Y") }
        if abs(pitchDelta) >= prLim { parts.append("P") }
        if abs(rollDelta) >= prLim { parts.append("R") }
        return parts.isEmpty ? nil : parts.joined()
    }

    /// Spark aus Centroid-Cosine 0,50–0,95, nicht Hit-Prozent (LookOf 82 ≠ Drift).
    static func printDriftSample(centroidCosine: Double?) -> Double? {
        guard let centroidCosine, centroidCosine.isFinite else { return nil }
        return max(0, min(100, centroidCosine * 100))
    }

    /// gallery.json.sha256. Fehlend = alte Galerie, ok. Falsch = Banner.
    static func shaSidecarStatus(computed: String, sidecar: String?) -> (ok: Bool, missing: Bool) {
        let have = sidecar?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if have.isEmpty { return (true, true) }
        let a = computed.lowercased()
        let b = have.lowercased()
        return (a == b || b.hasPrefix(a) || a.hasPrefix(b), false)
    }

    static func shaVerifyNote(ok: Bool, missing: Bool) -> String? {
        if missing || ok { return nil }
        return "gallery.json.sha256 passt nicht — Backup laden?"
    }

    /// 3+ leftover: greedy + 2-opt. scores[row][col] höher besser, nil ungültig.
    static func leftoverAssign(scores: [[Double?]]) -> [Int?] {
        let n = scores.count
        guard n > 0 else { return [] }
        let m = scores[0].count
        guard m > 0 else { return Array(repeating: nil, count: n) }
        var result = [Int?](repeating: nil, count: n)
        var pairs: [(r: Int, c: Int, s: Double)] = []
        for r in 0..<n {
            guard r < scores.count, scores[r].count == m else { continue }
            for c in 0..<m {
                if let s = scores[r][c] { pairs.append((r, c, s)) }
            }
        }
        pairs.sort { $0.s > $1.s }
        var usedRows = Set<Int>()
        var usedCols = Set<Int>()
        for p in pairs {
            if usedRows.contains(p.r) || usedCols.contains(p.c) { continue }
            result[p.r] = p.c
            usedRows.insert(p.r)
            usedCols.insert(p.c)
        }
        var improved = true
        var guardN = 0
        while improved, guardN < 16 {
            improved = false
            guardN += 1
            var assigned = result.enumerated().compactMap { item -> (r: Int, c: Int)? in
                guard let c = item.element else { return nil }
                return (item.offset, c)
            }
            for i in 0..<assigned.count {
                for j in (i + 1)..<assigned.count {
                    let a = assigned[i]
                    let b = assigned[j]
                    let cur = (scores[a.r][a.c] ?? -1) + (scores[b.r][b.c] ?? -1)
                    guard let swA = scores[a.r][b.c], let swB = scores[b.r][a.c] else { continue }
                    if swA + swB > cur + 1e-9 {
                        result[a.r] = b.c
                        result[b.r] = a.c
                        assigned[i] = (a.r, b.c)
                        assigned[j] = (b.r, a.c)
                        improved = true
                    }
                }
            }
        }
        return result
    }

    /// 2-opt-Zeile: Top-2 Spread < 0,08 nicht zuweisen (Twin-Spalte).
    static func leftoverAssignDropAmbiguous(
        scores: [[Double?]],
        assigned: [Int?]
    ) -> [Int?] {
        var out = assigned
        let n = min(out.count, scores.count)
        for r in 0..<n {
            let vals = scores[r].compactMap { $0 }
            if leftoverAmbiguous(scores: vals) {
                out[r] = nil
            }
        }
        return out
    }

    /// Nach leftover-Wipe 800 ms stumm — Genuine 0,64 tauft den Nachbarn sonst sofort.
    static let leftoverWipeMuteSec: TimeInterval = 0.80

    static func leftoverWipeMuteUntil(now: TimeInterval, mute: TimeInterval = leftoverWipeMuteSec) -> TimeInterval {
        now + mute
    }

    static func leftoverWipeMutes(until: TimeInterval?, now: TimeInterval, histCount: Int = 0) -> Bool {
        guard let until, now < until else { return false }
        return histCount < leftoverWipeMuteHistFloor
    }

    /// Starke Lock (≥ 4 Stimmen) nicht 800 ms stumm nach Wipe.
    static let leftoverWipeMuteHistFloor = 4

    /// Nicken F→¾: 2 Frames halten, sonst ¾-Centroid auf Frontal-Sonde.
    static let poseSlotHoldNeed = 2

    static func poseSlotSticky(prev: String?, raw: String, hold: Int, need: Int = poseSlotHoldNeed) -> (slot: String, hold: Int) {
        if raw == "upper" { return ("upper", 0) }
        guard let prev, !prev.isEmpty, prev != "upper" else { return (raw, 0) }
        if raw == prev { return (prev, 0) }
        let n = hold + 1
        if n >= need { return (raw, 0) }
        return (prev, n)
    }

    /// Dropout > 0,40 s: IoU ist Müll, Print hält den Track.
    static let reconnectGapSec: TimeInterval = 0.40

    static func reconnectPrefersPrint(gap: TimeInterval, fromGhost: Bool = false, need: TimeInterval = reconnectGapSec) -> Bool {
        fromGhost || gap >= need
    }

    /// Ghost-Print < 0,80 stiehlt die UUID (Walker 0,64). Dropout ohne Print: IoU tot.
    static func reconnectGhostNeedsBaptize(fromGhost: Bool, cosine: Double?) -> Bool {
        fromGhost && !leftoverBaptize(cosine: cosine)
    }

    static func reconnectSkipsIoU(gap: TimeInterval, fromGhost: Bool = false) -> Bool {
        reconnectPrefersPrint(gap: gap, fromGhost: fromGhost)
    }

    /// Enrollment: gleicher Slot + Cosine 0,95 in 400 ms = Burst, nicht zweite Pose.
    static let enrollmentBurstWindow: TimeInterval = 0.40
    static let enrollmentBurstCosine = 0.95

    static func enrollmentBurstDup(
        sameSlot: Bool,
        cosine: Double?,
        within: TimeInterval,
        window: TimeInterval = enrollmentBurstWindow,
        floor: Double = enrollmentBurstCosine
    ) -> Bool {
        sameSlot && within >= 0 && within < window && (cosine ?? 0) >= floor
    }

    /// Nach Deskew: Laplacian < 0,10 = Motion-Blur, Print verwerfen.
    static let motionBlurFloor = 0.10

    static func motionBlurDrops(aligned: Bool, sharpness: Double, floor: Double = motionBlurFloor) -> Bool {
        aligned && sharpness < floor
    }

    static func swapFlashHold() -> TimeInterval { 0.45 }

    /// Pairwise ≥ 0,80: Badge statt still taufen.
    static func siblingBadge(pairCosine: Double?) -> String? {
        guard let pairCosine, pairCosine >= familyCosineLo else { return nil }
        return "Geschwister?"
    }

    static func liveNameDisagreeLabel(lookName: String?, printName: String?) -> String {
        "L \(lookName ?? "—") · P \(printName ?? "—")"
    }

    /// Rename: gleicher Name einer *anderen* Identität → Confirm.
    static func renameConflict(newName: String, existing: [String], selfName: String) -> Bool {
        let n = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty else { return false }
        return existing.contains { other in
            other.caseInsensitiveCompare(selfName) != .orderedSame
                && other.caseInsensitiveCompare(n) == .orderedSame
        }
    }

    /// Geschwister: Centroid-Cosine ≥ 0,80 → +4 Floor **für dieses Paar**.
    /// Keine obere Grenze — Zwillinge bei 0,91 brauchen den Bump am meisten.
    /// Nicht global: ein Geschwisterpaar darf den Rest der Galerie nicht anheben.
    static func familyBump(bestPairCosine: Double) -> Double {
        bestPairCosine >= familyCosineLo ? familyFloorBump : 0
    }

    static func familyBump(pairwiseCosine: [Double]) -> Double {
        familyBump(bestPairCosine: pairwiseCosine.max() ?? 0)
    }

    static func cosine(_ a: [Double], _ b: [Double]) -> Double {
        let n = min(a.count, b.count)
        guard n > 0 else { return 0 }
        var dot = 0.0
        var na = 0.0
        var nb = 0.0
        for i in 0 ..< n {
            dot += a[i] * b[i]
            na += a[i] * a[i]
            nb += b[i] * b[i]
        }
        let d = sqrt(na) * sqrt(nb)
        guard d > 1e-12 else { return 0 }
        return max(-1, min(1, dot / d))
    }

    static func l2normalize(_ v: [Double]) -> [Double] {
        var s = 0.0
        for x in v { s += x * x }
        let n = sqrt(s)
        guard n > 1e-12 else { return v }
        return v.map { $0 / n }
    }

    /// Komponenten-Median der letzten Live-Prints, dann L2. Weniger Glücks-Frame als One-Euro-alpha.
    static func medianBlend(_ vectors: [[Double]]) -> [Double] {
        let pool = vectors.filter { $0.count >= 32 }
        guard let dim = pool.first?.count else { return [] }
        let aligned = pool.filter { $0.count == dim }
        guard !aligned.isEmpty else { return [] }
        if aligned.count == 1 { return l2normalize(aligned[0]) }
        var out = [Double](repeating: 0, count: dim)
        var col = [Double](repeating: 0, count: aligned.count)
        for i in 0 ..< dim {
            for (j, v) in aligned.enumerated() { col[j] = v[i] }
            col.sort()
            if col.count % 2 == 1 {
                out[i] = col[col.count / 2]
            } else {
                out[i] = (col[col.count / 2 - 1] + col[col.count / 2]) / 2
            }
        }
        return l2normalize(out)
    }

    /// Landmark-Yaw in Radiant, wenn Vision 0/nil liefert. Nase links vom Augenmittel = negativ.
    static func yawFromLandmarks(leftEye: (x: Double, y: Double), rightEye: (x: Double, y: Double), nose: (x: Double, y: Double)?) -> Double {
        let midX = (leftEye.x + rightEye.x) / 2
        let span = max(1e-6, abs(rightEye.x - leftEye.x))
        let nx = nose?.x ?? midX
        let offset = (nx - midX) / span
        return max(-1.2, min(1.2, offset * 1.15))
    }

    static func visionYawMissing(_ yaw: Double) -> Bool {
        abs(yaw) < 0.02
    }

    /// Gewichteter Mittelvektor. `weights` parallel zu `vectors`.
    static func weightedMean(_ vectors: [[Double]], weights: [Double]) -> [Double] {
        guard !vectors.isEmpty, vectors.count == weights.count else { return [] }
        let dim = vectors[0].count
        guard dim >= 32 else { return [] }
        var acc = [Double](repeating: 0, count: dim)
        var wsum = 0.0
        for (v, wRaw) in zip(vectors, weights) {
            guard v.count == dim else { continue }
            let w = max(0.08, wRaw)
            for i in 0 ..< dim { acc[i] += v[i] * w }
            wsum += w
        }
        guard wsum > 0 else { return [] }
        let inv = 1.0 / wsum
        for i in acc.indices { acc[i] *= inv }
        return l2normalize(acc)
    }

    static func rejected(_ probe: [Double], by gallery: [[Double]]) -> Bool {
        guard probe.count >= 32 else { return false }
        for v in gallery where v.count == probe.count {
            if cosine(probe, v) >= rejectCosine { return true }
        }
        return false
    }

    static func tar(atFar far: Double, genuine: [Double], impostor: [Double]) -> (tar: Double, threshold: Double)? {
        guard !genuine.isEmpty, !impostor.isEmpty, far > 0, far < 1 else { return nil }
        let desc = impostor.sorted(by: >)
        // Ohne mindestens 1 Impostor bei FAR ist die Schwelle nicht definiert
        // (n=500 @ 0,1 % → m=0 → höchster Impostor, gelabelt als 0,1 % FAR).
        guard far * Double(desc.count) >= 1 else { return nil }
        let m = Int(far * Double(desc.count))
        let idx = min(desc.count - 1, max(0, m - 1))
        let t = desc[idx]
        let hits = genuine.filter { $0 >= t }.count
        return (Double(hits) / Double(genuine.count), t)
    }

    struct TarCI: Equatable {
        var tar: Double
        var threshold: Double
        var lo: Double
        var hi: Double
        var draws: Int
    }

    /// Bootstrap-95 %-CI, wenn n_impostor < 200. Sonst Punkt = Intervall.
    /// Eine Schwelle bei n=10 lügt — der CI macht das sichtbar.
    static func tarBootstrap(
        atFar far: Double,
        genuine: [Double],
        impostor: [Double],
        draws: Int = 200,
        seed: UInt64 = 0xAE615C4A
    ) -> TarCI? {
        guard let point = tar(atFar: far, genuine: genuine, impostor: impostor) else { return nil }
        if impostor.count >= 200 {
            return TarCI(tar: point.tar, threshold: point.threshold, lo: point.tar, hi: point.tar, draws: 0)
        }
        var state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
        func nextU() -> UInt64 {
            state &+= 0x9E3779B97F4A7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            return z ^ (z >> 31)
        }
        func pick(_ xs: [Double]) -> Double {
            xs[Int(nextU() % UInt64(xs.count))]
        }
        var rates: [Double] = []
        rates.reserveCapacity(draws)
        for _ in 0 ..< draws {
            let g = (0 ..< genuine.count).map { _ in pick(genuine) }
            let i = (0 ..< impostor.count).map { _ in pick(impostor) }
            if let t = tar(atFar: far, genuine: g, impostor: i) {
                rates.append(t.tar)
            }
        }
        guard !rates.isEmpty else {
            return TarCI(tar: point.tar, threshold: point.threshold, lo: point.tar, hi: point.tar, draws: 0)
        }
        rates.sort()
        let loI = max(0, Int((0.025 * Double(rates.count - 1)).rounded()))
        let hiI = min(rates.count - 1, Int((0.975 * Double(rates.count - 1)).rounded()))
        return TarCI(tar: point.tar, threshold: point.threshold, lo: rates[loI], hi: rates[hiI], draws: rates.count)
    }

    static func lowerFaceOccluded(eyes: Bool, mouth: Bool) -> Bool {
        eyes && !mouth
    }

    /// Leerer Print ist nicht automatisch eine Maske. Okklusion nur bei Augen ohne Mund.
    static func printDeadLabel(capture: Double, sharpness: Double, masked: Bool, continuity: Bool = false) -> String {
        if skipPrint(sharpness: sharpness, continuity: continuity) {
            return "Print tot · unscharf"
        }
        if masked { return "Print tot · Maske?" }
        if capture < 0.35 { return "Print tot · Aufnahme schwach" }
        return "Print tot"
    }

    /// Unscharf unter aktivem Floor: harte Ablehnung, nicht nur Score-Dämpfung.
    /// Continuity darf 0,10 — sonst skipPrint erzeugt den Print und qualityRejects wirft ihn weg.
    static func qualityRejects(capture: Double, size: Double, sharpness: Double, continuity: Bool = false) -> Bool {
        (capture < 0.35 && size < 0.16) || sharpness < activeSharpnessFloor(continuity: continuity)
    }

    /// Maske: voller Print enthält Stoff. Teil-Print (Stirn/Augen) führt, Deckel 88.
    /// Ohne Galerie-Teil-Print: nur den vollen Score dämpfen — nie Partial vs Full-Centroid.
    static func combinePrint(full: Double, partial: Double, occluded: Bool, galleryHasPartial: Bool = true) -> Double {
        guard occluded else { return full }
        if !galleryHasPartial {
            return full * 0.45
        }
        return max(full * 0.45, min(88, partial))
    }

    /// 1-Euro auf einem Skalar. Live-Box, nicht der Print.
    struct OneEuro {
        var minCutoff: Double = 1.2
        var beta: Double = 0.007
        var dCutoff: Double = 1.0
        private var xHat: Double?
        private var dxHat: Double = 0
        private var tPrev: Double = 0

        init(minCutoff: Double = 1.2, beta: Double = 0.007, dCutoff: Double = 1.0) {
            self.minCutoff = minCutoff
            self.beta = beta
            self.dCutoff = dCutoff
        }

        mutating func filter(_ value: Double, now: Double, boxArea: Double = 1) -> Double {
            guard let prev = xHat else {
                xHat = value
                tPrev = now
                return value
            }
            let dt = max(1e-3, now - tPrev)
            tPrev = now
            let dx = (value - prev) / dt
            let ad = alpha(dCutoff, dt: dt)
            dxHat = ad * dx + (1 - ad) * dxHat
            let cutoff = MatchMath.oneEuroCutoff(base: minCutoff, dt: dt, boxArea: boxArea) + beta * abs(dxHat)
            let a = alpha(cutoff, dt: dt)
            let hat = a * value + (1 - a) * prev
            xHat = hat
            return hat
        }

        mutating func reset() {
            xHat = nil
            dxHat = 0
            tPrev = 0
        }

        private func alpha(_ cutoff: Double, dt: Double) -> Double {
            let tau = 1.0 / (2.0 * Double.pi * max(1e-4, cutoff))
            return 1.0 / (1.0 + tau / dt)
        }
    }

    private static func clamp01(_ n: Double) -> Double { min(1, max(0, n)) }

    static let unknownRejectFloor = 50.0

    /// Slider 78 → 50. 70 → 42. 96 → 68. Open-Set folgt der Galerie-Schwelle.
    static func unknownRejectFloor(slider: Double) -> Double {
        min(70, max(40, slider - 28))
    }

    /// Alle Gallery-Scores unter Floor: Overlay statt Taufe (Open-Set).
    static func unknownReject(bestPercent: Double, floor: Double = unknownRejectFloor) -> Bool {
        bestPercent < floor
    }

    static func unknownRejectNote() -> String { "unbekannt — keine Nähe" }

    /// Desk-View ist nicht FaceTime-Front. Spiegeln tauft Zwillinge auf ein Gesicht.
    static func mirrorAsFront(positionFront: Bool, unspecified: Bool, deskView: Bool) -> Bool {
        if deskView { return false }
        return positionFront || unspecified
    }

    /// Ein Dropout darf leftover-Need nicht auf 0,50 s kippen.
    static func medianLiveDt(_ dts: [TimeInterval], fallback: TimeInterval = 0.125) -> TimeInterval {
        let ok = dts.filter { $0 > 0.02 && $0 < 0.40 }
        guard !ok.isEmpty else { return fallback }
        let sorted = ok.sorted()
        return sorted[sorted.count / 2]
    }

    /// Name-Lock ohne Vote 8 s → tot. Sonst klebt Anna nach Verlassen.
    static let nameLockVoteTTL: TimeInterval = 8

    static func nameLockExpired(
        lastVote: TimeInterval?,
        now: TimeInterval,
        hold: TimeInterval = nameLockVoteTTL
    ) -> Bool {
        guard let lastVote else { return false }
        return now - lastVote >= hold
    }

    /// Idle→Live: 2 Frames Gesicht bevor 8 fps. Blinker am Türrahmen sonst.
    static let liveFaceNeed = 2

    static func liveFacesLatch(
        present: Bool,
        on: Bool,
        streak: Int,
        need: Int = liveFaceNeed
    ) -> (on: Bool, streak: Int) {
        if !present { return (false, 0) }
        if on { return (true, 0) }
        let n = streak + 1
        if n >= need { return (true, 0) }
        return (false, n)
    }

    /// Live-NMS: Tile/Equalize-Zwillinge. Höher als Foto-0,28, enger als duplicate 0,42 allein.
    static let liveNmsIoU = 0.45

    static func liveDuplicate(iou: Double, nested: Double, iouFloor: Double = liveNmsIoU) -> Bool {
        iou >= iouFloor || nested >= 0.55
    }

    /// leftover-Hold EMA: ein scharfer Twin 0,70 tauft nicht.
    /// 8 fps: alpha an dt, sonst Spike 0,06 in einem Tick.
    static let leftoverHoldCaptureJump: Double = 0.20
    static let leftoverHoldAlphaAE: Double = 0.08

    /// AE-Sprung 0,20: Hold-EMA träge, nicht 0,35.
    static func leftoverHoldAlphaJump(_ jump: Double, floor: Double = leftoverHoldCaptureJump) -> Bool {
        jump >= floor
    }

    static func leftoverCaptureJump(prev: Double?, next: Double?) -> Double {
        guard let prev, let next else { return 0 }
        return abs(next - prev)
    }

    static func leftoverHoldAlpha(
        dt: TimeInterval,
        base: Double = liveScoreAlpha,
        ref: TimeInterval = 0.016,
        captureJump: Double = 0
    ) -> Double {
        var a = min(1, max(0, base))
        if leftoverHoldAlphaJump(captureJump) { a = min(a, leftoverHoldAlphaAE) }
        guard dt > ref, ref > 0 else { return a }
        return 1 - pow(1 - a, ref / dt)
    }

    static func leftoverHoldEMA(prev: Double?, next: Double, alpha: Double = liveScoreAlpha) -> Double {
        liveScoreEMA(prev: prev, next: next, alpha: alpha)
    }

    /// Glättung vor leftoverPick. Roh 0,70 / Hold 0,64 → 0,66, nicht 0,70.
    /// AE-Sprung: α 0,08, sonst Hold in einem Tick umgeschrieben.
    static func leftoverHoldSmooth(raw: Double?, prev: Double?, dt: TimeInterval = 0.016, captureJump: Double = 0) -> Double? {
        guard let raw else { return nil }
        return leftoverHoldEMA(prev: prev, next: raw, alpha: leftoverHoldAlpha(dt: dt, captureJump: captureJump))
    }

    /// Twin-Spike ≥ 0,04 ohne Baptize 0,80: leftover nicht taufen.
    static let leftoverHoldSpike = 0.04

    /// Floor auf RAW. Smoothed 0,50 ∧ Hold 0,80 = 0,70 tauft den Impostor.
    static func leftoverPickPrint(raw: Double?, smoothed: Double?) -> Double? { raw }

    /// Nacht-Hold 0,61 → 0,66 ist Erholung, kein Twin-Spike.
    static func leftoverHoldClimb(prev: Double?, floor: Double = leftoverPrintGenuine) -> Bool {
        guard let prev else { return false }
        return prev < floor
    }

    static func leftoverHoldBlocks(
        raw: Double?,
        prev: Double?,
        spike: Double = leftoverHoldSpike,
        baptize: Double = pinPrintCosine
    ) -> Bool {
        guard let raw else { return false }
        if leftoverBaptize(cosine: raw) { return false }
        guard let prev else { return false }
        if leftoverHoldClimb(prev: prev) { return false }
        return raw - prev + 1e-9 >= spike
    }

    /// Centroid 0,89–0,94: Merge-Wizard, nie still taufen.
    static func mergeSuggest(pairCosine: Double, lo: Double = 0.89, hi: Double = 0.94) -> Bool {
        pairCosine >= lo && pairCosine < hi
    }

    static let printCacheCap = 512

    /// Burst nach 513 Gesichtern nicht kalt — älteste raus, nicht removeAll.
    static func printCacheDropCount(count: Int, cap: Int = printCacheCap) -> Int {
        max(0, count - cap)
    }

    /// Cache-Hit ans Ende. Sonst FIFO trotz LRU-Claim.
    static func printCacheTouch(order: inout [Data], key: Data) {
        if let i = order.firstIndex(of: key) {
            order.remove(at: i)
        }
        order.append(key)
    }

    /// 3 Frames gleiche Zuordnung, dann UUID-Switch. Ein 2-opt-Tick tauft sonst den Twin.
    static let leftoverMajorityNeed = 3

    static func leftoverAssignMajority(
        committed: UUID?,
        proposed: UUID?,
        lastProposed: UUID?,
        streak: Int,
        need: Int = leftoverMajorityNeed,
        locked: Bool = false
    ) -> (commit: UUID?, last: UUID?, streak: Int, ready: Bool) {
        if locked {
            return (committed, lastProposed, 0, false)
        }
        guard let proposed else {
            return (committed, nil, 0, false)
        }
        if let committed, proposed == committed {
            return (committed, proposed, 0, false)
        }
        if lastProposed == proposed {
            let n = streak + 1
            if n >= need {
                return (proposed, proposed, 0, true)
            }
            return (committed, proposed, n, false)
        }
        return (committed, proposed, 1, false)
    }

    static func leftoverMajorityLabel(streak: Int, need: Int = leftoverMajorityNeed) -> String? {
        guard streak > 0, streak < need else { return nil }
        return "MAJ \(streak)/\(need)"
    }

    /// 24 fps: Print skip wenn Vision > 18 ms. 8 fps nie — leftover braucht den Print.
    static let printBudgetMs = 18.0

    static func printBudgetSkip(visionMs: Double, dt: TimeInterval) -> Bool {
        if dt >= 0.08 { return false }
        return visionMs > printBudgetMs
    }

    /// Name-Lock Overlay Countdown der letzten 4 s, sonst wirkt tot nach Verlassen.
    static func nameLockTTLLabel(
        lastVote: TimeInterval?,
        now: TimeInterval,
        hold: TimeInterval = nameLockVoteTTL,
        window: TimeInterval = 4
    ) -> String? {
        guard let lastVote, now > 0, window > 0 else { return nil }
        let left = hold - (now - lastVote)
        guard left > 0, left <= window + 1e-9 else { return nil }
        return String(format: "TTL %.0fs", left)
    }

    /// Landmark-Jitter 0 über 4 Frames = Poster an der Wand.
    static func posterFaceReject(jitter: Double, frames: Int, need: Int = 4, floor: Double = 1e-4) -> Bool {
        frames >= need && jitter < floor
    }

    /// Sehr schmale Kiste ist kein Frontal — leftover auf Profil-Ghost.
    static let boxAspectMin = 0.38

    static func boxAspectFrontal(width: Double, height: Double, minAspect: Double = boxAspectMin) -> Bool {
        guard height > 1e-6 else { return false }
        return (width / height) >= minAspect
    }

    /// Schmale Kiste nur mit Baptize-Print, sonst Profil-Ghost.
    static func leftoverPickAspect(ok: Bool?, cosine: Double?) -> Bool {
        if ok != false { return true }
        return leftoverBaptize(cosine: cosine)
    }

    /// F→¾→P: Hold 0,64 darf den Track halten. Ohne Print bleibt Slot hart.
    static func leftoverAllowsCrossSlot(sameSlot: Bool?, cosine: Double?) -> Bool {
        if sameSlot != false { return true }
        return leftoverPrintOk(cosine: cosine)
    }

    /// 0,64–0,79: Overlay halten, UUID nicht stehlen, Live nicht zum Gast machen.
    static func leftoverHoldsTrack(
        cosine: Double?,
        holdPrev: Double? = nil,
        trail: [Double] = [],
        tapUntil: TimeInterval? = nil,
        now: TimeInterval = 0,
        stillFor: TimeInterval = 1,
        sharpness: Double? = nil,
        yawAbs: Double? = nil,
        blink: Bool = false,
        jpegDelta: Double? = nil,
        iou: Double? = nil,
        jpegRequired: Bool = false,
        nameLockUntil: TimeInterval? = nil
    ) -> Bool {
        if leftoverIoUJumpBlocks(iou) { return false }
        if leftoverNameLockBlocks(until: nameLockUntil, now: now) { return true }
        return leftoverPrintOk(cosine: cosine, sharpness: sharpness) && !leftoverTransfersId(
            cosine: cosine, holdPrev: holdPrev, trail: trail, tapUntil: tapUntil, now: now, stillFor: stillFor,
            sharpness: sharpness, yawAbs: yawAbs, blink: blink, jpegDelta: jpegDelta, iou: iou,
            jpegRequired: jpegRequired, nameLockUntil: nameLockUntil
        )
    }

    /// Dropout: UUID-Hold/Trail/Slot am Ghost **und** an Live. Nur Ghosts wischte den Live-Hold.
    /// emptyFor begrenzt emptyKeeps — sonst Tasche-im-Dunkeln ewig Hold.
    static func leftoverHoldSurvive<Value>(
        hold: [UUID: Value],
        ghosts: [UUID],
        live: [UUID] = [],
        emptyKeeps: Bool = false,
        emptyFor: TimeInterval = 0,
        locked: [UUID] = []
    ) -> [UUID: Value] {
        let keep = Set(ghosts + live + locked)
        if keep.isEmpty {
            if emptyKeeps && leftoverLatchKeeps(emptyFor: emptyFor) { return hold }
            return [:]
        }
        return hold.filter { keep.contains($0.key) }
    }

    /// Landmark-Jitter über Paare. 0 über 4 Frames = Poster.
    static func landmarkJitter(prev: [Point2], next: [Point2]) -> Double {
        let n = min(prev.count, next.count)
        guard n >= 4 else { return 1 }
        var s = 0.0
        for i in 0..<n {
            s += hypot(prev[i].x - next[i].x, prev[i].y - next[i].y)
        }
        return s / Double(n)
    }

    static func posterJitterAccum(prev: Double, next: Double, alpha: Double = 0.45) -> Double {
        prev * (1 - alpha) + next * alpha
    }

    static func posterStillAdvance(jitter: Double, streak: Int, floor: Double = 1e-4) -> Int {
        jitter < floor ? streak + 1 : 0
    }

    /// Enrollment: 200 ms nach Belichtungssprung kein Print. 8 fps: 0,40 s (sonst 1–2 Frames).
    static let exposureLockHold: TimeInterval = 0.20
    static let captureJumpDelta = 0.15
    static let captureBurstFrames = 3

    static func exposureLockHold(dt: TimeInterval, reconnect: Bool = false) -> TimeInterval {
        if reconnect { return dt >= 0.08 ? 0.80 : 0.40 }
        return dt >= 0.08 ? 0.40 : exposureLockHold
    }

    static func captureJumps(prev: Double, next: Double, delta: Double = captureJumpDelta) -> Bool {
        abs(next - prev) >= delta
    }

    /// Enrolled: AE-Sprung überschreibt den Gallery-Print nicht. holdStillSkip sitzt nur im IoU-Pfad.
    static func captureJumpBlocksPrint(prev: Double, next: Double, enrolled: Bool) -> Bool {
        enrolled && captureJumps(prev: prev, next: next)
    }

    /// Burst über 3 Frames: Undershoot nach Sprung darf den Print nicht schreiben.
    static func captureBurstBlocksPrint(
        history: [Double],
        next: Double,
        enrolled: Bool,
        window: Int = captureBurstFrames,
        delta: Double = captureJumpDelta
    ) -> Bool {
        guard enrolled else { return false }
        if let last = history.last, captureJumps(prev: last, next: next, delta: delta) { return true }
        let recent = Array(history.suffix(window)) + [next]
        guard let lo = recent.min(), let hi = recent.max() else { return false }
        return (hi - lo) >= delta
    }

    /// Ghost-Adopt: Trail bleibt. Wipe machte MAD tot, erster 0,82 taufte.
    static func printTrailKeepsOnGhostAdopt() -> Bool { true }

    /// Overlay-Tap auf enrolled sperrt leftover 3 s, nicht nur Anlegen/+.
    static func tapOverlayLocksName(pinned: Bool) -> Bool { pinned }

    /// Overlay-Tap auf Gast = Tauf-Vorschlag, nicht nur Select.
    static func tapGuestSuggests(pinned: Bool) -> Bool { !pinned }

    static func tapGuestNote() -> String { "TAUFEN?" }

    /// Survive-Prune: eine Statuszeile, kein stilles Wipe. Nur leerer Frame, nicht Partial.
    static func leftoverHoldPruneLine(before: Int, after: Int, liveEmpty: Bool = true) -> String? {
        guard liveEmpty else { return nil }
        let n = before - after
        return n > 0 ? "Hold prune \(n)" : nil
    }

    /// Manueller Tap: leftover 3 s kein Steal/Taufe.
    static let tapNameLockHold: TimeInterval = 3

    static func tapNameLockUntil(now: TimeInterval, hold: TimeInterval = tapNameLockHold) -> TimeInterval {
        now + hold
    }

    static func tapNameLockBlocks(until: TimeInterval?, now: TimeInterval) -> Bool {
        guard let until else { return false }
        return now < until
    }

    static func tapNameLockLabel(until: TimeInterval?, now: TimeInterval) -> String? {
        guard tapNameLockBlocks(until: until, now: now), let until else { return nil }
        let left = max(0, until - now)
        return String(format: "TAP %.0fs", left)
    }

    static func exposureLockUntil(now: TimeInterval, hold: TimeInterval = exposureLockHold) -> TimeInterval {
        now + hold
    }

    static func exposureLocks(now: TimeInterval, until: TimeInterval) -> Bool {
        until > 0 && now < until
    }

    static func exposureLockLabel(until: TimeInterval?, now: TimeInterval) -> String? {
        guard let until, now < until else { return nil }
        let left = until - now
        guard left > 0 else { return nil }
        return "AE \(commaTenths(left))s"
    }

    static func ghostTTLLabel(until: TimeInterval?, now: TimeInterval) -> String? {
        guard let until else { return nil }
        let left = until - now
        guard left > 0 else { return nil }
        return "GHOST \(commaTenths(left))s"
    }

    static func commaTenths(_ value: TimeInterval) -> String {
        let tenths = max(0, Int((value * 10).rounded()))
        return "\(tenths / 10),\(tenths % 10)"
    }

    /// Median-Trail Commit, nicht Mittel — ein Outlier-Frame tauft nicht.
    static func printCommitMedian(_ samples: [Double]) -> Double? {
        let ok = samples.filter { $0.isFinite }
        guard !ok.isEmpty else { return nil }
        let sorted = ok.sorted()
        return sorted[sorted.count / 2]
    }

    /// ≥ 3 Samples. Median der |x − Median|. Ein Sample hat kein MAD.
    static func printMAD(_ samples: [Double]) -> Double? {
        let ok = samples.filter(\.isFinite)
        guard ok.count >= 3, let med = printCommitMedian(ok) else { return nil }
        return printCommitMedian(ok.map { abs($0 - med) })
    }

    static let printMADSpike = 0.04

    /// Twin-Frame 0,80 neben Median 0,64: Peak−Median oder MAD über Spike.
    static func printMADBlocks(_ samples: [Double], spike: Double = printMADSpike) -> Bool {
        let ok = samples.filter(\.isFinite)
        guard ok.count >= 3, let med = printCommitMedian(ok) else { return false }
        let peak = ok.max() ?? med
        if peak - med > spike { return true }
        guard let mad = printMAD(ok) else { return false }
        return mad > spike
    }

    static func printMADNote() -> String { "MAD" }

    /// Maske: Partial-Print statt Vote-Skip wenn U-Slot-Refs da sind.
    static func partialPrintMasked(occluded: Bool, hasUpperRefs: Bool) -> Bool {
        occluded && hasUpperRefs
    }

    /// Open-Set: Bester Galerie-Centroid unter leftover-Floor — Overlay, keine Taufe.
    /// Profil-Floor 0,70 darf nicht an Genuine 0,62 scheitern. min(floor, session) tat das.
    static func unknownCentroid(bestCosine: Double?, floor: Double = leftoverPrintGenuine, capture: Double? = nil, yawAbs: Double? = nil) -> Bool {
        let session = leftoverSessionFloor(yawAbs: yawAbs, capture: capture)
        let bar: Double
        if yawAbs != nil || capture != nil {
            bar = session
        } else {
            bar = min(floor, session)
        }
        return (bestCosine ?? -1) < bar
    }

    /// leftover ohne Baptize-Print zeigt keinen eingeschriebenen Namen.
    static func leftoverShowsName(cosine: Double?) -> Bool {
        leftoverBaptize(cosine: cosine)
    }

    /// Overlay: ohne leftover Live-Pin. Mit leftover nur wenn diese Pose tauft — ¾ ohne Bin nicht Frontal-Name.
    static func leftoverNameFromHold(hasHold: Bool, hold: Double?, yawAbs: Double? = nil) -> Bool {
        if !hasHold { return true }
        if leftoverHoldBin(yawAbs: yawAbs ?? 0) != 0 {
            return leftoverBaptize(cosine: hold)
        }
        return leftoverBaptize(cosine: hold)
    }

    static func unknownStickyName(index: Int) -> String {
        "Gast \(max(1, index))"
    }

    /// 1-basiert. Nicht in der Liste → Gast n+1, nicht immer Gast 1.
    static func guestIndex(of id: UUID, order: [UUID]) -> Int {
        guard let i = order.firstIndex(of: id) else { return order.count + 1 }
        return i + 1
    }

    static func guestOrderAppend(id: UUID, onto order: [UUID]) -> [UUID] {
        if order.contains(id) { return order }
        return order + [id]
    }

    /// Enrolled leftover + unknown probe: UUID nicht stehlen.
    static func unknownStickyKeeps(bestCosine: Double?, enrolled: Bool) -> Bool {
        enrolled && unknownCentroid(bestCosine: bestCosine)
    }

    /// pairCosine 0,89–0,94: Twin-Wizard, leftover nicht taufen.
    static func leftoverTwinSuggest(pairCosine: Double?) -> Bool {
        guard let p = pairCosine else { return false }
        return mergeSuggest(pairCosine: p)
    }

    static func leftoverTwinNote() -> String { "TWIN" }

    /// Overlay `TWIN 0,93` hart, `TWIN? 0,90` weich — sonst wirkt 0,90 wie Veto ohne Zahl.
    static func leftoverTwinPairLabel(pairCosine: Double?) -> String? {
        guard let p = pairCosine else { return nil }
        let hard = leftoverTwinHardBlocks(pairCosine: p)
        let soft = leftoverTwinSuggest(pairCosine: p)
        guard hard || soft else { return nil }
        let hundredths = Int((p * 100).rounded())
        let whole = hundredths / 100
        let frac = abs(hundredths % 100)
        let fracStr = frac < 10 ? "0\(frac)" : "\(frac)"
        return hard ? "TWIN \(whole),\(fracStr)" : "TWIN? \(whole),\(fracStr)"
    }

    /// Overlay-Kiste: TWIN? amber, TWIN hart rot.
    static func leftoverTwinTint(pairCosine: Double?) -> String? {
        if leftoverTwinHardBlocks(pairCosine: pairCosine) { return "red" }
        if leftoverTwinSuggest(pairCosine: pairCosine) { return "amber" }
        return nil
    }

    /// Bei genau 2 Personen: Print und Geo müssen einig sein.
    static func twoPersonAnd(printAgree: Bool, geoAgree: Bool, gallery: Int) -> Bool {
        if gallery != 2 { return true }
        return printAgree && geoAgree
    }

    static func twoPersonAndNote() -> String { "Print und Maße uneinig" }

    static func mergeSuggestPairs(_ pairs: [(Int, Int, Double)]) -> [(Int, Int, Double)] {
        pairs.filter { mergeSuggest(pairCosine: $0.2) }
            .sorted { $0.2 > $1.2 }
    }

    static func mergeHintLabel(count: Int, a: String, b: String, cosine: Double) -> String {
        let pct = Int((cosine * 100).rounded())
        if count <= 1 {
            return "\(a) und \(b) \(pct)% — zusammenführen?"
        }
        return "\(a) und \(b) \(pct)% (+\(count - 1) weitere) — zusammenführen?"
    }

    /// Lid zu → auf, sonst Poster.
    static func livenessBlink(prevClosed: Bool, nowClosed: Bool) -> Bool {
        prevClosed && !nowClosed
    }

    static func posterNeedsBlink(stillFrames: Int, blinked: Bool, need: Int = 8) -> Bool {
        stillFrames >= need && !blinked
    }

    static func posterBlinkNote() -> String { "BLINK" }

    static func visionQualityLamp(_ q: Double) -> Lamp {
        if q >= 0.50 { return .green }
        if q >= 0.25 { return .amber }
        return .red
    }

    /// 8 fps Box: einfache 1D-Kalman statt 1-Euro (hängt hinter Sprung).
    static func boxKalman(
        prev: Double,
        meas: Double,
        p: Double,
        dt: TimeInterval,
        q: Double = 0.008,
        r: Double = 0.04
    ) -> (x: Double, p: Double) {
        let qScale = dt >= 0.08 ? q * 4 : q
        let pPred = p + qScale
        let k = pPred / (pPred + r)
        let x = prev + k * (meas - prev)
        return (x, (1 - k) * pPred)
    }

    static func boxKalmanUses(dt: TimeInterval) -> Bool { dt >= 0.08 }

    /// Velocity-EMA. Leerer Frame braucht vx, sonst Overlay klebt.
    static func boxKalmanVelocity(prev: Double, next: Double, dt: TimeInterval, prevV: Double = 0) -> Double {
        guard dt > 0.001 else { return prevV }
        let raw = (next - prev) / dt
        return 0.55 * raw + 0.45 * prevV
    }

    /// Leerer Frame: cx += vx·dt, Cap gegen Teleport.
    static func boxKalmanPredict(x: Double, v: Double, dt: TimeInterval, cap: Double = 0.12) -> Double {
        let step = v * dt
        let clipped = max(-cap, min(cap, step))
        return x + clipped
    }

    static func leftoverPredictBoxes(
        boxes: [UUID: (x: Double, y: Double)],
        vel: [UUID: (vx: Double, vy: Double)],
        dt: TimeInterval
    ) -> [UUID: (x: Double, y: Double)] {
        var out: [UUID: (x: Double, y: Double)] = [:]
        for (id, b) in boxes {
            let v = vel[id] ?? (vx: 0, vy: 0)
            out[id] = (
                x: boxKalmanPredict(x: b.x, v: v.vx, dt: dt),
                y: boxKalmanPredict(x: b.y, v: v.vy, dt: dt)
            )
        }
        return out
    }

    /// Walker-Doppelkiste: Live-Box auf der Predict-Kiste, aber nicht die beste.
    static func kalmanNmsDrops(iou: Double, bestIou: Double, floor: Double = 0.45) -> Bool {
        iou >= floor && iou + 1e-9 < bestIou
    }

    static func kalmanNmsKeeps(iou: Double, bestIou: Double, floor: Double = 0.45) -> Bool {
        !kalmanNmsDrops(iou: iou, bestIou: bestIou, floor: floor)
    }

    /// Live-Detector Crop um Kalman-Kisten. 8 fps False-Empty ohne ROI.
    /// 0,18 ließ HD-Gesicht 80×100 tot (Crop 144/1280 = 0,11). 0,10 lässt typische Kisten durch.
    static func liveRoiBox(
        kalman: [(x: Double, y: Double, w: Double, h: Double)],
        imageW: Double,
        imageH: Double,
        pad: Double = 1.8
    ) -> (x: Double, y: Double, w: Double, h: Double)? {
        guard !kalman.isEmpty, imageW > 1, imageH > 1 else { return nil }
        var minX = Double.infinity, minY = Double.infinity, maxX = -Double.infinity, maxY = -Double.infinity
        for b in kalman {
            minX = min(minX, b.x)
            minY = min(minY, b.y)
            maxX = max(maxX, b.x + b.w)
            maxY = max(maxY, b.y + b.h)
        }
        let bw = max(1, maxX - minX)
        let bh = max(1, maxY - minY)
        let px = bw * (pad - 1) / 2
        let py = bh * (pad - 1) / 2
        let x = max(0, minX - px)
        let y = max(0, minY - py)
        let w = min(imageW - x, bw + 2 * px)
        let h = min(imageH - y, bh + 2 * py)
        if w / imageW < 0.10 || h / imageH < 0.10 { return nil }
        if w / imageW > 0.92 && h / imageH > 0.92 { return nil }
        return (x, y, w, h)
    }

    /// Crop-Miss: ROI 1,4×, dann volles Bild. Sonst Continuity False-Empty.
    static func liveRoiMissRetries(hadROI: Bool, empty: Bool) -> Bool { hadROI && empty }

    /// 8 fps: Expand + Full = 3 Detector-Pässe > 125 ms. Direkt volles Bild.
    static func liveRoiMissGoesFull(dt: TimeInterval) -> Bool { dt >= 0.08 }

    static func liveRoiExpand(
        _ box: (x: Double, y: Double, w: Double, h: Double),
        imageW: Double,
        imageH: Double,
        factor: Double = 1.4
    ) -> (x: Double, y: Double, w: Double, h: Double) {
        let cx = box.x + box.w / 2
        let cy = box.y + box.h / 2
        let w = min(imageW, box.w * factor)
        let h = min(imageH, box.h * factor)
        let x = min(max(0, cx - w / 2), max(0, imageW - w))
        let y = min(max(0, cy - h / 2), max(0, imageH - h))
        return (x, y, w, h)
    }

    /// Jeder 8. Tick volles Bild — Walk-in außerhalb des Crops.
    static func liveRoiPeriodicFull(tick: Int, every: Int = 8) -> Bool {
        every > 0 && tick % every == 0
    }

    /// Zweite Kiste im Crop: nächster Tick voll, sonst klebt ROI an Anna.
    static func liveRoiSkipsForStranger(foundCount: Int, kalmanCount: Int) -> Bool {
        foundCount > kalmanCount && kalmanCount > 0
    }

    /// Ghost-Predict ändert cx/cy, nicht w/h — sonst Hash-Sprung.
    static func leftoverGhostAspectLock(
        predX: Double,
        predY: Double,
        lastW: Double,
        lastH: Double
    ) -> (x: Double, y: Double, w: Double, h: Double) {
        (predX, predY, lastW, lastH)
    }

    /// AE jagt: mehr Process-Noise, sonst Overlay klebt am alten Print.
    static func boxKalmanQ(captureJump: Bool, base: Double = 0.008) -> Double {
        captureJump ? base * 2.5 : base
    }

    /// Print-Bank: Blur zählt 0, scharf nach leftoverPrintSharp.
    static func printBankWeight(sharpness: Double?) -> Double {
        leftoverTrailWriteOk(sharpness: sharpness) ? max(0.15, sharpness ?? 1) : 0
    }

    static func printBankBlend(_ samples: [(vec: [Double], w: Double)]) -> [Double] {
        var acc: [Double] = []
        var wsum = 0.0
        for s in samples where s.w > 0 && s.vec.count >= 32 {
            if acc.isEmpty {
                acc = s.vec.map { $0 * s.w }
            } else if acc.count == s.vec.count {
                for i in acc.indices { acc[i] += s.vec[i] * s.w }
            } else { continue }
            wsum += s.w
        }
        guard wsum > 0, !acc.isEmpty else { return [] }
        let inv = 1.0 / wsum
        for i in acc.indices { acc[i] *= inv }
        return acc
    }

    static let clusterSplitNeed = 10

    static func clusterSplit(disagree: Int, need: Int = clusterSplitNeed) -> Bool {
        disagree >= need
    }

    static func clusterSplitAdvance(prev: Int, changed: Bool) -> Int {
        changed ? prev + 1 : prev
    }

    static func clusterSplitNote() -> String { "SPLIT" }

    static func centroidWeight(capture: Double, sharpness: Double, frontal: Double = 1, yawAbs: Double = 0) -> Double {
        let base = max(0.08, capture * (0.35 + 0.65 * max(0, sharpness)))
        let front = max(0.15, frontal)
        let yaw = 1 - min(1, max(0, yawAbs / 0.50))
        return base * front * max(0.15, yaw)
    }

    /// BOX, PRINT, GEO, LOCK: gemessene Stimmen einig, sonst keine Taufe.
    /// Geo votet nur ab conflictGeoFloor — 20 % Maße kippen keinen 90 % Print.
    static let conflictGeoFloor = 42.0

    static func conflictTickAgrees(
        boxId: UUID?,
        printId: UUID?,
        geoId: UUID?,
        lockId: UUID?,
        geoMix: Double? = nil
    ) -> Bool {
        var votes: [UUID] = []
        if let printId { votes.append(printId) }
        if let geoId, (geoMix ?? 100) >= conflictGeoFloor { votes.append(geoId) }
        if let lockId { votes.append(lockId) }
        if let boxId { votes.append(boxId) }
        guard votes.count >= 2 else { return true }
        return Set(votes).count == 1
    }

    static func conflictTickBaptize(
        boxId: UUID?,
        printId: UUID?,
        geoId: UUID?,
        lockId: UUID?,
        geoMix: Double? = nil
    ) -> UUID? {
        guard conflictTickAgrees(boxId: boxId, printId: printId, geoId: geoId, lockId: lockId, geoMix: geoMix) else {
            return nil
        }
        return printId ?? geoId ?? lockId ?? boxId
    }

    static func conflictTickNote() -> String { "KONFLIKT" }

    /// Live hat die Kiste schon getauft — leftover stiehlt die UUID nicht.
    static func leftoverYieldsToLive(liveId: UUID?, leftoverId: UUID) -> Bool {
        guard let liveId else { return false }
        return liveId != leftoverId
    }

    /// Burst: 3 Frames, schärfstes Ref statt erstes.
    static let enrollBurstNeed = 3

    static func enrollBurstReady(count: Int, need: Int = enrollBurstNeed) -> Bool {
        count >= need
    }

    static func enrollBurstPick(sharpness: [Double]) -> Int? {
        guard !sharpness.isEmpty else { return nil }
        return sharpness.enumerated().max(by: { $0.element < $1.element })?.offset
    }

    static func enrollBurstReplace(incomingSharp: Double, existingSharp: Double, eps: Double = 0.02) -> Bool {
        incomingSharp > existingSharp + eps
    }

    static func liveFAR(impostorAbove: Int, totalImpostor: Int) -> Double {
        guard totalImpostor > 0 else { return 0 }
        return Double(impostorAbove) / Double(totalImpostor)
    }

    static func liveFARLabel(_ far: Double) -> String {
        String(format: "FAR %.1f%%", far * 100)
    }

    static func guestPersistId(index: Int) -> String {
        "guest.\(max(1, index))"
    }

    static func guestPersistName(_ id: String) -> String? {
        guard id.hasPrefix("guest.") else { return nil }
        let n = id.dropFirst("guest.".count)
        return "Gast \(n)"
    }

    static func guestPersistKeeps(name: String) -> Bool {
        name.hasPrefix("Gast ") || name.hasPrefix("guest.")
    }

    static func leftoverStreakSincePersist(since: TimeInterval?, now: TimeInterval) -> TimeInterval {
        since ?? now
    }

    /// Box-Hash über Dropout. UUID stirbt, die Kiste bleibt.
    /// Live-Box ist Pixel. Ohne imageW/H fällt alles >1 in denselben Bin.
    /// 4K mit 12 Bins: zwei Köpfe 250 px auseinander ein Bin.
    static func leftoverBoxHashBins(imageW: Double) -> Int {
        if imageW >= 3000 { return 24 }
        if imageW >= 1920 { return 16 }
        return 12
    }

    static func leftoverBoxHashBinsInferred(_ hash: String) -> Int {
        let parts = hash.split(separator: ".").compactMap { Int($0) }
        let hi = parts.max() ?? 0
        if hi >= 16 { return 24 }
        if hi >= 12 { return 16 }
        return 12
    }

    static func leftoverBoxHashDistance(_ a: String, _ b: String) -> Int {
        let pa = a.split(separator: ".").compactMap { Int($0) }
        let pb = b.split(separator: ".").compactMap { Int($0) }
        guard pa.count == 4, pb.count == 4 else { return 99 }
        return abs(pa[0] - pb[0]) + abs(pa[1] - pb[1]) + abs(pa[2] - pb[2]) + abs(pa[3] - pb[3])
    }

    static func leftoverBoxHash(_ box: FaceBox, bins: Int? = nil, imageW: Double = 0, imageH: Double = 0) -> String {
        let used = bins ?? leftoverBoxHashBins(imageW: imageW)
        let u = leftoverBoxUnit(box, imageW: imageW, imageH: imageH)
        func q(_ v: Double) -> Int {
            let t = min(1, max(0, v))
            return min(used - 1, Int((t * Double(used)).rounded(.down)))
        }
        return "\(q(u.cx)).\(q(u.cy)).\(q(u.w)).\(q(u.h))"
    }

    /// 0–1 bleibt. Pixel durch Bildmaß. Sonst Clamp-auf-1 = ein Bin für alle.
    static func leftoverBoxUnit(_ box: FaceBox, imageW: Double = 0, imageH: Double = 0) -> (cx: Double, cy: Double, w: Double, h: Double) {
        var cx = box.x + box.width / 2
        var cy = box.y + box.height / 2
        var w = box.width
        var h = box.height
        if imageW > 1, imageH > 1 {
            cx /= imageW
            cy /= imageH
            w /= imageW
            h /= imageH
        }
        return (cx, cy, w, h)
    }

    /// cx/cy/w/h ±1. Detector-Jitter auf der Größe tötet Hold nicht.
    static func leftoverBoxHashNeighbors(_ hash: String, bins: Int = 12) -> [String] {
        let parts = hash.split(separator: ".").compactMap { Int($0) }
        guard parts.count == 4 else { return [hash] }
        let cx = parts[0], cy = parts[1], w = parts[2], h = parts[3]
        let far = w <= 2 || h <= 2
        let rPos = far ? 2 : 1
        let rSize = far ? 2 : 1
        let used = max(24, bins, leftoverBoxHashBinsInferred(hash))
        var out: [String] = []
        out.reserveCapacity((2 * rPos + 1) * (2 * rPos + 1) * (2 * rSize + 1) * (2 * rSize + 1))
        for dx in -rPos...rPos {
            for dy in -rPos...rPos {
                for dw in -rSize...rSize {
                    for dh in -rSize...rSize {
                        let x = cx + dx
                        let y = cy + dy
                        let ww = w + dw
                        let hh = h + dh
                        guard x >= 0, x < used, y >= 0, y < used else { continue }
                        guard ww >= 0, ww < used, hh >= 0, hh < used else { continue }
                        out.append("\(x).\(y).\(ww).\(hh)")
                    }
                }
            }
        }
        return out
    }

    /// Ghosts nach Dropout: leftover braucht die letzte Kiste, nicht nur live previous.
    static func leftoverGhostIds(previous: [UUID], ghosts: [UUID]) -> [UUID] {
        var seen = Set<UUID>()
        return (previous + ghosts).filter { seen.insert($0).inserted }
    }

    /// Partial-Dropout: previous nicht in used. Auch enrolled — sonst stirbt Hold nach einem Frame mit Nachbar.
    static func leftoverDropped(previous: [UUID], used: Set<UUID>) -> [UUID] {
        previous.filter { !used.contains($0) }
    }

    /// Kalman-Kiste vor Hash. Roh-Box springt Bins beim Kopfdrehen.
    static func leftoverHashBox(
        kalmanX: Double?,
        kalmanY: Double?,
        kalmanW: Double?,
        kalmanH: Double?,
        fallback: FaceBox
    ) -> FaceBox {
        guard let x = kalmanX, let y = kalmanY, let w = kalmanW, let h = kalmanH, w > 0, h > 0 else {
            return fallback
        }
        return FaceBox(x: x, y: y, width: w, height: h)
    }

    static func leftoverStreakBoxWrite(
        kalmanX: Double?,
        kalmanY: Double?,
        kalmanW: Double?,
        kalmanH: Double?,
        fallback: FaceBox
    ) -> FaceBox {
        leftoverHashBox(
            kalmanX: kalmanX, kalmanY: kalmanY, kalmanW: kalmanW, kalmanH: kalmanH, fallback: fallback
        )
    }

    /// Put und Lookup dieselbe Kiste. Write auf Roh-Box der adopted Kiste verfehlte den Bin.
    static func leftoverHoldWriteHash(
        kalmanX: Double?,
        kalmanY: Double?,
        kalmanW: Double?,
        kalmanH: Double?,
        fallback: FaceBox,
        imageW: Double = 0,
        imageH: Double = 0
    ) -> String {
        leftoverBoxHash(leftoverHashBox(
            kalmanX: kalmanX, kalmanY: kalmanY, kalmanW: kalmanW, kalmanH: kalmanH, fallback: fallback
        ), bins: leftoverBoxHashBins(imageW: imageW), imageW: imageW, imageH: imageH)
    }

    /// Trail-Write = Hold-Write. Roh-Box verfehlte den Bin nach Kalman-Put.
    static func leftoverTrailWriteHash(
        kalmanX: Double?,
        kalmanY: Double?,
        kalmanW: Double?,
        kalmanH: Double?,
        fallback: FaceBox,
        imageW: Double = 0,
        imageH: Double = 0
    ) -> String {
        leftoverHoldWriteHash(
            kalmanX: kalmanX, kalmanY: kalmanY, kalmanW: kalmanW, kalmanH: kalmanH, fallback: fallback,
            imageW: imageW, imageH: imageH
        )
    }

    static func leftoverTrailPut(
        hash: String,
        sample: Double,
        onto table: [String: (samples: [Double], at: TimeInterval)],
        now: TimeInterval,
        cap: Int = 8,
        sharpness: Double? = nil,
        yawAbs: Double? = nil,
        bin: Int? = nil,
        ttl: TimeInterval = leftoverAdoptSec
    ) -> [String: (samples: [Double], at: TimeInterval)] {
        var next = leftoverTrailPrune(table, now: now, ttl: ttl)
        if !leftoverTrailWriteOk(sharpness: sharpness, yawAbs: yawAbs) { return next }
        let key = bin.map { leftoverHoldHashKey(hash: hash, bin: $0) } ?? hash
        let row = leftoverCosineSparkPut(sample, onto: next[key]?.samples ?? [], cap: cap)
        next[key] = (row, now)
        return leftoverHashTrailCapped(next)
    }

    static func leftoverTrailLookup(
        hash: String,
        table: [String: (samples: [Double], at: TimeInterval)],
        now: TimeInterval,
        ttl: TimeInterval = leftoverAdoptSec,
        bin: Int? = nil,
        facesInFrame: Int = 1,
        occupied: [String] = []
    ) -> [Double] {
        if leftoverHashOwnOccupied(live: occupied, hash: hash) { return [] }
        if let bin {
            let key = leftoverHoldHashKey(hash: hash, bin: bin)
            if let row = table[key], now - row.at <= ttl {
                return row.samples
            }
            var best: (samples: [Double], at: TimeInterval, dist: Int)?
            if leftoverHoldNeighborScans(facesInFrame: facesInFrame) {
                for h in leftoverBoxHashNeighbors(hash) where h != hash {
                    let nk = leftoverHoldHashKey(hash: h, bin: bin)
                    guard let row = table[nk], now - row.at <= ttl else { continue }
                    let d = leftoverBoxHashDistance(hash, h)
                    if !leftoverHoldNeighborOk(facesInFrame: facesInFrame, dist: d) { continue }
                    if best == nil || d < best!.dist || (d == best!.dist && row.at > best!.at) {
                        best = (row.samples, row.at, d)
                    }
                }
            }
            if let best { return best.samples }
            if bin == 0 {
                return leftoverTrailLookup(hash: hash, table: table, now: now, ttl: ttl, bin: nil, facesInFrame: facesInFrame, occupied: occupied)
            }
            return []
        }
        if let row = table[hash], now - row.at <= ttl {
            return row.samples
        }
        if let row = table[leftoverHoldHashKey(hash: hash, bin: 0)], now - row.at <= ttl {
            return row.samples
        }
        var best: (samples: [Double], at: TimeInterval, dist: Int)?
        if leftoverHoldNeighborScans(facesInFrame: facesInFrame) {
            for h in leftoverBoxHashNeighbors(hash) where h != hash {
                let row = table[h] ?? table[leftoverHoldHashKey(hash: h, bin: 0)]
                guard let row, now - row.at <= ttl else { continue }
                let d = leftoverBoxHashDistance(hash, h)
                if !leftoverHoldNeighborOk(facesInFrame: facesInFrame, dist: d) { continue }
                if best == nil || d < best!.dist || (d == best!.dist && row.at > best!.at) {
                    best = (row.samples, row.at, d)
                }
            }
        }
        return best?.samples ?? []
    }

    static func leftoverTrailPrune(
        _ table: [String: (samples: [Double], at: TimeInterval)],
        now: TimeInterval,
        ttl: TimeInterval = leftoverAdoptSec,
        skip: Bool = false
    ) -> [String: (samples: [Double], at: TimeInterval)] {
        if leftoverHoldPruneSkips(rebased: skip) { return leftoverHashTrailCapped(table) }
        return leftoverHashTrailCapped(table.filter { now - $0.value.at <= ttl })
    }

    static func leftoverHoldLookup(
        hash: String,
        table: [String: (cosine: Double, at: TimeInterval)],
        now: TimeInterval,
        ttl: TimeInterval = leftoverAdoptSec,
        bin: Int? = nil,
        facesInFrame: Int = 1,
        occupied: [String] = []
    ) -> Double? {
        if leftoverHashOwnOccupied(live: occupied, hash: hash) { return nil }
        if let bin {
            let key = leftoverHoldHashKey(hash: hash, bin: bin)
            if let row = table[key], now - row.at <= ttl {
                return row.cosine
            }
            var best: (cosine: Double, at: TimeInterval, dist: Int)?
            if leftoverHoldNeighborScans(facesInFrame: facesInFrame) {
                for h in leftoverBoxHashNeighbors(hash) where h != hash {
                    let nk = leftoverHoldHashKey(hash: h, bin: bin)
                    guard let row = table[nk], now - row.at <= ttl else { continue }
                    let d = leftoverBoxHashDistance(hash, h)
                    if !leftoverHoldNeighborOk(facesInFrame: facesInFrame, dist: d) { continue }
                    if best == nil || d < best!.dist || (d == best!.dist && row.at > best!.at) {
                        best = (row.cosine, row.at, d)
                    }
                }
            }
            if let best { return best.cosine }
            if bin == 0 {
                return leftoverHoldLookup(hash: hash, table: table, now: now, ttl: ttl, bin: nil, facesInFrame: facesInFrame, occupied: occupied)
            }
            return nil
        }
        if let row = table[hash], now - row.at <= ttl {
            return row.cosine
        }
        if let row = table[leftoverHoldHashKey(hash: hash, bin: 0)], now - row.at <= ttl {
            return row.cosine
        }
        var best: (cosine: Double, at: TimeInterval, dist: Int)?
        if leftoverHoldNeighborScans(facesInFrame: facesInFrame) {
            for h in leftoverBoxHashNeighbors(hash) where h != hash {
                let row = table[h] ?? table[leftoverHoldHashKey(hash: h, bin: 0)]
                guard let row, now - row.at <= ttl else { continue }
                let d = leftoverBoxHashDistance(hash, h)
                if !leftoverHoldNeighborOk(facesInFrame: facesInFrame, dist: d) { continue }
                if best == nil || d < best!.dist || (d == best!.dist && row.at > best!.at) {
                    best = (row.cosine, row.at, d)
                }
            }
        }
        return best?.cosine
    }

    /// Dropout/holdPrev: immer Yaw-Bin. Unbinned liest ¾-Hash nicht (`hash#1`).
    /// ohne yawAbs: nicht frontal raten — ¾-Ghost würde Anna erben.
    static func leftoverHoldLookupYaw(
        hash: String,
        table: [String: (cosine: Double, at: TimeInterval)],
        now: TimeInterval,
        ttl: TimeInterval = leftoverAdoptSec,
        yawAbs: Double?,
        facesInFrame: Int = 1,
        occupied: [String] = []
    ) -> Double? {
        guard let yaw = yawAbs else { return nil }
        return leftoverHoldLookup(
            hash: hash,
            table: table,
            now: now,
            ttl: ttl,
            bin: leftoverHoldBin(yawAbs: yaw),
            facesInFrame: facesInFrame,
            occupied: occupied
        )
    }

    static func leftoverHoldPrune(
        _ table: [String: (cosine: Double, at: TimeInterval)],
        now: TimeInterval,
        ttl: TimeInterval = leftoverAdoptSec,
        skip: Bool = false
    ) -> [String: (cosine: Double, at: TimeInterval)] {
        if leftoverHoldPruneSkips(rebased: skip) { return table }
        return table.filter { now - $0.value.at <= ttl && leftoverHashHoldKeeps($0.value.cosine) }
    }

    static func leftoverHoldPut(
        hash: String,
        cosine: Double,
        onto table: [String: (cosine: Double, at: TimeInterval)],
        now: TimeInterval,
        bin: Int = 0,
        ttl: TimeInterval = leftoverAdoptSec
    ) -> [String: (cosine: Double, at: TimeInterval)] {
        var next = leftoverHoldPrune(table, now: now, ttl: ttl)
        guard leftoverHashHoldKeeps(cosine) else { return leftoverHashHoldCapped(next) }
        next[leftoverHoldHashKey(hash: hash, bin: bin)] = (cosine, now)
        return leftoverHashHoldCapped(next)
    }

    /// Gast-Liste überlebt leere Frames 8 s. Unbekannte ID fällt nicht auf Gast 1.
    static let guestOrderHold: TimeInterval = 8

    static func guestOrderKeeps(
        id: UUID,
        live: [UUID],
        lastSeen: TimeInterval?,
        now: TimeInterval,
        hold: TimeInterval = guestOrderHold
    ) -> Bool {
        if live.contains(id) { return true }
        guard let lastSeen else { return false }
        return now - lastSeen <= hold
    }

    /// Gast wird nur nach Tauf-Button persistiert. Nie 8 s silent.
    static func guestPersistWrites(tapped: Bool) -> Bool { tapped }

    static func guestPersistSilent(_: TimeInterval) -> Bool { false }

    static func leftoverStreakSinceEncode(_ table: [UUID: TimeInterval]) -> [String: Double] {
        Dictionary(uniqueKeysWithValues: table.map { ($0.key.uuidString, $0.value) })
    }

    static func leftoverStreakSinceDecode(_ raw: [String: Double]?) -> [UUID: TimeInterval] {
        guard let raw else { return [:] }
        var out: [UUID: TimeInterval] = [:]
        for (k, v) in raw {
            if let id = UUID(uuidString: k) { out[id] = v }
        }
        return out
    }

    /// Farbenblind Ampel: Form, nicht nur Farbe.
    static func lampGlyph(_ lamp: Lamp) -> String {
        switch lamp {
        case .green: return "●"
        case .amber: return "◐"
        case .red: return "✕"
        }
    }

    static func lampPattern(_ lamp: Lamp) -> String {
        switch lamp {
        case .green: return "solid"
        case .amber: return "half"
        case .red: return "cross"
        }
    }

    static func claheNeeded(luma: Double, continuity: Bool, floor: Double = 0.18) -> Bool {
        continuity && luma < floor
    }

    static func claheBanner(_ needed: Bool) -> String? { needed ? "CLAHE" : nil }

    static func liveROI(_ box: FaceBox, pad: Double = 0.18) -> FaceBox {
        let x = max(0, box.x - box.width * pad)
        let y = max(0, box.y - box.height * pad)
        let w = min(1 - x, box.width * (1 + 2 * pad))
        let h = min(1 - y, box.height * (1 + 2 * pad))
        return FaceBox(x: x, y: y, width: w, height: h)
    }
}

