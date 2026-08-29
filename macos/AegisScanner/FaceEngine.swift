import CoreGraphics
import Foundation
import Vision

enum FaceEngine {
    static func detect(in image: CGImage, mediaId: UUID, tiles: Bool = true) throws -> [FaceObservation] {
        let w = Double(image.width)
        let h = Double(image.height)
        var out = try detectOnce(in: image, mediaId: mediaId, originX: 0, originY: 0, imageWidth: w, imageHeight: h)
        let largest = out.map { max($0.box.width, $0.box.height) }.max() ?? 0
        let covered = out.reduce(0.0) { $0 + $1.box.width * $1.box.height }
        let coverage = covered / max(1, w * h)
        let crowd = out.isEmpty || largest < min(w, h) * 0.22 || (coverage < 0.14 && max(w, h) >= 1000)
        if tiles, crowd, max(image.width, image.height) >= 900 {
            let tw = max(280, Int((w * 0.58).rounded()))
            let th = max(280, Int((h * 0.58).rounded()))
            let origins: [(Int, Int)] = [
                (0, 0),
                (max(0, image.width - tw), 0),
                (0, max(0, image.height - th)),
                (max(0, image.width - tw), max(0, image.height - th)),
                (max(0, (image.width - tw) / 2), max(0, (image.height - th) / 2)),
            ]
            for (ox, oy) in origins {
                let tileBox = FaceBox(x: Double(ox), y: Double(oy), width: Double(tw), height: Double(th))
                guard let tile = crop(image, box: tileBox, pad: 0) else { continue }
                let found = try detectOnce(
                    in: tile,
                    mediaId: mediaId,
                    originX: Double(ox),
                    originY: Double(oy),
                    imageWidth: w,
                    imageHeight: h
                )
                out.append(contentsOf: found)
            }
            out = nms(out)
        }
        return nms(out)
    }

    private static func detectOnce(
        in image: CGImage,
        mediaId: UUID,
        originX: Double,
        originY: Double,
        imageWidth: Double,
        imageHeight: Double
    ) throws -> [FaceObservation] {
        let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
        let facesReq = VNDetectFaceRectanglesRequest()
        facesReq.revision = VNDetectFaceRectanglesRequestRevision3
        let landReq = VNDetectFaceLandmarksRequest()
        let qualityReq = VNDetectFaceCaptureQualityRequest()
        try handler.perform([facesReq, landReq, qualityReq])

        let observations = (facesReq.results ?? [])
        let landmarks = landReq.results ?? []
        let qualities = qualityReq.results ?? []
        var out: [FaceObservation] = []
        let w = Double(image.width)
        let h = Double(image.height)

        for face in observations where face.confidence >= 0.15 {
            var box = vnToPixels(face.boundingBox, width: w, height: h)
            box = FaceBox(
                x: box.x + originX,
                y: box.y + originY,
                width: box.width,
                height: box.height
            )
            let lm = landmarks.first { $0.uuid == face.uuid } ?? landmarks.first {
                hypot($0.boundingBox.midX - face.boundingBox.midX, $0.boundingBox.midY - face.boundingBox.midY) < 0.04
            }
            var points = extractPoints(lm, imageWidth: w, imageHeight: h)
            if originX != 0 || originY != 0 {
                points = points.map { Point2(x: $0.x + originX, y: $0.y + originY) }
            }
            let aligned = procrustes(points)
            let captureApple = Double(
                (qualities.first { $0.uuid == face.uuid }?.faceCaptureQuality ??
                    qualities.first?.faceCaptureQuality ?? 0.5)
            )
            let frontal = frontalScore(points)
            let size = min(1, (box.width * box.height) / max(1, imageWidth * imageHeight) / 0.12)
            let sharpness = sharpnessScore(crop(image, box: vnToPixels(face.boundingBox, width: w, height: h)))
            let capture = clamp01(0.40 * captureApple + 0.22 * sharpness + 0.18 * size + 0.20 * frontal)
            let inner = crop(image, box: vnToPixels(face.boundingBox, width: w, height: h), pad: 0.04)
            let printData = featurePrint(of: crop(image, box: vnToPixels(face.boundingBox, width: w, height: h), pad: 0.18)) ?? Data()
            let leftEye = regionCenter(lm?.landmarks?.leftEye, box: face.boundingBox, imageWidth: w, imageHeight: h)
            let rightEye = regionCenter(lm?.landmarks?.rightEye, box: face.boundingBox, imageWidth: w, imageHeight: h)
            let appearance: [Double]
            if let leftEye, let rightEye, let warped = warpEyes(image, left: leftEye, right: rightEye) {
                appearance = appearanceVector(of: warped)
            } else {
                appearance = appearanceVector(of: inner)
            }

            out.append(
                FaceObservation(
                    id: UUID(),
                    mediaId: mediaId,
                    box: box,
                    score: Double(face.confidence),
                    landmarks: points,
                    aligned: aligned,
                    featurePrint: printData,
                    appearance: appearance,
                    graph: graphBiomarkers(points),
                    geom3d: geom3dFeatures(aligned),
                    quality: FaceQuality(sharpness: sharpness, size: size, frontal: frontal, capture: capture),
                    trackId: nil
                )
            )
        }
        return out
    }

    private static func nms(_ faces: [FaceObservation], iouThresh: Double = 0.28) -> [FaceObservation] {
        let ranked = faces.sorted { $0.score > $1.score }
        var kept: [FaceObservation] = []
        for face in ranked {
            if kept.contains(where: { samePerson($0.box, face.box) }) { continue }
            kept.append(face)
        }
        return kept.sorted { $0.box.x + $0.box.y * 0.15 < $1.box.x + $1.box.y * 0.15 }
    }

