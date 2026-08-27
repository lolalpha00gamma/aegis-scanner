import CoreGraphics
import Foundation
import Vision

enum FaceEngine {
    static func detect(in image: CGImage, mediaId: UUID) throws -> [FaceObservation] {
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

        for face in observations {
            let box = vnToPixels(face.boundingBox, width: w, height: h)
            let lm = landmarks.first { $0.uuid == face.uuid } ?? landmarks.first {
                hypot($0.boundingBox.midX - face.boundingBox.midX, $0.boundingBox.midY - face.boundingBox.midY) < 0.04
            }
            let points = extractPoints(lm, imageWidth: w, imageHeight: h)
            let aligned = procrustes(points)
            let captureApple = Double(
                (qualities.first { $0.uuid == face.uuid }?.faceCaptureQuality ??
                    qualities.first?.faceCaptureQuality ?? 0.5)
            )
            let frontal = frontalScore(points)
            let size = min(1, (box.width * box.height) / max(1, w * h) / 0.12)
            let sharpness = sharpnessScore(crop(image, box: box))
            let capture = clamp01(0.40 * captureApple + 0.22 * sharpness + 0.18 * size + 0.20 * frontal)
            let printData = featurePrint(of: crop(image, box: box, pad: 0.18)) ?? Data()

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
                }
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
            let ensemble = rank(models, minMargin: embedMargin) { m in
                let id = m.identity.id
                let embed = max(
                    pctVs(.featurePrint, id),
                    pctVs(.visionBox, id),
                    pctVs(.temporal, id),
                    pctVs(.photosStyle, id),
                    pctVs(.qualityGate, id)
                )
                let tP = pctVs(.temporal, id)
                let geoP = pctVs(.landmarkGeo, id)
                let trackBoost = tdesc != nil && tP > embed ? (tP - embed) * 0.4 : 0
                let geoBonus = box.identityId == id && geoP >= 70 ? 1.5 : 0
                return min(99.6, embed + trackBoost + geoBonus)
            }
            hits.append(toHit(.aegis, ensemble))
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
        let assign = (best?.percent ?? 0) >= matchFloor && margin >= minMargin
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
