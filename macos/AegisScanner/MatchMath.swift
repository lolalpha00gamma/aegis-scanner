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
    /// Starker Print ist Identität. Geo unter 35 darf ihn nicht auf 60 kappen.
    static let strongPrintFloor = 84.0
    /// Ab diesem Print-Wert vetoiert Kleidung/Haar nicht mehr.
    static let geoVetoSkipPrint = 88.0
    /// ¾/Profil: Maße vs. Frontal-Centroid lügen. Print ≥ 80 nicht vetoen.
    static let geoVetoYawSkip = 0.28
    static let geoVetoYawPrint = 80.0
    /// gallery.json Schema neben printRevision.
    static let gallerySchema = 2
    /// Box-IoU unter dem Wert: Bewegung, neuen Print verwerfen (Motion-Blur).
    static let holdStillIoU = 0.82

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
        cosine > floor
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
        floor: Double = leftoverIoU
    ) -> Int? {
        let ok = candidates.filter { leftoverPin(iou: $0.iou, floor: floor) }
        guard !ok.isEmpty else { return nil }
        let printable = ok.filter { c in
            guard let cos = c.cosine else { return false }
            return !leftoverNeedsPrint(cosine: cos) && !iouPrintBlocks(cosine: cos)
        }
        if let best = printable.max(by: { ($0.cosine ?? -1) < ($1.cosine ?? -1) }) {
            return best.index
        }
        return nil
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

    static func leftoverPinStatus(count: Int) -> String? {
        guard count > 0 else { return nil }
        return count == 1 ? "Leftover-Pin 1 Track" : "Leftover-Pin \(count) Tracks"
    }

    /// Bewegung: neuen Print nicht übernehmen. Schärfe allein sieht 8-fps-Blur nicht.
    static func holdStillSkip(iou: Double, floor: Double = holdStillIoU) -> Bool {
        iou < floor
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
            bits.append("Schema \(schemaVersion.map(String.init) ?? "<2")")
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

    /// Slot-Centroid wenn der Slot Refs hat, sonst 72/28-Fallback.
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
    static func oneEuroCutoff(base: Double, dt: Double) -> Double {
        dt >= 0.10 ? base * 1.7 : base
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
    /// Starke Prints (≥ 84) niemals unter den Embed kappen — Landmark-Rauschen
    /// (Jacke, Haar, ¾) ist keine andere Person.
    static func lookOf(geo: Double, embed: Double, pose: Double = 1, printMeasured: Bool) -> Double {
        if !printMeasured { return geo }
        if geo < 1 { return embed }
        if embed >= strongPrintFloor {
            let agree = clamp01((geo - 52) / 38) * clamp01(pose)
            return min(100, embed + 4.0 * agree)
        }
        if geo < 35 { return min(embed, 60) }
        let agree = clamp01((geo - 52) / 38) * clamp01(pose)
        return min(100, embed + 4.0 * agree)
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
        // floor(far·n) − 1: n=10/0,1 → 95; n=10/0,2 → 60; n=101/0,01 → 80.
        // ceil−1 bricht 101 Impostoren (Index 1 → 10 statt 80).
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

        mutating func filter(_ value: Double, now: Double) -> Double {
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
            let cutoff = MatchMath.oneEuroCutoff(base: minCutoff, dt: dt) + beta * abs(dxHat)
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
}