    private static func samePerson(_ a: FaceBox, _ b: FaceBox) -> Bool {
        if iou(a, b) >= 0.28 { return true }
        let x1 = max(a.x, b.x)
        let y1 = max(a.y, b.y)
        let x2 = min(a.x + a.width, b.x + b.width)
        let y2 = min(a.y + a.height, b.y + b.height)
        let inter = max(0, x2 - x1) * max(0, y2 - y1)
        let smaller = min(a.width * a.height, b.width * b.height)
        if smaller > 1, inter / smaller >= 0.55 { return true }
        let acx = a.x + a.width / 2
        let acy = a.y + a.height / 2
        let bcx = b.x + b.width / 2
        let bcy = b.y + b.height / 2
        let diag = max(hypot(a.width, a.height), hypot(b.width, b.height))
        return hypot(acx - bcx, acy - bcy) < 0.32 * diag
    }

    static func boxesOverlap(_ a: FaceBox, _ b: FaceBox) -> Bool {
        samePerson(a, b)
    }

    static func match(
        faces: [FaceObservation],
        identities: [Identity],
        media: [MediaItem]
    ) -> [MatchResult] {
        var tracked = faces
        assignTracks(faces: &tracked, media: media)
        let models = identities.map { identity -> IdentityModel in
            let owned = tracked.filter { identity.faceIds.contains($0.id) }
            let best = owned.max { $0.quality.capture < $1.quality.capture }
            let photos = (best?.quality.capture ?? 0) >= 0.35 ? best : nil
            return IdentityModel(
                identity: identity,
                photos: photos,
                meanPrint: owned,
                meanLandmarks: averageLandmarks(owned.map(\.aligned), owned.map { 0.2 + $0.quality.frontal }),
                temporal: owned.filter { face in
                    media.first { $0.id == face.mediaId }?.kind == .frame
                },
                ratios: averageVec(owned.compactMap { measures($0.aligned).ratios }),
                shape: averageVec(owned.compactMap { measures($0.aligned).shape }),
                eyes: averageVec(owned.compactMap { measures($0.aligned).eyes }),
                midface: averageVec(owned.compactMap { measures($0.aligned).midface }),
                jaw: averageVec(owned.compactMap { measures($0.aligned).jaw }),
                appearances: owned.map(\.appearance).filter { !$0.isEmpty },
                graphs: owned.map(\.graph).filter { !$0.isEmpty },
                geom3ds: owned.map(\.geom3d).filter { !$0.isEmpty }
            )
        }

        return tracked.map { face in
            var hits: [StrategyHit] = []

            let photos = rank(models, minMargin: embedMargin) { m in
                guard face.quality.capture >= 0.35 else { return 0 }
                return bestAppearance(face.appearance, m.appearances)
            }
            hits.append(toHit(.photosStyle, face.quality.capture < 0.35
                ? Ranked(identityId: nil, percent: 0, margin: photos.margin, versus: photos.versus)
                : photos))

            let box = rank(models, minMargin: embedMargin) { m in
                bestAppearance(face.appearance, m.appearances)
            }
            hits.append(toHit(.visionBox, box))

            let geo = rank(models, minMargin: landmarkMargin) { m in
                landmarkPercent(distance(face.aligned, m.meanLandmarks))
            }
            hits.append(hint(.landmarkGeo, geo))

            let probeM = measures(face.aligned)
            hits.append(hint(.ratios, rank(models, minMargin: landmarkMargin) { m in
                measuresPercent(vecDistance(probeM.ratios, m.ratios))
            }))
            hits.append(hint(.faceShape, rank(models, minMargin: landmarkMargin) { m in
                measuresPercent(vecDistance(probeM.shape, m.shape))
            }))
            hits.append(hint(.eyeRegion, rank(models, minMargin: landmarkMargin) { m in
                measuresPercent(vecDistance(probeM.eyes, m.eyes))
            }))
            hits.append(hint(.midface, rank(models, minMargin: landmarkMargin) { m in
                measuresPercent(vecDistance(probeM.midface, m.midface))
            }))
            hits.append(hint(.jawline, rank(models, minMargin: landmarkMargin) { m in
                measuresPercent(vecDistance(probeM.jaw, m.jaw))
            }))
            hits.append(hint(.graphBio, rank(models, minMargin: landmarkMargin) { m in
                bestVecPercent(face.graph, m.graphs)
            }))
            hits.append(hint(.geom3d, rank(models, minMargin: landmarkMargin) { m in
                bestVecPercent(face.geom3d, m.geom3ds)
            }))
            hits.append(hint(.texture, rank(models, minMargin: landmarkMargin) { m in
                bestAppearance(face.appearance, m.appearances)
            }))

            let gated = rank(models, minMargin: embedMargin) { m in
                let raw = bestAppearance(face.appearance, m.appearances)
                if face.quality.capture >= 0.35 { return raw }
                return raw * (0.45 + 0.55 * (face.quality.capture / 0.35))
            }
            hits.append(toHit(.qualityGate, gated))

            let temporal = rank(models, minMargin: embedMargin) { m in
                let gallery = m.temporal.isEmpty ? m.appearances : m.temporal.map(\.appearance)
                return bestAppearance(face.appearance, gallery)
            }
            hits.append(toHit(.temporal, temporal))

            let fp = rank(models, minMargin: embedMargin) { m in
                bestPrintPercent(face.featurePrint, m.meanPrint)
            }
            hits.append(hint(.featurePrint, fp))

            func pctVs(_ s: StrategyID, _ id: UUID) -> Double {
                hits.first { $0.strategy == s }?.versus.first { $0.identityId == id }?.percent ?? 0
            }
            let lowCapture = face.quality.capture < 0.35
            func geoMixOf(_ id: UUID) -> Double {
                0.16 * pctVs(.landmarkGeo, id)
                    + 0.12 * pctVs(.ratios, id)
                    + 0.10 * pctVs(.faceShape, id)
                    + 0.14 * pctVs(.eyeRegion, id)
                    + 0.12 * pctVs(.midface, id)
                    + 0.10 * pctVs(.jawline, id)
                    + 0.14 * pctVs(.graphBio, id)
                    + 0.12 * pctVs(.geom3d, id)
            }
            let ids = models.map(\.identity.id)
            let embedRow = ids.map { id -> Double in
                if lowCapture { return max(pctVs(.qualityGate, id), pctVs(.photosStyle, id)) }
                return max(
                    pctVs(.visionBox, id),
                    pctVs(.temporal, id),
                    pctVs(.photosStyle, id),
                    pctVs(.qualityGate, id)
                )
            }
            let textureRow = ids.map { pctVs(.texture, $0) }
            let graphRow = ids.map { pctVs(.graphBio, $0) }
            let geoRow = ids.map { geoMixOf($0) }
            let geom3dRow = ids.map { pctVs(.geom3d, $0) }
            let terFused = terFusion(
                [embedRow, textureRow, graphRow, geoRow, geom3dRow],
                [0.42, 0.20, 0.14, 0.14, 0.10]
            )
            hits.append(hint(.terFusion, rank(models, minMargin: embedMargin) { m in
                let i = ids.firstIndex(of: m.identity.id) ?? 0
                return i < terFused.count ? terFused[i] : 0
            }))
            let ensemble = rank(models, minMargin: embedMargin) { m in
                let i = ids.firstIndex(of: m.identity.id) ?? 0
                return i < embedRow.count ? embedRow[i] : 0
            }
            let geoRanked = models.map { (id: $0.identity.id, p: geoMixOf($0.identity.id)) }
                .sorted { $0.p > $1.p }
            let appearanceBest = pctVs(.texture, ensemble.versus.first?.identityId ?? UUID())
            let others = ensemble.versus.dropFirst().map(\.percent)
            let decided = decide(
                percent: ensemble.percent,
                margin: ensemble.margin,
                bestId: ensemble.versus.first?.identityId,
                bestName: models.first { $0.identity.id == ensemble.versus.first?.identityId }?.identity.name,
                secondName: models.first { $0.identity.id == ensemble.versus.dropFirst().first?.identityId }?.identity.name,
                geoAgrees: geoRanked.first?.id == ensemble.versus.first?.identityId,
                geoMargin: (geoRanked.first?.p ?? 0) - (geoRanked.dropFirst().first?.p ?? 0),
                lowCapture: lowCapture,
                appearance: face.appearance.isEmpty ? nil : appearanceBest,
                geoMix: geoRanked.first?.p ?? 0,
                galleryZ: galleryZScore(ensemble.percent, Array(others))
            )
            var aegis = ensemble
            aegis.identityId = decided.id
            hits.append(toHit(.aegis, aegis, note: decided.note))
            if let owner = identities.first(where: { $0.faceIds.contains(face.id) }) {
                hits = hits.map { h in
                    let selfP = max(h.versus.first { $0.identityId == owner.id }?.percent ?? 0, 96)
                    var versus = h.versus.map { v in
                        v.identityId == owner.id ? IdentityScore(identityId: v.identityId, percent: selfP, distance: v.distance) : v
                    }
                    versus.sort { $0.percent > $1.percent }
                    let second = versus.first { $0.identityId != owner.id }?.percent ?? 0
                    return StrategyHit(
                        strategy: h.strategy,
                        identityId: owner.id,
                        percent: selfP,
                        distance: h.distance,
                        margin: selfP - second,
                        versus: versus,
                        note: "Referenz dieser Person."
                    )
                }
            }
            return MatchResult(faceId: face.id, hits: hits)
        }
    }

