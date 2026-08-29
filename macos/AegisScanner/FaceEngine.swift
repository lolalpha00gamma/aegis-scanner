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
            let printData = featurePrint(of: crop(image, box: vnToPixels(face.boundingBox, width: w, height: h), pad: 0.18)) ?? Data()

            out.append(
                FaceObservation(
                    id: UUID(),
                    mediaId: mediaId,
                    box: box,
                    score: Double(face.confidence),
                    landmarks: points,
                    aligned: aligned,
                    featurePrint: printData,
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
                shape: averageVec(owned.compactMap { measures($0.aligned).shape })
            )
        }

        var trackPrint: [UUID: Data] = [:]
        let groups = Dictionary(grouping: tracked.compactMap { f -> (UUID, FaceObservation)? in
            guard let t = f.trackId else { return nil }
            return (t, f)
        }, by: { $0.0 })
        for (tid, pairs) in groups {
            trackPrint[tid] = averagePrint(pairs.map(\.1))
        }

        return tracked.map { face in
            var hits: [StrategyHit] = []

            let photos = rank(models, minMargin: embedMargin) { m in
                guard face.quality.capture >= 0.35, let g = m.photos else { return 0 }
                return printPercent(face.featurePrint, g.featurePrint)
            }
            hits.append(toHit(.photosStyle, face.quality.capture < 0.35
                ? Ranked(identityId: nil, percent: 0, margin: photos.margin, versus: photos.versus)
                : photos))

            let box = rank(models, minMargin: embedMargin) { m in
                guard let g = m.meanPrint.first ?? m.photos else { return 0 }
                return printPercent(face.featurePrint, g.featurePrint)
            }
            hits.append(toHit(.visionBox, box))

            let geo = rank(models, minMargin: landmarkMargin) { m in
                landmarkPercent(distance(face.aligned, m.meanLandmarks))
            }
            hits.append(toHit(.landmarkGeo, geo))

            let probeM = measures(face.aligned)
            let ratioHit = rank(models, minMargin: landmarkMargin) { m in
                measuresPercent(vecDistance(probeM.ratios, m.ratios))
            }
            hits.append(toHit(.ratios, ratioHit))
            let shapeHit = rank(models, minMargin: landmarkMargin) { m in
                measuresPercent(vecDistance(probeM.shape, m.shape))
            }
            hits.append(toHit(.faceShape, shapeHit))

            let gated = rank(models, minMargin: embedMargin) { m in
                guard let g = m.meanPrint.first ?? m.photos else { return 0 }
                let raw = printPercent(face.featurePrint, g.featurePrint)
                if face.quality.capture >= 0.35 { return raw }
                return raw * (0.45 + 0.55 * (face.quality.capture / 0.35))
            }
            hits.append(toHit(.qualityGate, gated))

            let temporal = rank(models, minMargin: embedMargin) { m in
                let probe = face.trackId.flatMap { trackPrint[$0] } ?? face.featurePrint
                let gallery = averagePrint(m.temporal.isEmpty ? m.meanPrint : m.temporal)
                return printPercent(probe, gallery)
            }
            hits.append(toHit(.temporal, temporal))

            let fp = rank(models, minMargin: embedMargin) { m in
                printPercent(face.featurePrint, averagePrint(m.meanPrint))
            }
            hits.append(toHit(.featurePrint, fp))

            func pctVs(_ s: StrategyID, _ id: UUID) -> Double {
                hits.first { $0.strategy == s }?.versus.first { $0.identityId == id }?.percent ?? 0
            }
            let tdesc = face.trackId.flatMap { trackPrint[$0] }
            let lowCapture = face.quality.capture < 0.35
            let ensemble = rank(models, minMargin: embedMargin) { m in
                let id = m.identity.id
                let embed: Double
                if lowCapture {
                    embed = max(pctVs(.qualityGate, id), pctVs(.photosStyle, id))
                } else {
                    embed = max(
                        pctVs(.featurePrint, id),
                        pctVs(.visionBox, id),
                        pctVs(.temporal, id),
                        pctVs(.photosStyle, id),
                        pctVs(.qualityGate, id)
                    )
                }
                let tP = pctVs(.temporal, id)
                let geoMix = 0.4 * pctVs(.landmarkGeo, id) + 0.35 * pctVs(.ratios, id) + 0.25 * pctVs(.faceShape, id)
                if lowCapture { return min(99.6, embed) }
                let trackBoost = tdesc != nil && tP > embed ? (tP - embed) * 0.35 : 0
                let agree = geoMix >= 70 && embed >= matchFloor ? 2.2 : 0
                let disagree = embed >= matchFloor && geoMix < 45 ? 3.0 : 0
                return min(99.6, 0.72 * embed + 0.28 * geoMix + trackBoost + agree - disagree)
            }
            hits.append(toHit(.aegis, ensemble))
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
                        versus: versus
                    )
                }
            }
            return MatchResult(faceId: face.id, hits: hits)
        }
    }

    // MARK: - geometry / prints

    private static let matchFloor = 72.0
    private static let embedMargin = 8.0
    private static let landmarkMargin = 10.0

    private struct IdentityModel {
        var identity: Identity
        var photos: FaceObservation?
        var meanPrint: [FaceObservation]
        var meanLandmarks: [Point2]
        var temporal: [FaceObservation]
        var ratios: [Double]
        var shape: [Double]
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
        let assign = (best?.percent ?? 0) >= matchFloor && (margin >= minMargin || strong)
        return Ranked(
            identityId: assign ? best?.identityId : nil,
            percent: best?.percent ?? 0,
            margin: margin,
            versus: versus
        )
    }

    private static func toHit(_ strategy: StrategyID, _ ranked: Ranked) -> StrategyHit {
        StrategyHit(
            strategy: strategy,
            identityId: ranked.identityId,
            percent: ranked.percent,
            margin: ranked.margin,
            versus: ranked.versus
        )
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
        let t = 11.0
        let k = 0.45
        return 100.0 / (1.0 + exp(k * (d - t)))
    }

    private static func landmarkPercent(_ d: Double) -> Double {
        100.0 / (1.0 + exp(28.0 * (d - 0.11)))
    }

    private static func measuresPercent(_ d: Double) -> Double {
        100.0 / (1.0 + exp(42.0 * (d - 0.085)))
    }

    private static func measures(_ pts: [Point2]) -> (ratios: [Double], shape: [Double]) {
        guard pts.count >= 4 else { return ([], []) }
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
        let top = pts.filter { $0.y < cy }
        let bot = pts.filter { $0.y >= cy }
        let left = pts.filter { $0.x < cx }
        let right = pts.filter { $0.x >= cx }
        let topH = max((top.map(\.y).max() ?? cy) - (top.map(\.y).min() ?? minY), 1e-6)
        let botH = max((bot.map(\.y).max() ?? maxY) - (bot.map(\.y).min() ?? cy), 1e-6)
        let leftW = max((left.map(\.x).max() ?? cx) - (left.map(\.x).min() ?? minX), 1e-6)
        let rightW = max((right.map(\.x).max() ?? maxX) - (right.map(\.x).min() ?? cx), 1e-6)
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
        return (ratios, shape)
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

    private static func averagePrint(_ faces: [FaceObservation]) -> Data {
        faces.max { $0.quality.capture < $1.quality.capture }?.featurePrint ?? Data()
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
                var bestIou = 0.28
                for t in tracks.indices {
                    let last = tracks[t].last!
                    let v = iou(faces[i].box, faces[last].box)
                    if v > bestIou { bestIou = v; best = t }
                }
                if best >= 0 {
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
}
