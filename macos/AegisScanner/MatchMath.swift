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
    /// gallery.json Schema neben printRevision. 15 = HashTrail remaining + KeepBoxes nach Survive.
    static let gallerySchema = 15
    /// gallery.json.bak + .bak.1 + .bak.2. Crash während Save hält drei Stände.
    static func galleryBakRotate() -> Int { 3 }
    static func galleryBakName(_ i: Int) -> String {
        i <= 0 ? "gallery.json.bak" : "gallery.json.bak.\(i)"
    }
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
        holdOccupied: [String] = [],
        holdOnlyUnsure: Bool = false,
        iouOnly: Bool = false
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
        func holdOf(_ i: Int) -> Double? {
            leftoverHoldPrevOf(
                frontal: holdPrev,
                yawAbs: yawAbs[i],
                bins: holdBins,
                id: leftoverId,
                hash: holdHash,
                hashTable: holdHashTable,
                now: holdAt,
                ttl: holdTTL,
                facesInFrame: facesInFrame,
                occupied: holdOccupied
            )
        }
        var ok = candidates.filter { leftoverPin(iou: $0.iou, floor: floor) }
        ok = ok.filter {
            !leftoverHoldBlocks(
                raw: $0.cosine,
                prev: holdOf($0.index)
            )
        }
        ok = ok.filter {
            if iouOnly { return true }
            return leftoverPrintOk(
                cosine: leftoverPickPrint(raw: $0.cosine, smoothed: holdOf($0.index), holdOnlyUnsure: holdOnlyUnsure),
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
                    raw: leftoverPickPrint(raw: $0.cosine, smoothed: holdOf($0.index), holdOnlyUnsure: holdOnlyUnsure),
                    prev: holdOf($0.index),
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
        if !iouOnly, printable.allSatisfy({
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
        if iouOnly {
            let ious = pool.map(\.iou)
            if let i = leftoverPickArgmaxIou(ious) {
                return pool[i].index
            }
            return nil
        }
        let origRaw = Dictionary(uniqueKeysWithValues: candidates.map {
            ($0.index, leftoverPickPrint(raw: $0.cosine, smoothed: holdOf($0.index), holdOnlyUnsure: holdOnlyUnsure) ?? -1.0)
        })
        let floorRaw = pool.map { origRaw[$0.index] ?? ($0.cosine ?? -1) }
        if leftoverAmbiguousBlocks(raw: floorRaw, scored: scored) { return nil }
        if leftoverSoftmaxBlocks(leftoverScoreSoftmax(scored), capture: session) { return nil }
        let arg = leftoverPickArgmax(raw: floorRaw, scored: scored)
        let rawBest = floorRaw.indices.max(by: { floorRaw[$0] < floorRaw[$1] })
        if arg == rawBest, leftoverOpenSetUnsure(scores: floorRaw) { return nil }
        let topYaw = floorRaw.enumerated().max(by: { $0.element < $1.element }).flatMap { yawAbs[pool[$0.offset].index] }
        if leftoverOpenSetGalleryFloor(floorRaw, floor: leftoverSessionFloor(yawAbs: topYaw, capture: session)) { return nil }
        if let i = arg {
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

    /// Detect-Skip ohne Print-Vec: max IoU, nicht Hold-Zahl 0,70.
    static func leftoverPickArgmaxIou(_ ious: [Double]) -> Int? {
        guard !ious.isEmpty else { return nil }
        return ious.indices.max(by: { ious[$0] < ious[$1] })
    }

    /// Argmax auf Roh-Cosine. leftoverScore nur Tie-Break wenn Spread ≤ 0,08.
    /// Score-Inflation (Schärfe/Yaw/Heat) darf den Nachbarn mit 0,50 vs 0,70 nicht wählen.
    static func leftoverPickArgmax(raw: [Double], scored: [Double], tie: Double = 0.08) -> Int? {
        guard !raw.isEmpty, raw.count == scored.count else { return nil }
        guard let rawBest = raw.indices.max(by: { raw[$0] < raw[$1] }) else { return nil }
        let maxRaw = raw[rawBest]
        var best = rawBest
        for i in raw.indices {
            if maxRaw - raw[i] <= tie, scored[i] > scored[best] {
                best = i
            }
        }
        return best
    }

    /// Detect-Skip / skipPrints: letzter Voll-Print hält leftoverHold.
    static func leftoverCoastPrintKeeps(skipDetect: Bool, skipPrints: Bool = false) -> Bool {
        skipDetect || skipPrints
    }

    static func leftoverCoastCosine(
        skipDetect: Bool,
        skipPrints: Bool = false,
        live: Double?,
        stored: Double?,
        livePrintEmpty: Bool = false
    ) -> Double? {
        if leftoverCoastPrintKeeps(skipDetect: skipDetect, skipPrints: skipPrints), livePrintEmpty {
            return stored
        }
        if let live { return live }
        if leftoverCoastPrintKeeps(skipDetect: skipDetect, skipPrints: skipPrints) { return stored }
        return nil
    }

    /// Letzter Voll-Print-Vektor. skipPrints ohne Vec = leftoverHold-Zahl bleibt tot gegen Twin.
    static func leftoverCoastPrintVecOf(live: [Double], stored: [Double]) -> [Double] {
        if live.count >= 32 { return live }
        if stored.count >= 32 { return stored }
        return live
    }

    static func leftoverCoastPrintCosine(live: [Double], stored: [Double]) -> Double? {
        guard live.count >= 32, stored.count == live.count else { return nil }
        return cosine(live, stored)
    }

    /// skipPrints: Live leer, Cache ≥32. `v.count ≥ 32` tot — sonst Coast nie gegen Twin.
    static func leftoverCoastPrintSkipCosine(
        live: [Double],
        liveStored: [Double],
        old: [Double],
        oldStored: [Double]
    ) -> Double? {
        if live.count >= 32, old.count == live.count { return cosine(live, old) }
        return leftoverCoastPrintCosine(
            live: leftoverCoastPrintVecOf(live: live, stored: liveStored),
            stored: leftoverCoastPrintVecOf(live: old, stored: oldStored)
        )
    }

    /// skipPrints hält den letzten Print-Yaw. Copy liveYaw vorher macht Δ immer 0.
    static func leftoverPrintYawMerge(
        printed: [UUID: Double],
        live: [UUID: Double],
        skipPrints: Bool,
        printedIds: Set<UUID>? = nil
    ) -> [UUID: Double] {
        guard !skipPrints else { return printed }
        var out = printed
        for (id, yaw) in live {
            if let printedIds, !printedIds.contains(id) { continue }
            out[id] = yaw
        }
        return out
    }

    static func leftoverCoastPrintMerge(
        stored: [UUID: [Double]],
        live: [UUID: [Double]],
        skipPrints: Bool
    ) -> [UUID: [Double]] {
        guard !skipPrints else { return stored }
        var out = stored
        for (id, vec) in live {
            let next = leftoverCoastPrintVecOf(live: vec, stored: out[id] ?? [])
            if next.count >= 32 { out[id] = next }
        }
        return out
    }

    /// Identischer Cache-Vec: Stamp nicht auf now. skipPrints→Detect sonst TTL tot.
    static func leftoverCoastPrintSame(_ a: [Double], _ b: [Double], eps: Double = 1e-12) -> Bool {
        guard a.count >= 32, a.count == b.count else { return false }
        for i in a.indices where abs(a[i] - b[i]) > eps { return false }
        return true
    }

    static func leftoverPrintBudgetYawDelta(printed: [UUID: Double], live: [UUID: Double]) -> Double? {
        let ds = live.compactMap { id, yaw -> Double? in
            leftoverPrintBudgetYawDeltaOf(printed: printed, live: yaw, id: id)
        }
        return ds.max()
    }

    static func leftoverPrintBudgetYawDeltaOf(printed: [UUID: Double], live: Double?, id: UUID) -> Double? {
        guard let live, let p = printed[id] else { return nil }
        return abs(live - p)
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
        return now - last >= 0 && now - last < leftoverJpegProbeTTLPref(ttl)
    }

    /// Pref 0,25–1,2 s. Hart 0,80: Indoor 8 fps Probe tot, 24 fps Jank.
    static func leftoverJpegProbeTTLPref(_ pref: TimeInterval) -> TimeInterval {
        min(1.2, max(0.25, pref))
    }

    /// Crop-Fail als −1 merken. Sonst jede Frame reextract.
    static func leftoverJpegProbePut(_ delta: Double?) -> Double { delta ?? -1 }

    static func leftoverJpegProbeGet(_ stored: Double?) -> Double? {
        guard let stored, stored >= 0 else { return nil }
        return stored
    }

    /// Twin teilt sonst die UUID-Probe. Spatial-Key, Rank `#101` strip.
    static func leftoverJpegProbeKey(_ hash: String) -> String {
        leftoverHoldHashSpatial(hash)
    }

    static func leftoverJpegRestoreAt(now: TimeInterval, ttl: TimeInterval) -> TimeInterval {
        now - leftoverJpegProbeTTLPref(ttl)
    }

    static func leftoverJpegProbeLookup(
        table: [String: (delta: Double, at: TimeInterval, cosine: Double)],
        hash: String
    ) -> (delta: Double, at: TimeInterval, cosine: Double)? {
        let key = leftoverJpegProbeKey(hash)
        guard !key.isEmpty else { return nil }
        return table[key]
    }

    static func leftoverJpegProbeStore(
        table: [String: (delta: Double, at: TimeInterval, cosine: Double)],
        hash: String,
        delta: Double?,
        at: TimeInterval,
        cosine: Double?
    ) -> [String: (delta: Double, at: TimeInterval, cosine: Double)] {
        let key = leftoverJpegProbeKey(hash)
        guard !key.isEmpty else { return table }
        var out = table
        out[key] = (delta: leftoverJpegProbePut(delta), at: at, cosine: cosine ?? 0)
        if out.count > leftoverHashHoldCapN {
            let keep = out.sorted { $0.value.at > $1.value.at }.prefix(leftoverHashHoldCapN)
            out = Dictionary(uniqueKeysWithValues: keep.map { ($0.key, $0.value) })
        }
        return out
    }

    /// JPEG-Probe RAM-only tot nach Restart. Spatial-Key.
    /// Cap analog leftoverHashHoldCapN — Encode sonst ungekürzt.
    /// Remaining TTL — at=now nach Restore sonst 1,2 s zu frisch.
    static func leftoverJpegByHashCapped(
        _ table: [String: (delta: Double, at: TimeInterval, cosine: Double)],
        cap: Int = leftoverHashHoldCapN
    ) -> [String: (delta: Double, at: TimeInterval, cosine: Double)] {
        if table.count <= cap { return table }
        return Dictionary(uniqueKeysWithValues: table.sorted { $0.value.at > $1.value.at }.prefix(cap).map { ($0.key, $0.value) })
    }

    static func leftoverJpegRemaining(at: TimeInterval, now: TimeInterval, ttl: TimeInterval) -> TimeInterval {
        let used = leftoverJpegProbeTTLPref(ttl)
        return max(0, used - max(0, now - at))
    }

    static func leftoverJpegAtFromRemaining(remaining: TimeInterval, now: TimeInterval, ttl: TimeInterval) -> TimeInterval {
        let used = leftoverJpegProbeTTLPref(ttl)
        let left = min(used, max(0, remaining))
        return now - (used - left)
    }

    static func leftoverJpegByHashEncode(
        _ table: [String: (delta: Double, at: TimeInterval, cosine: Double)],
        now: TimeInterval = 0,
        ttl: TimeInterval = 0.80
    ) -> [String: [Double]] {
        var out: [String: [Double]] = [:]
        for (k, v) in leftoverJpegByHashCapped(table) {
            let key = leftoverHoldHashSpatial(k)
            guard !key.isEmpty else { continue }
            out[key] = [v.delta, v.cosine, leftoverJpegRemaining(at: v.at, now: now, ttl: ttl)]
        }
        return out
    }

    static func leftoverJpegByHashDecode(
        _ raw: [String: [Double]]?,
        now: TimeInterval,
        ttl: TimeInterval = 0.80
    ) -> [String: (delta: Double, at: TimeInterval, cosine: Double)] {
        guard let raw else { return [:] }
        var out: [String: (delta: Double, at: TimeInterval, cosine: Double)] = [:]
        for (k, v) in raw {
            let key = leftoverHoldHashSpatial(k)
            guard !key.isEmpty, !v.isEmpty else { continue }
            let at: TimeInterval
            if v.count >= 3 {
                at = leftoverJpegAtFromRemaining(remaining: v[2], now: now, ttl: ttl)
            } else {
                at = leftoverJpegRestoreAt(now: now, ttl: ttl)
            }
            out[key] = (delta: v[0], at: at, cosine: v.count >= 2 ? v[1] : 0)
        }
        return out
    }

    /// Mehrheit UND 3 gleiche Ticks. Mehrheit allein springt Geschwister.
    /// JUMP-LOCK: neue Majority tot, Overlay hält `held` — nil wischt sonst den Namen.
    static func leftoverLiveNameAnd(voted: String?, hist: [String], need: Int = 3, locked: Bool = false, held: String? = nil) -> String? {
        if locked { return held }
        guard let voted, leftoverLiveNameHolds(hist, need: need) == voted else { return nil }
        return voted
    }

    /// Mehrheit < Need: Overlay „?“ statt Gast-Taufe.
    /// Streak 2: „??“ — Tick 1 vs Tick 2 unterscheidbar.
    static func leftoverUnsureChip(voted: String?, hist: [String], need: Int, streak: Int = 0) -> String? {
        let tokens = hist.filter { !$0.isEmpty }
        if leftoverLiveNameHolds(tokens, need: need) != nil { return nil }
        if tokens.isEmpty && voted == nil && streak <= 0 { return nil }
        if streak >= 2 { return "??" }
        return "?"
    }

    static func cameraMutexOwnerHelios() -> String { "helios" }
    static func cameraMutexOwnerAegis() -> String { "aegis" }
    static func cameraMutexName() -> String { "helios.aegis.camera.lock" }
    /// Caches statt /tmp: Reboot räumt tmp, Lock blieb tot.
    static func cameraMutexCacheFolder() -> String { "HeliosAegis" }
    static func cameraMutexRelPath() -> String {
        cameraMutexCacheFolder() + "/" + cameraMutexName()
    }
    static func cameraMutexWriteKind() -> String { "caches" }
    static func cameraMutexReadOrder() -> [String] { ["caches", "tmp"] }
    static func cameraMutexFlockExclusive() -> Bool { true }
    /// Heartbeat auf der Capture-Queue darf nicht hinter LOCK_EX warten.
    static func cameraMutexFlockNonblock() -> Bool { true }
    static func cameraMutexFlockReadShared() -> Bool { true }
    static func cameraMutexClaimCadence() -> Int { 1 }
    static func cameraMutexClaimEveryFrame() -> Bool { true }
    static func cameraMutexClaimMinDt() -> TimeInterval { 0.08 }
    /// LOCK_NB 3× tot → 400 ms, sonst Claim hämmert hinter Aegis-Write.
    static func cameraMutexClaimBackoffFails() -> Int { 3 }
    static func cameraMutexClaimBackoffDt() -> TimeInterval { 0.40 }
    static func cameraMutexClaimDue(
        last: TimeInterval,
        now: TimeInterval,
        minDt: TimeInterval = cameraMutexClaimMinDt(),
        fails: Int = 0
    ) -> Bool {
        let wait = fails >= cameraMutexClaimBackoffFails() ? max(minDt, cameraMutexClaimBackoffDt()) : minDt
        return now - last >= wait
    }
    static func cameraMutexFsyncBeforeUnlock() -> Bool { true }
    /// 2.1.163: Caches-only Write. tmp bleibt Read-Legacy für Helios < 1.5.161.
    static func cameraMutexWriteTmp() -> Bool { false }
    /// LOCK_SH|NB fehlgeschlagen: nicht als holder=nil claimen.
    static func cameraMutexSkipClaim(readBusy: Bool) -> Bool { readBusy }
    /// Unter LOCK_EX neu lesen. Aegis schreibt nicht über Helios, der nach dem unlocked Read kam.
    /// pidLive false: Holder-PID tot (Crash/Sleep) — Lock frei, nicht 12 s stale.
    static func cameraMutexWriteAllowed(
        existing: String?,
        owner: String,
        now: TimeInterval,
        pidLive: Bool? = nil
    ) -> Bool {
        let holder = existing.flatMap { cameraMutexParse($0, now: now, pidLive: pidLive) }
        return cameraMutexClaimWrites(holder: holder, owner: owner)
    }
    static func cameraMutexBumpGen(_ existing: String?) -> UInt32 {
        (existing.flatMap { cameraMutexGen($0) } ?? 0) &+ 1
    }
    /// SH-Read Gen. Fehlt das Feld (alte 3-Zeile) → 0.
    static func cameraMutexExpectedGen(_ existing: String?) -> UInt32 {
        existing.flatMap { cameraMutexGen($0) } ?? 0
    }
    /// Gen-Mismatch: jemand schrieb zwischen Parse und LOCK_EX.
    /// Helios hat Continuity-Vorrang und schreibt trotzdem. Aegis bricht ab.
    static func cameraMutexCasAllows(existing: String?, owner: String, expectedGen: UInt32?) -> Bool {
        guard let expected = expectedGen else { return true }
        if cameraMutexExpectedGen(existing) == expected { return true }
        return owner == cameraMutexOwnerHelios()
    }
    static func cameraMutexLockedLine(
        existing: String?,
        owner: String,
        pid: Int32,
        now: TimeInterval,
        expectedGen: UInt32? = nil,
        pidLive: Bool? = nil
    ) -> String? {
        guard cameraMutexWriteAllowed(existing: existing, owner: owner, now: now, pidLive: pidLive) else { return nil }
        guard cameraMutexCasAllows(existing: existing, owner: owner, expectedGen: expectedGen) else { return nil }
        return cameraMutexLine(owner: owner, pid: pid, now: now, gen: cameraMutexBumpGen(existing))
    }
    /// 3 s war kürzer als Continuity-Frame. Heartbeat 2 s, Stale 12.
    static func cameraMutexStale() -> TimeInterval { 12 }

    static func cameraMutexHeartbeatSec() -> TimeInterval { 2 }

    /// Int(now) = Sekundenraster: Claim 12,9 / Parse 13,0 = 1 s tot. %.3f hält ms.
    /// gen 0: alte 3-Felder-Zeile (2.1.160).
    static func cameraMutexLine(owner: String, pid: Int32, now: TimeInterval, gen: UInt32 = 0) -> String {
        if gen == 0 {
            return String(format: "%@ %d %.3f", owner, pid, now)
        }
        return String(format: "%@ %d %.3f %u", owner, pid, now, gen)
    }

    static func cameraMutexPid(_ text: String) -> Int32? {
        let parts = text.split(whereSeparator: { $0 == " " || $0 == "\n" }).map(String.init)
        guard parts.count >= 2 else { return nil }
        return Int32(parts[1])
    }

    static func cameraMutexGen(_ text: String) -> UInt32? {
        let parts = text.split(whereSeparator: { $0 == " " || $0 == "\n" }).map(String.init)
        guard parts.count >= 4 else { return nil }
        return UInt32(parts[3])
    }

    /// cachesEmpty: ftruncate-Rennen. Leerer Caches-String ist Write-in-flight, nicht Legacy-tmp.
    static func cameraMutexPickText(caches: String?, tmp: String?, cachesEmpty: Bool = false) -> String? {
        if let caches, !caches.isEmpty { return caches }
        if cachesEmpty { return nil }
        if let tmp, !tmp.isEmpty { return tmp }
        return nil
    }

    /// pidLive nil = Tests ohne kill(2). Crash: pid tot → Lock frei, nicht 12 s warten.
    static func cameraMutexParse(
        _ text: String,
        now: TimeInterval,
        stale: TimeInterval = cameraMutexStale(),
        pidLive: Bool? = nil
    ) -> String? {
        let parts = text.split(whereSeparator: { $0 == " " || $0 == "\n" }).map(String.init)
        guard parts.count >= 3, let stamp = TimeInterval(parts[2]) else { return nil }
        if now - stamp > stale { return nil }
        if let pidLive, !pidLive { return nil }
        let owner = parts[0]
        if owner != cameraMutexOwnerHelios() && owner != cameraMutexOwnerAegis() { return nil }
        return owner
    }

    static func cameraMutexBlocks(holder: String?, owner: String) -> Bool {
        guard let holder else { return false }
        return holder != owner
    }

    static func cameraMutexYieldsContinuity(holder: String?, owner: String) -> Bool {
        holder == cameraMutexOwnerHelios() && owner == cameraMutexOwnerAegis()
    }

    /// Helios hat Continuity-Vorrang. Aegis schreibt nie über einen fremden Holder.
    static func cameraMutexClaimWrites(holder: String?, owner: String) -> Bool {
        if owner == cameraMutexOwnerHelios() { return true }
        if owner == cameraMutexOwnerAegis() {
            return holder == nil || holder == cameraMutexOwnerAegis()
        }
        return false
    }

    /// Yield klebt bei Helios und in der Atomic-Lücke (holder nil).
    /// 2.1.160: wasYielded blieb ewig true — Aegis-Session blieb auf Continuity.
    static func cameraMutexYieldsNow(holder: String?, owner: String, wasYielded: Bool) -> Bool {
        if cameraMutexYieldsContinuity(holder: holder, owner: owner) { return true }
        if !wasYielded { return false }
        if holder == nil { return true }
        if holder == cameraMutexOwnerHelios() { return true }
        return false
    }

    /// Live-Yield: Session auf Built-in umlegen, nicht nur Heartbeat killen.
    static func cameraMutexYieldReconfigure(yielded: Bool, isContinuity: Bool) -> Bool {
        yielded && isContinuity
    }

    /// Heartbeat bleibt. 4 s nach Helios-Weg = Continuity zurück, nicht für immer Built-in.
    static func cameraMutexYieldGrace() -> TimeInterval { 4 }

    static func cameraMutexYieldGracePref(_ seconds: Double) -> TimeInterval {
        min(8, max(2, seconds))
    }

    static func cameraMutexYieldAutoReturnPref(_ on: Bool) -> Bool { on }

    static func cameraMutexYieldAutoReturn(
        yielded: Bool,
        holder: String?,
        owner: String,
        since: TimeInterval,
        now: TimeInterval,
        grace: TimeInterval = cameraMutexYieldGrace()
    ) -> Bool {
        guard yielded else { return false }
        if cameraMutexYieldsContinuity(holder: holder, owner: owner) { return false }
        if now - since < grace { return false }
        return holder == nil || holder == owner
    }

    static func cameraMutexChip(holder: String?, yielded: Bool) -> String {
        if yielded { return "YIELD" }
        return holder ?? "—"
    }

    /// HUD: Holder plus LOCK_NB-Druck. backoff nach 3 Fails.
    static func cameraMutexClaimChip(
        holder: String?,
        yielded: Bool,
        fails: Int = 0,
        lastDt: TimeInterval = 0,
        term: String? = nil
    ) -> String {
        if yielded { return "YIELD" }
        let base = holder ?? "—"
        if let term, !term.isEmpty { return "\(base) · \(term)" }
        if fails >= cameraMutexClaimBackoffFails() { return "\(base) · backoff" }
        if fails > 0 { return "\(base) · \(fails)nb" }
        if lastDt > 0, lastDt < 10 {
            return String(format: "%@ · %.0fms", base, lastDt * 1000)
        }
        return base
    }

    static func cameraMutexPidDead(_ pid: Int32?) -> Bool {
        guard let pid else { return true }
        return pid <= 0
    }

    static func cameraMutexStamp(_ text: String) -> TimeInterval? {
        let parts = text.split(whereSeparator: { $0 == " " || $0 == "\n" }).map(String.init)
        guard parts.count >= 3 else { return nil }
        return TimeInterval(parts[2])
    }

    /// Nach Sleep: tot-PID SIGKILL. Hung-live (Prozess da, Stamp tot) nach Stale 12 s.
    /// Continuity 8 fps schreibt 2 s Heartbeat — 5 s live bleibt. Self nie.
    static func cameraMutexHeartbeatKillPid(
        pid: Int32?,
        live: Bool?,
        now: TimeInterval,
        stamped: TimeInterval?,
        heartbeat: TimeInterval = cameraMutexHeartbeatSec()
    ) -> Int32? {
        guard let pid, pid > 0 else { return nil }
        if live == false { return pid }
        if live == true {
            guard let stamped else { return nil }
            if now - stamped >= cameraMutexStale() { return pid }
            return nil
        }
        guard let stamped else { return nil }
        if now - stamped >= heartbeat * 3 { return pid }
        return nil
    }

    static func cameraMutexHeartbeatKillAllowed(target: Int32?, selfPid: Int32) -> Int32? {
        guard let target, target > 0, target != selfPid else { return nil }
        return target
    }

    static func cameraMutexSigTerm() -> Int32 { 15 }
    static func cameraMutexSigKill() -> Int32 { 9 }
    static func cameraMutexTermWait() -> TimeInterval { 2 }

    static func cameraMutexHeartbeatKillSignal(termSentAt: TimeInterval?, now: TimeInterval, wait: TimeInterval = 2) -> Int32 {
        guard let t = termSentAt, now - t >= wait else { return cameraMutexSigTerm() }
        return cameraMutexSigKill()
    }

    static func cameraMutexHeartbeatKillChip(signal: Int32) -> String {
        signal == cameraMutexSigKill() ? "SIGKILL" : "SIGTERM"
    }

    static func cameraMutexHeartbeatTermStamp(prev: [Int32: TimeInterval], pid: Int32, signal: Int32, now: TimeInterval) -> [Int32: TimeInterval] {
        var next = prev
        if signal == cameraMutexSigTerm() {
            next[pid] = prev[pid] ?? now
        } else {
            next.removeValue(forKey: pid)
        }
        return next
    }

    /// SIGTERM + Holder noch live: Lock nicht stehlen. Nächster Beat SIGKILL.
    static func cameraMutexTermBlocksWrite(signal: Int32, pidLive: Bool?) -> Bool {
        signal == cameraMutexSigTerm() && pidLive == true
    }

    static func cameraMutexTermRemain(
        termSentAt: TimeInterval?,
        now: TimeInterval,
        wait: TimeInterval = 2
    ) -> TimeInterval? {
        guard let t = termSentAt else { return nil }
        return max(0, wait - (now - t))
    }

    static func cameraMutexTermChip(signal: Int32, remain: TimeInterval?) -> String? {
        if signal == cameraMutexSigKill() { return "SIGKILL" }
        if signal == cameraMutexSigTerm(), let r = remain {
            return String(format: "TERM %.1f", r).replacingOccurrences(of: ".", with: ",")
        }
        return nil
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
    static func leftoverBaptizeFloor(continuity: Bool) -> Double {
        continuity ? 0.76 : pinPrintCosine
    }

    static func leftoverBaptize(cosine: Double?, continuity: Bool = false) -> Bool {
        guard let cosine else { return false }
        return cosine >= leftoverBaptizeFloor(continuity: continuity)
    }

    static let leftoverBaptizeQualityFloor = 0.18

    static func leftoverBaptizeQualityFloorOf(continuity: Bool) -> Double {
        continuity ? 0.06 : leftoverBaptizeQualityFloor
    }

    /// Produkt Blur × Pose. Blink = 0. OR-Gates allein ließen weichen Blur + leichten Yaw durch.
    static func leftoverBaptizeQualityProduct(sharpness: Double?, yawAbs: Double?, blink: Bool = false) -> Double {
        if blink { return 0 }
        let s = max(0, min(1, sharpness ?? 1))
        let pose: Double
        if let y = yawAbs {
            pose = max(0, 1 - y / leftoverPrintProfileYaw)
        } else {
            pose = 1
        }
        return s * pose
    }

    /// Taufe roh ≥ 0,80 UND smooth ≥ 0,80. nil Smooth ist Dropout, nicht Taufe.
    /// Qualität: Blur / Blink / Profil sperren — Poster und Lid-Schluss taufen sonst den Nachbarn.
    static func leftoverBaptizeQuality(sharpness: Double? = nil, yawAbs: Double? = nil, blink: Bool = false, continuity: Bool = false) -> Bool {
        if blink { return false }
        if let y = yawAbs, y >= leftoverPrintProfileYaw { return false }
        if let s = sharpness, s < activeSharpnessFloor(continuity: continuity) { return false }
        return leftoverBaptizeQualityProduct(sharpness: sharpness, yawAbs: yawAbs, blink: blink) + 1e-12 >= leftoverBaptizeQualityFloorOf(continuity: continuity)
    }

    static func leftoverBaptizeBoth(
        raw: Double?,
        smooth: Double?,
        sharpness: Double? = nil,
        yawAbs: Double? = nil,
        blink: Bool = false,
        continuity: Bool = false
    ) -> Bool {
        leftoverBaptize(cosine: raw, continuity: continuity)
            && leftoverBaptize(cosine: smooth, continuity: continuity)
            && leftoverBaptizeQuality(sharpness: sharpness, yawAbs: yawAbs, blink: blink, continuity: continuity)
    }

    static func leftoverBaptizeGate(
        raw: Double?,
        smooth: Double?,
        sharpness: Double? = nil,
        yawAbs: Double? = nil,
        blink: Bool = false,
        jpegDelta: Double? = nil,
        jpegRequired: Bool = false,
        continuity: Bool = false
    ) -> Bool {
        leftoverBaptizeBoth(raw: raw, smooth: smooth, sharpness: sharpness, yawAbs: yawAbs, blink: blink, continuity: continuity)
            && leftoverBaptizeJpegOk(jpegDelta, required: jpegRequired)
    }

    /// Twin 0,80 nach Hold 0,64: Spike, kein Steal. 0,80 nach 0,80 bleibt Taufe.
    static func leftoverBaptizeSpike(
        raw: Double?,
        prev: Double?,
        spike: Double = leftoverHoldSpike,
        continuity: Bool = false
    ) -> Bool {
        guard leftoverBaptize(cosine: raw, continuity: continuity), let prev else { return false }
        if leftoverBaptize(cosine: prev, continuity: continuity) { return false }
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
        nameLockUntil: TimeInterval? = nil,
        jump: Double = leftoverIoUJump,
        continuity: Bool = false
    ) -> Bool {
        if tapNameLockBlocks(until: tapUntil, now: now) { return false }
        if leftoverNameLockBlocks(until: nameLockUntil, now: now) { return false }
        if leftoverBaptizeStillBlocks(stillFor: stillFor, cosine: cosine, holdPrev: holdPrev, continuity: continuity) { return false }
        if leftoverIoUJumpBlocks(iou, jump: jump) { return false }
        guard leftoverBaptize(cosine: cosine, continuity: continuity) else { return false }
        if !leftoverBaptizeQuality(sharpness: sharpness, yawAbs: yawAbs, blink: blink, continuity: continuity) { return false }
        if !leftoverBaptizeJpegOk(jpegDelta, required: jpegRequired) { return false }
        if printMADBlocks(trail) { return false }
        let trailMean: Double? = trail.isEmpty ? nil : trail.reduce(0, +) / Double(trail.count)
        if leftoverBaptizeSpike(raw: cosine, prev: holdPrev, continuity: continuity) {
            let n = trail.filter { leftoverBaptize(cosine: $0, continuity: continuity) }.count
            return n >= 3 && leftoverBaptizeGate(raw: cosine, smooth: trailMean, sharpness: sharpness, yawAbs: yawAbs, blink: blink, jpegDelta: jpegDelta, jpegRequired: jpegRequired, continuity: continuity)
        }
        return leftoverBaptizeGate(raw: cosine, smooth: holdPrev, sharpness: sharpness, yawAbs: yawAbs, blink: blink, jpegDelta: jpegDelta, jpegRequired: jpegRequired, continuity: continuity)
    }

    static let leftoverBaptizeStillNeed: TimeInterval = 0.45

    /// Erste Begegnung ohne Hold: 0,45 s still bevor Taufe. Hold 0,64 skippt.
    static func leftoverBaptizeStillBlocks(
        stillFor: TimeInterval,
        cosine: Double?,
        holdPrev: Double?,
        continuity: Bool = false
    ) -> Bool {
        guard leftoverBaptize(cosine: cosine, continuity: continuity) else { return false }
        if leftoverPrintOk(cosine: holdPrev) { return false }
        return stillFor < leftoverBaptizeStillNeed
    }

    static func leftoverWipeHist(cosine: Double?, continuity: Bool = false) -> Bool {
        !leftoverBaptize(cosine: cosine, continuity: continuity)
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

    static func leftoverIoUJumpBlocks(_ iou: Double?, jump: Double = leftoverIoUJump) -> Bool {
        guard let iou else { return false }
        return iou + 1e-12 < leftoverHoldKalmanJumpPref(jump)
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
        leftoverHashRankRebase(raw ?? [:])
    }

    static func leftoverHoldTrailBinsDecode(_ raw: [String: [Double]]?) -> [String: [Double]] {
        leftoverHashRankRebase(raw ?? [:])
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

    /// Remaining analog JPEG. Decode-at=now startet TTL nach Restore neu.
    static func leftoverHashHoldRemainingEncode(
        _ table: [String: (cosine: Double, at: TimeInterval)],
        now: TimeInterval,
        ttl: TimeInterval
    ) -> [String: Double] {
        var out: [String: Double] = [:]
        let used = leftoverHoldTTLPref(ttl)
        for (k, v) in leftoverHashHoldCapped(table) where leftoverHashHoldKeeps(v.cosine) {
            out[k] = leftoverJpegRemaining(at: v.at, now: now, ttl: used)
        }
        return out
    }

    static func leftoverHashHoldDecode(
        _ raw: [String: Double]?,
        now: TimeInterval,
        remaining: [String: Double]? = nil,
        ttl: TimeInterval = leftoverAdoptSec
    ) -> [String: (cosine: Double, at: TimeInterval)] {
        guard let raw else { return [:] }
        let used = leftoverHoldTTLPref(ttl)
        return Dictionary(uniqueKeysWithValues: raw.filter { leftoverHashHoldKeeps($0.value) }.map { key, cosine in
            let at: TimeInterval
            if let left = remaining?[key] {
                at = leftoverJpegAtFromRemaining(remaining: left, now: now, ttl: used)
            } else {
                at = now
            }
            return (key, (cosine: cosine, at: at))
        })
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

    static func leftoverIoUJumpChip(_ iou: Double?, jump: Double = leftoverIoUJump) -> String? {
        leftoverIoUJumpBlocks(iou, jump: jump) ? "JUMP" : nil
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
    /// Rank `#101` blockt Exact nicht — Spatial-strip fraß Twin-L.
    static func leftoverOccupiedRankBlocks(live: [String], hash: String) -> Bool {
        let spatial = leftoverHoldHashSpatial(hash)
        if spatial.isEmpty { return live.contains(hash) }
        if hash != spatial {
            return live.contains(hash)
        }
        return live.contains { leftoverHoldHashSpatial($0) == spatial && leftoverHoldHashSpatial($0) == $0 }
    }

    static func leftoverHashOwnOccupied(live: [String], hash: String) -> Bool {
        leftoverOccupiedRankBlocks(live: live, hash: hash)
    }

    /// leftoverLastHash ist Vor-Tick. Erster Twin-Frame: stored leer, Exact-Steal.
    /// Live zuerst — Ghost-Hashes sonst Exact auf Tote.
    /// Rank `#101` nach Restore Spatial: sonst Occupied doppelt.
    /// Tick schreibt `#101`: emit Spatial, nicht Original — live Rank sonst Occupied Rank.
    static func leftoverOccupiedMerge(stored: [String], live: [String]) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        for h in live + stored where !h.isEmpty {
            let key = leftoverHoldHashSpatial(h)
            if key.isEmpty { continue }
            if seen.insert(key).inserted { out.append(key) }
        }
        return out
    }

    /// Zwei Live gleiches Spatial: kleinerer yawAbs Exact, Rest `#101`.
    /// Merge ohne Yaw emittiert nur Spatial — Center-Stage x-Tie beide Occupied.
    /// Twin weg: stored `#101` bleibt Occupied, Exact tot für den einen der bleibt.
    static func leftoverOccupiedTwinGone(liveOfSpatial: Int, storedRanked: Bool) -> Bool {
        storedRanked && liveOfSpatial == 1
    }

    static func leftoverOccupiedMergeYaw(
        stored: [String],
        live: [(hash: String, yawAbs: Double)]
    ) -> [String] {
        var groups: [String: [(hash: String, yawAbs: Double)]] = [:]
        var order: [String] = []
        for row in live where !row.hash.isEmpty {
            let key = leftoverHoldHashSpatial(row.hash)
            if key.isEmpty { continue }
            if groups[key] == nil { order.append(key) }
            groups[key, default: []].append(row)
        }
        var seen = Set<String>()
        var out: [String] = []
        for key in order {
            let rows = (groups[key] ?? []).sorted { $0.yawAbs + 1e-9 < $1.yawAbs }
            if rows.count <= 1 {
                if seen.insert(key).inserted { out.append(key) }
                continue
            }
            for (i, _) in rows.enumerated() {
                let emit = i == 0 ? key : leftoverHoldHashTwinKey(hash: key, rank: i)
                if seen.insert(emit).inserted { out.append(emit) }
            }
        }
        for h in stored where !h.isEmpty {
            let ranked = leftoverHoldHashSpatial(h) != h
            let spatial = leftoverHoldHashSpatial(h)
            let liveN = groups[spatial]?.count ?? 0
            if leftoverOccupiedTwinGone(liveOfSpatial: liveN, storedRanked: ranked) {
                continue
            }
            let emit: String
            if ranked {
                emit = h
            } else {
                emit = spatial
            }
            if emit.isEmpty { continue }
            if seen.insert(emit).inserted { out.append(emit) }
        }
        return out
    }

    /// Hamming-0 Twins: strikt links behält Exact, rechts Occupied.
    /// Gleichstand ohne Yaw: beide tot. Mit Yaw: kleinerer yawAbs Exact (Center-Stage).
    /// Yaw auch gleich: tieKey lexikographisch kleiner Exact — sonst beide Occupied.
    static func leftoverHashTwinLeft(
        x: Double,
        others: [Double],
        yawAbs: Double = 0,
        otherYaws: [Double] = [],
        tieKey: String = "",
        otherTieKeys: [String] = []
    ) -> Bool {
        if others.allSatisfy({ x + 1e-9 < $0 }) { return true }
        if others.contains(where: { $0 + 1e-9 < x }) { return false }
        guard otherYaws.count == others.count, !otherYaws.isEmpty else { return false }
        let tied = zip(others, otherYaws).compactMap { ox, oy -> Double? in
            abs(ox - x) <= 1e-9 ? oy : nil
        }
        if !tied.isEmpty && tied.allSatisfy({ yawAbs + 1e-9 < $0 }) { return true }
        if !tied.isEmpty && tied.allSatisfy({ abs(yawAbs - $0) <= 1e-9 }),
           otherTieKeys.count == others.count, !tieKey.isEmpty {
            let keys = zip(others, otherTieKeys).compactMap { ox, k -> String? in
                abs(ox - x) <= 1e-9 ? k : nil
            }
            return keys.allSatisfy { tieKey < $0 }
        }
        return false
    }

    static func leftoverHashTwinOccupied(
        occupied: [String],
        hash: String,
        x: Double,
        others: [(hash: String, x: Double)],
        yawAbs: Double = 0,
        otherYaws: [Double] = [],
        tieKey: String = "",
        otherTieKeys: [String] = []
    ) -> [String] {
        let bare = leftoverHoldHashBare(hash)
        guard !bare.isEmpty else { return occupied }
        let twins = others.filter { leftoverHoldHashBare($0.hash) == bare }
        guard !twins.isEmpty else { return occupied }
        let twinYaws: [Double]
        if otherYaws.count == others.count {
            twinYaws = zip(others, otherYaws).compactMap { row, yaw in
                leftoverHoldHashBare(row.hash) == bare ? yaw : nil
            }
        } else {
            twinYaws = []
        }
        let twinKeys: [String]
        if otherTieKeys.count == others.count {
            twinKeys = zip(others, otherTieKeys).compactMap { row, key in
                leftoverHoldHashBare(row.hash) == bare ? key : nil
            }
        } else {
            twinKeys = []
        }
        if leftoverHashTwinLeft(
            x: x,
            others: twins.map(\.x),
            yawAbs: yawAbs,
            otherYaws: twinYaws,
            tieKey: tieKey,
            otherTieKeys: twinKeys
        ) {
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

    static func leftoverHashTwinRank(x: Double, others: [Double], yawAbs: Double = 0, otherYaws: [Double] = []) -> Int {
        let left = others.filter { $0 < x - 1e-9 }.count
        guard otherYaws.count == others.count else { return left }
        let tied = zip(others, otherYaws).filter { abs($0.0 - x) <= 1e-9 }
        return left + tied.filter { $0.1 < yawAbs - 1e-9 }.count
    }

    static func leftoverHoldHashTwinKey(hash: String, rank: Int) -> String {
        let bare = leftoverHoldHashBare(hash)
        if rank <= 0 { return bare }
        return leftoverHoldHashKey(hash: bare, bin: leftoverHashTwinRankBase + rank)
    }

    static func leftoverHashTwinRanked(
        hash: String,
        x: Double,
        others: [(hash: String, x: Double)],
        yawAbs: Double = 0,
        otherYaws: [Double] = []
    ) -> String {
        let bare = leftoverHoldHashBare(hash)
        guard !bare.isEmpty else { return hash }
        let twins = others.filter { leftoverHoldHashBare($0.hash) == bare }
        guard !twins.isEmpty else { return hash }
        let twinYaws: [Double]
        if otherYaws.count == others.count {
            twinYaws = zip(others, otherYaws).compactMap { row, yaw in
                leftoverHoldHashBare(row.hash) == bare ? yaw : nil
            }
        } else {
            twinYaws = []
        }
        return leftoverHoldHashTwinKey(
            hash: bare,
            rank: leftoverHashTwinRank(x: x, others: twins.map(\.x), yawAbs: yawAbs, otherYaws: twinYaws)
        )
    }

    /// leftoverLiveHashTick allein: Twin aus leftoverLastHash unsichtbar, erster Frame steals.
    static func leftoverOccupiedOthers(
        live: [(id: UUID, hash: String, x: Double)],
        stored: [(id: UUID, hash: String, x: Double)],
        except: UUID?
    ) -> [(hash: String, x: Double)] {
        leftoverOccupiedOtherRows(live: live, stored: stored, except: except).map { (hash: $0.hash, x: $0.x) }
    }

    /// Twin-Tie braucht UUID, nicht nur Hash. Occupied rief leftoverHashTwinLeft ohne Key.
    static func leftoverOccupiedOtherRows(
        live: [(id: UUID, hash: String, x: Double)],
        stored: [(id: UUID, hash: String, x: Double)],
        except: UUID?
    ) -> [(hash: String, x: Double, key: String)] {
        var seen = Set<UUID>()
        var out: [(hash: String, x: Double, key: String)] = []
        for row in live + stored {
            if row.id == except { continue }
            if seen.contains(row.id) { continue }
            seen.insert(row.id)
            if row.hash.isEmpty { continue }
            out.append((hash: row.hash, x: row.x, key: row.id.uuidString))
        }
        return out
    }

    /// empty wischt leftoverLastHash. Ghost-Bins sonst blocken Re-Entry.
    /// Miss-Coast 1 Tick: Detect-Drop darf LastHash nicht leeren.
    static func leftoverLastHashWipes(empty: Bool, overlayKeep: Bool = false, missCoast: Bool = false) -> Bool {
        empty && !overlayKeep && !missCoast
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
    /// Hash leer, Person ging. 0,90 bleibt tot (Test Far).
    static let leftoverFillXRescue = 0.28

    static func leftoverFillXRescuePref(_ pref: Double) -> Double {
        min(0.36, max(0.16, pref))
    }

    static func leftoverFillXPadPref(_ pref: Double) -> Double {
        min(0.20, max(0.06, pref))
    }

    /// Solo: erster Pass padRescue (18 cm). Twin: enges Pad, Hash, dann Rescue.
    static func leftoverHoldRemintPad(
        faces: Int,
        pad: Double = leftoverFillXPad,
        padRescue: Double = leftoverFillXRescue
    ) -> Double {
        faces <= 1 ? leftoverFillXRescuePref(padRescue) : leftoverFillXPadPref(pad)
    }

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

    /// n≤8 min-cost Recursion. n>8 / Wide-Pad: Kuhn-Munkres + 2/3/4-opt.
    static let leftoverAssignHungarianN = 8

    /// Pad 0,40 bei n=8 explodiert Recursion. FillX greedy.
    static func leftoverAssignHungarianWide(_ pad: Double) -> Bool {
        pad > leftoverFillXPad + 0.08
    }

    static func leftoverAssignHungarianX(
        assigned: [Int?],
        liveX: [Double],
        holdX: [Double],
        pad: Double = leftoverFillXPad,
        spread: Double = leftoverAmbiguousSpread,
        scores: [[Double?]]? = nil
    ) -> [Int?] {
        var out = assigned
        if out.count < holdX.count {
            out += Array(repeating: Optional<Int>.none, count: holdX.count - out.count)
        }
        let n = holdX.count
        let m = liveX.count
        if n == 0 || m == 0 { return out }
        if leftoverAssignHungarianWide(pad) || n > leftoverAssignHungarianN || m > leftoverAssignHungarianN {
            return leftoverAssignHungarianXKuhn(
                assigned: assigned, liveX: liveX, holdX: holdX, pad: pad, spread: spread, scores: scores
            )
        }
        let used = Set(out.prefix(n).compactMap { $0 })
        let rows = (0..<n).filter { out[$0] == nil }
        let cols = (0..<m).filter { !used.contains($0) }
        guard !rows.isEmpty, !cols.isEmpty else { return out }
        var best: [Int?]?
        var bestCost = Double.infinity
        var bestN = -1
        func rec(_ i: Int, _ taken: Set<Int>, _ cost: Double, _ nAss: Int, _ cur: [Int?]) {
            if i == rows.count {
                if nAss > bestN || (nAss == bestN && cost < bestCost) {
                    bestN = nAss
                    bestCost = cost
                    best = cur
                }
                return
            }
            let r = rows[i]
            rec(i + 1, taken, cost, nAss, cur)
            for c in cols where !taken.contains(c) {
                let d = abs(liveX[c] - holdX[r])
                if d > pad { continue }
                var nxt = cur
                nxt[r] = c
                rec(i + 1, taken.union([c]), cost + leftoverAssignHungarianXStep(
                    dx: d, pad: pad, row: r, col: c, scores: scores
                ), nAss + 1, nxt)
            }
        }
        rec(0, [], 0, 0, out)
        guard let chosen = best else {
            return leftoverAssignHungarianXGreedy(
                assigned: assigned, liveX: liveX, holdX: holdX, pad: pad, spread: spread, scores: scores
            )
        }
        if leftoverAssignHungarianXHasPrint(scores) { return chosen }
        return leftoverAssignSpreadVeto(assigned: chosen, liveX: liveX, holdX: holdX, pad: pad, spread: spread)
    }

    /// n>8: Recursion tot. Kuhn-Munkres + 2/3/4-opt hält Print im Crowd. 2-opt allein hängt 4-Zyklus.
    static func leftoverAssignHungarianXGreedy(
        assigned: [Int?],
        liveX: [Double],
        holdX: [Double],
        pad: Double,
        spread: Double = leftoverAmbiguousSpread,
        scores: [[Double?]]? = nil
    ) -> [Int?] {
        var out = assigned
        if out.count < holdX.count {
            out += Array(repeating: Optional<Int>.none, count: holdX.count - out.count)
        }
        var used = Set(out.prefix(holdX.count).compactMap { $0 })
        var pairs: [(cost: Double, r: Int, c: Int)] = []
        for r in 0..<holdX.count {
            if r < out.count, out[r] != nil { continue }
            for c in 0..<liveX.count where !used.contains(c) {
                let d = abs(liveX[c] - holdX[r])
                if d > pad { continue }
                let cost = leftoverAssignHungarianXStep(dx: d, pad: pad, row: r, col: c, scores: scores)
                pairs.append((cost, r, c))
            }
        }
        pairs.sort { a, b in
            if abs(a.cost - b.cost) > 1e-12 { return a.cost < b.cost }
            if a.r != b.r { return a.r < b.r }
            return a.c < b.c
        }
        for p in pairs {
            if p.r < out.count, out[p.r] != nil { continue }
            if used.contains(p.c) { continue }
            out[p.r] = p.c
            used.insert(p.c)
        }
        out = leftoverAssignHungarianX2opt(assigned: out, liveX: liveX, holdX: holdX, pad: pad, scores: scores)
        out = leftoverAssignHungarianX3opt(assigned: out, liveX: liveX, holdX: holdX, pad: pad, scores: scores)
        out = leftoverAssignHungarianX4opt(assigned: out, liveX: liveX, holdX: holdX, pad: pad, scores: scores)
        if leftoverAssignHungarianXHasPrint(scores) { return out }
        return leftoverAssignSpreadVeto(assigned: out, liveX: liveX, holdX: holdX, pad: pad, spread: spread)
    }

    static func leftoverAssignHungarianX2opt(
        assigned: [Int?],
        liveX: [Double],
        holdX: [Double],
        pad: Double,
        scores: [[Double?]]?
    ) -> [Int?] {
        var out = assigned
        var improved = true
        var guardN = 0
        while improved, guardN < 16 {
            improved = false
            guardN += 1
            let n = min(out.count, holdX.count)
            for i in 0..<n {
                guard let c1 = out[i], c1 < liveX.count else { continue }
                for j in (i + 1)..<n {
                    guard let c2 = out[j], c2 < liveX.count else { continue }
                    let d11 = abs(liveX[c1] - holdX[i])
                    let d22 = abs(liveX[c2] - holdX[j])
                    let d12 = abs(liveX[c2] - holdX[i])
                    let d21 = abs(liveX[c1] - holdX[j])
                    if d12 > pad || d21 > pad { continue }
                    let cur = leftoverAssignHungarianXStep(dx: d11, pad: pad, row: i, col: c1, scores: scores)
                        + leftoverAssignHungarianXStep(dx: d22, pad: pad, row: j, col: c2, scores: scores)
                    let sw = leftoverAssignHungarianXStep(dx: d12, pad: pad, row: i, col: c2, scores: scores)
                        + leftoverAssignHungarianXStep(dx: d21, pad: pad, row: j, col: c1, scores: scores)
                    if sw + 1e-9 < cur {
                        out[i] = c2
                        out[j] = c1
                        improved = true
                    }
                }
            }
        }
        return out
    }

    /// 3-Zyklus. 2-opt bleibt in 4-Zyklus-Minima hängen.
    static func leftoverAssignHungarianX3opt(
        assigned: [Int?],
        liveX: [Double],
        holdX: [Double],
        pad: Double,
        scores: [[Double?]]?
    ) -> [Int?] {
        var out = assigned
        var improved = true
        var guardN = 0
        while improved, guardN < 8 {
            improved = false
            guardN += 1
            let n = min(out.count, holdX.count)
            for i in 0..<n {
                guard let c1 = out[i], c1 < liveX.count else { continue }
                for j in (i + 1)..<n {
                    guard let c2 = out[j], c2 < liveX.count else { continue }
                    for k in (j + 1)..<n {
                        guard let c3 = out[k], c3 < liveX.count else { continue }
                        let rows = [i, j, k]
                        let cols = [c1, c2, c3]
                        let cur = leftoverAssignHungarianXCycleCost(
                            rows: rows, cols: cols, liveX: liveX, holdX: holdX, pad: pad, scores: scores
                        )
                        let cands = [[c2, c3, c1], [c3, c1, c2]]
                        for cand in cands {
                            guard let sw = leftoverAssignHungarianXCycleCostIfPad(
                                rows: rows, cols: cand, liveX: liveX, holdX: holdX, pad: pad, scores: scores
                            ), sw + 1e-9 < cur else { continue }
                            out[i] = cand[0]
                            out[j] = cand[1]
                            out[k] = cand[2]
                            improved = true
                        }
                    }
                }
            }
        }
        return out
    }

    /// 4-Zyklus. Greedy+2-opt bleibt auf der Diagonale wenn jedes Paar-Swap teurer ist.
    static func leftoverAssignHungarianX4opt(
        assigned: [Int?],
        liveX: [Double],
        holdX: [Double],
        pad: Double,
        scores: [[Double?]]?
    ) -> [Int?] {
        var out = assigned
        var improved = true
        var guardN = 0
        while improved, guardN < 6 {
            improved = false
            guardN += 1
            let n = min(out.count, holdX.count)
            for i in 0..<n {
                guard let c1 = out[i], c1 < liveX.count else { continue }
                for j in (i + 1)..<n {
                    guard let c2 = out[j], c2 < liveX.count else { continue }
                    for k in (j + 1)..<n {
                        guard let c3 = out[k], c3 < liveX.count else { continue }
                        for l in (k + 1)..<n {
                            guard let c4 = out[l], c4 < liveX.count else { continue }
                            let rows = [i, j, k, l]
                            let cols = [c1, c2, c3, c4]
                            let cur = leftoverAssignHungarianXCycleCost(
                                rows: rows, cols: cols, liveX: liveX, holdX: holdX, pad: pad, scores: scores
                            )
                            let cands = [[c2, c3, c4, c1], [c4, c1, c2, c3]]
                            for cand in cands {
                                guard let sw = leftoverAssignHungarianXCycleCostIfPad(
                                    rows: rows, cols: cand, liveX: liveX, holdX: holdX, pad: pad, scores: scores
                                ), sw + 1e-9 < cur else { continue }
                                out[i] = cand[0]
                                out[j] = cand[1]
                                out[k] = cand[2]
                                out[l] = cand[3]
                                improved = true
                            }
                        }
                    }
                }
            }
        }
        return out
    }

    static func leftoverAssignHungarianXCycleCost(
        rows: [Int],
        cols: [Int],
        liveX: [Double],
        holdX: [Double],
        pad: Double,
        scores: [[Double?]]?
    ) -> Double {
        var s = 0.0
        for t in 0..<rows.count {
            let r = rows[t]
            let c = cols[t]
            let d = abs(liveX[c] - holdX[r])
            s += leftoverAssignHungarianXStep(dx: d, pad: pad, row: r, col: c, scores: scores)
        }
        return s
    }

    static func leftoverAssignHungarianXCycleCostIfPad(
        rows: [Int],
        cols: [Int],
        liveX: [Double],
        holdX: [Double],
        pad: Double,
        scores: [[Double?]]?
    ) -> Double? {
        var s = 0.0
        for t in 0..<rows.count {
            let r = rows[t]
            let c = cols[t]
            guard c < liveX.count, r < holdX.count else { return nil }
            let d = abs(liveX[c] - holdX[r])
            if d > pad { return nil }
            s += leftoverAssignHungarianXStep(dx: d, pad: pad, row: r, col: c, scores: scores)
        }
        return s
    }

    /// n>8 / Wide-Pad: Kuhn-Munkres O(n³) statt n!-Recursion. 2/3/4-opt poliert.
    static func leftoverAssignHungarianXKuhn(
        assigned: [Int?],
        liveX: [Double],
        holdX: [Double],
        pad: Double,
        spread: Double = leftoverAmbiguousSpread,
        scores: [[Double?]]? = nil
    ) -> [Int?] {
        var out = assigned
        if out.count < holdX.count {
            out += Array(repeating: Optional<Int>.none, count: holdX.count - out.count)
        }
        let n = holdX.count
        let m = liveX.count
        if n == 0 || m == 0 { return out }
        let used = Set(out.prefix(n).compactMap { $0 })
        let rows = (0..<n).filter { out[$0] == nil }
        let cols = (0..<m).filter { !used.contains($0) }
        if !rows.isEmpty, !cols.isEmpty {
            let R = rows.count
            let C = cols.count
            let N = max(R, C)
            let inf = 1_000_000.0
            var cost = Array(repeating: Array(repeating: 0.0, count: N), count: N)
            for i in 0..<R {
                let r = rows[i]
                for j in 0..<C {
                    let c = cols[j]
                    let d = abs(liveX[c] - holdX[r])
                    if d > pad {
                        cost[i][j] = inf
                    } else {
                        cost[i][j] = leftoverAssignHungarianXStep(
                            dx: d, pad: pad, row: r, col: c, scores: scores
                        )
                    }
                }
            }
            let match = leftoverAssignHungarianMunkres(cost: cost)
            if match.count == N {
                for i in 0..<R {
                    let j = match[i]
                    if j >= 0, j < C, cost[i][j] < inf / 2 {
                        out[rows[i]] = cols[j]
                    }
                }
            }
        }
        out = leftoverAssignHungarianX2opt(assigned: out, liveX: liveX, holdX: holdX, pad: pad, scores: scores)
        out = leftoverAssignHungarianX3opt(assigned: out, liveX: liveX, holdX: holdX, pad: pad, scores: scores)
        out = leftoverAssignHungarianX4opt(assigned: out, liveX: liveX, holdX: holdX, pad: pad, scores: scores)
        if leftoverAssignHungarianXHasPrint(scores) { return out }
        return leftoverAssignSpreadVeto(assigned: out, liveX: liveX, holdX: holdX, pad: pad, spread: spread)
    }

    /// Kuhn-Munkres Min-Cost, quadratische Matrix. Dummy-Spalten = 0 (unassigned).
    static func leftoverAssignHungarianMunkres(cost: [[Double]]) -> [Int] {
        let n = cost.count
        guard n > 0 else { return [] }
        guard cost.allSatisfy({ $0.count == n }) else { return Array(repeating: -1, count: n) }
        var u = Array(repeating: 0.0, count: n + 1)
        var v = Array(repeating: 0.0, count: n + 1)
        var p = Array(repeating: 0, count: n + 1)
        var way = Array(repeating: 0, count: n + 1)
        for i in 1...n {
            p[0] = i
            var j0 = 0
            var minv = Array(repeating: Double.infinity, count: n + 1)
            var used = Array(repeating: false, count: n + 1)
            repeat {
                used[j0] = true
                let i0 = p[j0]
                var delta = Double.infinity
                var j1 = 0
                for j in 1...n where !used[j] {
                    let cur = cost[i0 - 1][j - 1] - u[i0] - v[j]
                    if cur < minv[j] {
                        minv[j] = cur
                        way[j] = j0
                    }
                    if minv[j] < delta {
                        delta = minv[j]
                        j1 = j
                    }
                }
                if j1 == 0 { break }
                for j in 0...n {
                    if used[j] {
                        u[p[j]] += delta
                        v[j] -= delta
                    } else {
                        minv[j] -= delta
                    }
                }
                j0 = j1
            } while p[j0] != 0
            repeat {
                let j1 = way[j0]
                p[j0] = p[j1]
                j0 = j1
            } while j0 != 0
        }
        var ans = Array(repeating: -1, count: n)
        for j in 1...n {
            if p[j] != 0 {
                ans[p[j] - 1] = j - 1
            }
        }
        return ans
    }

    /// Kalman-Box sitzt: VNDetect + Print sparen. Coast 7/8 Ticks, Tick 0 voll.
    static let leftoverDetectSkipIoU: Double = 0.92

    static func leftoverDetectSkip(iou: Double?, floor: Double = leftoverDetectSkipIoU) -> Bool {
        guard let iou else { return false }
        return iou >= floor
    }

    static func leftoverDetectSkipAll(ious: [Double], floor: Double = leftoverDetectSkipIoU, need: Int = 1) -> Bool {
        guard !ious.isEmpty else { return false }
        let hits = ious.filter { $0 >= floor }.count
        return hits >= max(need, 1) && hits == ious.count
    }

    static func leftoverDetectSkipTick(skip: Bool, tick: Int, every: Int = 8) -> Bool {
        guard skip, every > 0 else { return false }
        return tick % every != 0
    }

    /// skipDetect: VNDetect tot, Kalman-Coast. skipPrints allein ließ detectOnce laufen.
    static func leftoverDetectSkipVision(skipDetect: Bool) -> Bool { skipDetect }

    /// Zombie-Keys nach Remint-Apply (Source bleibt) dürfen Skip nicht kippen.
    static func leftoverDetectSkipLiveIous(stored: [UUID: Double], live: [UUID]) -> [Double] {
        live.compactMap { stored[$0] }
    }

    /// Print da: Twin-Spread-Veto tot — sonst 0,90 vs 0,40 fällt auf |Δx|.
    static func leftoverAssignHungarianXHasPrint(_ scores: [[Double?]]?) -> Bool {
        guard let scores else { return false }
        return scores.contains { row in row.contains { ($0 ?? 0) > 0 } }
    }

    /// Unassigned-Hold und Twin-Mitte 0,08. Hungarian n=2 (0,00/0,10 vs 0,09/0,20) bleibt.
    static func leftoverAssignSpreadVeto(
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
        let n = holdX.count
        for r in 0..<n {
            guard let c = out[r], c < liveX.count else { continue }
            let d = abs(liveX[c] - holdX[r])
            var d2Unassigned = Double.infinity
            var d2Twin = Double.infinity
            var twin = false
            for h in 0..<n where h != r {
                let dH = abs(liveX[c] - holdX[h])
                if out[h] == nil { d2Unassigned = min(d2Unassigned, dH) }
                let gap = abs(holdX[r] - holdX[h])
                if gap <= spread + 1e-12 {
                    twin = true
                    d2Twin = min(d2Twin, dH)
                }
            }
            if leftoverXAmbiguous(d: d, d2: d2Unassigned, pad: pad, spread: spread) {
                out[r] = nil
                continue
            }
            if twin, leftoverXAmbiguous(d: d, d2: d2Twin, pad: pad, spread: spread) {
                out[r] = nil
            }
        }
        return out
    }

    /// Print-Assign, x-Fill nur für leere Zeilen, Twin-Spread danach.
    /// Remint (x) zuerst — Print füllt Rest, stiehlt keine Remint-Spalte.
    /// 1 Hold + 1 Live nach Vision-Restart. ≥2 ließ Einzelperson tot.
    static func leftoverAssignLiveGateNeed(_ pref: Int) -> Int {
        min(3, max(1, pref))
    }

    static func leftoverAssignLiveGate(unnamed: Int, unused: Int, need: Int = 1) -> Bool {
        let n = leftoverAssignLiveGateNeed(need)
        return unnamed >= n && unused >= n
    }

    static func leftoverAssignRemint(
        liveX: [Double],
        holdX: [Double],
        pad: Double = leftoverFillXPad
    ) -> [Int?] {
        leftoverAssignHungarianX(
            assigned: Array(repeating: Optional<Int>.none, count: holdX.count),
            liveX: liveX,
            holdX: holdX,
            pad: leftoverFillXPadPref(pad)
        )
    }

    static func leftoverAssignLive(
        scores: [[Double?]],
        liveX: [Double],
        holdX: [Double],
        pad: Double = leftoverFillXRescue,
        padFill: Double = leftoverFillXPad
    ) -> [Int?] {
        var assigned = leftoverAssignHungarianX(
            assigned: Array(repeating: Optional<Int>.none, count: holdX.count),
            liveX: liveX,
            holdX: holdX,
            pad: leftoverFillXPadPref(padFill),
            scores: scores
        )
        var used = Set(assigned.compactMap { $0 })
        let printed = leftoverAssignHungarian(scores: scores)
        if assigned.count < printed.count {
            assigned += Array(repeating: Optional<Int>.none, count: printed.count - assigned.count)
        }
        for r in printed.indices {
            if r < assigned.count, assigned[r] != nil { continue }
            guard let c = printed[r], !used.contains(c) else { continue }
            if r < assigned.count {
                assigned[r] = c
            }
            used.insert(c)
        }
        assigned = leftoverAssignDropAmbiguous(
            scores: scores,
            assigned: leftoverAssignHungarianX(
                assigned: leftoverAssignHungarianX(
                    assigned: assigned,
                    liveX: liveX,
                    holdX: holdX,
                    pad: leftoverFillXPadPref(padFill),
                    scores: scores
                ),
                liveX: liveX,
                holdX: holdX,
                pad: leftoverFillXRescuePref(pad),
                scores: scores
            )
        )
        return leftoverAssignPrintSteal2opt(assigned: assigned, printed: printed, scores: scores)
    }

    /// HungarianX PrintW 0,8. 0,3 verliert gegen Twins mit ähnlichem X.
    static let leftoverAssignHungarianPrintW = 0.8

    static func leftoverAssignHungarianXCost(
        dx: Double,
        pad: Double,
        printCos: Double?,
        printW: Double = leftoverAssignHungarianPrintW
    ) -> Double {
        leftoverAssignCost(iou: leftoverAssignCostIoU(dx: dx, pad: pad), printCos: printCos, printW: printW)
    }

    static func leftoverAssignHungarianXStep(
        dx: Double,
        pad: Double,
        row: Int,
        col: Int,
        scores: [[Double?]]?
    ) -> Double {
        guard let scores else { return dx }
        let printCos: Double? = (row < scores.count && col < scores[row].count) ? scores[row][col] : nil
        return leftoverAssignHungarianXCost(dx: dx, pad: pad, printCos: printCos)
    }

    /// 1−IoU + 0,3·(1−print). X-Remint tauft Geschwister; Print darf stehlen.
    static func leftoverAssignCost(iou: Double, printCos: Double?, printW: Double = 0.3) -> Double {
        let i = max(0, min(1, iou))
        let p = max(0, min(1, printCos ?? 0))
        let w = max(0, min(1, printW))
        return (1 - i) + w * (1 - p)
    }

    /// |Δx|/Pad → IoU. PrintW 0,3 verliert sonst gegen dx>Pad — Steal bleibt nötig.
    static func leftoverAssignCostIoU(dx: Double, pad: Double) -> Double {
        let p = max(1e-6, abs(pad))
        return max(0, min(1, 1 - abs(dx) / p))
    }

    static func leftoverAssignPrintSteals(
        remintCol: Int?,
        printCol: Int?,
        remintPrint: Double?,
        printPrint: Double?,
        gap: Double = 0.15
    ) -> Bool {
        guard let remintCol, let printCol else { return false }
        if remintCol == printCol { return false }
        let p = printPrint ?? -1
        let r = remintPrint ?? -1
        return p >= r + gap && p + 1e-12 >= leftoverPrintCosine
    }

    static func leftoverAssignPrintStealApply(
        assigned: [Int?],
        printed: [Int?],
        scores: [[Double?]],
        gap: Double = 0.15
    ) -> [Int?] {
        var out = assigned
        let n = max(out.count, printed.count)
        if out.count < n {
            out += Array(repeating: Optional<Int>.none, count: n - out.count)
        }
        func score(_ r: Int, _ c: Int?) -> Double? {
            guard let c, r < scores.count, c < scores[r].count else { return nil }
            return scores[r][c]
        }
        for r in 0..<n {
            let remintCol = out[r]
            let printCol = r < printed.count ? printed[r] : nil
            if leftoverAssignPrintSteals(
                remintCol: remintCol,
                printCol: printCol,
                remintPrint: score(r, remintCol),
                printPrint: score(r, printCol),
                gap: gap
            ), let pc = printCol {
                if let other = out.enumerated().first(where: { $0.element == pc && $0.offset != r }) {
                    out[other.offset] = remintCol
                }
                out[r] = pc
            }
        }
        return out
    }

    /// Ein Pass lässt 3-Zyklus hängen wenn Zeile 0 nicht stiehlt. 2-opt bis Ruhe.
    static func leftoverAssignPrintSteal2opt(
        assigned: [Int?],
        printed: [Int?],
        scores: [[Double?]],
        gap: Double = 0.15
    ) -> [Int?] {
        var out = assigned
        var guardN = 0
        var improved = true
        while improved, guardN < 16 {
            improved = false
            guardN += 1
            let nxt = leftoverAssignPrintStealApply(
                assigned: out, printed: printed, scores: scores, gap: gap
            )
            if nxt != out {
                out = nxt
                improved = true
            }
        }
        return out
    }

    /// AssignLive: Hash + Hold + PairLast in einem Schritt, sonst Desync.
    static func leftoverAssignAtomic<Value>(hold: [UUID: Value], from: UUID, to: UUID) -> [UUID: Value] {
        leftoverHoldMove(hold: hold, from: from, to: to)
    }

    /// Vision-Restart: leftoverHold[old] auf Live-UUID nach x.
    /// stored nur Keys, die im Hold sitzen — Stale-Streak sonst näher und tot.
    /// Hash-Rescue wenn x > Pad (Kopfbewegung 8 fps).
    static func leftoverHoldHashRescue(
        liveHash: String,
        stored: [(id: UUID, hash: String)],
        occupied: Set<UUID> = [],
        facesInFrame: Int = 1
    ) -> UUID? {
        let spatial = leftoverHoldHashSpatial(liveHash)
        guard !spatial.isEmpty else { return nil }
        let hits = stored.filter { s in
            guard !occupied.contains(s.id), !s.hash.isEmpty else { return false }
            if facesInFrame >= 2 { return s.hash == liveHash }
            return leftoverHoldHashSpatial(s.hash) == spatial
        }
        if hits.count == 1 { return hits[0].id }
        return nil
    }

    /// Hamming-1 nur Solo. Twin bleibt Exact-only — Nachbar-Bin stiehlt sonst.
    static func leftoverHoldHashHammingRescue(
        liveHash: String,
        stored: [(id: UUID, hash: String)],
        occupied: Set<UUID> = [],
        facesInFrame: Int
    ) -> UUID? {
        guard facesInFrame == 1 else { return nil }
        let spatial = leftoverHoldHashSpatial(liveHash)
        guard !spatial.isEmpty else { return nil }
        let hits = stored.filter {
            !occupied.contains($0.id)
                && leftoverBoxHashDistance(leftoverHoldHashSpatial($0.hash), spatial) == 1
        }
        if hits.count == 1 { return hits[0].id }
        return nil
    }

    /// leftoverLastHash leer nach Restart: Hash-Key aus leftoverHoldByHash, nur Solo.
    /// Twin bleibt Exact-only.
    static func leftoverHoldByHashSolo(
        liveHash: String,
        holdIDs: [UUID],
        tableKeys: [String]
    ) -> UUID? {
        leftoverHoldByHashRescue(
            liveHash: liveHash,
            stored: holdIDs.map { ($0, "") },
            tableKeys: tableKeys
        )
    }

    /// Tick füllt Last-Löcher. Last nicht überschreiben.
    static func leftoverStoredHashMerge(last: [UUID: String], tick: [UUID: String]) -> [UUID: String] {
        var out = last
        for (k, v) in tick where !v.isEmpty {
            if let have = out[k], !have.isEmpty { continue }
            out[k] = v
        }
        return out
    }

    /// leftoverHoldByHash persistiert. Unique Spatial (Bins `#0`/`#1` zählen als eins).
    /// Hash-Match zuerst — 1-open stiehlt sonst den Nachbarn. Twin tot.
    static func leftoverHoldByHashRescue(
        liveHash: String,
        stored: [(id: UUID, hash: String)],
        occupied: Set<UUID> = [],
        tableKeys: [String],
        facesInFrame: Int = 1
    ) -> UUID? {
        if let hit = leftoverHoldHashRescue(
            liveHash: liveHash, stored: stored, occupied: occupied, facesInFrame: facesInFrame
        ) {
            return hit
        }
        let spatial = leftoverHoldHashSpatial(liveHash)
        guard !spatial.isEmpty else { return nil }
        let inTable = tableKeys.contains { leftoverHoldHashSpatial($0) == spatial && !$0.isEmpty }
        guard inTable else { return nil }
        let open = stored.filter { !occupied.contains($0.id) }
        let hashed = open.filter { leftoverHoldHashSpatial($0.hash) == spatial && !$0.hash.isEmpty }
        if hashed.count == 1 { return hashed[0].id }
        if hashed.count > 1 { return nil }
        let known = open.filter { !$0.hash.isEmpty }
        let people = Set(tableKeys.map { leftoverHoldHashSpatial($0) }.filter { !$0.isEmpty })
        if known.isEmpty, open.count == 1, people.count == 1 { return open[0].id }
        return nil
    }

    static func leftoverHoldRemint<Value>(
        hold: [UUID: Value],
        live: [(id: UUID, x: Double)],
        stored: [(id: UUID, x: Double)],
        occupied: Set<UUID> = [],
        liveHash: [UUID: String] = [:],
        storedHash: [UUID: String] = [:],
        hashTableKeys: [String] = [],
        pad: Double = leftoverFillXPad,
        padRescue: Double = leftoverFillXRescue
    ) -> [UUID: Value] {
        var out = hold
        var taken = occupied
        let holds = stored.filter { hold[$0.id] != nil }
        let firstPad = leftoverHoldRemintPad(faces: live.count, pad: pad, padRescue: padRescue)
        for row in live {
            if hold[row.id] != nil {
                taken.insert(row.id)
                continue
            }
            guard let match = leftoverHoldXMatch(
                liveX: row.x, holds: holds, pad: firstPad, occupied: taken
            ) else { continue }
            if match == row.id { continue }
            if let v = hold[match] {
                out[row.id] = v
                taken.insert(match)
            }
        }
        if !liveHash.isEmpty {
            let storedH: [(id: UUID, hash: String)] = holds.compactMap { s in
                guard let h = storedHash[s.id], !h.isEmpty else { return nil }
                return (s.id, h)
            }
            for row in live {
                if hold[row.id] != nil { continue }
                if out[row.id] != nil { continue }
                guard let h = liveHash[row.id], !h.isEmpty else { continue }
                guard let match = leftoverHoldHashRescue(
                    liveHash: h, stored: storedH, occupied: taken, facesInFrame: live.count
                ) else { continue }
                if match == row.id { continue }
                if let v = hold[match] {
                    out[row.id] = v
                    taken.insert(match)
                }
            }
            for row in live {
                if hold[row.id] != nil { continue }
                if out[row.id] != nil { continue }
                guard let h = liveHash[row.id], !h.isEmpty else { continue }
                guard let match = leftoverHoldHashHammingRescue(
                    liveHash: h, stored: storedH, occupied: taken, facesInFrame: live.count
                ) else { continue }
                if match == row.id { continue }
                if let v = hold[match] {
                    out[row.id] = v
                    taken.insert(match)
                }
            }
        }
        for row in live {
            if hold[row.id] != nil { continue }
            if out[row.id] != nil { continue }
            guard let match = leftoverHoldXMatch(
                liveX: row.x, holds: holds, pad: leftoverFillXRescuePref(padRescue), occupied: taken
            ) else { continue }
            if match == row.id { continue }
            if let v = hold[match] {
                out[row.id] = v
                taken.insert(match)
            }
        }
        if !hashTableKeys.isEmpty, !liveHash.isEmpty {
            let storedH: [(id: UUID, hash: String)] = holds.map { s in
                (s.id, storedHash[s.id] ?? "")
            }
            for row in live {
                if hold[row.id] != nil { continue }
                if out[row.id] != nil { continue }
                guard let h = liveHash[row.id], !h.isEmpty else { continue }
                guard let match = leftoverHoldByHashRescue(
                    liveHash: h, stored: storedH, occupied: taken, tableKeys: hashTableKeys, facesInFrame: live.count
                ) else { continue }
                if match == row.id { continue }
                if let v = hold[match] {
                    out[row.id] = v
                    taken.insert(match)
                }
            }
        }
        return out
    }

    /// Survive vor Remint wischt persistierte UUIDs. Live-mediaId ≠ Gallery nach Restart.
    static func leftoverHoldRemintBeforeSurvive() -> Bool { true }

    /// Hold ohne StreakBox: x-Match tot, Hash-Rescue bleibt.
    static func leftoverHoldRemintXUnknown() -> Double { -1 }

    /// Streak x zuerst, Ghosts, dann Hold-Keys. Sonst persist Hold ohne Box tot.
    static func leftoverHoldRemintRows(
        streak: [(id: UUID, x: Double)],
        holdIds: [UUID],
        ghosts: [(id: UUID, x: Double)] = []
    ) -> [(id: UUID, x: Double)] {
        var seen = Set<UUID>()
        var out: [(id: UUID, x: Double)] = []
        for row in streak + ghosts where seen.insert(row.id).inserted {
            out.append(row)
        }
        for id in holdIds where seen.insert(id).inserted {
            out.append((id: id, x: leftoverHoldRemintXUnknown()))
        }
        return out
    }

    static func leftoverHoldBinFromKey(_ key: String) -> Int? {
        guard let dot = key.lastIndex(of: ".") else { return nil }
        return Int(key[key.index(after: dot)...])
    }

    /// Bin-Keys `UUID.bin` analog leftoverHoldRemint.
    static func leftoverHoldRemintBins<Value>(
        hold: [String: Value],
        live: [(id: UUID, x: Double)],
        stored: [(id: UUID, x: Double)],
        occupied: Set<UUID> = [],
        liveHash: [UUID: String] = [:],
        storedHash: [UUID: String] = [:],
        hashTableKeys: [String] = [],
        pad: Double = leftoverFillXPad,
        padRescue: Double = leftoverFillXRescue
    ) -> [String: Value] {
        var out = hold
        var taken = occupied
        let present = Set(hold.keys.compactMap { leftoverHoldId(from: $0) })
        let holds = stored.filter { present.contains($0.id) }
        let firstPad = leftoverHoldRemintPad(faces: live.count, pad: pad, padRescue: padRescue)
        for row in live {
            if present.contains(row.id) {
                taken.insert(row.id)
                continue
            }
            guard let match = leftoverHoldXMatch(
                liveX: row.x, holds: holds, pad: firstPad, occupied: taken
            ) else { continue }
            if match == row.id { continue }
            for (key, v) in hold {
                guard leftoverHoldId(from: key) == match, let bin = leftoverHoldBinFromKey(key) else { continue }
                out[leftoverHoldKey(id: row.id, bin: bin)] = v
            }
            taken.insert(match)
        }
        if !liveHash.isEmpty {
            let storedH: [(id: UUID, hash: String)] = holds.compactMap { s in
                guard let h = storedHash[s.id], !h.isEmpty else { return nil }
                return (s.id, h)
            }
            for row in live {
                if present.contains(row.id) { continue }
                if out.keys.contains(where: { leftoverHoldId(from: $0) == row.id }) { continue }
                guard let h = liveHash[row.id], !h.isEmpty else { continue }
                guard let match = leftoverHoldHashRescue(
                    liveHash: h, stored: storedH, occupied: taken, facesInFrame: live.count
                ) else { continue }
                if match == row.id { continue }
                for (key, v) in hold {
                    guard leftoverHoldId(from: key) == match, let bin = leftoverHoldBinFromKey(key) else { continue }
                    out[leftoverHoldKey(id: row.id, bin: bin)] = v
                }
                taken.insert(match)
            }
        }
        if !liveHash.isEmpty {
            let storedH: [(id: UUID, hash: String)] = holds.compactMap { s in
                guard let h = storedHash[s.id], !h.isEmpty else { return nil }
                return (s.id, h)
            }
            for row in live {
                if present.contains(row.id) { continue }
                if out.keys.contains(where: { leftoverHoldId(from: $0) == row.id }) { continue }
                guard let h = liveHash[row.id], !h.isEmpty else { continue }
                guard let match = leftoverHoldHashHammingRescue(
                    liveHash: h, stored: storedH, occupied: taken, facesInFrame: live.count
                ) else { continue }
                if match == row.id { continue }
                for (key, v) in hold {
                    guard leftoverHoldId(from: key) == match, let bin = leftoverHoldBinFromKey(key) else { continue }
                    out[leftoverHoldKey(id: row.id, bin: bin)] = v
                }
                taken.insert(match)
            }
        }
        for row in live {
            if present.contains(row.id) { continue }
            if out.keys.contains(where: { leftoverHoldId(from: $0) == row.id }) { continue }
            guard let match = leftoverHoldXMatch(
                liveX: row.x, holds: holds, pad: leftoverFillXRescuePref(padRescue), occupied: taken
            ) else { continue }
            if match == row.id { continue }
            for (key, v) in hold {
                guard leftoverHoldId(from: key) == match, let bin = leftoverHoldBinFromKey(key) else { continue }
                out[leftoverHoldKey(id: row.id, bin: bin)] = v
            }
            taken.insert(match)
        }
        if !hashTableKeys.isEmpty, !liveHash.isEmpty {
            let storedH: [(id: UUID, hash: String)] = holds.map { s in
                (s.id, storedHash[s.id] ?? "")
            }
            for row in live {
                if present.contains(row.id) { continue }
                if out.keys.contains(where: { leftoverHoldId(from: $0) == row.id }) { continue }
                guard let h = liveHash[row.id], !h.isEmpty else { continue }
                guard let match = leftoverHoldByHashRescue(
                    liveHash: h, stored: storedH, occupied: taken, tableKeys: hashTableKeys, facesInFrame: live.count
                ) else { continue }
                if match == row.id { continue }
                for (key, v) in hold {
                    guard leftoverHoldId(from: key) == match, let bin = leftoverHoldBinFromKey(key) else { continue }
                    out[leftoverHoldKey(id: row.id, bin: bin)] = v
                }
                taken.insert(match)
            }
        }
        return out
    }

    /// Transfer: leftoverLiveHashTick[new] → old, sonst Rank 1 Frame tot.
    /// Überschreibt — Live-Hash ist frischer als leftoverLastHash[old].
    /// leftoverPendingMirror hält bestehende Namen; Hash darf das nicht.
    static func leftoverLiveHashTickCopy(
        tick: [UUID: String],
        from: UUID,
        to: UUID
    ) -> [UUID: String] {
        guard from != to, let v = tick[from], !v.isEmpty else { return tick }
        var out = tick
        out[to] = v
        out.removeValue(forKey: from)
        return out
    }

    /// PairLast/Streak/Commit/Disagree nach AssignLive. TickCopy ist String-only.
    /// Dest überschreiben — leeres Ziel droppt sonst den Transfer (Hash/Hold desync).
    static func leftoverHoldMove<Value>(hold: [UUID: Value], from: UUID, to: UUID) -> [UUID: Value] {
        guard from != to, let v = hold[from] else { return hold }
        var out = hold
        out[to] = v
        out.removeValue(forKey: from)
        return out
    }

    /// PairLast/Commit: Value ist Live-UUID. Key-Move allein lässt Commit auf newId.
    static func leftoverHoldMoveId(hold: [UUID: UUID], from: UUID, to: UUID) -> [UUID: UUID] {
        var out = leftoverHoldMove(hold: hold, from: from, to: to)
        for (k, v) in out where v == from {
            out[k] = to
        }
        return out
    }

    /// AssignLive: UUID.bin-Keys analog leftoverHoldMove, sonst Bins tot auf alter UUID.
    static func leftoverHoldMoveBins<Value>(hold: [String: Value], from: UUID, to: UUID) -> [String: Value] {
        leftoverAssignAtomicBins(hold: hold, from: from, to: to)
    }

    static func leftoverAssignAtomicBins<Value>(hold: [String: Value], from: UUID, to: UUID) -> [String: Value] {
        guard from != to else { return hold }
        var out = hold
        for (key, v) in hold {
            guard leftoverHoldId(from: key) == from, let bin = leftoverHoldBinFromKey(key) else { continue }
            out[leftoverHoldKey(id: to, bin: bin)] = v
            out.removeValue(forKey: key)
        }
        return out
    }

    /// AssignLive-Transfer: leftoverClearStreak darf PairCommit nicht droppen.
    static func leftoverClearDropsPair(transferred: Bool) -> Bool {
        !leftoverStreakKeepsLive(transferred: transferred)
    }

    /// PairLast/Commit nach x-Remint: Value auf Live-UUID, nicht nur Key.
    /// Dest nicht auf self überschreiben — Twin-proposed sonst tot, Majority neu.
    static func leftoverHoldRemintMap(
        live: [(id: UUID, x: Double)],
        stored: [(id: UUID, x: Double)],
        holdKeys: Set<UUID>,
        occupied: Set<UUID> = [],
        liveHash: [UUID: String] = [:],
        storedHash: [UUID: String] = [:],
        hashTableKeys: [String] = [],
        pad: Double = leftoverFillXPad,
        padRescue: Double = leftoverFillXRescue
    ) -> [UUID: UUID] {
        let seed = Dictionary(uniqueKeysWithValues: holdKeys.map { ($0, $0) })
        let moved = leftoverHoldRemint(
            hold: seed,
            live: live,
            stored: stored,
            occupied: occupied,
            liveHash: liveHash,
            storedHash: storedHash,
            hashTableKeys: hashTableKeys,
            pad: pad,
            padRescue: padRescue
        )
        var remap: [UUID: UUID] = [:]
        for (liveId, storedId) in moved where liveId != storedId {
            remap[storedId] = liveId
        }
        return remap
    }

    /// Ein Plan für alle Hold-Maps. 20× leftoverHoldRemint sonst Hold A→C und Streak B→C.
    static func leftoverHoldRemintApply<Value>(hold: [UUID: Value], remap: [UUID: UUID]) -> [UUID: Value] {
        guard !remap.isEmpty else { return hold }
        var out = hold
        for (stored, live) in remap where stored != live {
            if let v = hold[stored] {
                out[live] = v
            }
        }
        return out
    }

    /// Apply hält Source (Rollback). Drop räumt Zombies — leftoverLastIoU sonst skippt nie.
    static func leftoverHoldRemintDrop<Value>(hold: [UUID: Value], remap: [UUID: UUID]) -> [UUID: Value] {
        var out = leftoverHoldRemintApply(hold: hold, remap: remap)
        for (stored, live) in remap where stored != live {
            out.removeValue(forKey: stored)
        }
        return out
    }

    /// Nach Drop liegt der Wert auf live. leftover matching liest noch die Source-UUID.
    static func leftoverHoldRemintLookup<Value>(
        hold: [UUID: Value],
        id: UUID,
        remap: [UUID: UUID] = [:]
    ) -> Value? {
        if let v = hold[id] { return v }
        if let live = remap[id], live != id { return hold[live] }
        return nil
    }

    /// leftoverHold sitzt nur über Remint-Lookup, nicht auf leftoverId.
    static func leftoverHoldViaLookup<Value>(
        hold: [UUID: Value],
        id: UUID,
        remap: [UUID: UUID]
    ) -> Bool {
        hold[id] == nil && leftoverHoldRemintLookup(hold: hold, id: id, remap: remap) != nil
    }

    /// leftoverCoastPrintSkipCosine nil + Hold nur Lookup = Unsure. Twin nicht auf 0,70 taufen.
    static func leftoverHoldLookupUnsure(skipCosine: Double?, holdViaLookup: Bool) -> Bool {
        skipCosine == nil && holdViaLookup
    }

    static func leftoverHoldLookupUnsureNote() -> String { "?" }

    /// leftoverTried nicht auf Unsure/Lookaway. Nächster Tick mit Print darf pinnen.
    static func leftoverTriedInserts(unsure: Bool, lookaway: Bool = false) -> Bool { !unsure && !lookaway }

    /// Unsure ist kein Pin. leftoverPinStatus sonst Lüge.
    static func leftoverPinCounts(unsure: Bool, lookaway: Bool = false) -> Bool { !unsure || lookaway }

    static let leftoverUnsureStreakNeed = 3

    static func leftoverUnsureStreakAdvance(prev: Int, unsure: Bool) -> Int {
        unsure ? prev + 1 : 0
    }

    static func leftoverUnsureStreakClears(ticks: Int, need: Int = leftoverUnsureStreakNeed) -> Bool {
        ticks >= need
    }

    /// RAM-Cache ohne Print 2 s → nil. Twin nach Stillstand sonst leftoverCoastPrint 1,0.
    static let leftoverCoastPrintTtl: TimeInterval = 2

    static func leftoverCoastPrintFresh(
        vec: [Double],
        stamped: TimeInterval?,
        now: TimeInterval,
        ttl: TimeInterval = leftoverCoastPrintTtl
    ) -> [Double] {
        guard vec.count >= 32, let stamped, now - stamped <= ttl else { return [] }
        return vec
    }

    static func leftoverCoastPrintStampMerge(
        stamped: [UUID: TimeInterval],
        live: [UUID: [Double]],
        skipPrints: Bool,
        now: TimeInterval,
        stored: [UUID: [Double]] = [:]
    ) -> [UUID: TimeInterval] {
        guard !skipPrints else { return stamped }
        var out = stamped
        for (id, vec) in live where vec.count >= 32 {
            if let old = stored[id], leftoverCoastPrintSame(old, vec) { continue }
            out[id] = now
        }
        return out
    }

    static func leftoverCoastPrintVecEncode(_ table: [UUID: [Double]]) -> [String: [Double]] {
        Dictionary(uniqueKeysWithValues: table.compactMap { id, v in
            v.count >= 32 ? (id.uuidString, v) : nil
        })
    }

    static func leftoverCoastPrintVecDecode(_ raw: [String: [Double]]?) -> [UUID: [Double]] {
        guard let raw else { return [:] }
        var out: [UUID: [Double]] = [:]
        for (k, v) in raw {
            guard let id = UUID(uuidString: k), v.count >= 32 else { continue }
            out[id] = v
        }
        return out
    }

    /// Remaining Age, nicht Unix. Restart < TTL hält den Vec.
    static func leftoverCoastPrintAgeEncode(
        vecs: [UUID: [Double]],
        stamped: [UUID: TimeInterval],
        now: TimeInterval,
        ttl: TimeInterval = leftoverCoastPrintTtl
    ) -> [String: Double] {
        var out: [String: Double] = [:]
        for (id, vec) in vecs where vec.count >= 32 {
            let age: TimeInterval
            if let t = stamped[id] {
                age = max(0, ttl - max(0, now - t))
            } else {
                age = 0
            }
            if age > 0 { out[id.uuidString] = age }
        }
        return out
    }

    static func leftoverCoastPrintAgeDecode(
        vecs: [String: [Double]]?,
        remaining: [String: Double]?,
        now: TimeInterval,
        ttl: TimeInterval = leftoverCoastPrintTtl
    ) -> (print: [UUID: [Double]], at: [UUID: TimeInterval]) {
        let decoded = leftoverCoastPrintVecDecode(vecs)
        var printOut: [UUID: [Double]] = [:]
        var at: [UUID: TimeInterval] = [:]
        for (id, vec) in decoded {
            let left = remaining?[id.uuidString] ?? 0
            guard left > 0 else { continue }
            printOut[id] = vec
            at[id] = now - (ttl - min(ttl, left))
        }
        return (printOut, at)
    }

    /// Remint kopiert 3 Ada-Votes. Twin sonst sofort getauft. keep 1 → Need 3 braucht 2 echte Ticks.
    static func leftoverNameHistRemintTrim(
        hist: [UUID: [String]],
        remap: [UUID: UUID],
        keep: Int = 1
    ) -> [UUID: [String]] {
        guard !remap.isEmpty else { return hist }
        let moved = Set(remap.filter { $0.key != $0.value }.map(\.value))
        var out = hist
        for id in moved {
            if let h = out[id] { out[id] = Array(h.suffix(max(0, keep))) }
        }
        return out
    }

    /// Detect-Skip ohne beide Coast-Vec: nur IoU. Hold-Zahl nicht als Cosine.
    static func leftoverDetectSkipIoUOnly(
        skipCosine: Double?,
        skipDetect: Bool,
        skipPrints: Bool,
        holdViaLookup: Bool
    ) -> Bool {
        leftoverCoastPrintKeeps(skipDetect: skipDetect, skipPrints: skipPrints)
            && skipCosine == nil
            && !holdViaLookup
    }

    /// Gemessener Print oder nil. Hold-Lookup 0,70 und Detect-Skip-IoU nie als Cosine.
    static func leftoverCoastCosineMeasured(
        skipCosine: Double?,
        skipDetect: Bool,
        skipPrints: Bool,
        live: Double?,
        stored: Double?,
        livePrintEmpty: Bool,
        holdViaLookup: Bool
    ) -> Double? {
        if leftoverHoldLookupUnsure(skipCosine: skipCosine, holdViaLookup: holdViaLookup) {
            return nil
        }
        if let skipCosine { return skipCosine }
        if leftoverDetectSkipIoUOnly(
            skipCosine: skipCosine,
            skipDetect: skipDetect,
            skipPrints: skipPrints,
            holdViaLookup: holdViaLookup
        ) {
            return nil
        }
        return leftoverCoastCosine(
            skipDetect: skipDetect,
            skipPrints: skipPrints,
            live: live,
            stored: stored,
            livePrintEmpty: livePrintEmpty
        )
    }

    /// Identität als ein Objekt. LibraryStore remintet Hold/Pending/Streak/Hash/IoU/Name/Miss/Pair
    /// plus Live-Skalare (Yaw/Still/Blink/EMA) über Pack. Arrays (Print-Trail, Name-Hist) extra.
    struct FaceTrackBox: Equatable {
        var x: Double = 0
        var y: Double = 0
        var w: Double = 0
        var h: Double = 0
    }

    struct FaceTrack: Equatable {
        var hold: Double = 0
        var pending: String = ""
        var streak: Int = 0
        var lastHash: String = ""
        var lastIoU: Double = 0
        var nameHeld: String = ""
        var nameUntil: TimeInterval = 0
        var miss: Int = 0
        var streakBox: FaceTrackBox? = nil
        var kalman: FaceTrackBox? = nil
        var pairLast: UUID? = nil
        var pairStreak: Int = 0
        var yaw: Double = 0
        var pitch: Double = 0
        var roll: Double = 0
        var stillFor: TimeInterval = 0
        var scoreEma: Double = 0
        var poseAt: TimeInterval = 0
        var blinkSeen: Bool = false
        var lidClosed: Bool = false
        var openStreak: Int = 0
        var voteAt: TimeInterval = 0
        var px: Double = 0
        var py: Double = 0
        var pw: Double = 0
        var ph: Double = 0
        var coastAt: TimeInterval = 0
        var unsureTicks: Int = 0
    }

    /// Kalman-Vel nach Remint sonst 0. dt 0 / Sleep > 2 s tot.
    static func leftoverFaceTrackKalmanVel(
        prev: FaceTrackBox?,
        live: FaceTrackBox,
        dt: Double
    ) -> (px: Double, py: Double, pw: Double, ph: Double) {
        guard let prev, dt > 1e-4, dt < 2 else { return (0, 0, 0, 0) }
        return (
            (live.x - prev.x) / dt,
            (live.y - prev.y) / dt,
            (live.w - prev.w) / dt,
            (live.h - prev.h) / dt
        )
    }

    static func leftoverFaceTrackKalmanPredict(
        box: FaceTrackBox,
        px: Double,
        py: Double,
        dt: Double,
        cap: Double = 0.12
    ) -> FaceTrackBox {
        FaceTrackBox(
            x: boxKalmanPredict(x: box.x, v: px, dt: dt, cap: cap),
            y: boxKalmanPredict(x: box.y, v: py, dt: dt, cap: cap),
            w: box.w,
            h: box.h
        )
    }

    /// leftoverPredictHeld: Decay dann Predict. FaceTrack.px/py nach Remint sonst 0.
    static func leftoverFaceTrackPredictHeld(
        box: FaceTrackBox,
        px: Double,
        py: Double,
        dt: Double,
        miss: Int
    ) -> (box: FaceTrackBox, px: Double, py: Double) {
        let v = leftoverHoldKalmanVelDecay(vx: px, vy: py, miss: miss)
        return (leftoverFaceTrackKalmanPredict(box: box, px: v.vx, py: v.vy, dt: dt), v.vx, v.vy)
    }

    static func leftoverFaceTrackVelFromKalman(
        _ vel: [UUID: (vx: Double, vy: Double)]
    ) -> (px: [UUID: Double], py: [UUID: Double]) {
        var px: [UUID: Double] = [:]
        var py: [UUID: Double] = [:]
        for (id, v) in vel {
            if v.vx != 0 { px[id] = v.vx }
            if v.vy != 0 { py[id] = v.vy }
        }
        return (px, py)
    }

    static func leftoverFaceTrackKalmanBox(
        _ table: [UUID: (x: Double, y: Double, w: Double, h: Double, px: Double, py: Double, pw: Double, ph: Double)]
    ) -> [UUID: FaceTrackBox] {
        Dictionary(uniqueKeysWithValues: table.map { id, k in
            (id, FaceTrackBox(x: k.x, y: k.y, w: k.w, h: k.h))
        })
    }

    static func leftoverFaceTrackVelMerge(
        vel: [UUID: (vx: Double, vy: Double)],
        px: [UUID: Double],
        py: [UUID: Double]
    ) -> [UUID: (vx: Double, vy: Double)] {
        var out = vel
        for id in Set(px.keys).union(py.keys) {
            let vx = px[id] ?? out[id]?.vx ?? 0
            let vy = py[id] ?? out[id]?.vy ?? 0
            out[id] = (vx, vy)
        }
        return out
    }

    static func leftoverFaceTrackRemintPair(
        _ tracks: [UUID: FaceTrack],
        remap: [UUID: UUID]
    ) -> [UUID: FaceTrack] {
        guard !remap.isEmpty else { return tracks }
        var out = tracks
        for (id, t) in tracks {
            if let p = t.pairLast, let mapped = remap[p], mapped != p {
                var next = t
                next.pairLast = mapped
                out[id] = next
            }
        }
        return out
    }

    static func leftoverFaceTrackRemint(
        _ tracks: [UUID: FaceTrack],
        remap: [UUID: UUID]
    ) -> [UUID: FaceTrack] {
        leftoverFaceTrackRemintPair(leftoverHoldRemintApply(hold: tracks, remap: remap), remap: remap)
    }

    static func leftoverFaceTrackRemintDrop(
        _ tracks: [UUID: FaceTrack],
        remap: [UUID: UUID]
    ) -> [UUID: FaceTrack] {
        leftoverFaceTrackRemintPair(leftoverHoldRemintDrop(hold: tracks, remap: remap), remap: remap)
    }

    static func leftoverFaceTrackPack(
        hold: [UUID: Double],
        pending: [UUID: String],
        streak: [UUID: Int],
        lastHash: [UUID: String],
        lastIoU: [UUID: Double],
        nameHeld: [UUID: String],
        nameUntil: [UUID: TimeInterval],
        miss: [UUID: Int],
        streakBox: [UUID: FaceTrackBox] = [:],
        kalman: [UUID: FaceTrackBox] = [:],
        pairLast: [UUID: UUID] = [:],
        pairStreak: [UUID: Int] = [:],
        yaw: [UUID: Double] = [:],
        pitch: [UUID: Double] = [:],
        roll: [UUID: Double] = [:],
        stillFor: [UUID: TimeInterval] = [:],
        scoreEma: [UUID: Double] = [:],
        poseAt: [UUID: TimeInterval] = [:],
        blinkSeen: [UUID: Bool] = [:],
        lidClosed: [UUID: Bool] = [:],
        openStreak: [UUID: Int] = [:],
        voteAt: [UUID: TimeInterval] = [:],
        px: [UUID: Double] = [:],
        py: [UUID: Double] = [:],
        pw: [UUID: Double] = [:],
        ph: [UUID: Double] = [:],
        coastAt: [UUID: TimeInterval] = [:],
        unsureTicks: [UUID: Int] = [:]
    ) -> [UUID: FaceTrack] {
        let keys = leftoverHoldRemintKeys([
            Set(hold.keys), Set(pending.keys), Set(streak.keys), Set(lastHash.keys),
            Set(lastIoU.keys), Set(nameHeld.keys), Set(nameUntil.keys), Set(miss.keys),
            Set(streakBox.keys), Set(kalman.keys), Set(pairLast.keys), Set(pairStreak.keys),
            Set(yaw.keys), Set(pitch.keys), Set(roll.keys), Set(stillFor.keys),
            Set(scoreEma.keys), Set(poseAt.keys), Set(blinkSeen.keys), Set(lidClosed.keys),
            Set(openStreak.keys), Set(voteAt.keys), Set(px.keys), Set(py.keys), Set(pw.keys), Set(ph.keys),
            Set(coastAt.keys), Set(unsureTicks.keys)
        ])
        var out: [UUID: FaceTrack] = [:]
        out.reserveCapacity(keys.count)
        for id in keys {
            out[id] = FaceTrack(
                hold: hold[id] ?? 0,
                pending: pending[id] ?? "",
                streak: streak[id] ?? 0,
                lastHash: lastHash[id] ?? "",
                lastIoU: lastIoU[id] ?? 0,
                nameHeld: nameHeld[id] ?? "",
                nameUntil: nameUntil[id] ?? 0,
                miss: miss[id] ?? 0,
                streakBox: streakBox[id],
                kalman: kalman[id],
                pairLast: pairLast[id],
                pairStreak: pairStreak[id] ?? 0,
                yaw: yaw[id] ?? 0,
                pitch: pitch[id] ?? 0,
                roll: roll[id] ?? 0,
                stillFor: stillFor[id] ?? 0,
                scoreEma: scoreEma[id] ?? 0,
                poseAt: poseAt[id] ?? 0,
                blinkSeen: blinkSeen[id] ?? false,
                lidClosed: lidClosed[id] ?? false,
                openStreak: openStreak[id] ?? 0,
                voteAt: voteAt[id] ?? 0,
                px: px[id] ?? 0,
                py: py[id] ?? 0,
                pw: pw[id] ?? 0,
                ph: ph[id] ?? 0,
                coastAt: coastAt[id] ?? 0,
                unsureTicks: unsureTicks[id] ?? 0
            )
        }
        return out
    }

    struct FaceTrackMaps: Equatable {
        var hold: [UUID: Double] = [:]
        var pending: [UUID: String] = [:]
        var streak: [UUID: Int] = [:]
        var lastHash: [UUID: String] = [:]
        var lastIoU: [UUID: Double] = [:]
        var nameHeld: [UUID: String] = [:]
        var nameUntil: [UUID: TimeInterval] = [:]
        var miss: [UUID: Int] = [:]
        var streakBox: [UUID: FaceTrackBox] = [:]
        var kalman: [UUID: FaceTrackBox] = [:]
        var pairLast: [UUID: UUID] = [:]
        var pairStreak: [UUID: Int] = [:]
        var yaw: [UUID: Double] = [:]
        var pitch: [UUID: Double] = [:]
        var roll: [UUID: Double] = [:]
        var stillFor: [UUID: TimeInterval] = [:]
        var scoreEma: [UUID: Double] = [:]
        var poseAt: [UUID: TimeInterval] = [:]
        var blinkSeen: [UUID: Bool] = [:]
        var lidClosed: [UUID: Bool] = [:]
        var openStreak: [UUID: Int] = [:]
        var voteAt: [UUID: TimeInterval] = [:]
        var px: [UUID: Double] = [:]
        var py: [UUID: Double] = [:]
        var pw: [UUID: Double] = [:]
        var ph: [UUID: Double] = [:]
        var coastAt: [UUID: TimeInterval] = [:]
        var unsureTicks: [UUID: Int] = [:]
    }

    /// Pack-Inverse. Nur gesetzte Felder — Defaults nicht in die Maps schreiben.
    static func leftoverFaceTrackUnpack(_ tracks: [UUID: FaceTrack]) -> FaceTrackMaps {
        var m = FaceTrackMaps()
        m.hold.reserveCapacity(tracks.count)
        m.pending.reserveCapacity(tracks.count)
        m.streak.reserveCapacity(tracks.count)
        m.lastHash.reserveCapacity(tracks.count)
        m.lastIoU.reserveCapacity(tracks.count)
        m.nameHeld.reserveCapacity(tracks.count)
        m.nameUntil.reserveCapacity(tracks.count)
        m.miss.reserveCapacity(tracks.count)
        for (id, t) in tracks {
            if t.hold != 0 { m.hold[id] = t.hold }
            if !t.pending.isEmpty { m.pending[id] = t.pending }
            if t.streak != 0 { m.streak[id] = t.streak }
            if !t.lastHash.isEmpty { m.lastHash[id] = t.lastHash }
            if t.lastIoU != 0 { m.lastIoU[id] = t.lastIoU }
            if !t.nameHeld.isEmpty { m.nameHeld[id] = t.nameHeld }
            if t.nameUntil != 0 { m.nameUntil[id] = t.nameUntil }
            if t.miss != 0 { m.miss[id] = t.miss }
            if let box = t.streakBox { m.streakBox[id] = box }
            if let kal = t.kalman { m.kalman[id] = kal }
            if let pair = t.pairLast { m.pairLast[id] = pair }
            if t.pairStreak != 0 { m.pairStreak[id] = t.pairStreak }
            if t.yaw != 0 { m.yaw[id] = t.yaw }
            if t.pitch != 0 { m.pitch[id] = t.pitch }
            if t.roll != 0 { m.roll[id] = t.roll }
            if t.stillFor != 0 { m.stillFor[id] = t.stillFor }
            if t.scoreEma != 0 { m.scoreEma[id] = t.scoreEma }
            if t.poseAt != 0 { m.poseAt[id] = t.poseAt }
            if t.blinkSeen { m.blinkSeen[id] = true }
            if t.lidClosed { m.lidClosed[id] = true }
            if t.openStreak != 0 { m.openStreak[id] = t.openStreak }
            if t.voteAt != 0 { m.voteAt[id] = t.voteAt }
            if t.px != 0 { m.px[id] = t.px }
            if t.py != 0 { m.py[id] = t.py }
            if t.pw != 0 { m.pw[id] = t.pw }
            if t.ph != 0 { m.ph[id] = t.ph }
            if t.coastAt != 0 { m.coastAt[id] = t.coastAt }
            if t.unsureTicks != 0 { m.unsureTicks[id] = t.unsureTicks }
        }
        return m
    }

    static func leftoverFaceTrackBox(_ box: FaceBox) -> FaceTrackBox {
        FaceTrackBox(x: box.x, y: box.y, w: box.width, h: box.height)
    }

    static func leftoverFaceBox(_ box: FaceTrackBox) -> FaceBox {
        FaceBox(x: box.x, y: box.y, width: box.w, height: box.h)
    }

    /// Ein Remint für die Identitäts-Maps. Kalman-Vel (px/py) im Struct.
    /// Live-Skalare (Yaw/Still/Blink/EMA) mit Pack. Arrays (Trail/Hist) extra Drop.
    static func leftoverFaceTrackRemintDropMaps(
        hold: [UUID: Double],
        pending: [UUID: String],
        streak: [UUID: Int],
        lastHash: [UUID: String],
        lastIoU: [UUID: Double],
        nameHeld: [UUID: String],
        nameUntil: [UUID: TimeInterval],
        miss: [UUID: Int],
        streakBox: [UUID: FaceTrackBox] = [:],
        kalman: [UUID: FaceTrackBox] = [:],
        pairLast: [UUID: UUID] = [:],
        pairStreak: [UUID: Int] = [:],
        yaw: [UUID: Double] = [:],
        pitch: [UUID: Double] = [:],
        roll: [UUID: Double] = [:],
        stillFor: [UUID: TimeInterval] = [:],
        scoreEma: [UUID: Double] = [:],
        poseAt: [UUID: TimeInterval] = [:],
        blinkSeen: [UUID: Bool] = [:],
        lidClosed: [UUID: Bool] = [:],
        openStreak: [UUID: Int] = [:],
        voteAt: [UUID: TimeInterval] = [:],
        px: [UUID: Double] = [:],
        py: [UUID: Double] = [:],
        pw: [UUID: Double] = [:],
        ph: [UUID: Double] = [:],
        coastAt: [UUID: TimeInterval] = [:],
        unsureTicks: [UUID: Int] = [:],
        remap: [UUID: UUID]
    ) -> FaceTrackMaps {
        leftoverFaceTrackUnpack(
            leftoverFaceTrackRemintDrop(
                leftoverFaceTrackPack(
                    hold: hold,
                    pending: pending,
                    streak: streak,
                    lastHash: lastHash,
                    lastIoU: lastIoU,
                    nameHeld: nameHeld,
                    nameUntil: nameUntil,
                    miss: miss,
                    streakBox: streakBox,
                    kalman: kalman,
                    pairLast: pairLast,
                    pairStreak: pairStreak,
                    yaw: yaw,
                    pitch: pitch,
                    roll: roll,
                    stillFor: stillFor,
                    scoreEma: scoreEma,
                    poseAt: poseAt,
                    blinkSeen: blinkSeen,
                    lidClosed: lidClosed,
                    openStreak: openStreak,
                    voteAt: voteAt,
                    px: px,
                    py: py,
                    pw: pw,
                    ph: ph,
                    coastAt: coastAt,
                    unsureTicks: unsureTicks
                ),
                remap: remap
            )
        )
    }

    static func leftoverHoldRemintApplyId(hold: [UUID: UUID], remap: [UUID: UUID]) -> [UUID: UUID] {
        var out = leftoverHoldRemintApply(hold: hold, remap: remap)
        for (k, v) in out {
            if let nv = remap[v], nv != v {
                out[k] = nv
            }
        }
        return out
    }

    /// PairLast/Commit: Source-Key nach Value-Remap droppen, sonst Zombie-Commit.
    static func leftoverHoldRemintDropId(hold: [UUID: UUID], remap: [UUID: UUID]) -> [UUID: UUID] {
        var out = leftoverHoldRemintApplyId(hold: hold, remap: remap)
        for (stored, live) in remap where stored != live {
            out.removeValue(forKey: stored)
        }
        return out
    }

    static func leftoverHoldRemintKeys(_ maps: [Set<UUID>]) -> Set<UUID> {
        var s = Set<UUID>()
        for m in maps { s.formUnion(m) }
        return s
    }

    /// Bin-Keys `UUID.bin` denselben Plan. 2× leftoverHoldRemintBins sonst Hold A→C, Bin B→C.
    static func leftoverHoldRemintApplyBins<Value>(hold: [String: Value], remap: [UUID: UUID]) -> [String: Value] {
        guard !remap.isEmpty else { return hold }
        var out = hold
        for (stored, live) in remap where stored != live {
            for (key, v) in hold {
                guard leftoverHoldId(from: key) == stored, let bin = leftoverHoldBinFromKey(key) else { continue }
                out[leftoverHoldKey(id: live, bin: bin)] = v
            }
        }
        return out
    }

    static func leftoverHoldRemintDropBins<Value>(hold: [String: Value], remap: [UUID: UUID]) -> [String: Value] {
        var out = leftoverHoldRemintApplyBins(hold: hold, remap: remap)
        for (stored, live) in remap where stored != live {
            for key in hold.keys {
                if leftoverHoldId(from: key) == stored {
                    out.removeValue(forKey: key)
                }
            }
        }
        return out
    }

    static func leftoverUUIDUUIDMapRemintDest(_ table: [UUID: UUID], remap: [UUID: UUID]) -> [UUID: UUID] {
        var out: [UUID: UUID] = [:]
        for (k, v) in table {
            let nk = remap[k] ?? k
            let nv = remap[v] ?? v
            out[nk] = nv
        }
        return out
    }

    static func leftoverHoldRemintId(
        hold: [UUID: UUID],
        live: [(id: UUID, x: Double)],
        stored: [(id: UUID, x: Double)],
        occupied: Set<UUID> = [],
        liveHash: [UUID: String] = [:],
        storedHash: [UUID: String] = [:],
        hashTableKeys: [String] = [],
        pad: Double = leftoverFillXPad,
        padRescue: Double = leftoverFillXRescue
    ) -> [UUID: UUID] {
        let remap = leftoverHoldRemintMap(
            live: live,
            stored: stored,
            holdKeys: Set(hold.keys),
            occupied: occupied,
            liveHash: liveHash,
            storedHash: storedHash,
            hashTableKeys: hashTableKeys,
            pad: pad,
            padRescue: padRescue
        )
        var out = leftoverHoldRemint(
            hold: hold,
            live: live,
            stored: stored,
            occupied: occupied,
            liveHash: liveHash,
            storedHash: storedHash,
            hashTableKeys: hashTableKeys,
            pad: pad,
            padRescue: padRescue
        )
        for (k, v) in out {
            if let nv = remap[v] {
                out[k] = nv
            }
        }
        return out
    }

    static func overlayChipKeep(_ chip: String) -> Int {
        let u = chip.uppercased()
        if u.hasPrefix("JUMP") || u.hasPrefix("LOCK") || u.hasPrefix("TWIN") || u.hasPrefix("NBR") || u.hasPrefix("HOLD") { return 0 }
        if u.hasPrefix("HASH") || u.hasPrefix("JPEG") { return 1 }
        if u.hasPrefix("STILL") || u.hasPrefix("PRINT") { return 1 }
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

    /// Live-Box auf Hold-Keys nach Remint. leftoverAdvance schreibt nur bei AssignLive.
    /// Ohne das bleibt leftoverStreakBox[old] — nächster Restart matched tote x.
    static func leftoverStreakBoxLive(
        boxes: [UUID: FaceBox],
        live: [(id: UUID, box: FaceBox)],
        holdIds: Set<UUID>
    ) -> [UUID: FaceBox] {
        var out = boxes
        for row in live where holdIds.contains(row.id) {
            out[row.id] = row.box
        }
        return out
    }

    static func leftoverStreakBoxEncode(_ boxes: [UUID: FaceBox]) -> [String: [Double]] {
        Dictionary(uniqueKeysWithValues: boxes.map {
            ($0.key.uuidString, [$0.value.x, $0.value.y, $0.value.width, $0.value.height])
        })
    }

    static func leftoverStreakBoxDecode(_ raw: [String: [Double]]?) -> [UUID: FaceBox] {
        guard let raw else { return [:] }
        var out: [UUID: FaceBox] = [:]
        for (k, v) in raw {
            guard let id = UUID(uuidString: k), v.count >= 4 else { continue }
            out[id] = FaceBox(x: v[0], y: v[1], width: v[2], height: v[3])
        }
        return out
    }

    /// Kalman RAM-only tot nach Restart. Schema 12 x/y/w/h/p + vel.
    static func leftoverHoldKalmanEncode(
        _ table: [UUID: (x: Double, y: Double, w: Double, h: Double, px: Double, py: Double, pw: Double, ph: Double)],
        vel: [UUID: (vx: Double, vy: Double)] = [:]
    ) -> [String: [Double]] {
        Dictionary(uniqueKeysWithValues: table.map { id, k in
            let v = vel[id] ?? (vx: 0, vy: 0)
            return (id.uuidString, [k.x, k.y, k.w, k.h, k.px, k.py, k.pw, k.ph, v.vx, v.vy])
        })
    }

    static func leftoverHoldKalmanDecode(
        _ raw: [String: [Double]]?
    ) -> (
        kalman: [UUID: (x: Double, y: Double, w: Double, h: Double, px: Double, py: Double, pw: Double, ph: Double)],
        vel: [UUID: (vx: Double, vy: Double)]
    ) {
        guard let raw else { return ([:], [:]) }
        var kalman: [UUID: (x: Double, y: Double, w: Double, h: Double, px: Double, py: Double, pw: Double, ph: Double)] = [:]
        var vel: [UUID: (vx: Double, vy: Double)] = [:]
        for (k, v) in raw {
            guard let id = UUID(uuidString: k), v.count >= 8 else { continue }
            kalman[id] = (x: v[0], y: v[1], w: v[2], h: v[3], px: v[4], py: v[5], pw: v[6], ph: v[7])
            if v.count >= 10 {
                vel[id] = (vx: v[8], vy: v[9])
            }
        }
        return (kalman, vel)
    }

    /// Remint kopiert Kalman auf neue UUID. IoU-Sprung = Reset, sonst Box klebt am Ghost.
    static func leftoverHoldKalmanJumpPref(_ pref: Double) -> Double {
        min(0.50, max(0.30, pref))
    }

    /// Continuity 8 fps Box 0,32–0,38. Webcam 24 fps darf 0,50.
    static func leftoverHoldKalmanJumpCam(dt: TimeInterval, pref: Double) -> Double {
        leftoverHoldKalmanJumpPref(dt >= 0.08 ? min(pref, 0.34) : pref)
    }

    static func leftoverHoldKalmanResets(iou: Double?, jump: Double = leftoverIoUJump) -> Bool {
        guard let iou else { return false }
        return iou + 1e-12 < leftoverHoldKalmanJumpPref(jump)
    }

    /// Restore: Meas weit, IoU-Reset Tick 1 statt Kriechen. 2 Ticks Skip.
    static func leftoverHoldKalmanSkipReset(ago: Int, ticks: Int = 2) -> Bool {
        ago >= 0 && ago < ticks
    }

    /// Live leer: Meas tot. Ghost-only Hold: Kalman Predict, kein IoU-Reset.
    static func leftoverHoldKalmanPredictOnly(
        ago: Int,
        liveEmpty: Bool,
        ghostHeld: Bool = false,
        missCoast: Bool = false,
        ticks: Int = 2
    ) -> Bool {
        leftoverHoldKalmanSkipReset(ago: ago, ticks: ticks)
            || missCoast
            || (liveEmpty && ghostHeld)
    }

    static func leftoverHoldKalmanRestoredAdvance(prev: Int, restored: Bool) -> Int {
        restored ? 0 : min(99, prev + 1)
    }

    /// Miss 1 voll, danach α 0,82. Halt läuft sonst mit last-v weiter.
    static func leftoverHoldKalmanVelDecay(
        vx: Double,
        vy: Double,
        miss: Int,
        alpha: Double = 0.82
    ) -> (vx: Double, vy: Double) {
        if miss <= 1 { return (vx, vy) }
        return (vx * alpha, vy * alpha)
    }

    static func leftoverHoldKalmanKeep<Value>(kalman: [UUID: Value], live: [UUID], missCoast: Bool = false) -> [UUID: Value] {
        let keep = Set(live)
        if keep.isEmpty {
            if missCoast { return kalman }
            return [:]
        }
        return kalman.filter { keep.contains($0.key) }
    }

    static func leftoverLiveHashTickWipes(empty: Bool, missCoast: Bool = false) -> Bool {
        empty && !missCoast
    }

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

    /// Remaining analog HashHold. Decode-at=now startet Trail-TTL nach Restore neu.
    static func leftoverHashTrailRemainingEncode(
        _ table: [String: (samples: [Double], at: TimeInterval)],
        now: TimeInterval,
        ttl: TimeInterval
    ) -> [String: Double] {
        var out: [String: Double] = [:]
        let used = leftoverHoldTTLPref(ttl)
        for (k, v) in leftoverHashTrailCapped(table) where !v.samples.isEmpty {
            out[k] = leftoverJpegRemaining(at: v.at, now: now, ttl: used)
        }
        return out
    }

    static func leftoverHashTrailDecode(
        _ raw: [String: [Double]]?,
        now: TimeInterval,
        remaining: [String: Double]? = nil,
        ttl: TimeInterval = leftoverAdoptSec
    ) -> [String: (samples: [Double], at: TimeInterval)] {
        guard let raw else { return [:] }
        let used = leftoverHoldTTLPref(ttl)
        return leftoverHashTrailCapped(Dictionary(uniqueKeysWithValues: raw.filter { !$0.value.isEmpty }.map { key, samples in
            let at: TimeInterval
            if let left = remaining?[key] {
                at = leftoverJpegAtFromRemaining(remaining: left, now: now, ttl: used)
            } else {
                at = now
            }
            return (key, (samples: samples, at: at))
        }))
    }

    /// Nach Restore: TTL darf nicht 1,2 s nach App-Start sterben. Erstes Live-Tick setzt `at`.
    /// keepAt: Decode hat at=now. Rebase aufs erste Gesicht startet TTL neu — Indoor 4 s tot.
    static func leftoverHashHoldRebase(
        _ table: [String: (cosine: Double, at: TimeInterval)],
        now: TimeInterval,
        keepAt: Bool = false
    ) -> [String: (cosine: Double, at: TimeInterval)] {
        if keepAt { return leftoverHashHoldCapped(table) }
        return Dictionary(uniqueKeysWithValues: table.map { ($0.key, (cosine: $0.value.cosine, at: now)) })
    }

    static func leftoverHashTrailRebase(
        _ table: [String: (samples: [Double], at: TimeInterval)],
        now: TimeInterval,
        keepAt: Bool = false
    ) -> [String: (samples: [Double], at: TimeInterval)] {
        if keepAt { return leftoverHashTrailCapped(table) }
        return Dictionary(uniqueKeysWithValues: table.map { ($0.key, (samples: $0.value.samples, at: now)) })
    }

    static func leftoverCaptureHistEncode(_ hist: [Double]) -> [Double] {
        Array(hist.suffix(leftoverCaptureHistCap))
    }

    /// Remaining analog HashHold. Schema 15 ohne Tabelle = Hist bleibt.
    /// remaining 0 nach Restart: Indoor-Blur tot, sonst Taufe 0,70.
    static func leftoverCaptureHistRemainingEncode(
        _ table: [String: [Double]],
        at: [String: TimeInterval],
        now: TimeInterval,
        ttl: TimeInterval
    ) -> [String: Double] {
        let used = leftoverHoldTTLPref(ttl)
        var out: [String: Double] = [:]
        for k in table.keys {
            if let t = at[k] {
                out[k] = max(0, used - max(0, now - t))
            } else {
                out[k] = used
            }
        }
        return out
    }

    /// remaining Tabelle da, Key fehlt (Rank): halten. Nur 0 droppt. nil = Schema 15.
    static func leftoverCaptureHistKeeps(remaining: Double?) -> Bool {
        remaining.map { $0 > 0 } ?? true
    }

    static func leftoverCaptureHistTableDecodeFresh(
        _ raw: [String: [Double]]?,
        remaining: [String: Double]?,
        keep: [String] = []
    ) -> [String: [Double]] {
        let table = leftoverCaptureHistTableDecode(raw, keep: keep)
        guard let remaining else { return table }
        return Dictionary(uniqueKeysWithValues: table.filter {
            leftoverCaptureHistKeeps(remaining: remaining[$0.key])
        })
    }

    static func leftoverCaptureHistAtDecode(
        remaining: [String: Double]?,
        now: TimeInterval,
        ttl: TimeInterval
    ) -> [String: TimeInterval] {
        guard let remaining else { return [:] }
        let used = leftoverHoldTTLPref(ttl)
        var out: [String: TimeInterval] = [:]
        for (k, left) in remaining where leftoverCaptureHistKeeps(remaining: left) {
            let clamped = min(used, max(0, left))
            out[k] = now - (used - clamped)
        }
        return out
    }

    static func leftoverCaptureHistAtPut(
        hash: String,
        now: TimeInterval,
        onto at: [String: TimeInterval]
    ) -> [String: TimeInterval] {
        var next = at
        next[hash] = now
        return next
    }

    /// Overlay-Spark RAM-only: Restart flackert 2 Ticks Gast. Chip halten, Hold = need.
    static let leftoverSparkChipHoldNeed = 2

    static func leftoverSparkChipEncode(
        _ table: [UUID: (chip: String, hold: Int)]
    ) -> [String: String] {
        Dictionary(uniqueKeysWithValues: table.compactMap { k, v in
            v.chip.isEmpty ? nil : (k.uuidString, v.chip)
        })
    }

    static func leftoverSparkChipDecode(
        _ raw: [String: String]?,
        hold: Int = leftoverSparkChipHoldNeed
    ) -> [UUID: (chip: String, hold: Int)] {
        guard let raw else { return [:] }
        let used = max(1, hold)
        var out: [UUID: (chip: String, hold: Int)] = [:]
        for (k, v) in raw where !v.isEmpty {
            guard let id = UUID(uuidString: k) else { continue }
            out[id] = (chip: v, hold: used)
        }
        return out
    }

    /// persist UUID tot nach Restart. stabilize vor Remint — lastHash hält Chip.
    /// Remint-Miss: UUID neu, Hash gleich — Chip sonst Gast-Flash.
    static func leftoverSparkChipTickKeeps(
        id: UUID,
        live: Set<UUID>,
        hold: Set<UUID> = [],
        lastHash: String? = nil,
        liveHash: Set<String> = [],
        hashTable: [String: String] = [:]
    ) -> Bool {
        if live.contains(id) || hold.contains(id) { return true }
        guard let lastHash, !lastHash.isEmpty else { return false }
        if !liveHash.isEmpty, liveHash.contains(lastHash) { return true }
        return hashTable[lastHash] != nil && !liveHash.isEmpty
    }

    static func leftoverSparkChipHashPut(table: [String: String], hash: String?, chip: String?) -> [String: String] {
        guard let hash, !hash.isEmpty, let chip, !chip.isEmpty else { return table }
        if UUID(uuidString: hash) != nil { return table }
        var out = table
        out[hash] = chip
        if out.count > 64, let first = out.keys.first {
            out.removeValue(forKey: first)
        }
        return out
    }

    static func leftoverSparkChipHashGet(table: [String: String], hash: String?) -> String? {
        guard let hash, !hash.isEmpty else { return nil }
        return table[hash]
    }

    /// Hash→Chip neben UUID. Restart + Remint sonst Gast. UUID-Keys bleiben Decode.
    static func leftoverSparkChipHashEncode(_ table: [String: String]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: table.compactMap { k, v in
            if k.isEmpty || v.isEmpty { return nil }
            if UUID(uuidString: k) != nil { return nil }
            return (k, v)
        })
    }

    static func leftoverSparkChipPack(
        uuid: [UUID: (chip: String, hold: Int)],
        hash: [String: String]
    ) -> [String: String] {
        var out = leftoverSparkChipEncode(uuid)
        for (k, v) in leftoverSparkChipHashEncode(hash) {
            out[k] = v
        }
        return out
    }

    static func leftoverSparkChipUnpack(
        _ raw: [String: String]?
    ) -> (uuid: [UUID: (chip: String, hold: Int)], hash: [String: String]) {
        (leftoverSparkChipDecode(raw), leftoverSparkChipHashEncode(raw ?? [:]))
    }

    /// Remint-Miss: Chip unter alter UUID, Overlay liest Live. Gleiches Hash → Live-UUID.
    static func leftoverSparkChipTickDest(
        id: UUID,
        live: Set<UUID>,
        lastHash: String?,
        liveByHash: [String: UUID]
    ) -> UUID {
        if live.contains(id) { return id }
        guard let lastHash, !lastHash.isEmpty, let dest = liveByHash[lastHash], live.contains(dest) else {
            return id
        }
        return dest
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

    /// Open-Set: Gap ≤ 0,08 oder Energy klein = Unsure, nicht Gast-Taufe.
    static let leftoverOpenSetGap: Double = 0.08
    static let leftoverOpenSetEnergyFloor: Double = 0.04

    static func leftoverOpenSetGapNow(top: Double, second: Double, floor: Double = leftoverOpenSetGap) -> Bool {
        top - second <= floor
    }

    /// logΣexp / t. Klare 1-Klasse ≈ 0. Zwei nahe Scores → größer. Unsure wenn > Floor.
    static func leftoverOpenSetEnergy(_ scores: [Double], t: Double = leftoverScoreTemp) -> Double {
        guard !scores.isEmpty else { return 0 }
        let m = scores.max() ?? 0
        let z = scores.reduce(0.0) { acc, s in
            let e = t * (s - m)
            if e < -20 { return acc }
            return acc + exp(e)
        }
        return log(max(z, 1e-12)) / max(t, 1e-6)
    }

    static func leftoverOpenSetUnsure(scores: [Double], floor: Double = leftoverOpenSetEnergyFloor, gap: Double = leftoverOpenSetGap) -> Bool {
        let ok = scores.filter { $0.isFinite }
        guard ok.count >= 2 else { return false }
        let sorted = ok.sorted(by: >)
        if leftoverOpenSetGapNow(top: sorted[0], second: sorted[1], floor: gap) { return true }
        return leftoverOpenSetEnergy(ok) > floor
    }

    /// leftoverPick: Roh-Cosine unter Genuine = Unsure. Nicht leftoverHoldSmooth (0,70/0,50 → 0,57).
    static func leftoverOpenSetGalleryFloor(_ scores: [Double], floor: Double = leftoverPrintGenuine) -> Bool {
        let ok = scores.filter { $0.isFinite }
        guard let top = ok.max() else { return true }
        return top < floor
    }

    /// Overlay: ohne Mehrheit „?“, nie Gast-Name Tick 1. Streak 2 = „??“.
    static func leftoverOverlayUnsureFirst(voted: String?, hist: [String], need: Int, guest: String, streak: Int = 0) -> String {
        let tokens = hist.filter { !$0.isEmpty }
        if let name = leftoverLiveNameHolds(tokens, need: need) { return name }
        return leftoverUnsureChip(voted: voted, hist: hist, need: need, streak: streak) ?? "?"
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

    /// Rank `#101` und Bin `#0` nach Rebase Spatial. Exact sonst tot.
    static func leftoverHoldSpatialOccupied(live: [String], hash: String) -> Bool {
        let spatial = leftoverHoldHashSpatial(hash)
        guard !spatial.isEmpty else { return false }
        return live.contains { leftoverHoldHashSpatial($0) == spatial && $0 != hash }
    }

    static func leftoverHoldHashLookupKeys(hash: String, bin: Int? = nil, occupied: [String] = []) -> [String] {
        let spatial = leftoverHoldHashSpatial(hash)
        let steal = leftoverHoldSpatialOccupied(live: occupied, hash: hash)
        var keys: [String] = []
        func add(_ k: String) {
            if !k.isEmpty, !keys.contains(k) { keys.append(k) }
        }
        if let bin {
            add(leftoverHoldHashKey(hash: hash, bin: bin))
            if !steal {
                add(leftoverHoldHashKey(hash: spatial, bin: bin))
                add(spatial)
            }
            add(hash)
        } else {
            add(hash)
            if !steal {
                add(spatial)
                add(leftoverHoldHashKey(hash: spatial, bin: 0))
            }
            add(leftoverHoldHashKey(hash: hash, bin: 0))
        }
        return keys
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
        locked: [UUID] = [],
        missCoast: Bool = false
    ) -> [String: Double] {
        leftoverHoldSurviveBinMap(hold: hold, ghosts: ghosts, live: live, emptyKeeps: emptyKeeps, emptyFor: emptyFor, locked: locked, missCoast: missCoast)
    }

    static func leftoverHoldSurviveBinMap<Value>(
        hold: [String: Value],
        ghosts: [UUID],
        live: [UUID] = [],
        emptyKeeps: Bool = false,
        emptyFor: TimeInterval = 0,
        locked: [UUID] = [],
        missCoast: Bool = false
    ) -> [String: Value] {
        let keep = Set(ghosts + live + locked)
        if keep.isEmpty {
            if emptyKeeps && leftoverLatchKeeps(emptyFor: emptyFor) { return hold }
            if missCoast { return hold }
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
    /// Miss-Coast: Kalman-IDs nach Keep nicht droppen wenn Hold nach Remint leer.
    /// Ghost-only: Kalman ∩ Ghosts auch ohne missCoast — sonst Predict tot.
    /// Survive Hold allein: Kalman ∩ Hold ohne Ghost. Restore PredictOnly: Kalman ganz.
    static func leftoverKeepBoxes(
        used: Set<UUID>,
        dropped: Set<UUID>,
        ghosts: [UUID] = [],
        hold: [UUID] = [],
        missCoast: Bool = false,
        kalman: [UUID] = [],
        predictOnly: Bool = false
    ) -> Set<UUID> {
        var keep = used.union(dropped)
        keep.formUnion(ghosts)
        keep.formUnion(hold)
        if missCoast || predictOnly {
            keep.formUnion(kalman)
        } else {
            let extra = Set(ghosts).union(hold)
            keep.formUnion(kalman.filter { extra.contains($0) })
        }
        return keep
    }

    /// Survive zuerst: Hold-IDs nach Remint, nicht pre-Survive.
    static func leftoverKeepHoldIds(hold: [UUID], bins: [UUID] = []) -> [UUID] {
        Array(Set(hold).union(bins))
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

    /// n=3: 3-Zyklus nach 2-opt. Greedy allein lässt Crowd-Taufe.
    static func leftoverAssignHungarian(scores: [[Double?]]) -> [Int?] {
        var result = leftoverAssign(scores: scores)
        let n = result.count
        guard n >= 3, !scores.isEmpty else { return result }
        var assigned = result.enumerated().compactMap { item -> (r: Int, c: Int)? in
            guard let c = item.element else { return nil }
            return (item.offset, c)
        }
        guard assigned.count >= 3 else { return result }
        func score(_ r: Int, _ c: Int) -> Double? {
            guard r < scores.count, c < scores[r].count else { return nil }
            return scores[r][c]
        }
        for i in 0..<assigned.count {
            for j in (i + 1)..<assigned.count {
                for k in (j + 1)..<assigned.count {
                    let a = assigned[i], b = assigned[j], cyc = assigned[k]
                    let cur = (score(a.r, a.c) ?? -1) + (score(b.r, b.c) ?? -1) + (score(cyc.r, cyc.c) ?? -1)
                    if let s1 = score(a.r, b.c), let s2 = score(b.r, cyc.c), let s3 = score(cyc.r, a.c),
                       s1 + s2 + s3 > cur + 1e-9 {
                        result[a.r] = b.c
                        result[b.r] = cyc.c
                        result[cyc.r] = a.c
                        assigned[i] = (a.r, b.c)
                        assigned[j] = (b.r, cyc.c)
                        assigned[k] = (cyc.r, a.c)
                    } else if let s1 = score(a.r, cyc.c), let s2 = score(cyc.r, b.c), let s3 = score(b.r, a.c),
                              s1 + s2 + s3 > cur + 1e-9 {
                        result[a.r] = cyc.c
                        result[cyc.r] = b.c
                        result[b.r] = a.c
                        assigned[i] = (a.r, cyc.c)
                        assigned[k] = (cyc.r, b.c)
                        assigned[j] = (b.r, a.c)
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

    /// Floor auf RAW. Ohne Live-Print: Hold/Coast, sonst leftoverPrintOk stirbt 7/8 Detect-Skip.
    /// holdOnlyUnsure: Hold-Lookup 0,70 ist kein Cosine. Twin nicht taufen.
    static func leftoverPickPrint(raw: Double?, smoothed: Double?, holdOnlyUnsure: Bool = false) -> Double? {
        if holdOnlyUnsure { return raw }
        return raw ?? smoothed
    }

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

    /// Remint: dest tot, Majority-Streak 0. Commit bleibt wenn Value == proposed.
    static func leftoverPairCommitKeeps(committed: UUID?, proposed: UUID?) -> Bool {
        guard let committed, let proposed else { return false }
        return committed == proposed
    }

    /// Remint-Miss: proposed ≠ committed. Majority 3 Ticks Overlay, nicht sofort Gast.
    static func leftoverPairCommitHold(
        committed: UUID?,
        proposed: UUID?,
        miss: Int,
        need: Int = leftoverMajorityNeed
    ) -> Bool {
        guard committed != nil, proposed != nil, committed != proposed else { return false }
        return miss < need
    }

    static func leftoverPairCommitMissAdvance(prev: Int, keeps: Bool, hold: Bool) -> Int {
        if keeps { return 0 }
        if hold || prev >= leftoverMajorityNeed { return min(8, prev + 1) }
        return 0
    }

    static func leftoverAssignMajority(
        committed: UUID?,
        proposed: UUID?,
        lastProposed: UUID?,
        streak: Int,
        need: Int = leftoverMajorityNeed,
        locked: Bool = false,
        commitMiss: Int = 0
    ) -> (commit: UUID?, last: UUID?, streak: Int, ready: Bool) {
        if locked {
            return (committed, lastProposed, 0, false)
        }
        guard let proposed else {
            return (committed, nil, 0, false)
        }
        if leftoverPairCommitKeeps(committed: committed, proposed: proposed) {
            return (committed, proposed, 0, false)
        }
        if leftoverPairCommitHold(committed: committed, proposed: proposed, miss: commitMiss, need: need) {
            return (committed, lastProposed, streak, false)
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

    /// Remint-Miss Overlay. Majority-Label sonst lügt während Hold.
    static func leftoverPairCommitHoldLabel(miss: Int, need: Int = leftoverMajorityNeed) -> String? {
        guard miss > 0, miss < need else { return nil }
        return "HOLD \(miss)/\(need)"
    }

    /// 24 fps: Print skip wenn Vision > 18 ms. 8 fps nie — leftover braucht den Print.
    /// skipPrints nur bei stabilem Track: Kalman-IoU ≥ 0,92 *und* |yaw| < 8°.
    /// yawDelta: Drehung seit letztem Print. |yaw| allein lässt langsame Drehung 5° skippen.
    /// Continuity nie — liveDt-Jitter 16 ms darf Desk-View nicht skippen.
    /// Sonst ein Print trotz 19 ms — Twin-Taufe nach Kopf-Drehung.
    static let printBudgetMs = 18.0
    static let printBudgetIoU: Double = leftoverDetectSkipIoU
    static let printBudgetYawRad: Double = 8.0 * Double.pi / 180.0

    static func printBudgetSkip(
        visionMs: Double,
        dt: TimeInterval,
        minIoU: Double? = nil,
        yawAbs: Double? = nil,
        continuity: Bool = false,
        yawDelta: Double? = nil,
        stillFor: TimeInterval? = nil
    ) -> Bool {
        if continuity { return false }
        if dt >= 0.08 { return false }
        if visionMs <= printBudgetMs { return false }
        if let iou = minIoU, iou + 1e-9 < printBudgetIoU { return false }
        if let yaw = yawAbs, abs(yaw) + 1e-9 >= printBudgetYawRad { return false }
        if let delta = yawDelta, abs(delta) + 1e-9 >= printBudgetYawRad { return false }
        if let still = stillFor, still + 1e-9 < holdStillNeed { return false }
        return true
    }

    /// Twin bewegt, Ada still: min() ließ Ada mitdrucken. Je UUID, nicht global.
    static func printBudgetSkipIds(
        ids: [UUID],
        lastIoU: [UUID: Double],
        yaw: [UUID: Double],
        printedYaw: [UUID: Double],
        stillFor: [UUID: TimeInterval],
        visionMs: Double,
        dt: TimeInterval,
        continuity: Bool
    ) -> Set<UUID> {
        var out = Set<UUID>()
        out.reserveCapacity(ids.count)
        for id in ids {
            guard stillFor[id] != nil else { continue }
            let skip = printBudgetSkip(
                visionMs: visionMs,
                dt: dt,
                minIoU: lastIoU[id],
                yawAbs: yaw[id].map { abs($0) },
                continuity: continuity,
                yawDelta: leftoverPrintBudgetYawDeltaOf(printed: printedYaw, live: yaw[id], id: id),
                stillFor: stillFor[id]
            )
            if skip { out.insert(id) }
        }
        return out
    }

    static func printBudgetSkipAll(skipIds: Set<UUID>, liveIds: [UUID]) -> Bool {
        !liveIds.isEmpty && liveIds.allSatisfy { skipIds.contains($0) }
    }

    static func leftoverPrintSkipHits(face: FaceBox, skipBoxes: [FaceBox], iou: Double = printBudgetIoU) -> Bool {
        skipBoxes.contains {
            boxIoU(
                ax: face.x, ay: face.y, aw: face.width, ah: face.height,
                bx: $0.x, by: $0.y, bw: $0.width, bh: $0.height
            ) + 1e-9 >= iou
        }
    }

    static func leftoverPrintSkipBoxes(
        tracks: [(id: UUID, x: Double, y: Double, w: Double, h: Double)],
        skipIds: Set<UUID>
    ) -> [FaceBox] {
        tracks.compactMap { t in
            skipIds.contains(t.id) ? FaceBox(x: t.x, y: t.y, width: t.w, height: t.h) : nil
        }
    }

    /// Ada still: Overlay `still`. Twin print bleibt stumm — Skip ist die Nachricht.
    static func leftoverPrintSkipChip(skipped: Bool) -> String? {
        skipped ? "still" : nil
    }

    /// Global: `Ada still · Twin print`.
    static func leftoverPrintSkipSummary(still: [String], printing: [String]) -> String? {
        var bits: [String] = []
        let s = still.filter { !$0.isEmpty }
        let p = printing.filter { !$0.isEmpty }
        if !s.isEmpty { bits.append(s.joined(separator: "/") + " still") }
        if !p.isEmpty { bits.append(p.joined(separator: "/") + " print") }
        return bits.isEmpty ? nil : bits.joined(separator: " · ")
    }

    /// Crop nur um Gesichter die Print brauchen. Ada still im Crop fraß Twin-Budget.
    static func liveRoiTracks(
        tracks: [(id: UUID, x: Double, y: Double, w: Double, h: Double)],
        skipIds: Set<UUID>
    ) -> [(x: Double, y: Double, w: Double, h: Double)] {
        let need = tracks.filter { !skipIds.contains($0.id) }
        let use = need.isEmpty ? tracks : need
        return use.map { (x: $0.x, y: $0.y, w: $0.w, h: $0.h) }
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
        nameLockUntil: TimeInterval? = nil,
        jump: Double = leftoverIoUJump,
        continuity: Bool = false
    ) -> Bool {
        if leftoverIoUJumpBlocks(iou, jump: jump) { return false }
        if leftoverNameLockBlocks(until: nameLockUntil, now: now) { return true }
        return leftoverPrintOk(cosine: cosine, sharpness: sharpness) && !leftoverTransfersId(
            cosine: cosine, holdPrev: holdPrev, trail: trail, tapUntil: tapUntil, now: now, stillFor: stillFor,
            sharpness: sharpness, yawAbs: yawAbs, blink: blink, jpegDelta: jpegDelta, iou: iou,
            jpegRequired: jpegRequired, nameLockUntil: nameLockUntil, jump: jump, continuity: continuity
        )
    }

    /// Dropout: UUID-Hold/Trail/Slot am Ghost **und** an Live. Nur Ghosts wischte den Live-Hold.
    /// emptyFor begrenzt emptyKeeps — sonst Tasche-im-Dunkeln ewig Hold.
    /// 1-Face-Miss ohne Ghost: Detect-Drop wischt persist leftoverHold. Coast 1 Tick.
    static func leftoverHoldMissAdvance(prev: Int, hit: Bool) -> Int {
        hit ? 0 : prev + 1
    }

    /// Detect-Drop: liveIds leer, adopted kann Faces haben. Hit = irgendein Live.
    static func leftoverHoldMissHit(live: Int, adopted: Int) -> Bool {
        live > 0 || adopted > 0
    }

    /// Indoor 8 fps Dropout 2 Ticks. Hart 1 tot. Pref 1–3, Default 2.
    static func leftoverHoldMissNeedPref(_ pref: Int) -> Int {
        min(3, max(1, pref))
    }

    static func leftoverHoldMissNeedAuto(dt: TimeInterval, pref: Int) -> Int {
        let p = leftoverHoldMissNeedPref(pref)
        if dt >= 0.20 { return max(p, 3) }
        return p
    }

    static func leftoverHoldMissCoast(miss: Int, need: Int = 2) -> Bool {
        let n = leftoverHoldMissNeedPref(need)
        return miss > 0 && miss <= n
    }

    static func leftoverPredictOnMissCoast(_ missCoast: Bool) -> Bool { missCoast }

    /// found.isEmpty wischte Streak/Pair/Kalman trotz Miss-Coast Hold.
    static func leftoverEmptyWipesMaps(emptyLatch: Bool, missCoast: Bool) -> Bool {
        !emptyLatch && !missCoast
    }

    static func leftoverEmptyWipesOverlay(emptyChip: Bool, missCoast: Bool) -> Bool {
        !emptyChip && !missCoast
    }

    static func leftoverHoldSurvive<Value>(
        hold: [UUID: Value],
        ghosts: [UUID],
        live: [UUID] = [],
        emptyKeeps: Bool = false,
        emptyFor: TimeInterval = 0,
        locked: [UUID] = [],
        missCoast: Bool = false
    ) -> [UUID: Value] {
        let keep = Set(ghosts + live + locked)
        if keep.isEmpty {
            if emptyKeeps && leftoverLatchKeeps(emptyFor: emptyFor) { return hold }
            if missCoast { return hold }
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
        let samples = leftoverPrintBankPrune(samples)
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
        let parts = leftoverHoldHashSpatial(hash).split(separator: ".").compactMap { Int($0) }
        let hi = parts.max() ?? 0
        if hi >= 16 { return 24 }
        if hi >= 12 { return 16 }
        return 12
    }

    static func leftoverBoxHashDistance(_ a: String, _ b: String) -> Int {
        let pa = leftoverHoldHashSpatial(a).split(separator: ".").compactMap { Int($0) }
        let pb = leftoverHoldHashSpatial(b).split(separator: ".").compactMap { Int($0) }
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
        let parts = leftoverHoldHashSpatial(hash).split(separator: ".").compactMap { Int($0) }
        guard parts.count == 4 else { return [leftoverHoldHashSpatial(hash)] }
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
            for k in leftoverHoldHashLookupKeys(hash: hash, bin: bin, occupied: occupied) {
                if let row = table[k], now - row.at <= ttl { return row.samples }
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
        for k in leftoverHoldHashLookupKeys(hash: hash, bin: nil, occupied: occupied) {
            if let row = table[k], now - row.at <= ttl { return row.samples }
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
            for k in leftoverHoldHashLookupKeys(hash: hash, bin: bin, occupied: occupied) {
                if let row = table[k], now - row.at <= ttl { return row.cosine }
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
        for k in leftoverHoldHashLookupKeys(hash: hash, bin: nil, occupied: occupied) {
            if let row = table[k], now - row.at <= ttl { return row.cosine }
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

    /// leftoverStreakSince war absolute Epoch — Survive wischt Hold vor Remint nach Restart.
    /// Remaining analog NameLockUntil. Schema 8 (>100) = Epoch, rebase auf now.
    static func leftoverSeenRemainingEncode(
        since: [UUID: TimeInterval],
        now: TimeInterval,
        ttl: TimeInterval
    ) -> [String: Double] {
        let used = leftoverHoldTTLPref(ttl)
        var out: [String: Double] = [:]
        for (id, t) in since {
            let left = used - (now - t)
            if left > 0 { out[id.uuidString] = left }
        }
        return out
    }

    static func leftoverSeenRestore(
        _ raw: [String: Double]?,
        now: TimeInterval,
        ttl: TimeInterval
    ) -> [UUID: TimeInterval] {
        let used = leftoverHoldTTLPref(ttl)
        var out: [UUID: TimeInterval] = [:]
        for (id, v) in leftoverStreakSinceDecode(raw) {
            if v > 100 {
                out[id] = v > now ? v : now
            } else if v > 0 {
                out[id] = now - (used - v)
            }
        }
        return out
    }

    /// leftoverLastHash / leftoverNameLockHeld. App-Restart sonst Rescue ohne storedHash.
    static func leftoverUUIDStringMapEncode(_ table: [UUID: String]) -> [String: String] {
        var out: [String: String] = [:]
        for (k, v) in table where !v.isEmpty {
            out[k.uuidString] = v
        }
        return out
    }

    static func leftoverUUIDStringMapDecode(_ raw: [String: String]?) -> [UUID: String] {
        guard let raw else { return [:] }
        var out: [UUID: String] = [:]
        for (k, v) in raw {
            guard let id = UUID(uuidString: k), !v.isEmpty else { continue }
            out[id] = v
        }
        return out
    }

    /// leftoverNameLockHeld nach Restart: Until = now + Arm, sonst Survive wischt Hold vor Remint.
    static func leftoverNameLockUntilRestore(
        held: [UUID: String],
        remaining: [UUID: TimeInterval] = [:],
        now: TimeInterval,
        arm: TimeInterval
    ) -> [UUID: TimeInterval] {
        let used = leftoverNameLockSecPref(arm)
        var out: [UUID: TimeInterval] = [:]
        for (id, left) in remaining where left > 0 {
            out[id] = now + left
        }
        if used > 0 {
            for id in held.keys where out[id] == nil {
                out[id] = now + used
            }
        }
        return out
    }

    /// Remaining seconds, nicht absolute Epoch — Restart sonst Until in der Vergangenheit.
    static func leftoverNameLockUntilEncode(until: [UUID: TimeInterval], now: TimeInterval) -> [String: Double] {
        var out: [String: Double] = [:]
        for (id, t) in until {
            let left = t - now
            if left > 0 { out[id.uuidString] = left }
        }
        return out
    }

    static func leftoverNameLockUntilDecode(_ raw: [String: Double]?, now: TimeInterval) -> [UUID: TimeInterval] {
        var out: [UUID: TimeInterval] = [:]
        for (k, v) in leftoverStreakSinceDecode(raw) where v > 0 {
            out[k] = now + v
        }
        return out
    }

    /// Schema-7 Backup: Until leer darf Held nicht wischen — Restore-Arm sonst Gast.
    /// Live-Tick: emptyKeeps false — Until leer nach Ablauf sonst Held-Leak.
    static func leftoverNameLockHeldSurvive(
        held: [UUID: String],
        until: [UUID: TimeInterval],
        emptyKeeps: Bool = true
    ) -> [UUID: String] {
        if until.isEmpty { return emptyKeeps ? held : [:] }
        return held.filter { until[$0.key] != nil }
    }

    /// Overlay-Sticky nach Lock-TTL. Survive wischt Held mit Until — Overlay sonst „?“.
    /// Matching bleibt leftoverNameLockKeeps (Until). Coast hält Live/Ghost/Locked.
    static func leftoverNameLockHeldCoast(
        held: [UUID: String],
        live: [UUID],
        locked: [UUID],
        ghosts: [UUID] = []
    ) -> [UUID: String] {
        let keep = Set(live).union(locked).union(ghosts)
        if keep.isEmpty { return [:] }
        return held.filter { keep.contains($0.key) && !$0.value.isEmpty }
    }

    static func leftoverUUIDUUIDMapEncode(_ table: [UUID: UUID]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: table.map { ($0.key.uuidString, $0.value.uuidString) })
    }

    /// RemintId setzt dest=key. dest≠id droppt PairCommit nach Restart — Taufe Gast n+1.
    static func leftoverUUIDUUIDMapDecode(_ raw: [String: String]?) -> [UUID: UUID] {
        guard let raw else { return [:] }
        var out: [UUID: UUID] = [:]
        for (k, v) in raw {
            guard let id = UUID(uuidString: k), let dest = UUID(uuidString: v) else { continue }
            out[id] = dest
        }
        return out
    }

    /// Dest tot nach Vision-Restart. keep = Live ∪ Identitäten.
    /// Key live, Dest Twin-weg: PairCommit halten, nicht droppen.
    /// Hold-Key A overlay, dest Twin-B ghost: Key nicht live — Taufe sonst Tick 1.
    /// keep leer + hold: nur Hold-Keys, nicht die ganze Tabelle.
    /// Ghost-UUID fehlt in leftoverHold: Twin-Session fällt, Majority tauft Tick 1.
    static func leftoverUUIDUUIDMapDropHold(
        hold: Set<UUID>,
        ghosts: [UUID] = [],
        missKeys: [UUID] = [],
        commitMiss: [UUID: Int] = [:]
    ) -> Set<UUID> {
        var out = hold.union(ghosts).union(missKeys)
        for (k, miss) in commitMiss where leftoverGhostHoldsCommit(miss: miss) {
            out.insert(k)
        }
        return out
    }

    /// Overlay HOLD stirbt vor Ghost: PairCommit fällt, Majority tauft Tick 1.
    static func leftoverGhostHoldsCommit(miss: Int, need: Int = leftoverMajorityNeed) -> Bool {
        miss > 0 && miss < need
    }

    static func leftoverUUIDUUIDMapDropDangling(
        _ table: [UUID: UUID],
        keep: Set<UUID>,
        hold: Set<UUID> = []
    ) -> [UUID: UUID] {
        if keep.isEmpty && hold.isEmpty { return table }
        let destOk = keep.union(hold)
        var out: [UUID: UUID] = [:]
        for (k, v) in table {
            if destOk.contains(k) || destOk.contains(v) {
                out[k] = v
            }
        }
        return out
    }

    static func leftoverUUIDIntMapEncode(_ table: [UUID: Int]) -> [String: Int] {
        Dictionary(uniqueKeysWithValues: table.map { ($0.key.uuidString, $0.value) })
    }

    static func leftoverUUIDIntMapDecode(_ raw: [String: Int]?) -> [UUID: Int] {
        guard let raw else { return [:] }
        var out: [UUID: Int] = [:]
        for (k, v) in raw {
            guard let id = UUID(uuidString: k) else { continue }
            out[id] = v
        }
        return out
    }

    /// Hold-Trail unbeschränkt fraß RAM. EMA 4 Samples.
    static func leftoverHoldTrailCap(_ trail: [Double], cap: Int = 4) -> [Double] {
        trail.count <= cap ? trail : Array(trail.suffix(cap))
    }

    static func leftoverHoldTrailEMA(
        _ trail: [Double],
        sample: Double,
        cap: Int = 4,
        alpha: Double = 0.4
    ) -> [Double] {
        let a = min(1, max(0, alpha))
        let ema = trail.last.map { $0 * (1 - a) + sample * a } ?? sample
        return leftoverHoldTrailCap(leftoverCosineSparkPut(ema, onto: trail, cap: cap), cap: cap)
    }

    /// Rank-Key `#101` nach Restart tot. Spatial gewinnt, Rank ist Live-Frame.
    /// Yaw-Bin `#0`/`#1`/`#2` bleibt — Spatial-Strip killt leftoverHoldHashKey sonst.
    static func leftoverHoldHashBin(_ key: String) -> Int? {
        guard let i = key.lastIndex(of: "#") else { return nil }
        return Int(key[key.index(after: i)...])
    }

    static func leftoverHashIsTwinRank(_ key: String) -> Bool {
        (leftoverHoldHashBin(key) ?? 0) >= leftoverHashTwinRankBase
    }

    static func leftoverHashRankRebase<Value>(_ table: [String: Value]) -> [String: Value] {
        var out: [String: Value] = [:]
        for (k, v) in table {
            if leftoverHashIsTwinRank(k) { continue }
            if leftoverHoldHashSpatial(k).isEmpty { continue }
            out[k] = v
        }
        for (k, v) in table {
            guard leftoverHashIsTwinRank(k) else { continue }
            let spatial = leftoverHoldHashSpatial(k)
            if spatial.isEmpty { continue }
            if out[spatial] == nil { out[spatial] = v }
        }
        return out
    }

    /// leftoverLastHash Werte `#101` nach Restore. Occupied sonst Rank+Spatial doppelt.
    /// Yaw `#0`/`#1`/`#2` hält — Spatial-Strip killt leftoverHoldHashKey sonst.
    static func leftoverLastHashRankRebase(_ table: [UUID: String]) -> [UUID: String] {
        var out: [UUID: String] = [:]
        for (k, v) in table {
            if leftoverHashIsTwinRank(v) {
                let s = leftoverHoldHashSpatial(v)
                if !s.isEmpty { out[k] = s }
            } else if !leftoverHoldHashSpatial(v).isEmpty {
                out[k] = v
            }
        }
        return out
    }

    static func leftoverStringMapMove<Value>(hold: [String: Value], from: String, to: String) -> [String: Value] {
        guard from != to, let v = hold[from] else { return hold }
        var out = hold
        out[to] = v
        out.removeValue(forKey: from)
        return out
    }

    static func leftoverCaptureHistTableMove(
        table: [String: [Double]],
        from: String,
        to: String
    ) -> [String: [Double]] {
        leftoverStringMapMove(hold: table, from: from, to: to)
    }

    static func leftoverHoldMoveRankKey<Value>(
        hold: [String: Value],
        hash: String,
        fromRank: Int,
        toRank: Int
    ) -> [String: Value] {
        leftoverStringMapMove(
            hold: hold,
            from: leftoverHoldHashTwinKey(hash: hash, rank: fromRank),
            to: leftoverHoldHashTwinKey(hash: hash, rank: toRank)
        )
    }

    static func leftoverUUIDTrailEncode(_ table: [UUID: [Double]]) -> [String: [Double]] {
        leftoverHoldTrailBinsEncode(Dictionary(uniqueKeysWithValues: table.map {
            ($0.key.uuidString, leftoverHoldTrailCap($0.value))
        }))
    }

    static func leftoverUUIDTrailDecode(_ raw: [String: [Double]]?) -> [UUID: [Double]] {
        var out: [UUID: [Double]] = [:]
        for (k, v) in leftoverHoldTrailBinsDecode(raw) {
            guard let id = UUID(uuidString: k), !v.isEmpty else { continue }
            out[id] = leftoverHoldTrailCap(v)
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

    /// 3 Yaw-Slots. Coach kannte nur F+¾, ¾R blieb unsichtbar.
    static func leftoverEnrollSlotChip(haveFrontal: Bool, haveLeft: Bool, haveRight: Bool) -> String? {
        var miss: [String] = []
        if !haveFrontal { miss.append("F") }
        if !haveLeft { miss.append("¾L") }
        if !haveRight { miss.append("¾R") }
        return miss.isEmpty ? nil : "enroll " + miss.joined(separator: " ")
    }

    static func leftoverEnrollSlotHave(
        yaw: Double,
        haveFrontal: Bool,
        haveLeft: Bool,
        haveRight: Bool
    ) -> (frontal: Bool, left: Bool, right: Bool) {
        var f = haveFrontal
        var l = haveLeft
        var r = haveRight
        let a = abs(yaw)
        if a < 0.28 { f = true }
        else if a < 0.70 {
            if yaw < 0 { l = true } else { r = true }
        }
        return (f, l, r)
    }

    static func leftoverFaceTrackLookup(tracks: [UUID: FaceTrack], id: UUID) -> FaceTrack? {
        tracks[id]
    }

    static func leftoverFaceTrackHolds(track: FaceTrack?, now: TimeInterval, ttl: TimeInterval = leftoverLatch) -> Bool {
        guard let t = track else { return false }
        if t.hold <= 0 { return false }
        if t.poseAt > 0 {
            return now >= t.poseAt && now - t.poseAt < ttl
        }
        if t.nameUntil > 0 && now >= t.nameUntil { return false }
        return true
    }

    static func leftoverFaceTrackHoldChip(track: FaceTrack?, now: TimeInterval) -> String? {
        leftoverFaceTrackHolds(track: track, now: now) ? "hold" : nil
    }

    /// Burst 0,98. Gallery-on-disk sonst identische Prints.
    static func leftoverPrintPruneDup(cosine: Double, floor: Double = 0.98) -> Bool {
        cosine + 1e-12 >= floor
    }

    /// Burst 0,98 nicht in die Bank. gallery.json sonst identische Prints.
    static func leftoverPrintBankPrune(_ samples: [(vec: [Double], w: Double)], floor: Double = 0.98) -> [(vec: [Double], w: Double)] {
        var kept: [(vec: [Double], w: Double)] = []
        for s in samples where s.vec.count >= 32 && s.w > 0 {
            let dup = kept.contains { leftoverPrintPruneDup(cosine: cosine($0.vec, s.vec), floor: floor) }
            if !dup { kept.append(s) }
        }
        return kept
    }

    static func leftoverPairCommitWALFresh(
        stamped: TimeInterval?,
        now: TimeInterval,
        ttl: TimeInterval = 2
    ) -> Bool {
        guard let stamped, ttl > 0 else { return false }
        return now - stamped >= 0 && now - stamped < ttl
    }

    static func leftoverPairCommitWALStamp(
        prev: TimeInterval?,
        commit: Bool,
        now: TimeInterval
    ) -> TimeInterval? {
        commit ? now : prev
    }

    static func leftoverPairCommitWALName() -> String { "gallery.pair.wal" }

    static func leftoverPairCommitWALBak(_ i: Int) -> String {
        i <= 0 ? leftoverPairCommitWALName() : leftoverPairCommitWALName() + ".\(i)"
    }

    static func leftoverPairCommitWALBytes(pairs: [String: String]?) -> Data? {
        guard let pairs, !pairs.isEmpty else { return nil }
        return try? JSONEncoder().encode(pairs)
    }

    static func leftoverPairCommitWALRestore(data: Data?, stamped: TimeInterval?, now: TimeInterval) -> [String: String]? {
        guard leftoverPairCommitWALFresh(stamped: stamped, now: now), let data else { return nil }
        return leftoverPairCommitWALRestoreDisk(data: data)
    }

    /// Crash-Restore: Datei, nicht RAM-Stamp. 2 s TTL wäre nach Restart tot.
    static func leftoverPairCommitWALRestoreDisk(data: Data?) -> [String: String]? {
        guard let data, !data.isEmpty else { return nil }
        return try? JSONDecoder().decode([String: String].self, from: data)
    }

    static func leftoverPairCommitWALAgeMax() -> TimeInterval { 86_400 }

    static func leftoverPairCommitWALAgeOk(
        age: TimeInterval?,
        max: TimeInterval = leftoverPairCommitWALAgeMax()
    ) -> Bool {
        guard let age, age >= 0 else { return false }
        return age < max
    }

    /// WAL neuer als gallery.json → Taufe retten. gallery neuer → Save fertig, WAL tot.
    static func leftoverPairCommitWALApply(
        gallery: [String: String]?,
        wal: [String: String]?,
        galleryMtime: TimeInterval?,
        walMtime: TimeInterval?,
        now: TimeInterval
    ) -> [String: String]? {
        let walAge = walMtime.map { now - $0 }
        let walOk = leftoverPairCommitWALAgeOk(age: walAge) && wal != nil && !(wal?.isEmpty ?? true)
        if !walOk {
            return (gallery?.isEmpty == false) ? gallery : nil
        }
        let walPairs = wal!
        if gallery == nil || gallery?.isEmpty == true { return walPairs }
        if let gm = galleryMtime, let wm = walMtime, wm > gm + 1e-6 {
            var merged = gallery ?? [:]
            for (k, v) in walPairs { merged[k] = v }
            return merged
        }
        return gallery
    }

    static func leftoverPairCommitWALShouldClear(saved: Bool) -> Bool { saved }

    static func leftoverFaceTrackStoreGet(tracks: [UUID: FaceTrack], id: UUID, now: TimeInterval) -> FaceTrack? {
        let t = leftoverFaceTrackLookup(tracks: tracks, id: id)
        return leftoverFaceTrackHolds(track: t, now: now) ? t : nil
    }

    static func leftoverFaceTrackStoreName(tracks: [UUID: FaceTrack], id: UUID, now: TimeInterval) -> String? {
        leftoverFaceTrackStoreGet(tracks: tracks, id: id, now: now)?.nameHeld
    }

    /// Jump-Lock nameUntil ist 1,2 s. Store hält über poseAt (Latch 4 s).
    static func leftoverFaceTrackStoreNameOf(
        hold: Double,
        nameHeld: String,
        nameUntil: TimeInterval,
        now: TimeInterval,
        poseAt: TimeInterval = 0
    ) -> String? {
        let t = FaceTrack(hold: hold, nameHeld: nameHeld, nameUntil: nameUntil, poseAt: poseAt)
        guard leftoverFaceTrackHolds(track: t, now: now), !nameHeld.isEmpty else { return nil }
        return nameHeld
    }

    /// Mehrheit vor Sticky vor Unsure. Streak 2 an Sticky = „Ada?“, nicht „??“.
    static func leftoverOverlayStickyName(held: String, streak: Int) -> String {
        guard !held.isEmpty else { return leftoverUnsureChip(voted: nil, hist: [], need: 3, streak: streak) ?? "?" }
        return streak >= 2 ? "\(held)?" : held
    }

    /// Lock-Held, sonst letztes Hist-Token (Remint keep 1). Kein Gast-Tick-1.
    static func leftoverOverlayGuestStickyOf(sticky: String?, hist: [String]) -> String? {
        if let sticky, !sticky.isEmpty { return sticky }
        guard let last = hist.last(where: { !$0.isEmpty }), !last.isEmpty else { return nil }
        return last
    }

    /// Overlay: StoreName vor Hist. Nach Remint Hist leer, Ada sonst Gast.
    /// Sticky/Hist-Tail nach Store, sonst „?“.
    static func leftoverOverlayGuestOf(
        storeName: String?,
        voted: String?,
        hist: [String],
        need: Int,
        guest: String,
        streak: Int = 0,
        sticky: String? = nil
    ) -> String {
        if let n = storeName, !n.isEmpty { return n }
        let tokens = hist.filter { !$0.isEmpty }
        if let name = leftoverLiveNameHolds(tokens, need: need) { return name }
        if let held = leftoverOverlayGuestStickyOf(sticky: sticky, hist: tokens) {
            return leftoverOverlayStickyName(held: held, streak: streak)
        }
        return leftoverOverlayUnsureFirst(
            voted: voted, hist: hist, need: need, guest: guest, streak: streak
        )
    }

    /// leftoverHold[id] ist Frontal. ¾ nur in Bins — StoreName sonst hold 0.
    static func leftoverHoldMaxOf(frontal: Double?, bins: [String: Double], id: UUID) -> Double {
        var m = frontal ?? 0
        for b in 0...2 {
            if let v = leftoverHoldBinRead(bins: bins, id: id, bin: b) {
                m = max(m, v)
            }
        }
        return m
    }

    /// leftoverHasHold ohne poseAt: Ghost nach Latch noch Hold.
    static func leftoverHasHoldOf(
        hold: Double?,
        bins: [String: Double],
        id: UUID,
        poseAt: TimeInterval,
        now: TimeInterval,
        nameUntil: TimeInterval = 0
    ) -> Bool {
        let h = leftoverHoldMaxOf(frontal: hold, bins: bins, id: id)
        if h <= 0 { return false }
        return leftoverFaceTrackHolds(
            track: FaceTrack(hold: h, nameHeld: "-", nameUntil: nameUntil, poseAt: poseAt),
            now: now
        )
    }

    static func leftoverStoreChip(name: String?) -> String? {
        guard let n = name, !n.isEmpty else { return nil }
        return "store \(n)"
    }

    /// „?“ / „??“ / Gast. „Ada?“ ist Name, kein Unsure.
    static func leftoverOverlayPeakIsUnsure(_ name: String) -> Bool {
        let t = name.trimmingCharacters(in: .whitespaces)
        if t.isEmpty { return true }
        if t == "?" || t == "??" { return true }
        if t.hasPrefix("Gast") { return true }
        return false
    }

    static func leftoverOverlayPeakBare(_ name: String) -> String {
        var t = name.trimmingCharacters(in: .whitespaces)
        if t.hasSuffix("?") && t != "?" && t != "??" {
            t.removeLast()
        }
        return t
    }

    /// Remint-UUID 1–3 Frames „?“. Peak hält Ada, nicht UUID.
    static func leftoverOverlayPeakGuest(
        guest: String,
        held: String?,
        remaining: Int,
        need: Int = 3
    ) -> (name: String, remaining: Int) {
        if !leftoverOverlayPeakIsUnsure(guest) { return (guest, need) }
        if remaining > 0, let held, !leftoverOverlayPeakIsUnsure(held) {
            return (held, remaining - 1)
        }
        return (guest, 0)
    }

    /// Display: PeakGuest dekrementiert. SwiftUI nach Advance — remain=0 hielte Ada tot.
    static func leftoverOverlayPeakName(guest: String, held: String?) -> String {
        if !leftoverOverlayPeakIsUnsure(guest) { return guest }
        if let held, !leftoverOverlayPeakIsUnsure(held) { return held }
        return guest
    }

    static func leftoverOverlayPeakAdvance(
        guest: [UUID: String],
        held: [UUID: String],
        remain: [UUID: Int],
        live: [UUID],
        need: Int = 3
    ) -> (held: [UUID: String], remain: [UUID: Int]) {
        var h = held
        var r = remain
        let keep = Set(live)
        for id in keep.union(Set(h.keys)) {
            if !keep.contains(id) {
                h.removeValue(forKey: id)
                r.removeValue(forKey: id)
                continue
            }
            let g = guest[id] ?? "?"
            let step = leftoverOverlayPeakGuest(guest: g, held: h[id], remaining: r[id] ?? 0, need: need)
            if leftoverOverlayPeakIsUnsure(step.name) {
                h.removeValue(forKey: id)
                r[id] = 0
            } else {
                h[id] = leftoverOverlayPeakBare(step.name)
                r[id] = step.remaining
            }
        }
        return (h, r)
    }

}