    // MARK: - geometry / prints

    private static let matchFloor = 84.0
    private static let soloFloor = 90.0
    private static let embedMargin = 12.0
    private static let landmarkMargin = 14.0
    private static let appearanceFloor = 70.0
    private static let zFloor = 1.5

    private struct IdentityModel {
        var identity: Identity
        var photos: FaceObservation?
        var meanPrint: [FaceObservation]
        var meanLandmarks: [Point2]
        var temporal: [FaceObservation]
        var ratios: [Double]
        var shape: [Double]
        var eyes: [Double]
        var midface: [Double]
        var jaw: [Double]
        var appearances: [[Double]]
        var graphs: [[Double]]
        var geom3ds: [[Double]]
    }

    private struct Ranked {
        var identityId: UUID?
        var percent: Double
        var margin: Double
        var versus: [IdentityScore]
    }

    private static func rank(
        _ models: [IdentityModel],
        minMargin: Double,
        scoreOf: (IdentityModel) -> Double
    ) -> Ranked {
        var versus = models.map { IdentityScore(identityId: $0.identity.id, percent: scoreOf($0)) }
        versus.sort { $0.percent > $1.percent }
        let best = versus.first
        let second = versus.dropFirst().first
        let margin = (best?.percent ?? 0) - (second?.percent ?? 0)
        let strong = (best?.percent ?? 0) >= 90 && margin >= 4
        let hasRival = second != nil
        let assign: Bool
        if hasRival {
            assign = (best?.percent ?? 0) >= matchFloor && (margin >= minMargin || strong)
        } else {
            assign = (best?.percent ?? 0) >= soloFloor && minMargin <= embedMargin
        }
        return Ranked(
            identityId: assign ? best?.identityId : nil,
            percent: best?.percent ?? 0,
            margin: margin,
            versus: versus
        )
    }

    private static func hint(_ strategy: StrategyID, _ ranked: Ranked) -> StrategyHit {
        var copy = ranked
        copy.identityId = nil
        return toHit(strategy, copy)
    }

    private static func toHit(_ strategy: StrategyID, _ ranked: Ranked, note: String = "") -> StrategyHit {
        let text: String
        if !note.isEmpty {
            text = note
        } else if ranked.identityId != nil {
            text = String(format: "Abstand %.1f Pkt.", ranked.margin)
        } else if ranked.versus.count < 2 {
            text = String(format: "Nur eine Person eingeschrieben. Nähe %.0f%% reicht nicht (braucht %.0f%%).", ranked.percent, soloFloor)
        } else if ranked.percent < matchFloor {
            text = String(format: "Beste Nähe %.0f%% liegt unter %.0f%%.", ranked.percent, matchFloor)
        } else {
            text = String(format: "Zu nah (%.1f Pkt Abstand) — nicht zugeordnet.", ranked.margin)
        }
        return StrategyHit(
            strategy: strategy,
            identityId: ranked.identityId,
            percent: ranked.percent,
            margin: ranked.margin,
            versus: ranked.versus,
            note: text
        )
    }

