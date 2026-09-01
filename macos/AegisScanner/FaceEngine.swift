import CoreGraphics
import Foundation
import Vision

enum FaceEngine {
    static func detect(in image: CGImage, mediaId: UUID, tiles: Bool = true) throws -> [FaceObservation] {
        let w = Double(image.width)
        let h = Double(image.height)
        var out = try detectOnce(in: image, mediaId: mediaId, originX: 0, originY: 0, imageWidth: w, imageHeight: h)
        let stats = lumaStats(image)
        if stats.dark || out.isEmpty, let lifted = equalize(image) {
            let extra = try detectOnce(
                in: lifted,
                mediaId: mediaId,
                originX: 0,
                originY: 0,
                imageWidth: w,
                imageHeight: h,
                minConfidence: out.isEmpty ? 0.12 : 0.15
            )
            if stats.dark {
                out = extra + out
            } else {
                out.append(contentsOf: extra)
            }
            out = nms(out)
        }
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
                let source = stats.dark ? (equalize(tile) ?? tile) : tile
                let found = try detectOnce(
                    in: source,
                    mediaId: mediaId,
                    originX: Double(ox),
                    originY: Double(oy),
                    imageWidth: w,
                    imageHeight: h,
                    minConfidence: stats.dark ? 0.12 : 0.15
                )
                out.append(contentsOf: found)
            }
            out = nms(out)
        }
        return stampPrints(nms(out), from: image)
    }

    private static func detectOnce(
        in image: CGImage,
        mediaId: UUID,
        originX: Double,
        originY: Double,
        imageWidth: Double,
        imageHeight: Double,
        minConfidence: Float = 0.15
    ) throws -> [FaceObservation] {
        let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
        let facesReq = VNDetectFaceRectanglesRequest()
        facesReq.revision = VNDetectFaceRectanglesRequestRevision3
        try handler.perform([facesReq])
        let observations = facesReq.results ?? []
        let landReq = VNDetectFaceLandmarksRequest()
        let qualityReq = VNDetectFaceCaptureQualityRequest()
        if !observations.isEmpty {
            landReq.inputFaceObservations = observations
            qualityReq.inputFaceObservations = observations
        }
        try handler.perform([landReq, qualityReq])
        let landmarks = landReq.results ?? []
        let qualities = qualityReq.results ?? []
        var out: [FaceObservation] = []
        let w = Double(image.width)
        let h = Double(image.height)

        for face in observations where face.confidence >= minConfidence {
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
            var strokes = extractStrokes(lm, imageWidth: w, imageHeight: h)

            if originX != 0 || originY != 0 {
                strokes = strokes.map { stroke in
                    LandmarkStroke(
                        label: stroke.label,
                        closed: stroke.closed,
                        points: stroke.points.map { Point2(x: $0.x + originX, y: $0.y + originY) }
                    )
                }
            }
            var points = strokes.flatMap(\.points)
            if points.isEmpty {
                points = extractPoints(lm, imageWidth: w, imageHeight: h)
                if originX != 0 || originY != 0 {
                    points = points.map { Point2(x: $0.x + originX, y: $0.y + originY) }
                }
            }
            let hair = hairline(from: points)
            let chin = points.max { $0.y < $1.y }
            let left = points.min { $0.x < $1.x }
            let right = points.max { $0.x < $1.x }
            if let hair, let browL = strokes.first(where: { $0.label == "Braue L" })?.points.first,
               let browR = strokes.first(where: { $0.label == "Braue R" })?.points.last {
                strokes.append(LandmarkStroke(label: "Haaransatz", closed: false, points: [browL, hair, browR]))
            }
            if let left {
                let tick = Point2(x: left.x - max(8, box.width * 0.06), y: left.y)
                strokes.append(LandmarkStroke(label: "Ohr L", closed: false, points: [left, tick]))
            }
            if let right {
                let tick = Point2(x: right.x + max(8, box.width * 0.06), y: right.y)
                strokes.append(LandmarkStroke(label: "Ohr R", closed: false, points: [right, tick]))
            }
            if let chin {
                let tick = Point2(x: chin.x, y: chin.y + max(8, box.height * 0.05))
                strokes.append(LandmarkStroke(label: "Kinn", closed: false, points: [chin, tick]))
            }
            if let nose = strokes.first(where: { $0.label == "Nase" }), nose.points.count >= 2 {
                let nLeft = nose.points.min { $0.x < $1.x }!
                let nRight = nose.points.max { $0.x < $1.x }!
                strokes.append(LandmarkStroke(label: "Nasenbreite", closed: false, points: [nLeft, nRight]))
            }
            if let mouth = strokes.first(where: { $0.label == "Mund" }), mouth.points.count >= 2 {
                let mLeft = mouth.points.min { $0.x < $1.x }!
                let mRight = mouth.points.max { $0.x < $1.x }!
                strokes.append(LandmarkStroke(label: "Mundbreite", closed: false, points: [mLeft, mRight]))
            }
            let frame = namedFromStrokes(strokes)
            let aligned = procrustes(points, left: frame?.leftEye, right: frame?.rightEye)
            let namedImg = frame.map(namedList) ?? []
            let namedAligned = procrustes(namedImg, left: frame?.leftEye, right: frame?.rightEye)
            let sheet = frame.map(ratioSheet) ?? []
            let captureApple = Double(
                qualities.first { $0.uuid == face.uuid }?.faceCaptureQuality ?? 0.5
            )
            let frontal = frame.map(frontalScore) ?? frontalScore(points)
            let size = min(1, (box.width * box.height) / max(1, imageWidth * imageHeight) / 0.12)
            let faceCrop = crop(image, box: vnToPixels(face.boundingBox, width: w, height: h))
            let sharpness = sharpnessScore(faceCrop)
            let structure = sharpnessScore(equalize(faceCrop) ?? faceCrop)
            let edge = max(structure, sharpness * 0.4)
            let capture = clamp01(
                0.16 * captureApple + 0.30 * edge + 0.22 * size + 0.24 * frontal + 0.08 * (edge > 0.12 ? 1 : 0.45)
            )
            let inner = crop(image, box: vnToPixels(face.boundingBox, width: w, height: h), pad: 0.04)
            let leftEyeFull = frame?.leftEye ?? regionCenter(lm?.landmarks?.leftEye, box: face.boundingBox, imageWidth: w, imageHeight: h)
            let rightEyeFull = frame?.rightEye ?? regionCenter(lm?.landmarks?.rightEye, box: face.boundingBox, imageWidth: w, imageHeight: h)
            // Tile-local eyes: overlay points were shifted by origin, the CGImage is the tile.
            let leftEye = leftEyeFull.map { Point2(x: $0.x - originX, y: $0.y - originY) }
            let rightEye = rightEyeFull.map { Point2(x: $0.x - originX, y: $0.y - originY) }
            let appearance: [Double]
            if let leftEye, let rightEye, let warped = warpEyes(image, left: leftEye, right: rightEye, size: 128) {
                appearance = appearanceVector(of: warped)
            } else {
                appearance = appearanceVector(of: inner)
            }
            let printData = Data()
            let bone = boneKeypoints(namedAligned)
            let yaw = face.yaw?.doubleValue ?? 0
            let pitch = face.pitch?.doubleValue ?? 0

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
                    graph: graphBiomarkers(bone.isEmpty ? points : bone),
                    geom3d: geom3dFromNamed(namedAligned),
                    quality: FaceQuality(
                        sharpness: sharpness,
                        size: size,
                        frontal: frontal,
                        capture: capture,
                        yaw: yaw,
                        pitch: pitch
                    ),
                    trackId: nil,
                    strokes: strokes,
                    namedAligned: namedAligned,
                    ratioSheet: sheet
                )
            )
        }
        return out
    }

    private static func nms(_ faces: [FaceObservation], iouThresh: Double = 0.28) -> [FaceObservation] {
        let ranked = faces.sorted { $0.score > $1.score }
        var kept: [FaceObservation] = []
        for face in ranked {
            if kept.contains(where: { duplicateDetection($0.box, face.box) }) { continue }
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

    /// High-IoU / nested twin of the same detection. Two people standing
    /// together overlap a bit — that is not a duplicate.
    private static func duplicateDetection(_ a: FaceBox, _ b: FaceBox) -> Bool {
        if iou(a, b) >= 0.42 { return true }
        let x1 = max(a.x, b.x)
        let y1 = max(a.y, b.y)
        let x2 = min(a.x + a.width, b.x + b.width)
        let y2 = min(a.y + a.height, b.y + b.height)
        let inter = max(0, x2 - x1) * max(0, y2 - y1)
        let smaller = min(a.width * a.height, b.width * b.height)
        return smaller > 1 && inter / smaller >= 0.7
    }

    static func boxesOverlap(_ a: FaceBox, _ b: FaceBox) -> Bool {
        samePerson(a, b)
    }

    /// Same face id, or overlapping boxes on the same photo. Never across photos —
    /// two portraits share similar pixel coords and used to swallow person 3 into person 2.
    static func identityOwning(face: FaceObservation, identities: [Identity], faces: [FaceObservation]) -> Identity? {
        for identity in identities {
            for fid in identity.faceIds {
                if fid == face.id { return identity }
                guard let owned = faces.first(where: { $0.id == fid }) else { continue }
                if owned.mediaId == face.mediaId, duplicateDetection(owned.box, face.box) {
                    return identity
                }
            }
        }
        return nil
    }

    static func unnamedFace(on mediaId: UUID, faces: [FaceObservation], identities: [Identity]) -> FaceObservation? {
        let enrolled = Set(identities.flatMap(\.faceIds))
        let owned = faces.filter { $0.mediaId == mediaId && enrolled.contains($0.id) }
        return faces
            .filter { face in
                face.mediaId == mediaId
                    && !enrolled.contains(face.id)
                    && !owned.contains { duplicateDetection($0.box, face.box) }
            }
            .sorted { $0.box.x + $0.box.y * 0.15 < $1.box.x + $1.box.y * 0.15 }
            .first
    }

    /// Face that Anlegen must enroll. Never an already-named person, never a silent + reference.
    static func faceForNewIdentity(
        selected: FaceObservation?,
        visibleMediaId: UUID?,
        faces: [FaceObservation],
        identities: [Identity]
    ) -> FaceObservation? {
        if let selected, identityOwning(face: selected, identities: identities, faces: faces) == nil {
            return selected
        }
        if let visibleMediaId, let next = unnamedFace(on: visibleMediaId, faces: faces, identities: identities) {
            return next
        }
        if let selected {
            return unnamedFace(on: selected.mediaId, faces: faces, identities: identities)
        }
        return nil
    }

    static func match(
        faces: [FaceObservation],
        identities: [Identity],
        media: [MediaItem],
        threshold: Double = 78
    ) -> [MatchResult] {
        matchFloor = min(96, max(70, threshold))
        soloFloor = min(96, matchFloor + 4)
        var tracked = faces
        assignTracks(faces: &tracked, media: media)
        let models = identities.map { identity -> IdentityModel in
            let owned = tracked.filter { identity.faceIds.contains($0.id) }
            let best = owned.max { $0.quality.capture < $1.quality.capture }
            let photos = (best?.quality.capture ?? 0) >= 0.35 ? best : nil
            let namedSets = owned.map { $0.namedAligned.isEmpty ? $0.aligned : $0.namedAligned }
            return IdentityModel(
                identity: identity,
                photos: photos,
                meanPrint: owned,
                landmarkSets: namedSets.filter { !$0.isEmpty },
                temporal: owned.filter { face in
                    media.first { $0.id == face.mediaId }?.kind == .frame
                },
                ratios: owned.compactMap { let r = measures($0).ratios; return r.isEmpty ? nil : r },
                shape: owned.compactMap { let r = measures($0).shape; return r.isEmpty ? nil : r },
                eyes: owned.compactMap { let r = measures($0).eyes; return r.isEmpty ? nil : r },
                midface: owned.compactMap { let r = measures($0).midface; return r.isEmpty ? nil : r },
                jaw: owned.compactMap { let r = measures($0).jaw; return r.isEmpty ? nil : r },
                appearances: owned.map(\.appearance).filter { !$0.isEmpty },
                graphs: owned.map(\.graph).filter { !$0.isEmpty },
                geom3ds: owned.map(\.geom3d).filter { !$0.isEmpty }
            )
        }

        return tracked.map { face in
            var hits: [StrategyHit] = []

            let photos = rank(models, minMargin: embedMargin) { m in
                guard face.quality.capture >= 0.35 else { return 0 }
                return bestPrintPercent(face.featurePrint, m.meanPrint)
            }
            hits.append(toHit(.photosStyle, face.quality.capture < 0.35
                ? Ranked(identityId: nil, percent: 0, margin: photos.margin, versus: photos.versus)
                : photos))

            let box = rank(models, minMargin: embedMargin) { m in
                bestPrintPercent(face.featurePrint, m.meanPrint)
            }
            hits.append(toHit(.visionBox, box))

            let geoPts = face.namedAligned.isEmpty ? face.aligned : face.namedAligned
            let geo = rank(models, minMargin: landmarkMargin) { m in
                bestLandmarkPercent(geoPts, m.landmarkSets)
            }
            hits.append(hint(.landmarkGeo, geo))

            let probeM = measures(face)
            hits.append(hint(.ratios, rank(models, minMargin: landmarkMargin) { m in
                bestRatioPercent(probeM.ratios, m.ratios)
            }))
            hits.append(hint(.faceShape, rank(models, minMargin: landmarkMargin) { m in
                bestRatioPercent(probeM.shape, m.shape)
            }))
            hits.append(hint(.eyeRegion, rank(models, minMargin: landmarkMargin) { m in
                bestRatioPercent(probeM.eyes, m.eyes)
            }))
            hits.append(hint(.midface, rank(models, minMargin: landmarkMargin) { m in
                bestRatioPercent(probeM.midface, m.midface)
            }))
            hits.append(hint(.jawline, rank(models, minMargin: landmarkMargin) { m in
                bestRatioPercent(probeM.jaw, m.jaw)
            }))
            hits.append(hint(.graphBio, rank(models, minMargin: landmarkMargin) { m in
                bestVecPercent(face.graph, m.graphs)
            }))
            hits.append(hint(.geom3d, rank(models, minMargin: landmarkMargin) { m in
                bestRatioPercent(face.geom3d, m.geom3ds)
            }))
            hits.append(hint(.texture, rank(models, minMargin: landmarkMargin) { m in
                bestAppearance(face.appearance, m.appearances)
            }))

            let gated = rank(models, minMargin: embedMargin) { m in
                let raw = bestPrintPercent(face.featurePrint, m.meanPrint)
                if tinyUnreliable(face.quality) {
                    return raw * (0.45 + 0.55 * (face.quality.capture / 0.35))
                }
                return raw
            }
            hits.append(toHit(.qualityGate, gated))

            let temporal = rank(models, minMargin: embedMargin) { m in
                let gallery = m.temporal.isEmpty ? m.meanPrint : m.temporal
                return bestPrintPercent(face.featurePrint, gallery)
            }
            hits.append(toHit(.temporal, temporal))

            let fp = rank(models, minMargin: embedMargin) { m in
                bestPrintPercent(face.featurePrint, m.meanPrint)
            }
            hits.append(toHit(.featurePrint, fp))

            func pctVs(_ s: StrategyID, _ id: UUID) -> Double {
                hits.first { $0.strategy == s }?.versus.first { $0.identityId == id }?.percent ?? 0
            }
            let lowCapture = tinyUnreliable(face.quality)
            func geoMixOf(_ id: UUID) -> Double {
                0.20 * pctVs(.ratios, id)
                    + 0.16 * pctVs(.faceShape, id)
                    + 0.14 * pctVs(.midface, id)
                    + 0.14 * pctVs(.eyeRegion, id)
                    + 0.12 * pctVs(.landmarkGeo, id)
                    + 0.12 * pctVs(.jawline, id)
                    + 0.08 * pctVs(.graphBio, id)
                    + 0.04 * pctVs(.geom3d, id)
            }
            func lookOfId(_ id: UUID) -> Double {
                let embed: Double = {
                    if lowCapture { return max(pctVs(.qualityGate, id), pctVs(.featurePrint, id)) }
                    return max(
                        pctVs(.featurePrint, id),
                        pctVs(.visionBox, id),
                        pctVs(.temporal, id),
                        pctVs(.photosStyle, id),
                        pctVs(.qualityGate, id)
                    )
                }()
                return lookOf(geo: geoMixOf(id), embed: embed, pose: poseWeight(face.quality))
            }
            let ids = models.map(\.identity.id)
            let embedRow = ids.map { id -> Double in
                if lowCapture { return max(pctVs(.qualityGate, id), pctVs(.featurePrint, id)) }
                return max(
                    pctVs(.featurePrint, id),
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
            let lookRow = ids.map { lookOfId($0) }
            let terFused = terFusion(
                [lookRow, geoRow, graphRow, embedRow, geom3dRow, textureRow],
                [0.40, 0.26, 0.14, 0.12, 0.05, 0.03]
            )
            hits.append(hint(.terFusion, rank(models, minMargin: embedMargin) { m in
                let i = ids.firstIndex(of: m.identity.id) ?? 0
                return i < terFused.count ? terFused[i] : 0
            }))
            let ensemble = rank(models, minMargin: embedMargin) { m in
                lookOfId(m.identity.id)
            }
            let geoRanked = models.map { (id: $0.identity.id, p: geoMixOf($0.identity.id)) }
                .sorted { $0.p > $1.p }
            let lookWinner = ensemble.versus.first?.identityId
            let others = ensemble.versus.dropFirst().map(\.percent)
            let fusedVersus = ensemble.versus.map { v in
                IdentityScore(
                    identityId: v.identityId,
                    percent: lookOfId(v.identityId),
                    distance: v.distance
                )
            }
            let fusedBest = fusedVersus.first?.percent ?? 0
            let fusedSecond = fusedVersus.dropFirst().first?.percent ?? 0
            let decided = decide(
                percent: fusedBest,
                margin: fusedBest - fusedSecond,
                bestId: ensemble.versus.first?.identityId,
                bestName: models.first { $0.identity.id == ensemble.versus.first?.identityId }?.identity.name,
                secondName: models.first { $0.identity.id == ensemble.versus.dropFirst().first?.identityId }?.identity.name,
                geoAgrees: geoRanked.first?.id == ensemble.versus.first?.identityId,
                geoMargin: (geoRanked.first?.p ?? 0) - (geoRanked.dropFirst().first?.p ?? 0),
                lowCapture: lowCapture,
                appearance: nil,
                geoMix: lookWinner.map { geoMixOf($0) } ?? (geoRanked.first?.p ?? 0),
                galleryZ: galleryZScore(fusedBest, Array(others)),
                textureReliable: false,
                evidence: fusedBest
            )
            var aegis = ensemble
            aegis.identityId = decided.id
            aegis.percent = fusedBest
            aegis.margin = fusedBest - fusedSecond
            aegis.versus = fusedVersus
            hits.append(toHit(.aegis, aegis, note: decided.note))
            if let owner = identities.first(where: { $0.faceIds.contains(face.id) }) {
                hits = hits.map { h in
                    let selfP = h.versus.first { $0.identityId == owner.id }?.percent ?? h.percent
                    let second = h.versus.first { $0.identityId != owner.id }?.percent ?? 0
                    return StrategyHit(
                        strategy: h.strategy,
                        identityId: owner.id,
                        percent: selfP,
                        distance: h.distance,
                        margin: selfP - second,
                        versus: h.versus,
                        note: "Referenz dieser Person — gemessene Werte, nicht hochgesetzt."
                    )
                }
            }
            return MatchResult(faceId: face.id, hits: hits)
        }
    }

    // MARK: - geometry / prints

    private static var matchFloor = 78.0
    private static var soloFloor = 82.0
    private static let embedMargin = 12.0
    private static let landmarkMargin = 14.0
    private static let zFloor = 1.5

    private struct IdentityModel {
        var identity: Identity
        var photos: FaceObservation?
        var meanPrint: [FaceObservation]
        var landmarkSets: [[Point2]]
        var temporal: [FaceObservation]
        var ratios: [[Double]]
        var shape: [[Double]]
        var eyes: [[Double]]
        var midface: [[Double]]
        var jaw: [[Double]]
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
        galleryZ: Double,
        textureReliable: Bool = false,
        evidence: Double? = nil
    ) -> (id: UUID?, note: String) {
        let best = bestName ?? "Beste"
        let second = secondName ?? "Zweite"
        _ = appearance
        _ = textureReliable
        _ = evidence
        _ = geoAgrees
        _ = geoMargin
        _ = geoMix
        guard let bestId, percent > 0 else {
            return (nil, "Keine Vergleichsperson.")
        }
        if lowCapture {
            return (nil, String(format: "Aufnahme zu schwach für eine Zuordnung, Nähe %.0f%%.", percent))
        }
        if secondName == nil {
            if percent >= soloFloor {
                return (bestId, String(format: "Nur eine Person eingeschrieben. Nähe %.0f%% reicht.", percent))
            }
            return (nil, String(format: "Nur eine Person eingeschrieben. Nähe %.0f%% reicht nicht (braucht %.0f%%). Andere Gesichter bleiben offen.", percent, soloFloor))
        }
        if percent < matchFloor {
            return (nil, String(format: "Beste Nähe %.0f%% liegt unter %.0f%%. Nicht zugeordnet.", percent, matchFloor))
        }
        if galleryZ < zFloor && percent < 92 {
            return (nil, String(format: "Kein Ausreißer in der Galerie (z=%.1f). Alle Personen ähnlich nah — nicht zugeordnet.", galleryZ))
        }
        if margin >= embedMargin || (percent >= 94 && margin >= 6) {
            return (bestId, String(format: "Abstand %.1f Pkt zu %@.", margin, second))
        }
        return (nil, String(format: "%@ %.0f%% und %@ %.0f%% zu nah — nicht zugeordnet.", best, percent, second, percent - margin))
    }

    private static func bestPrintPercent(_ probe: Data, _ faces: [FaceObservation]) -> Double {
        guard !probe.isEmpty else { return 0 }
        var best = 0.0
        for f in faces where !f.featurePrint.isEmpty {
            let p = printPercent(probe, f.featurePrint)
            if p > best { best = p }
        }
        return best
    }

    /// Vision face boxes: origin lower-left of the image, normalized 0…1.
    private static func vnToPixels(_ r: CGRect, width: Double, height: Double) -> FaceBox {
        FaceBox(
            x: r.origin.x * width,
            y: (1 - r.origin.y - r.height) * height,
            width: r.width * width,
            height: r.height * height
        )
    }

    /// VNFaceLandmarkRegion2D.normalizedPoints are relative to the *face box*,
    /// origin lower-left of that box — not the full image.
    private static func landmarkToPixels(_ p: CGPoint, box: CGRect, imageWidth: Double, imageHeight: Double) -> Point2 {
        Point2(
            x: (Double(box.origin.x) + Double(p.x) * Double(box.width)) * imageWidth,
            y: (1 - Double(box.origin.y) - Double(p.y) * Double(box.height)) * imageHeight
        )
    }

    private static func extractPoints(_ obs: VNFaceObservation?, imageWidth: Double, imageHeight: Double) -> [Point2] {
        extractStrokes(obs, imageWidth: imageWidth, imageHeight: imageHeight).flatMap(\.points)
    }

    private static func extractStrokes(_ obs: VNFaceObservation?, imageWidth: Double, imageHeight: Double) -> [LandmarkStroke] {
        guard let obs, let lm = obs.landmarks else { return [] }
        let box = obs.boundingBox
        let regions: [(String, VNFaceLandmarkRegion2D?, Bool)] = [
            ("Kontur", lm.faceContour, false),
            ("Braue L", lm.leftEyebrow, false),
            ("Braue R", lm.rightEyebrow, false),
            ("Auge L", lm.leftEye, true),
            ("Auge R", lm.rightEye, true),
            ("Nase", lm.nose, false),
            ("Nasenrücken", lm.noseCrest, false),
            ("Mund", lm.outerLips, true),
            ("Lippen", lm.innerLips, true),
        ]
        var strokes: [LandmarkStroke] = []
        for (label, region, closed) in regions {
            guard let region, region.pointCount >= 2 else { continue }
            var pts: [Point2] = []
            for i in 0 ..< region.pointCount {
                pts.append(landmarkToPixels(region.normalizedPoints[i], box: box, imageWidth: imageWidth, imageHeight: imageHeight))
            }
            if closed, let first = pts.first { pts.append(first) }
            strokes.append(LandmarkStroke(label: label, closed: closed, points: pts))
        }
        return strokes
    }

    private static func hairline(from pts: [Point2]) -> Point2? {
        guard pts.count >= 3 else { return nil }
        let chin = pts.max { $0.y < $1.y }!
        let brow = pts.min { $0.y < $1.y }!
        return Point2(
            x: brow.x + (brow.x - chin.x) * 0.18,
            y: brow.y + (brow.y - chin.y) * 0.18
        )
    }

    private static func procrustes(_ pts: [Point2], left: Point2? = nil, right: Point2? = nil) -> [Point2] {
        if let left, let right {
            let cx = (left.x + right.x) / 2
            let cy = (left.y + right.y) / 2
            let dx = right.x - left.x
            let dy = right.y - left.y
            let dist = max(hypot(dx, dy), 1e-6)
            let ang = -atan2(dy, dx)
            let c = cos(ang)
            let s = sin(ang)
            return pts.map { p in
                let x = p.x - cx
                let y = p.y - cy
                return Point2(x: (x * c - y * s) / dist, y: (x * s + y * c) / dist)
            }
        }
        guard pts.count >= 8 else { return pts }
        let n = pts.count
        let cx = pts.map(\.x).reduce(0, +) / Double(n)
        let cy = pts.map(\.y).reduce(0, +) / Double(n)
        var scale = 0.0
        for p in pts { scale += hypot(p.x - cx, p.y - cy) }
        scale = max(scale / Double(n), 1e-6)
        return pts.map { Point2(x: ($0.x - cx) / scale, y: ($0.y - cy) / scale) }
    }

    private static func frontalScore(_ frame: NamedFace) -> Double {
        let iod = max(hypot(frame.rightEye.x - frame.leftEye.x, frame.rightEye.y - frame.leftEye.y), 1e-6)
        let midX = (frame.leftEye.x + frame.rightEye.x) / 2
        let offset = abs(frame.noseTip.x - midX) / iod
        let tilt = abs(frame.rightEye.y - frame.leftEye.y) / iod
        return clamp01(1 - offset * 1.8) * clamp01(1 - tilt * 2.4)
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

    /// Apple face-identity print on a natural crop. Never image-print, never warp —
    /// Vision aligns internally. Image-print was matching jackets, not faces (4% same person).
    private static func identityPrint(of image: CGImage?) -> Data? {
        facePrintOnly(of: image)
    }

    private static func facePrintOnly(of image: CGImage?) -> Data? {
        guard let image else { return nil }
        guard let req = makeFacePrintRequest() else { return nil }
        let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
        guard (try? handler.perform([req])) != nil else { return nil }
        for obs in req.results ?? [] {
            if let data = extractPrint(obs) { return data }
        }
        return nil
    }

    private static func makeFacePrintRequest() -> VNRequest? {
        guard let cls = NSClassFromString("VNGenerateFacePrintRequest") as? VNRequest.Type else { return nil }
        return cls.init()
    }

    private static func extractPrint(_ obs: VNObservation) -> Data? {
        if let fp = obs as? VNFeaturePrintObservation {
            return archivePrint(fp)
        }
        if obs.responds(to: NSSelectorFromString("facePrint")),
           let fp = obs.value(forKey: "facePrint") as? VNFeaturePrintObservation {
            return archivePrint(fp)
        }
        return nil
    }

    private static func archivePrint(_ obs: VNFeaturePrintObservation) -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: obs, requiringSecureCoding: true)
    }

    private static func imageFeaturePrint(of image: CGImage?) -> Data? {
        guard let image else { return nil }
        let req = VNGenerateImageFeaturePrintRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([req])
            guard let obs = req.results?.first as? VNFeaturePrintObservation else { return nil }
            return archivePrint(obs)
        } catch {
            return nil
        }
    }

    private static func stampPrints(_ faces: [FaceObservation], from image: CGImage) -> [FaceObservation] {
        let found = facePrintsInImage(image)
        var used = Set<Int>()
        return faces.map { face in
            var next = face
            var bestI = -1
            var bestIoU = 0.20
            for (i, item) in found.enumerated() where !used.contains(i) {
                let o = iou(item.box, face.box)
                if o > bestIoU {
                    bestIoU = o
                    bestI = i
                }
            }
            if bestI >= 0 {
                used.insert(bestI)
                next.featurePrint = found[bestI].data
                return next
            }
            if let crop = self.crop(image, box: face.box, pad: 0.55),
               let data = identityPrint(of: crop) {
                next.featurePrint = data
            } else {
                next.featurePrint = Data()
            }
            return next
        }
    }

    private struct LocatedPrint {
        var box: FaceBox
        var data: Data
    }

    /// Run Apple's face-print on the whole photo so Vision can detect and align itself.
    /// Warped 256px patches made the request fail and silently stored an image-print of the jacket.
    private static func facePrintsInImage(_ image: CGImage) -> [LocatedPrint] {
        guard let req = makeFacePrintRequest() else { return [] }
        let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
        guard (try? handler.perform([req])) != nil else { return [] }
        let w = Double(image.width)
        let h = Double(image.height)
        var out: [LocatedPrint] = []
        for obs in req.results ?? [] {
            guard let data = extractPrint(obs) else { continue }
            let box: FaceBox
            if let face = obs as? VNFaceObservation {
                box = vnToPixels(face.boundingBox, width: w, height: h)
            } else {
                box = vnToPixels(obs.boundingBox, width: w, height: h)
            }
            out.append(LocatedPrint(box: box, data: data))
        }
        return out
    }

    private static func eyeCenters(_ face: FaceObservation) -> (Point2, Point2)? {
        func mean(_ pts: [Point2]) -> Point2? {
            guard !pts.isEmpty else { return nil }
            return Point2(
                x: pts.map(\.x).reduce(0, +) / Double(pts.count),
                y: pts.map(\.y).reduce(0, +) / Double(pts.count)
            )
        }
        guard let left = mean(face.strokes.first { $0.label == "Auge L" }?.points ?? []),
              let right = mean(face.strokes.first { $0.label == "Auge R" }?.points ?? [])
        else { return nil }
        return (left, right)
    }

    private static func printVector(_ data: Data) -> [Double] {
        guard let obs = try? NSKeyedUnarchiver.unarchivedObject(ofClass: VNFeaturePrintObservation.self, from: data) else {
            return []
        }
        let n = obs.elementCount
        guard n >= 16 else { return [] }
        let raw = obs.data
        if obs.elementType.rawValue == 2 {
            let bytes = n * MemoryLayout<Double>.size
            guard raw.count >= bytes else { return [] }
            var vals = [Double](repeating: 0, count: n)
            vals.withUnsafeMutableBytes { dest in
                raw.copyBytes(to: dest, count: bytes)
            }
            return vals
        }
        let bytes = n * MemoryLayout<Float>.size
        guard raw.count >= bytes else { return [] }
        var vals = [Float](repeating: 0, count: n)
        vals.withUnsafeMutableBytes { dest in
            raw.copyBytes(to: dest, count: bytes)
        }
        return vals.map { Double($0) }
    }

    private static func cosine(_ a: [Double], _ b: [Double]) -> Double {
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

    private static func printDistance(_ a: Data, _ b: Data) -> Double {
        guard
            let oa = try? NSKeyedUnarchiver.unarchivedObject(ofClass: VNFeaturePrintObservation.self, from: a),
            let ob = try? NSKeyedUnarchiver.unarchivedObject(ofClass: VNFeaturePrintObservation.self, from: b)
        else { return 40 }
        var d: Float = 40
        try? oa.computeDistance(&d, to: ob)
        return Double(d)
    }

    /// Real face-print cosine. Same person in ¾/hat should stay high.
    /// Empty or mixed print types (face vs image) are unmeasured — not "4%".
    private static func printPercent(_ a: Data, _ b: Data) -> Double {
        guard !a.isEmpty, !b.isEmpty else { return 0 }
        let va = printVector(a)
        let vb = printVector(b)
        if va.count >= 32, vb.count >= 32 {
            guard va.count == vb.count else { return 0 }
            let c = cosine(va, vb)
            return 100.0 / (1.0 + exp(-11.0 * (c - 0.42)))
        }
        let d = printDistance(a, b)
        if d >= 35 { return 0 }
        if d >= 3 {
            return 100.0 / (1.0 + exp(0.7 * (d - 8)))
        }
        return 100.0 / (1.0 + exp(8.0 * (d - 0.62)))
    }

    private static func landmarkPercent(_ d: Double) -> Double {
        100.0 / (1.0 + exp(32.0 * (d - 0.10)))
    }

    private static func measuresPercent(_ d: Double) -> Double {
        100.0 / (1.0 + exp(48.0 * (d - 0.07)))
    }

    private static func appearancePercent(_ d: Double) -> Double {
        100.0 / (1.0 + exp(8.0 * (d - 0.72)))
    }

    private static func bestAppearance(_ probe: [Double], _ gallery: [[Double]]) -> Double {
        var best = 0.0
        for g in gallery {
            let c = cosine(probe, g)
            let p = 100.0 / (1.0 + exp(-10.0 * (c - 0.12)))
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
        // One rival is margin's job. Variance of a 1-element cohort is 0, and
        // max(0, 6) then silently demanded a 9-point gap — exactly when two
        // similar people needed the embedding to separate them.
        guard others.count >= 2 else { return 99 }
        let mean = others.reduce(0, +) / Double(others.count)
        let v = others.reduce(0.0) { $0 + ($1 - mean) * ($1 - mean) } / Double(others.count)
        let denom = max(sqrt(v), 1)
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
        return landmarkToPixels(CGPoint(x: x, y: y), box: box, imageWidth: imageWidth, imageHeight: imageHeight)
    }

    private static func warpEyes(_ image: CGImage, left: Point2, right: Point2, size: Int = 128) -> CGImage? {
        guard let ctx = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        // Landmark pixels are top-left; CGContext is bottom-left.
        let H = Double(image.height)
        let lx = left.x
        let ly = H - left.y
        let rx = right.x
        let ry = H - right.y
        let dx = rx - lx
        let dy = ry - ly
        let dist = max(hypot(dx, dy), 1e-6)
        let iod = Double(size) / 3.15
        let eyeY = Double(size) * 0.38
        let s = iod / dist
        let ang = -atan2(dy, dx)
        let cosA = cos(ang)
        let sinA = sin(ang)
        let a = s * cosA
        let b = s * sinA
        let c = -s * sinA
        let d = s * cosA
        let cx = (lx + rx) / 2
        let cy = (ly + ry) / 2
        let half = Double(size) / 2
        let e = half - a * cx - c * cy
        let f = eyeY - b * cx - d * cy
        ctx.concatenate(CGAffineTransform(a: a, b: b, c: c, d: d, tx: e, ty: f))
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return ctx.makeImage()
    }

    private struct NamedFace {
        var leftEye: Point2
        var rightEye: Point2
        var leftOuter: Point2
        var leftInner: Point2
        var rightInner: Point2
        var rightOuter: Point2
        var nasion: Point2
        var noseTip: Point2
        var noseLeft: Point2
        var noseRight: Point2
        var mouthLeft: Point2
        var mouthRight: Point2
        var mouthTop: Point2
        var mouthBottom: Point2
        var chin: Point2
        var jawLeft: Point2
        var jawRight: Point2
        var cheekLeft: Point2
        var cheekRight: Point2
        var browLeft: Point2
        var browRight: Point2
        var eyeOpenL: Double
        var eyeOpenR: Double
    }

    private static func namedList(_ n: NamedFace) -> [Point2] {
        [
            n.leftOuter, n.leftInner, n.rightInner, n.rightOuter,
            n.nasion, n.noseTip, n.noseLeft, n.noseRight,
            n.mouthLeft, n.mouthRight, n.mouthTop, n.mouthBottom,
            n.chin, n.jawLeft, n.jawRight, n.cheekLeft, n.cheekRight,
            n.browLeft, n.browRight, n.leftEye, n.rightEye,
        ]
    }

    private static func boneKeypoints(_ list: [Point2]) -> [Point2] {
        guard list.count >= 21 else { return list }
        return list.enumerated().filter { $0.offset < 8 || $0.offset > 11 }.map(\.element)
    }

    private static func meanPts(_ p: [Point2]) -> Point2? {
        guard !p.isEmpty else { return nil }
        return Point2(
            x: p.map(\.x).reduce(0, +) / Double(p.count),
            y: p.map(\.y).reduce(0, +) / Double(p.count)
        )
    }

    private static func namedFromStrokes(_ strokes: [LandmarkStroke]) -> NamedFace? {
        func pts(_ label: String) -> [Point2] {
            strokes.first { $0.label == label }?.points ?? []
        }
        let eyeL = pts("Auge L")
        let eyeR = pts("Auge R")
        guard let leftEye = meanPts(eyeL), let rightEye = meanPts(eyeR) else { return nil }
        let leftOuter = eyeL.min { $0.x < $1.x } ?? leftEye
        let leftInner = eyeL.max { $0.x < $1.x } ?? leftEye
        let rightInner = eyeR.min { $0.x < $1.x } ?? rightEye
        let rightOuter = eyeR.max { $0.x < $1.x } ?? rightEye
        let nose = pts("Nase")
        let crest = pts("Nasenrücken")
        let noseAll = nose + crest
        guard !noseAll.isEmpty else { return nil }
        let nasion = (crest + nose).min { $0.y < $1.y } ?? leftEye
        let noseTip = (crest + nose).max { $0.y < $1.y } ?? nasion
        let noseLeft = noseAll.min { $0.x < $1.x } ?? nasion
        let noseRight = noseAll.max { $0.x < $1.x } ?? nasion
        let mouth = pts("Mund")
        let mouthLeft = mouth.min { $0.x < $1.x } ?? Point2(x: (leftEye.x + noseTip.x) / 2, y: noseTip.y + 20)
        let mouthRight = mouth.max { $0.x < $1.x } ?? Point2(x: (rightEye.x + noseTip.x) / 2, y: noseTip.y + 20)
        let mouthTop = mouth.min { $0.y < $1.y } ?? noseTip
        let mouthBottom = mouth.max { $0.y < $1.y } ?? noseTip
        let contour = pts("Kontur")
        let chin = contour.max { $0.y < $1.y } ?? mouthBottom
        let ys = contour.map(\.y)
        let minY = ys.min() ?? leftEye.y
        let maxY = ys.max() ?? chin.y
        let h = max(maxY - minY, 1e-6)
        let lower = contour.filter { $0.y > minY + h * 0.55 }
        let jawLeft = lower.min { $0.x < $1.x } ?? contour.min { $0.x < $1.x } ?? leftEye
        let jawRight = lower.max { $0.x < $1.x } ?? contour.max { $0.x < $1.x } ?? rightEye
        let cheekLeft = contour.min { $0.x < $1.x } ?? jawLeft
        let cheekRight = contour.max { $0.x < $1.x } ?? jawRight
        let browLeft = meanPts(pts("Braue L")) ?? Point2(x: leftEye.x, y: leftEye.y - 12)
        let browRight = meanPts(pts("Braue R")) ?? Point2(x: rightEye.x, y: rightEye.y - 12)
        let eyeH: ([Point2]) -> Double = { p in
            guard let lo = p.map(\.y).min(), let hi = p.map(\.y).max() else { return 0 }
            return hi - lo
        }
        return NamedFace(
            leftEye: leftEye, rightEye: rightEye,
            leftOuter: leftOuter, leftInner: leftInner,
            rightInner: rightInner, rightOuter: rightOuter,
            nasion: nasion, noseTip: noseTip, noseLeft: noseLeft, noseRight: noseRight,
            mouthLeft: mouthLeft, mouthRight: mouthRight, mouthTop: mouthTop, mouthBottom: mouthBottom,
            chin: chin, jawLeft: jawLeft, jawRight: jawRight, cheekLeft: cheekLeft, cheekRight: cheekRight,
            browLeft: browLeft, browRight: browRight,
            eyeOpenL: eyeH(eyeL), eyeOpenR: eyeH(eyeR)
        )
    }

    private static func d(_ a: Point2, _ b: Point2) -> Double {
        hypot(b.x - a.x, b.y - a.y)
    }

    private static func ratioSheet(_ n: NamedFace) -> [NamedRatio] {
        let iod = max(d(n.leftEye, n.rightEye), 1e-6)
        let noseW = d(n.noseLeft, n.noseRight)
        let noseL = d(n.nasion, n.noseTip)
        let icd = d(n.leftInner, n.rightInner)
        let ocd = d(n.leftOuter, n.rightOuter)
        let eyeWL = d(n.leftOuter, n.leftInner)
        let eyeWR = d(n.rightInner, n.rightOuter)
        let brow = d(n.browLeft, n.browRight)
        let jawW = d(n.jawLeft, n.jawRight)
        let cheekW = d(n.cheekLeft, n.cheekRight)
        let faceH = max(d(n.nasion, n.chin), 1e-6)
        let midH = d(n.nasion, n.noseTip)
        let lowH = d(n.noseTip, n.chin)
        let philtrum = d(n.noseTip, n.mouthTop)
        let chinL = (d(n.jawLeft, n.chin) + d(n.jawRight, n.chin)) / 2
        let mouthW = d(n.mouthLeft, n.mouthRight)
        let mouthH = d(n.mouthTop, n.mouthBottom)
        let eyeOpen = (n.eyeOpenL + n.eyeOpenR) / 2
        func row(_ id: String, _ label: String, _ value: Double, _ group: String, _ identity: Bool = true) -> NamedRatio {
            NamedRatio(id: id, label: label, value: value.isFinite ? value : 0, group: group, identity: identity)
        }
        return [
            row("noseW_iod", "Nasenbreite / Augenabstand", noseW / iod, "mid"),
            row("noseL_iod", "Nasenlänge / Augenabstand", noseL / iod, "mid"),
            row("nasalIndex", "Nasenindex (Breite/Länge)", noseW / max(noseL, 1e-6), "mid"),
            row("icd_iod", "Innerer Augenwinkel / IOD", icd / iod, "eyes"),
            row("ocd_iod", "Äußerer Augenwinkel / IOD", ocd / iod, "eyes"),
            row("eyeWL_iod", "Lidspalte L / IOD", eyeWL / iod, "eyes"),
            row("eyeWR_iod", "Lidspalte R / IOD", eyeWR / iod, "eyes"),
            row("brow_iod", "Brauenabstand / IOD", brow / iod, "eyes"),
            row("jaw_iod", "Kieferbreite / IOD", jawW / iod, "jaw"),
            row("cheek_iod", "Wangenbreite / IOD", cheekW / iod, "shape"),
            row("faceH_iod", "Gesichtshöhe / IOD", faceH / iod, "shape"),
            row("jaw_faceH", "Kiefer / Gesichtshöhe", jawW / faceH, "shape"),
            row("cheek_faceH", "Wangen / Gesichtshöhe", cheekW / faceH, "shape"),
            row("jaw_cheek", "Kiefer / Wangen", jawW / max(cheekW, 1e-6), "shape"),
            row("mid_faceH", "Mittelgesicht / Höhe", midH / faceH, "mid"),
            row("low_faceH", "Untergesicht / Höhe", lowH / faceH, "jaw"),
            row("philtrum_nose", "Philtrum / Nasenlänge", philtrum / max(noseL, 1e-6), "mid"),
            row("noseW_jaw", "Nase / Kiefer", noseW / max(jawW, 1e-6), "shape"),
            row("icd_cheek", "Augenwinkel / Wangen", icd / max(cheekW, 1e-6), "eyes"),
            row("chin_iod", "Kinn / IOD", chinL / iod, "jaw"),
            row("mouthW_iod", "Mundbreite / IOD (Mimik)", mouthW / iod, "mimik", false),
            row("mouthH_iod", "Mundöffnung / IOD (Mimik)", mouthH / iod, "mimik", false),
            row("eyeOpen_iod", "Lidöffnung / IOD (Mimik)", eyeOpen / iod, "mimik", false),
        ]
    }

    private static func measures(_ face: FaceObservation) -> (ratios: [Double], shape: [Double], eyes: [Double], midface: [Double], jaw: [Double]) {
        let sheet = face.ratioSheet
        guard !sheet.isEmpty else { return ([], [], [], [], []) }
        func group(_ g: String) -> [Double] {
            sheet.filter { $0.group == g && $0.identity }.map(\.value)
        }
        return (
            sheet.filter(\.identity).map(\.value),
            group("shape"),
            group("eyes"),
            group("mid"),
            group("jaw")
        )
    }

    private static func geom3dFromNamed(_ named: [Point2]) -> [Double] {
        guard named.count >= 21 else { return [] }
        let n = NamedFace(
            leftEye: named[19], rightEye: named[20],
            leftOuter: named[0], leftInner: named[1],
            rightInner: named[2], rightOuter: named[3],
            nasion: named[4], noseTip: named[5], noseLeft: named[6], noseRight: named[7],
            mouthLeft: named[8], mouthRight: named[9], mouthTop: named[10], mouthBottom: named[11],
            chin: named[12], jawLeft: named[13], jawRight: named[14],
            cheekLeft: named[15], cheekRight: named[16],
            browLeft: named[17], browRight: named[18],
            eyeOpenL: 0, eyeOpenR: 0
        )
        let iod = max(d(n.leftEye, n.rightEye), 1e-6)
        let sheet = ratioSheet(n).filter(\.identity).map(\.value)
        let noseArea = shoelace([n.nasion, n.noseLeft, n.noseRight]) / (iod * iod)
        let jawAng = angleAt(n.jawLeft, n.chin, n.jawRight) / .pi
        return Array(sheet.prefix(15)) + [noseArea, jawAng]
    }

    private static func ratioScore(_ a: [Double], _ b: [Double]) -> Double {
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

    private static func bestLandmarkPercent(_ probe: [Point2], _ gallery: [[Point2]]) -> Double {
        guard !probe.isEmpty, !gallery.isEmpty else { return 0 }
        var best = 0.0
        for g in gallery {
            let p = landmarkPercent(distance(probe, g))
            if p > best { best = p }
        }
        return best
    }

    private static func bestRatioPercent(_ probe: [Double], _ gallery: [[Double]]) -> Double {
        guard !probe.isEmpty, !gallery.isEmpty else { return 0 }
        var best = 0.0
        for g in gallery {
            let p = ratioScore(probe, g)
            if p > best { best = p }
        }
        return best
    }

    private static func averageRaw(_ vecs: [[Double]]) -> [Double] {
        guard let first = vecs.first, !first.isEmpty else { return [] }
        var acc = Array(repeating: 0.0, count: first.count)
        var n = 0.0
        for v in vecs {
            guard v.count == first.count else { continue }
            for i in 0 ..< first.count { acc[i] += v[i] }
            n += 1
        }
        guard n > 0 else { return [] }
        return acc.map { $0 / n }
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
        let n = first.count
        var acc = Array(repeating: Point2(x: 0, y: 0), count: n)
        var wsum = 0.0
        for (i, set) in sets.enumerated() {
            guard set.count == n else { continue }
            let w = i < weights.count ? weights[i] : 1
            wsum += w
            for j in 0 ..< n {
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

    static var facePrintAvailable: Bool {
        NSClassFromString("VNGenerateFacePrintRequest") != nil
    }

    static func qualityRejects(_ q: FaceQuality) -> Bool {
        q.capture < 0.35 && q.size < 0.16
    }

    private static func tinyUnreliable(_ q: FaceQuality) -> Bool {
        q.capture < 0.35 && q.size < 0.16
    }

    private static func textureIsReliable(_ q: FaceQuality) -> Bool {
        q.capture >= 0.28 && q.sharpness >= 0.12
    }

    /// Embedding leads. Geometry supports and vetoes. Raster never votes.
    /// Pose (Vision yaw/pitch) shrinks the geometry weight off-frontal, so IOD
    /// ratios cannot block a 99% print on a profile, and cannot assign a stranger.
    private static func lookOf(geo: Double, embed: Double = 0, pose: Double = 1) -> Double {
        if embed < 1 { return geo }
        if geo >= 1 && geo < 35 { return min(embed, 60) }
        let geoW = 0.25 * clamp01(pose)
        return (1 - geoW) * embed + geoW * geo
    }

    /// 1 = frontal, ~0.7 at 45°, 0 at 90°. Vision yaw/pitch are radians.
    private static func poseWeight(_ q: FaceQuality) -> Double {
        let off = hypot(q.yaw, q.pitch)
        if off < 0.02 { return clamp01(q.frontal) == 0 ? 1 : max(q.frontal, 0.35) }
        return clamp01(cos(min(off, Double.pi / 2)))
    }

    private static func fuseIdentity(_ appear: Double, _ geo: Double, _ q: FaceQuality) -> Double {
        _ = appear
        return lookOf(geo: geo, pose: poseWeight(q))
    }

    private struct LumaStats {
        var mean: Double
        var p5: Double
        var p95: Double
        var dark: Bool
    }

    private static func lumaStats(_ image: CGImage?) -> LumaStats {
        guard let image else { return LumaStats(mean: 0, p5: 0, p95: 0, dark: true) }
        let w = min(96, image.width)
        let h = min(96, image.height)
        guard w > 1, h > 1, let ctx = CGContext(
            data: nil,
            width: w,
            height: h,
            bitsPerComponent: 8,
            bytesPerRow: w,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return LumaStats(mean: 128, p5: 40, p95: 220, dark: false) }
        ctx.interpolationQuality = .low
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
        guard let data = ctx.data else { return LumaStats(mean: 128, p5: 40, p95: 220, dark: false) }
        let buf = data.bindMemory(to: UInt8.self, capacity: w * h)
        var hist = [Int](repeating: 0, count: 256)
        var sum = 0.0
        let n = w * h
        for i in 0 ..< n {
            let v = Int(buf[i])
            hist[v] += 1
            sum += Double(v)
        }
        let mean = sum / Double(max(n, 1))
        func percentile(_ p: Double) -> Double {
            let target = p * Double(n)
            var acc = 0.0
            for i in 0 ..< 256 {
                acc += Double(hist[i])
                if acc >= target { return Double(i) }
            }
            return 255
        }
        let p5 = percentile(0.05)
        let p95 = percentile(0.95)
        return LumaStats(mean: mean, p5: p5, p95: p95, dark: mean < 78 || p5 < 22)
    }

    private static func equalize(_ image: CGImage?) -> CGImage? {
        guard let image else { return nil }
        let stats = lumaStats(image)
        guard stats.mean < 78 || stats.p5 < 22 else { return image }
        let w = image.width
        let h = image.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let ctx = CGContext(
            data: nil,
            width: w,
            height: h,
            bitsPerComponent: 8,
            bytesPerRow: w * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }
        ctx.interpolationQuality = .high
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
        guard let base = ctx.data else { return ctx.makeImage() }
        let ptr = base.bindMemory(to: UInt8.self, capacity: w * h * 4)
        let p5 = stats.p5
        let span = max(stats.p95 - p5, 12.0)
        let gamma = stats.mean < 55 ? 0.55 : stats.mean < 70 ? 0.62 : 0.78
        let n = w * h
        for i in 0 ..< n {
            let o = i * 4
            let r = Double(ptr[o])
            let g = Double(ptr[o + 1])
            let b = Double(ptr[o + 2])
            let y = 0.299 * r + 0.587 * g + 0.114 * b
            var y2 = ((y - p5) / span) * 240 + 8
            y2 = min(255, max(0, y2))
            y2 = 255 * pow(y2 / 255, gamma)
            let scale = y2 / max(y, 1)
            ptr[o] = UInt8(min(255, max(0, r * scale)))
            ptr[o + 1] = UInt8(min(255, max(0, g * scale)))
            ptr[o + 2] = UInt8(min(255, max(0, b * scale)))
        }
        return ctx.makeImage()
    }

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