    private static func decide(
        percent: Double,
        margin: Double,
        bestId: UUID?,
        bestName: String?,
        secondName: String?,
        geoAgrees: Bool,
        geoMargin: Double,
        lowCapture: Bool,
        appearance: Double?,
        geoMix: Double,
        galleryZ: Double
    ) -> (id: UUID?, note: String) {
        let best = bestName ?? "Beste"
        let second = secondName ?? "Zweite"
        let appear = appearance ?? 100
        let hasAppearance = appearance != nil
        guard let bestId, percent > 0 else {
            return (nil, "Keine Vergleichsperson.")
        }
        if lowCapture {
            return (nil, String(format: "Aufnahme zu schwach für eine Zuordnung, Nähe %.0f%%.", percent))
        }
        if secondName == nil {
            if percent >= soloFloor && appear >= appearanceFloor && geoMix >= 30 {
                return (bestId, String(format: "Nur eine Person eingeschrieben. Nähe %.0f%% reicht.", percent))
            }
            return (nil, String(format: "Nur eine Person eingeschrieben. Nähe %.0f%% reicht nicht (braucht %.0f%%). Andere Gesichter bleiben offen.", percent, soloFloor))
        }
        if percent < matchFloor {
            return (nil, String(format: "Beste Nähe %.0f%% liegt unter %.0f%%. Nicht zugeordnet.", percent, matchFloor))
        }
        if galleryZ < zFloor && percent < 96 {
            return (nil, String(format: "Kein Ausreißer in der Galerie (z=%.1f). Alle Personen ähnlich nah — nicht zugeordnet.", galleryZ))
        }
        if hasAppearance && appear < appearanceFloor {
            return (nil, String(format: "Aussehen passt nicht (%.0f%%). %@ %.0f%% — nicht zugeordnet.", appear, best, percent))
        }
        if geoMix < 32 && percent < 94 {
            return (nil, String(format: "Gesichtsmaße widersprechen (%.0f%%). Nicht zugeordnet.", geoMix))
        }
        if !geoAgrees && geoMargin >= 10 && percent < 94 {
            return (nil, String(format: "Maße sehen %@ näher. Embedding allein reicht nicht.", second))
        }
        if margin >= embedMargin || (percent >= 94 && margin >= 6) {
            return (bestId, String(format: "Abstand %.1f Pkt zu %@.", margin, second))
        }
        if geoAgrees && geoMargin >= 12 && appear >= 75 {
            return (bestId, String(format: "Embedding nur %.1f Pkt Abstand, Maße trennen %.1f Pkt (%@).", margin, geoMargin, second))
        }
        return (nil, String(format: "%@ %.0f%% und %@ %.0f%% zu nah — nicht zugeordnet.", best, percent, second, percent - margin))
    }

    private static func bestPrintPercent(_ probe: Data, _ faces: [FaceObservation]) -> Double {
        var best = 0.0
        for f in faces {
            let p = printPercent(probe, f.featurePrint)
            if p > best { best = p }
        }
        return best
    }

    private static func vnToPixels(_ r: CGRect, width: Double, height: Double) -> FaceBox {
        FaceBox(
            x: r.origin.x * width,
            y: (1 - r.origin.y - r.height) * height,
            width: r.width * width,
            height: r.height * height
        )
    }

    private static func extractPoints(_ obs: VNFaceObservation?, imageWidth: Double, imageHeight: Double) -> [Point2] {
        guard let lm = obs?.landmarks else { return [] }
        let regions: [VNFaceLandmarkRegion2D?] = [
            lm.faceContour, lm.leftEyebrow, lm.rightEyebrow, lm.leftEye, lm.rightEye,
            lm.nose, lm.noseCrest, lm.medianLine, lm.outerLips, lm.innerLips,
        ]
        var pts: [Point2] = []
        for region in regions.compactMap({ $0 }) {
            for i in 0 ..< region.pointCount {
                let p = region.normalizedPoints[i]
                pts.append(Point2(x: Double(p.x) * imageWidth, y: (1 - Double(p.y)) * imageHeight))
            }
        }
        return pts
    }

    private static func procrustes(_ pts: [Point2]) -> [Point2] {
        guard pts.count >= 8 else { return pts }
        let n = pts.count
        let cx = pts.map(\.x).reduce(0, +) / Double(n)
        let cy = pts.map(\.y).reduce(0, +) / Double(n)
        var scale = 0.0
        for p in pts { scale += hypot(p.x - cx, p.y - cy) }
        scale = max(scale / Double(n), 1e-6)
        return pts.map { Point2(x: ($0.x - cx) / scale, y: ($0.y - cy) / scale) }
    }

    private static func frontalScore(_ pts: [Point2]) -> Double {
        guard pts.count >= 8 else { return 0.5 }
        let xs = pts.map(\.x)
        let minX = xs.min() ?? 0
        let maxX = xs.max() ?? 1
        let mid = (minX + maxX) / 2
        let left = pts.filter { $0.x < mid }
        let right = pts.filter { $0.x >= mid }
        let ratio = Double(min(left.count, right.count)) / Double(max(max(left.count, right.count), 1))
        return clamp01(ratio)
    }

    private static func sharpnessScore(_ image: CGImage?) -> Double {
        guard let image else { return 0 }
        let w = min(64, image.width)
        let h = min(64, image.height)
        guard let ctx = CGContext(
            data: nil,
            width: w,
            height: h,
            bitsPerComponent: 8,
            bytesPerRow: w,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return 0.5 }
        ctx.interpolationQuality = .low
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
        guard let data = ctx.data else { return 0.5 }
        let buf = data.bindMemory(to: UInt8.self, capacity: w * h)
        var sum = 0.0
        var sum2 = 0.0
        var n = 0.0
        if h > 2, w > 2 {
            for y in 1 ..< (h - 1) {
                for x in 1 ..< (w - 1) {
                    let i = y * w + x
                    let lap = -Double(buf[i - w]) - Double(buf[i - 1]) + 4 * Double(buf[i])
                        - Double(buf[i + 1]) - Double(buf[i + w])
                    sum += lap
                    sum2 += lap * lap
                    n += 1
                }
            }
        }
        let mean = sum / max(n, 1)
        let variance = max(0, sum2 / max(n, 1) - mean * mean)
        return min(1, variance / 850)
    }

    private static func crop(_ image: CGImage, box: FaceBox, pad: Double = 0.22) -> CGImage? {
        let x = max(0, box.x - box.width * pad)
        let y = max(0, box.y - box.height * pad)
        let w = min(Double(image.width) - x, box.width * (1 + pad * 2))
        let h = min(Double(image.height) - y, box.height * (1 + pad * 2))
        return image.cropping(to: CGRect(x: x, y: y, width: max(1, w), height: max(1, h)))
    }

    private static func featurePrint(of image: CGImage?) -> Data? {
        guard let image else { return nil }
        let req = VNGenerateImageFeaturePrintRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([req])
            guard let obs = req.results?.first as? VNFeaturePrintObservation else { return nil }
            return try NSKeyedArchiver.archivedData(withRootObject: obs, requiringSecureCoding: true)
        } catch {
            return nil
        }
    }

    private static func printDistance(_ a: Data, _ b: Data) -> Double {
        guard
            let oa = try? NSKeyedUnarchiver.unarchivedObject(ofClass: VNFeaturePrintObservation.self, from: a),
            let ob = try? NSKeyedUnarchiver.unarchivedObject(ofClass: VNFeaturePrintObservation.self, from: b)
        else { return 40 }
        var d: Float = 40
        try? oa.computeDistance(&d, to: ob)
        return Double(d)
    }

    private static func printPercent(_ a: Data, _ b: Data) -> Double {
        let d = printDistance(a, b)
        let t = 8.0
        let k = 0.7
        return 100.0 / (1.0 + exp(k * (d - t)))
    }

    private static func landmarkPercent(_ d: Double) -> Double {
        100.0 / (1.0 + exp(32.0 * (d - 0.10)))
    }

    private static func measuresPercent(_ d: Double) -> Double {
        100.0 / (1.0 + exp(48.0 * (d - 0.07)))
    }

    private static func appearancePercent(_ d: Double) -> Double {
        100.0 / (1.0 + exp(14.0 * (d - 0.55)))
    }

    private static func bestAppearance(_ probe: [Double], _ gallery: [[Double]]) -> Double {
        var best = 0.0
        for g in gallery {
            let p = appearancePercent(vecDistance(probe, g))
            if p > best { best = p }
        }
        return best
    }

    private static func appearanceVector(of image: CGImage?) -> [Double] {
        guard let image else { return [] }
        let size = 64
        let cells = 16
        guard let ctx = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return [] }
        ctx.interpolationQuality = .medium
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: size, height: size))
        guard let data = ctx.data else { return [] }
        let ptr = data.bindMemory(to: UInt8.self, capacity: size * size * 4)
        var sum = [Double](repeating: 0, count: cells * cells)
        var counts = [Double](repeating: 0, count: cells * cells)
        for y in 0..<size {
            let cy = min(cells - 1, y * cells / size)
            for x in 0..<size {
                let cx = min(cells - 1, x * cells / size)
                let i = (y * size + x) * 4
                let g = 0.299 * Double(ptr[i]) + 0.587 * Double(ptr[i + 1]) + 0.114 * Double(ptr[i + 2])
                let c = cy * cells + cx
                sum[c] += g
                counts[c] += 1
            }
        }
        var out = (0..<(cells * cells)).map { sum[$0] / max(1, counts[$0]) }
        let mean = out.reduce(0, +) / Double(max(out.count, 1))
        out = out.map { $0 - mean }
        let norm = sqrt(out.reduce(0) { $0 + $1 * $1 })
        let n = max(norm, 1e-9)
        return out.map { $0 / n }
    }

    private static func galleryZScore(_ best: Double, _ others: [Double]) -> Double {
        guard !others.isEmpty else { return 99 }
        let mean = others.reduce(0, +) / Double(others.count)
        let v = others.reduce(0.0) { $0 + ($1 - mean) * ($1 - mean) } / Double(others.count)
        let denom = max(sqrt(v), 6)
        return (best - mean) / denom
    }

    private static func regionCenter(
        _ region: VNFaceLandmarkRegion2D?,
        box: CGRect,
        imageWidth: Double,
        imageHeight: Double
    ) -> Point2? {
        guard let region, region.pointCount > 0 else { return nil }
        var x = 0.0
        var y = 0.0
        for i in 0 ..< region.pointCount {
            let p = region.normalizedPoints[i]
            x += Double(p.x)
            y += Double(p.y)
        }
        x /= Double(region.pointCount)
        y /= Double(region.pointCount)
        let px = (Double(box.origin.x) + x * Double(box.width)) * imageWidth
        let py = (1 - (Double(box.origin.y) + y * Double(box.height))) * imageHeight
        return Point2(x: px, y: py)
    }

    private static func warpEyes(_ image: CGImage, left: Point2, right: Point2) -> CGImage? {
        let size = 64
        guard let ctx = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        let dx = right.x - left.x
        let dy = right.y - left.y
        let dist = max(hypot(dx, dy), 1e-6)
        let s = 32 / dist
        let ang = -atan2(dy, dx)
        let cosA = cos(ang)
        let sinA = sin(ang)
        let a = s * cosA
        let b = s * sinA
        let c = -s * sinA
        let d = s * cosA
        let cx = (left.x + right.x) / 2
        let cy = (left.y + right.y) / 2
        let e = 32 - a * cx - c * cy
        let f = 24 - b * cx - d * cy
        ctx.concatenate(CGAffineTransform(a: a, b: b, c: c, d: d, tx: e, ty: f))
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return ctx.makeImage()
    }

    private static func measures(_ pts: [Point2]) -> (ratios: [Double], shape: [Double], eyes: [Double], midface: [Double], jaw: [Double]) {
        guard pts.count >= 4 else { return ([], [], [], [], []) }
        let xs = pts.map(\.x)
        let ys = pts.map(\.y)
        let minX = xs.min() ?? 0
        let maxX = xs.max() ?? 1
        let minY = ys.min() ?? 0
        let maxY = ys.max() ?? 1
        let w = max(maxX - minX, 1e-6)
        let h = max(maxY - minY, 1e-6)
        let cx = (minX + maxX) / 2
        let cy = (minY + maxY) / 2
        let top = pts.filter { $0.y < minY + h * 0.38 }
        let mid = pts.filter { $0.y >= minY + h * 0.32 && $0.y <= minY + h * 0.68 }
        let bot = pts.filter { $0.y > minY + h * 0.62 }
        let left = pts.filter { $0.x < cx }
        let right = pts.filter { $0.x >= cx }
        let topH = max((top.map(\.y).max() ?? cy) - (top.map(\.y).min() ?? minY), 1e-6)
        let botH = max((bot.map(\.y).max() ?? maxY) - (bot.map(\.y).min() ?? cy), 1e-6)
        let midH = max((mid.map(\.y).max() ?? cy) - (mid.map(\.y).min() ?? cy), 1e-6)
        let leftW = max((left.map(\.x).max() ?? cx) - (left.map(\.x).min() ?? minX), 1e-6)
        let rightW = max((right.map(\.x).max() ?? maxX) - (right.map(\.x).min() ?? cx), 1e-6)
        let topLeft = top.filter { $0.x < cx }
        let topRight = top.filter { $0.x >= cx }
        let botW = max((bot.map(\.x).max() ?? maxX) - (bot.map(\.x).min() ?? minX), 1e-6)
        let ratios = l2([
            w / h,
            topH / h,
            botH / h,
            Double(top.count) / Double(max(pts.count, 1)),
            leftW / w,
            rightW / w,
        ])
        let shape = l2([
            w,
            h,
            w / h,
            leftW / rightW,
            topH / botH,
            Double(left.count) / Double(max(right.count, 1)),
        ])
        let eyes = l2([
            topH / h,
            Double(topLeft.count) / Double(max(topRight.count, 1)),
            leftW / w,
            rightW / w,
            Double(top.count) / Double(max(pts.count, 1)),
        ])
        let midface = l2([
            midH / h,
            Double(mid.count) / Double(max(pts.count, 1)),
            w / h,
            (mid.map(\.x).max() ?? maxX) - (mid.map(\.x).min() ?? minX),
        ])
        let jaw = l2([
            botH / h,
            botW / w,
            botW / h,
            Double(bot.count) / Double(max(pts.count, 1)),
            w / h,
        ])
        return (ratios, shape, eyes, midface, jaw)
    }

    private static func l2(_ v: [Double]) -> [Double] {
        let n = sqrt(v.reduce(0) { $0 + $1 * $1 })
        guard n > 1e-9 else { return v }
        return v.map { $0 / n }
    }

    private static func averageVec(_ vecs: [[Double]]) -> [Double] {
        guard let first = vecs.first, !first.isEmpty else { return [] }
        var acc = Array(repeating: 0.0, count: first.count)
        for v in vecs {
            for i in 0 ..< min(first.count, v.count) { acc[i] += v[i] }
        }
        let n = Double(max(vecs.count, 1))
        return l2(acc.map { $0 / n })
    }

    private static func vecDistance(_ a: [Double], _ b: [Double]) -> Double {
        let n = min(a.count, b.count)
        guard n > 0 else { return 1 }
        var s = 0.0
        for i in 0 ..< n {
            let d = a[i] - b[i]
            s += d * d
        }
        return sqrt(s)
    }

    private static func averageLandmarks(_ sets: [[Point2]], _ weights: [Double]) -> [Point2] {
        guard let first = sets.first, !first.isEmpty else { return [] }
        var acc = Array(repeating: Point2(x: 0, y: 0), count: first.count)
        var wsum = 0.0
        for (i, set) in sets.enumerated() {
            let w = i < weights.count ? weights[i] : 1
            wsum += w
            for j in 0 ..< min(first.count, set.count) {
                acc[j].x += set[j].x * w
                acc[j].y += set[j].y * w
            }
        }
        if wsum > 0 {
            for j in 0 ..< acc.count {
                acc[j].x /= wsum
                acc[j].y /= wsum
            }
        }
        return acc
    }

    private static func distance(_ a: [Point2], _ b: [Point2]) -> Double {
        let n = min(a.count, b.count)
        guard n > 0 else { return 1 }
        var s = 0.0
        for i in 0 ..< n { s += hypot(a[i].x - b[i].x, a[i].y - b[i].y) }
        return s / Double(n)
    }

    private static func assignTracks(faces: inout [FaceObservation], media: [MediaItem]) {
        let mediaById = Dictionary(uniqueKeysWithValues: media.map { ($0.id, $0) })
        let grouped = Dictionary(grouping: faces.indices.filter {
            mediaById[faces[$0].mediaId]?.kind == .frame
        }) { mediaById[faces[$0].mediaId]?.parentId ?? UUID() }

        for (_, idxs) in grouped {
            let sorted = idxs.sorted {
                (mediaById[faces[$0].mediaId]?.timeSec ?? 0) < (mediaById[faces[$1].mediaId]?.timeSec ?? 0)
            }
            var tracks: [[Int]] = []
            for i in sorted {
                var best = -1
                var bestScore = 0.0
                for t in tracks.indices {
                    let last = tracks[t].last!
                    let overlap = iou(faces[i].box, faces[last].box)
                    let pp = printPercent(faces[i].featurePrint, faces[last].featurePrint)
                    var score = 0.0
                    if overlap >= 0.28 { score = overlap + pp / 400 }
                    else if overlap >= 0.12 && pp >= 78 { score = 0.32 + overlap + (pp - 78) / 200 }
                    else if pp >= 92 && overlap >= 0.05 { score = 0.28 + pp / 400 }
                    if score > bestScore { bestScore = score; best = t }
                }
                if best >= 0, bestScore >= 0.28 {
                    tracks[best].append(i)
                    faces[i].trackId = faces[tracks[best][0]].trackId
                } else {
                    let tid = UUID()
                    faces[i].trackId = tid
                    tracks.append([i])
                }
            }
        }
    }

    private static func iou(_ a: FaceBox, _ b: FaceBox) -> Double {
        let x1 = max(a.x, b.x)
        let y1 = max(a.y, b.y)
        let x2 = min(a.x + a.width, b.x + b.width)
        let y2 = min(a.y + a.height, b.y + b.height)
        let inter = max(0, x2 - x1) * max(0, y2 - y1)
        let union = a.width * a.height + b.width * b.height - inter
        return union <= 0 ? 0 : inter / union
    }

    private static func clamp01(_ n: Double) -> Double { min(1, max(0, n)) }

    private static func bestVecPercent(_ probe: [Double], _ gallery: [[Double]]) -> Double {
        guard !probe.isEmpty, !gallery.isEmpty else { return 0 }
        var best = 0.0
        for g in gallery {
            let p = measuresPercent(vecDistance(probe, g))
            if p > best { best = p }
        }
        return best
    }

    private static func shoelace(_ pts: [Point2]) -> Double {
        guard pts.count >= 3 else { return 0 }
        var a = 0.0
        for i in 0 ..< pts.count {
            let p = pts[i]
            let q = pts[(i + 1) % pts.count]
            a += p.x * q.y - q.x * p.y
        }
        return abs(a) / 2
    }

    private static func angleAt(_ a: Point2, _ b: Point2, _ c: Point2) -> Double {
        let abx = a.x - b.x, aby = a.y - b.y
        let cbx = c.x - b.x, cby = c.y - b.y
        let den = max(hypot(abx, aby) * hypot(cbx, cby), 1e-9)
        let cos = min(1, max(-1, (abx * cbx + aby * cby) / den))
        return acos(cos)
    }

    private static func geom3dFeatures(_ pts: [Point2]) -> [Double] {
        guard pts.count >= 8 else { return [] }
        let xs = pts.map(\.x)
        let ys = pts.map(\.y)
        let minX = xs.min() ?? 0
        let maxX = xs.max() ?? 1
        let minY = ys.min() ?? 0
        let maxY = ys.max() ?? 1
        let w = max(maxX - minX, 1e-6)
        let h = max(maxY - minY, 1e-6)
        let cx = (minX + maxX) / 2
        let cy = (minY + maxY) / 2
        let top = pts.filter { $0.y < minY + h * 0.38 }
        let mid = pts.filter { $0.y >= minY + h * 0.32 && $0.y <= minY + h * 0.68 }
        let bot = pts.filter { $0.y > minY + h * 0.62 }
        let left = pts.filter { $0.x < cx }
        let right = pts.filter { $0.x >= cx }
        let leftTip = pts.min(by: { $0.x < $1.x }) ?? pts[0]
        let rightTip = pts.max(by: { $0.x < $1.x }) ?? pts[0]
        let chin = pts.max(by: { $0.y < $1.y }) ?? pts[0]
        let crown = pts.min(by: { $0.y < $1.y }) ?? pts[0]
        let topH = max((top.map(\.y).max() ?? cy) - (top.map(\.y).min() ?? minY), 1e-6)
        let botH = max((bot.map(\.y).max() ?? maxY) - (bot.map(\.y).min() ?? cy), 1e-6)
        let midW = max((mid.map(\.x).max() ?? maxX) - (mid.map(\.x).min() ?? minX), 1e-6)
        if pts.count >= 68 {
            func P(_ i: Int) -> Point2 { pts[i] }
            func d(_ i: Int, _ j: Int) -> Double { hypot(P(i).x - P(j).x, P(i).y - P(j).y) }
            let faceH = max(abs(P(8).y - P(27).y), 1e-6)
            let leftEye = Array(pts[36 ..< 42])
            let rightEye = Array(pts[42 ..< 48])
            let mouth = Array(pts[48 ..< min(60, pts.count)])
            let eyeL = Point2(
                x: leftEye.map(\.x).reduce(0, +) / Double(leftEye.count),
                y: leftEye.map(\.y).reduce(0, +) / Double(leftEye.count)
            )
            let eyeR = Point2(
                x: rightEye.map(\.x).reduce(0, +) / Double(rightEye.count),
                y: rightEye.map(\.y).reduce(0, +) / Double(rightEye.count)
            )
            let mouthC = Point2(
                x: mouth.map(\.x).reduce(0, +) / Double(max(mouth.count, 1)),
                y: mouth.map(\.y).reduce(0, +) / Double(max(mouth.count, 1))
            )
            func u(_ x: Double) -> Double { x / faceH }
            return l2([
                u(d(36, 39)),
                u((d(37, 41) + d(38, 40)) / 2),
                u(sqrt(shoelace(leftEye))),
                u(d(42, 45)),
                u((d(43, 47) + d(44, 46)) / 2),
                u(sqrt(shoelace(rightEye))),
                u(d(48, 54)),
                u(d(51, 57)),
                u(sqrt(shoelace(mouth))),
                u(d(31, 35)),
                u(sqrt(shoelace([P(27), P(31), P(35)]))),
                u(d(4, 12)),
                1,
                angleAt(P(0), P(8), P(16)),
                u(hypot(eyeR.x - eyeL.x, eyeR.y - eyeL.y)),
                u(abs(eyeL.y - mouthC.y)),
                d(4, 12) / faceH,
            ])
        }
        return l2([
            w / h,
            topH / h,
            botH / h,
            midW / w,
            Double(top.count) / Double(pts.count),
            Double(bot.count) / Double(pts.count),
            Double(left.count) / Double(max(right.count, 1)),
            angleAt(leftTip, chin, rightTip),
            hypot(crown.x - chin.x, crown.y - chin.y) / h,
            shoelace([leftTip, crown, rightTip, chin]) / (w * h),
            (left.reduce(0.0) { $0 + abs($1.x - cx) } / Double(max(left.count, 1))) / w,
            (right.reduce(0.0) { $0 + abs($1.x - cx) } / Double(max(right.count, 1))) / w,
            abs(topH - botH) / h,
            cy / h,
            cx / w,
        ])
    }

    private static func graphBiomarkers(_ pts: [Point2]) -> [Double] {
        let n = pts.count
        guard n >= 8 else { return [] }
        var dist = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        var maxd = 1e-9
        for i in 0 ..< n {
            for j in (i + 1) ..< n {
                let d = hypot(pts[i].x - pts[j].x, pts[i].y - pts[j].y)
                dist[i][j] = d
                dist[j][i] = d
                if d > maxd { maxd = d }
            }
        }
        let k = min(6, n - 1)
        var A = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        for i in 0 ..< n {
            let order = (0 ..< n).filter { $0 != i }.sorted { dist[i][$0] < dist[i][$1] }
            for t in 0 ..< k {
                let j = order[t]
                let w = dist[i][j] / maxd
                if w > A[i][j] {
                    A[i][j] = w
                    A[j][i] = w
                }
            }
        }
        let deg = A.map { $0.reduce(0, +) }
        var L = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        var Q = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        for i in 0 ..< n {
            for j in 0 ..< n {
                L[i][j] = (i == j ? deg[i] : 0) - A[i][j]
                Q[i][j] = (i == j ? deg[i] : 0) + A[i][j]
            }
        }
        let W = deg.reduce(0, +) / 2
        let shift = (2 * W) / Double(n)
        func absSum(_ eigs: [Double], off: Double = 0) -> Double {
            eigs.reduce(0) { $0 + abs($1 - off) }
        }
        let GE = absSum(jacobiEigs(A))
        let LE = absSum(jacobiEigs(L), off: shift)
        let SLE = absSum(jacobiEigs(Q), off: shift)
        let inf = 1e9
        var D = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        for i in 0 ..< n {
            for j in 0 ..< n {
                D[i][j] = i == j ? 0 : (A[i][j] > 0 ? A[i][j] : inf)
            }
        }
        for kk in 0 ..< n {
            for i in 0 ..< n {
                for j in 0 ..< n {
                    let v = D[i][kk] + D[kk][j]
                    if v < D[i][j] { D[i][j] = v }
                }
            }
        }
        for i in 0 ..< n {
            for j in 0 ..< n where D[i][j] >= inf / 2 {
                D[i][j] = 0
            }
        }
        let DistE = absSum(jacobiEigs(D))
        var M = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        for i in 0 ..< n {
            for j in 0 ..< n {
                M[i][j] = (i == j || A[i][j] > 0) ? 1 : 0
            }
        }
        let DE = absSum(jacobiEigs(M))
        return l2([GE, LE, DE, DistE, SLE])
    }

    private static func jacobiEigs(_ src: [[Double]]) -> [Double] {
        let n = src.count
        var a = src.map { $0 }
        for _ in 0 ..< 14 {
            var off = 0.0
            for i in 0 ..< n {
                for j in (i + 1) ..< n { off += a[i][j] * a[i][j] }
            }
            if off < 1e-10 { break }
            for p in 0 ..< n {
                for q in (p + 1) ..< n {
                    let apq = a[p][q]
                    if abs(apq) < 1e-12 { continue }
                    let app = a[p][p]
                    let aqq = a[q][q]
                    let tau = (aqq - app) / (2 * apq)
                    let t = (tau >= 0 ? 1.0 : -1.0) / (abs(tau) + sqrt(1 + tau * tau))
                    let c = 1 / sqrt(1 + t * t)
                    let s = t * c
                    a[p][p] = app - t * apq
                    a[q][q] = aqq + t * apq
                    a[p][q] = 0
                    a[q][p] = 0
                    for k in 0 ..< n where k != p && k != q {
                        let akp = a[k][p]
                        let akq = a[k][q]
                        a[k][p] = c * akp - s * akq
                        a[p][k] = a[k][p]
                        a[k][q] = s * akp + c * akq
                        a[q][k] = a[k][q]
                    }
                }
            }
        }
        return (0 ..< n).map { a[$0][$0] }
    }

    private static func pairTer(_ percent: Double) -> Double {
        let s = clamp01(percent / 100)
        return clamp01(1 / (1 + exp(10 * (s - 0.48))))
    }

    private static func terToProb(_ ter: Double) -> Double {
        1 / (1 + exp(6 * (clamp01(ter) - 0.5)))
    }

    private static func minMaxNorm(_ values: [Double]) -> [Double] {
        guard !values.isEmpty else { return [] }
        let lo = values.min() ?? 0
        let hi = values.max() ?? 0
        let span = max(hi - lo, 1e-6)
        return values.map { ($0 - lo) / span }
    }

    private static func terFusion(_ matchers: [[Double]], _ weights: [Double]) -> [Double] {
        guard let first = matchers.first, !first.isEmpty else { return [] }
        let n = first.count
        let P: [[Double]] = matchers.map { row in
            guard row.count == n else { return Array(repeating: 0.0, count: n) }
            let scaled = n == 1 ? row.map { clamp01($0 / 100) } : minMaxNorm(row)
            return scaled.map { terToProb(pairTer($0 * 100)) }
        }
        var alpha = P.enumerated().map { j, row -> Double in
            (row.max() ?? 0) * (j < weights.count ? max(0, weights[j]) : 1)
        }
        let asum = max(alpha.reduce(0, +), 1e-9)
        alpha = alpha.map { $0 / asum }
        var fused = Array(repeating: 0.0, count: n)
        for i in 0 ..< n {
            for j in 0 ..< P.count {
                fused[i] += alpha[j] * P[j][i]
            }
        }
        return fused.map { $0 * 100 }
    }
}
