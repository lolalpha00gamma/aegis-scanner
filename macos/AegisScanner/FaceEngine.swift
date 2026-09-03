import CoreGraphics
import Foundation
import ImageIO
import Vision

enum FaceEngine {
    private static let nmsLock = NSLock()
    private static var _dropped: [FaceBox] = []
    static var lastNMSDropped: [FaceBox] {
        nmsLock.lock(); defer { nmsLock.unlock() }
        return _dropped
    }

    static func detect(in image: CGImage, mediaId: UUID, tiles: Bool = true, orientation: CGImagePropertyOrientation = .up, minSharpness: Double = MatchMath.sharpnessFloor, continuity: Bool = false, cheapGraph: Bool = false) throws -> [FaceObservation] {
        let w = Double(image.width)
        let h = Double(image.height)
        var out = try detectOnce(in: image, mediaId: mediaId, originX: 0, originY: 0, imageWidth: w, imageHeight: h, orientation: orientation, cheapGraph: cheapGraph)
        let stats = lumaStats(image)
        if stats.dark || out.isEmpty, let lifted = equalize(image) {
            let extra = try detectOnce(
                in: lifted,
                mediaId: mediaId,
                originX: 0,
                originY: 0,
                imageWidth: w,
                imageHeight: h,
                minConfidence: out.isEmpty ? 0.12 : 0.15,
                orientation: orientation,
                cheapGraph: cheapGraph
            )
            if stats.dark {
                out = extra + out
            } else {
                out.append(contentsOf: extra)
            }
        }
        let largest = out.map { max($0.box.width, $0.box.height) }.max() ?? 0
        let covered = out.reduce(0.0) { $0 + $1.box.width * $1.box.height }
        let coverage = covered / max(1, w * h)
        let minSide = min(w, h)
        // Portrait mit einem großen Gesicht: Tiles erzeugen NMS-Zwillinge und
        // falsche Print-IoU. Nur crowd/klein oder leeres Bild kacheln.
        let hasLargeFace = largest >= minSide * 0.28
        let crowd = !hasLargeFace && (out.isEmpty || largest < minSide * 0.22 || (coverage < 0.14 && max(w, h) >= 1000))
        if tiles, crowd, max(image.width, image.height) >= 900 {
            let tw = max(280, Int((w * 0.58).rounded()))
            let th = max(280, Int((h * 0.58).rounded()))
            let origins: [(Int, Int)] = [
                (max(0, (image.width - tw) / 2), max(0, (image.height - th) / 2)),
                (0, 0),
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
                    minConfidence: stats.dark ? 0.12 : 0.15,
                    orientation: orientation,
                    cheapGraph: cheapGraph
                )
                out.append(contentsOf: found)
            }
        }
        return stampPrints(nms(out), from: image, orientation: orientation, continuity: continuity, minSharpness: minSharpness)
    }

    private static func detectOnce(
        in image: CGImage,
        mediaId: UUID,
        originX: Double,
        originY: Double,
        imageWidth: Double,
        imageHeight: Double,
        minConfidence: Float = 0.15,
        orientation: CGImagePropertyOrientation = .up,
        cheapGraph: Bool = false
    ) throws -> [FaceObservation] {
        let handler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
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
            let sheet = frame.map { ratioSheet($0, identityOnly: cheapGraph) } ?? []
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
            var yaw = face.yaw?.doubleValue ?? 0
            let pitch = face.pitch?.doubleValue ?? 0
            let roll = face.roll?.doubleValue ?? 0
            if MatchMath.visionYawMissing(yaw), let leftEyeFull, let rightEyeFull {
                yaw = MatchMath.yawFromLandmarks(
                    leftEye: (leftEyeFull.x, leftEyeFull.y),
                    rightEye: (rightEyeFull.x, rightEyeFull.y),
                    nose: frame.map { ($0.noseTip.x, $0.noseTip.y) }
                )
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
                    graph: cheapGraph
                        ? cheapGraphBiomarkers(bone.isEmpty ? points : bone)
                        : graphBiomarkers(bone.isEmpty ? points : bone),
                    geom3d: FaceShape3D.descriptor(named: namedAligned, yaw: yaw, pitch: pitch),
                    quality: FaceQuality(
                        sharpness: sharpness,
                        size: size,
                        frontal: frontal,
                        capture: capture,
                        yaw: yaw,
                        pitch: pitch,
                        roll: roll
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
        var dropped: [FaceBox] = []
        for face in ranked {
            if kept.contains(where: { duplicateDetection($0.box, face.box) }) {
                dropped.append(face.box)
                continue
            }
            kept.append(face)
        }
        nmsLock.lock()
        _dropped = dropped
        nmsLock.unlock()
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
    /// Tile-twins share a center even when IoU is modest (Vision + tile).
    private static func duplicateDetection(_ a: FaceBox, _ b: FaceBox) -> Bool {
        if iou(a, b) >= 0.42 { return true }
        let x1 = max(a.x, b.x)
        let y1 = max(a.y, b.y)
        let x2 = min(a.x + a.width, b.x + b.width)
        let y2 = min(a.y + a.height, b.y + b.height)
        let inter = max(0, x2 - x1) * max(0, y2 - y1)
        let smaller = min(a.width * a.height, b.width * b.height)
        if smaller > 1 && inter / smaller >= 0.7 { return true }
        let acx = a.x + a.width / 2
        let acy = a.y + a.height / 2
        let bcx = b.x + b.width / 2
        let bcy = b.y + b.height / 2
        let minDiag = min(hypot(a.width, a.height), hypot(b.width, b.height))
        return minDiag > 1 && hypot(acx - bcx, acy - bcy) < 0.18 * minDiag
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
        threshold: Double = 78,
        enabled: Set<StrategyID> = Set(StrategyID.allCases),
        continuity: Bool = false
    ) -> [MatchResult] {
        var tracked = faces
        assignTracks(faces: &tracked, media: media)
        let liveIds = Set(media.filter { $0.kind == .live }.map(\.id))
        func faceContinuity(_ face: FaceObservation) -> Bool {
            continuity && liveIds.contains(face.mediaId)
        }
        let models = identities.map { identity -> IdentityModel in
            let owned = tracked.filter { identity.faceIds.contains($0.id) }
            let best = owned.max { $0.quality.capture < $1.quality.capture }
            let photos = (best?.quality.capture ?? 0) >= 0.35 ? best : nil
            let namedSets = owned.map { $0.namedAligned.isEmpty ? $0.aligned : $0.namedAligned }
            return IdentityModel(
                identity: identity,
                photos: photos,
                meanPrint: owned,
                meanVec: meanPrintVector(owned),
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
        let f = MatchMath.floors(gallery: identities.count, slider: threshold)
        let floors = Floors(match: f.match, solo: f.solo)
        func pairFloors(_ a: UUID?, _ b: UUID?) -> Floors {
            guard let a, let b,
                  let va = models.first(where: { $0.identity.id == a })?.meanVec,
                  let vb = models.first(where: { $0.identity.id == b })?.meanVec,
                  va.count >= 32, va.count == vb.count
            else { return floors }
            let bump = MatchMath.familyBump(bestPairCosine: MatchMath.cosine(va, vb))
            guard bump > 0 else { return floors }
            return Floors(match: min(96, floors.match + bump), solo: min(96, floors.solo + bump))
        }

        return tracked.map { face in
            var hits: [StrategyHit] = []

            let photos = rank(models, minMargin: embedMargin, floors: floors) { m in
                guard face.quality.capture >= 0.35 else { return 0 }
                return bestPrintPercent(face, m.meanPrint)
            }
            let printOn = !face.featurePrint.isEmpty
            let geoOn = !(face.namedAligned.isEmpty && face.aligned.isEmpty)
            let texOn = !face.appearance.isEmpty
            let kiOn = enabled.contains(where: { $0.track == .ki })
            let shapeOn = enabled.contains(where: {
                $0 == .ratios || $0 == .faceShape || $0 == .eyeRegion || $0 == .midface
                    || $0 == .jawline || $0 == .landmarkGeo || $0 == .graphBio
            })

            hits.append(toHit(.photosStyle, face.quality.capture < 0.35
                ? Ranked(identityId: nil, percent: 0, margin: photos.margin, versus: photos.versus)
                : photos, floors: floors, measured: printOn))

            let box = rank(models, minMargin: embedMargin, floors: floors) { m in
                bestPrintPercent(face, m.meanPrint)
            }
            hits.append(toHit(.visionBox, box, floors: floors, measured: printOn))

            let geoPts = face.namedAligned.isEmpty ? face.aligned : face.namedAligned
            let geo = rank(models, minMargin: landmarkMargin, floors: floors) { m in
                bestLandmarkPercent(geoPts, m.landmarkSets)
            }
            hits.append(hint(.landmarkGeo, geo, floors: floors, measured: geoOn))

            let probeM = measures(face)
            let ratioInv = pooledInverse(models.flatMap(\.ratios))
            hits.append(hint(.ratios, rank(models, minMargin: landmarkMargin, floors: floors) { m in
                mahalanobisPercent(probeM.ratios, m.ratios, pooledInv: ratioInv)
            }, floors: floors, measured: !probeM.ratios.isEmpty))
            hits.append(hint(.faceShape, rank(models, minMargin: landmarkMargin, floors: floors) { m in
                bestRatioPercent(probeM.shape, m.shape)
            }, floors: floors, measured: !probeM.shape.isEmpty))
            hits.append(hint(.eyeRegion, rank(models, minMargin: landmarkMargin, floors: floors) { m in
                bestRatioPercent(probeM.eyes, m.eyes)
            }, floors: floors, measured: !probeM.eyes.isEmpty))
            hits.append(hint(.midface, rank(models, minMargin: landmarkMargin, floors: floors) { m in
                bestRatioPercent(probeM.midface, m.midface)
            }, floors: floors, measured: !probeM.midface.isEmpty))
            hits.append(hint(.jawline, rank(models, minMargin: landmarkMargin, floors: floors) { m in
                bestRatioPercent(probeM.jaw, m.jaw)
            }, floors: floors, measured: !probeM.jaw.isEmpty))
            hits.append(hint(.graphBio, rank(models, minMargin: landmarkMargin, floors: floors) { m in
                bestVecPercent(face.graph, m.graphs)
            }, floors: floors, measured: !face.graph.isEmpty))
            hits.append(hint(.geom3d, rank(models, minMargin: landmarkMargin, floors: floors) { m in
                bestRatioPercent(face.geom3d, m.geom3ds)
            }, floors: floors, measured: !face.geom3d.isEmpty))
            hits.append(hint(.texture, rank(models, minMargin: landmarkMargin, floors: floors) { m in
                bestAppearance(face.appearance, m.appearances)
            }, floors: floors, measured: texOn))

            let gated = rank(models, minMargin: embedMargin, floors: floors) { m in
                let raw = bestPrintPercent(face, m.meanPrint)
                if tinyUnreliable(face.quality, continuity: faceContinuity(face)) {
                    return raw * (0.45 + 0.55 * (face.quality.capture / 0.35))
                }
                return raw
            }
            hits.append(toHit(.qualityGate, gated, floors: floors, measured: printOn))

            let temporal = rank(models, minMargin: embedMargin, floors: floors) { m in
                let gallery = m.temporal.isEmpty ? m.meanPrint : m.temporal
                return bestPrintPercent(face, gallery)
            }
            hits.append(toHit(.temporal, temporal, floors: floors, measured: printOn))

            let fp = rank(models, minMargin: embedMargin, floors: floors) { m in
                bestPrintPercent(face, m.meanPrint)
            }
            hits.append(toHit(.featurePrint, fp, floors: floors, measured: printOn))

            func pctVs(_ s: StrategyID, _ id: UUID) -> Double {
                guard enabled.contains(s) else { return 0 }
                return hits.first { $0.strategy == s }?.versus.first { $0.identityId == id }?.percent ?? 0
            }
            let lowCapture = tinyUnreliable(face.quality, continuity: faceContinuity(face))
            func geoMixOf(_ id: UUID) -> Double {
                let parts: [(StrategyID, Double)] = [
                    (.ratios, 0.20), (.faceShape, 0.16), (.midface, 0.14), (.eyeRegion, 0.14),
                    (.landmarkGeo, 0.12), (.jawline, 0.12), (.graphBio, 0.08), (.geom3d, 0.04),
                ].filter { enabled.contains($0.0) }
                let w = parts.reduce(0.0) { $0 + $1.1 }
                guard w > 0 else { return 0 }
                return parts.reduce(0.0) { $0 + ($1.1 / w) * pctVs($1.0, id) }
            }
            func embedOf(_ id: UUID) -> Double {
                let raw = lowCapture ? pctVs(.qualityGate, id) : pctVs(.featurePrint, id)
                if let ident = models.first(where: { $0.identity.id == id }),
                   MatchMath.rejected(embedding(of: face), by: ident.identity.rejectedVecs)
                {
                    return min(raw, 35)
                }
                return raw
            }
            func lookOfId(_ id: UUID) -> Double {
                let geo = geoMixOf(id)
                let embed = embedOf(id)
                if kiOn && !printOn {
                    return min(geo, 49)
                }
                return lookOf(geo: geo, embed: embed, pose: poseWeight(face.quality), printMeasured: printOn)
            }
            let ids = models.map(\.identity.id)
            let embedRow = ids.map { embedOf($0) }
            let textureRow = ids.map { pctVs(.texture, $0) }
            let graphRow = ids.map { pctVs(.graphBio, $0) }
            let geoRow = ids.map { geoMixOf($0) }
            let geom3dRow = ids.map { pctVs(.geom3d, $0) }
            let lookRow = ids.map { lookOfId($0) }
            var matchers: [[Double]] = []
            var weights: [Double] = []
            if kiOn || shapeOn || enabled.contains(.geom3d) {
                matchers.append(lookRow); weights.append(0.40)
            }
            if shapeOn { matchers.append(geoRow); weights.append(0.26) }
            if enabled.contains(.graphBio) { matchers.append(graphRow); weights.append(0.14) }
            if kiOn { matchers.append(embedRow); weights.append(0.12) }
            if enabled.contains(.geom3d) { matchers.append(geom3dRow); weights.append(0.05) }
            if enabled.contains(.texture) { matchers.append(textureRow); weights.append(0.03) }
            let terFused = terFusion(matchers, weights)
            hits.append(hint(.terFusion, rank(models, minMargin: embedMargin, floors: floors) { m in
                let i = ids.firstIndex(of: m.identity.id) ?? 0
                return i < terFused.count ? terFused[i] : 0
            }, floors: floors))
            func fusedOf(_ id: UUID) -> Double {
                if printOn {
                    return lookOfId(id)
                }
                if enabled.contains(.terFusion),
                   let i = ids.firstIndex(of: id),
                   i < terFused.count {
                    return terFused[i]
                }
                return lookOfId(id)
            }
            let ensemble = rank(models, minMargin: embedMargin, floors: floors) { m in
                fusedOf(m.identity.id)
            }
            let geoRanked = models.map { (id: $0.identity.id, p: geoMixOf($0.identity.id)) }
                .sorted { $0.p > $1.p }
            let lookWinner = ensemble.versus.first?.identityId
            let others = ensemble.versus.dropFirst().map(\.percent)
            let fusedVersus = ensemble.versus.map { v in
                IdentityScore(
                    identityId: v.identityId,
                    percent: fusedOf(v.identityId),
                    distance: v.distance
                )
            }
            let fusedBest = fusedVersus.first?.percent ?? 0
            let fusedSecond = fusedVersus.dropFirst().first?.percent ?? 0
            let aegisFloors = pairFloors(
                ensemble.versus.first?.identityId,
                ensemble.versus.dropFirst().first?.identityId
            )
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
                evidence: fusedBest,
                floors: aegisFloors
            )
            var aegis = ensemble
            aegis.identityId = enabled.contains(.aegis) ? decided.id : nil
            aegis.percent = fusedBest
            aegis.margin = fusedBest - fusedSecond
            aegis.versus = fusedVersus
            let aegisNote = enabled.contains(.aegis)
                ? decided.note
                : "Spur ausgeschaltet — keine Namensvergabe."
            hits.append(toHit(.aegis, aegis, floors: aegisFloors, note: aegisNote, measured: kiOn || shapeOn || enabled.contains(.geom3d)))
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
                        note: "Referenz dieser Person — gemessene Werte, nicht hochgesetzt.",
                        measured: h.measured
                    )
                }
            }
            return MatchResult(faceId: face.id, hits: hits)
        }
    }

    /// Live-Pfad: Sonden gegen Identitäts-Centroids, nicht jedes Galerie-Foto.
    static func matchLive(
        probes: [FaceObservation],
        identities: [Identity],
        gallery: [FaceObservation],
        threshold: Double = 78,
        continuity: Bool = false
    ) -> [MatchResult] {
        let f = MatchMath.floors(gallery: identities.count, slider: threshold)
        let floors = Floors(match: f.match, solo: f.solo)
        let models: [(id: UUID, name: String, owned: [FaceObservation])] = identities.map { ident in
            let owned = gallery.filter { ident.faceIds.contains($0.id) }
            return (ident.id, ident.name, owned)
        }
        var centroidCache: [String: [Double]] = [:]
        var ratioCache: [String: [[Double]]] = [:]
        return probes.map { face in
            let pv = embedding(of: face)
            let probeRatios = face.ratioSheet.filter(\.identity).map(\.value)
            let probeSlot = poseSlot(face)
            var versus: [IdentityScore] = []
            versus.reserveCapacity(models.count)
            var printVersus: [IdentityScore] = []
            printVersus.reserveCapacity(models.count)
            var geoVersus: [(id: UUID, percent: Double)] = []
            geoVersus.reserveCapacity(models.count)
            var modelVec: [UUID: [Double]] = [:]
            let poseW = poseWeight(face.quality)
            for m in models {
                let pale = MatchMath.palePrintDroppedCount(m.owned, enrolledAt: { $0.enrolledAt })
                let key = MatchMath.liveCentroidCacheKey(
                    ids: m.owned.map(\.id),
                    slot: probeSlot.rawValue,
                    paleDropped: pale
                )
                let vec: [Double]
                if let hit = centroidCache[key] {
                    vec = hit
                } else {
                    vec = liveCentroid(m.owned, slot: probeSlot)
                    centroidCache[key] = vec
                }
                modelVec[m.id] = vec
                let printPct: Double
                let measured: Bool
                if pv.count >= 32, vec.count == pv.count {
                    printPct = MatchMath.printSigmoid(cosine: cosine(pv, vec))
                    measured = true
                } else {
                    printPct = 0
                    measured = false
                }
                let ratioPool: [[Double]]
                if let hit = ratioCache[key] {
                    ratioPool = hit
                } else {
                    let slotOwned = m.owned.filter { poseSlot($0) == probeSlot }
                    let poolSrc = slotOwned.isEmpty ? m.owned : slotOwned
                    ratioPool = poolSrc.map { $0.ratioSheet.filter(\.identity).map(\.value) }.filter { !$0.isEmpty }
                    ratioCache[key] = ratioPool
                }
                let geo = MatchMath.ratioPercent(probeRatios, MatchMath.medianComponents(ratioPool))
                let look = measured
                    ? MatchMath.lookOf(geo: geo, embed: printPct, pose: poseW, printMeasured: true)
                    : 0
                versus.append(IdentityScore(identityId: m.id, percent: look))
                printVersus.append(IdentityScore(identityId: m.id, percent: printPct))
                geoVersus.append((m.id, geo))
            }
            versus.sort { $0.percent > $1.percent }
            printVersus.sort { $0.percent > $1.percent }
            geoVersus.sort { $0.percent > $1.percent }
            let printWinnerEarly = printVersus.first
            let printMarginEarly = (printWinnerEarly?.percent ?? 0) - (printVersus.dropFirst().first?.percent ?? 0)
            let familyEarly: Bool = {
                guard let a = versus.first?.identityId, let b = printWinnerEarly?.identityId, a != b,
                      let va = modelVec[a], let vb = modelVec[b],
                      va.count >= 32, va.count == vb.count
                else { return false }
                return cosine(va, vb) >= MatchMath.familyCosineLo
            }()
            var printLed = false
            if MatchMath.liveNamePrintLeads(
                lookId: versus.first?.identityId,
                printId: printWinnerEarly?.identityId,
                printMeasured: pv.count >= 32,
                printMargin: printMarginEarly,
                family: familyEarly
            ), let pWin = printWinnerEarly,
               let idx = versus.firstIndex(where: { $0.identityId == pWin.identityId })
            {
                // LookOf-Prozent behalten. Print-Prozent unter Floor 84 kippte decide,
                // obwohl Look 86 (Print + Geo) durch wäre.
                let row = versus.remove(at: idx)
                versus.insert(row, at: 0)
                printLed = true
            }
            let best = versus.first
            let second = versus.dropFirst().first
            let margin = (best?.percent ?? 0) - (second?.percent ?? 0)
            let geoAvailable = !probeRatios.isEmpty && geoVersus.contains { $0.percent > 0 }
            let geoBest = geoVersus.first
            let geoMix: Double = {
                guard geoAvailable, let id = best?.identityId else { return 100 }
                return geoVersus.first { $0.id == id }?.percent ?? 0
            }()
            let geoMargin = (geoBest?.percent ?? 0) - (geoVersus.dropFirst().first?.percent ?? 0)
            let bump: Double
            let pairCos: Double?
            if let a = best?.identityId, let b = second?.identityId,
               let va = modelVec[a], let vb = modelVec[b],
               va.count >= 32, va.count == vb.count
            {
                let c = cosine(va, vb)
                pairCos = c
                bump = MatchMath.familyBump(bestPairCosine: c)
            } else {
                pairCos = nil
                bump = 0
            }
            let liveFloors = Floors(match: min(96, floors.match + bump), solo: min(96, floors.solo + bump))
            let printBest = printVersus.first { $0.identityId == best?.identityId }
            let printWinner = printVersus.first
            let nameAgree = MatchMath.liveNameAgree(
                lookId: best?.identityId,
                printId: printWinner?.identityId,
                printMeasured: pv.count >= 32
            )
            let capNote = MatchMath.lookOfCapNote(geo: geoMix, embed: printBest?.percent ?? 0)
            let decided = decide(
                percent: best?.percent ?? 0,
                margin: margin,
                bestId: best?.identityId,
                bestName: models.first { $0.id == best?.identityId }?.name,
                secondName: models.first { $0.id == second?.identityId }?.name,
                geoAgrees: MatchMath.liveGeoAgrees(
                    printBest: best?.identityId,
                    geoBest: geoBest?.id,
                    geoAvailable: geoAvailable
                ),
                geoMargin: geoAvailable ? geoMargin : margin,
                lowCapture: tinyUnreliable(face.quality, continuity: continuity),
                appearance: nil,
                geoMix: geoMix,
                galleryZ: galleryZScore(best?.percent ?? 0, versus.dropFirst().map(\.percent)),
                textureReliable: false,
                evidence: best?.percent ?? 0,
                floors: liveFloors,
                yawAbs: abs(face.quality.yaw)
            )
            var note: String = {
                guard let capNote else { return decided.note }
                if decided.note.isEmpty { return capNote }
                return capNote + ". " + decided.note
            }()
            var decidedId = decided.id
            if !nameAgree {
                decidedId = nil
                let disagree = MatchMath.liveNameDisagreeNote()
                note = note.isEmpty ? disagree : disagree + ". " + note
            } else if printLed {
                let lead = MatchMath.liveNamePrintLeadsNote()
                note = note.isEmpty ? lead : lead + ". " + note
            }
            let printHit = StrategyHit(
                strategy: .featurePrint,
                identityId: decidedId,
                percent: printBest?.percent ?? 0,
                margin: (printVersus.first?.percent ?? 0) - (printVersus.dropFirst().first?.percent ?? 0),
                versus: printVersus,
                note: decided.note,
                measured: pv.count >= 32
            )
            let aegisHit = StrategyHit(
                strategy: .aegis,
                identityId: decidedId,
                percent: best?.percent ?? 0,
                margin: margin,
                versus: versus,
                note: note,
                measured: pv.count >= 32,
                geoMix: geoAvailable ? geoMix : nil,
                pairCosine: pairCos
            )
            return MatchResult(faceId: face.id, hits: [printHit, aegisHit])
        }
    }

    // MARK: - geometry / prints

    private struct Floors {
        let match: Double
        let solo: Double
    }

    private static let embedMargin = 12.0
    private static let landmarkMargin = 14.0
    private static let zFloor = 1.5

    /// Slider ist Bias um 78. Kleine Galerien brauchen höhere Floors, sonst
    /// tauft ein einzelner Impostor-Treffer die einzige Person.
    static func effectiveFloors(galleryCount: Int, slider: Double, familyBump: Double = 0) -> (match: Double, solo: Double) {
        let f = MatchMath.floors(gallery: galleryCount, slider: slider, familyBump: familyBump)
        return (f.match, f.solo)
    }

    static func overlayHint(_ face: FaceObservation, gallery: [FaceObservation] = [], continuity: Bool = false) -> String? {
        if face.featurePrint.isEmpty {
            return MatchMath.printDeadLabel(
                capture: face.quality.capture,
                sharpness: face.quality.sharpness,
                masked: lowerFaceOccluded(face),
                continuity: continuity
            )
        }
        if face.quality.capture < 0.35 && face.quality.size < 0.16 { return "z zu klein" }
        if abs(face.quality.yaw) > 0.75 { return "Profil" }
        if face.quality.frontal < 0.22 { return "stark gedreht" }
        if face.quality.sharpness < MatchMath.activeSharpnessFloor(continuity: continuity) { return "unscharf" }
        let eyes = face.strokes.contains { $0.label.hasPrefix("Auge") && $0.points.count >= 4 }
        let mouth = face.strokes.contains { ($0.label == "Mund" || $0.label == "Lippen") && $0.points.count >= 4 }
        if eyes && !mouth { return partialEmbedding(of: face).count >= 32 ? "Maske · Teil-Print" : "Maske?" }
        if face.forcedPartial { return partialEmbedding(of: face).count >= 32 ? "U-Slot · Teil-Print" : "U-Slot" }
        if !eyes && mouth { return "Sonnenbrille / Okklusion?" }
        if gallery.count >= 1 {
            let pv = embedding(of: face)
            let mean = liveCentroid(gallery, slot: poseSlot(face))
            if pv.count >= 32, mean.count == pv.count {
                let c = cosine(pv, mean)
                if MatchMath.overlayAlienHint(cosine: c) { return "andere Person oder Brille?" }
            }
        }
        return nil
    }

    enum PoseSlot: String {
        case frontal, threeQuarter, profile, upper
        var titleDE: String {
            switch self {
            case .frontal: return "Frontal"
            case .threeQuarter: return "¾"
            case .profile: return "Profil"
            case .upper: return "Teil-Print"
            }
        }
    }

    static func poseSlot(_ face: FaceObservation) -> PoseSlot {
        if face.forcedPartial || lowerFaceOccluded(face) { return .upper }
        let y = abs(face.quality.yaw)
        if y >= 0.70 { return .profile }
        if y >= 0.28 { return .threeQuarter }
        return .frontal
    }

    static func poseCoverage(identity: Identity, faces: [FaceObservation]) -> (frontal: Int, threeQuarter: Int, profile: Int, upper: Int) {
        let refs = faces.filter { identity.faceIds.contains($0.id) }
        var f = 0, q = 0, p = 0, u = 0
        for r in refs {
            switch poseSlot(r) {
            case .frontal: f += 1
            case .threeQuarter: q += 1
            case .profile: p += 1
            case .upper: u += 1
            }
        }
        return (f, q, p, u)
    }

    static func poseCoverageLabel(identity: Identity, faces: [FaceObservation]) -> String {
        let c = poseCoverage(identity: identity, faces: faces)
        return "F\(c.frontal) · ¾\(c.threeQuarter) · P\(c.profile) · U\(c.upper)"
    }

    static func enrollmentCoach(
        face: FaceObservation,
        identity: Identity?,
        faces: [FaceObservation]
    ) -> String? {
        var haveF = false
        var haveQ = false
        if let identity {
            let c = poseCoverage(identity: identity, faces: faces)
            haveF = c.frontal >= 1
            haveQ = c.threeQuarter >= 1
        }
        return MatchMath.enrollmentCoach(haveFrontal: haveF, haveThreeQuarter: haveQ, yaw: face.quality.yaw)
    }

    static func poseCoverageWarning(
        adding face: FaceObservation,
        to identity: Identity,
        faces: [FaceObservation]
    ) -> String? {
        let slot = poseSlot(face)
        let c = poseCoverage(identity: identity, faces: faces)
        let have: Int
        switch slot {
        case .frontal: have = c.frontal
        case .threeQuarter: have = c.threeQuarter
        case .profile: have = c.profile
        case .upper: have = c.upper
        }
        guard have >= 2 else { return nil }
        var missing: [String] = []
        if c.frontal == 0 { missing.append("Frontal") }
        if c.threeQuarter == 0 { missing.append("¾") }
        if c.profile == 0 { missing.append("Profil") }
        if c.upper == 0, lowerFaceOccluded(face) { missing.append("Teil-Print") }
        guard !missing.isEmpty else { return nil }
        return "\(slot.titleDE) schon \(have)× — fehlt \(missing.joined(separator: ", "))"
    }

    static func poseCoverageBlocks(
        adding face: FaceObservation,
        to identity: Identity,
        faces: [FaceObservation]
    ) -> String? {
        let slot = poseSlot(face)
        if slot == .upper { return nil }
        let c = poseCoverage(identity: identity, faces: faces)
        let have: Int
        switch slot {
        case .frontal: have = c.frontal
        case .threeQuarter: have = c.threeQuarter
        case .profile: have = c.profile
        case .upper: have = c.upper
        }
        guard have >= 2 else { return nil }
        var missing: [String] = []
        if c.frontal == 0 { missing.append("Frontal") }
        if c.threeQuarter == 0 { missing.append("¾") }
        guard !missing.isEmpty else { return nil }
        return "\(slot.titleDE) schon \(have)× — erst \(missing.joined(separator: " oder ")) aufnehmen"
    }

    static func enrollmentPreview(
        face: FaceObservation,
        identities: [Identity],
        faces: [FaceObservation],
        addingTo: Identity? = nil
    ) -> String {
        var parts: [String] = []
        if let dest = addingTo {
            let refs = faces.filter { dest.faceIds.contains($0.id) }
            let mean = meanPrintVector(refs)
            let v = embedding(of: face)
            if mean.count >= 32, v.count == mean.count {
                let p = 100.0 / (1.0 + exp(-14.0 * (cosine(v, mean) - 0.55)))
                parts.append(String(format: "zu \(dest.name) %.0f %%", p))
            }
            if let w = poseCoverageWarning(adding: face, to: dest, faces: faces) {
                parts.append(w)
            }
            let c = poseCoverage(identity: dest, faces: faces)
            parts.append(MatchMath.poseMeterLabel(frontal: c.frontal, threeQuarter: c.threeQuarter, profile: c.profile, upper: c.upper))
        }
        if let coach = enrollmentCoach(face: face, identity: addingTo, faces: faces) {
            parts.insert(coach, at: 0)
        }
        if let dup = duplicateOf(face: face, identities: identities, faces: faces),
           dup.0.id != addingTo?.id
        {
            parts.append(String(format: "ähnlich \(dup.0.name) %.0f %%", dup.1 * 100))
        }
        if addingTo == nil, !face.featurePrint.isEmpty {
            parts.append(poseSlot(face).titleDE)
        }
        return parts.joined(separator: " · ")
    }

    private struct IdentityModel {
        var identity: Identity
        var photos: FaceObservation?
        var meanPrint: [FaceObservation]
        var meanVec: [Double]
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
        floors: Floors,
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
            assign = (best?.percent ?? 0) >= floors.match && (margin >= minMargin || strong)
        } else {
            assign = (best?.percent ?? 0) >= floors.solo && minMargin <= embedMargin
        }
        return Ranked(
            identityId: assign ? best?.identityId : nil,
            percent: best?.percent ?? 0,
            margin: margin,
            versus: versus
        )
    }

    private static func hint(_ strategy: StrategyID, _ ranked: Ranked, floors: Floors, measured: Bool = true) -> StrategyHit {
        var copy = ranked
        copy.identityId = nil
        return toHit(strategy, copy, floors: floors, measured: measured)
    }

    private static func toHit(_ strategy: StrategyID, _ ranked: Ranked, floors: Floors, note: String = "", measured: Bool = true) -> StrategyHit {
        let text: String
        if !measured {
            text = "nicht gemessen"
        } else if !note.isEmpty {
            text = note
        } else if ranked.identityId != nil {
            text = String(format: "Abstand %.1f Pkt.", ranked.margin)
        } else if ranked.versus.count < 2 {
            text = String(format: "Nur eine Person eingeschrieben. Nähe %.0f%% reicht nicht (braucht %.0f%%).", ranked.percent, floors.solo)
        } else if ranked.percent < floors.match {
            text = String(format: "Beste Nähe %.0f%% liegt unter %.0f%%.", ranked.percent, floors.match)
        } else {
            text = String(format: "Zu nah (%.1f Pkt Abstand) — nicht zugeordnet.", ranked.margin)
        }
        return StrategyHit(
            strategy: strategy,
            identityId: ranked.identityId,
            percent: ranked.percent,
            margin: ranked.margin,
            versus: ranked.versus,
            note: text,
            measured: measured
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
        evidence: Double? = nil,
        floors: Floors,
        yawAbs: Double = 0
    ) -> (id: UUID?, note: String) {
        let best = bestName ?? "Beste"
        let second = secondName ?? "Zweite"
        _ = appearance
        _ = textureReliable
        _ = evidence
        guard let bestId, percent > 0 else {
            return (nil, "Keine Vergleichsperson.")
        }
        if lowCapture {
            return (nil, String(format: "Aufnahme zu schwach für eine Zuordnung, Nähe %.0f%%.", percent))
        }
        if MatchMath.geoVetoBlocks(geoAgrees: geoAgrees, geoMix: geoMix, printPercent: percent, yawAbs: yawAbs) {
            return (nil, String(format: "Maße widersprechen (%.0f%%, Abstand %.1f). Print allein reicht nicht.", geoMix, geoMargin))
        }
        let yawNote = MatchMath.geoVetoYawSkipped(
            geoAgrees: geoAgrees, geoMix: geoMix, printPercent: percent, yawAbs: yawAbs
        ) ? "\(MatchMath.yawSkipNote()). " : ""
        if secondName == nil {
            if percent >= floors.solo {
                return (bestId, yawNote + String(format: "Nur eine Person eingeschrieben. Nähe %.0f%% reicht.", percent))
            }
            return (nil, String(format: "Nur eine Person eingeschrieben. Nähe %.0f%% reicht nicht (braucht %.0f%%). Andere Gesichter bleiben offen.", percent, floors.solo))
        }
        if percent < floors.match {
            return (nil, String(format: "Beste Nähe %.0f%% liegt unter %.0f%%. Nicht zugeordnet.", percent, floors.match))
        }
        if galleryZ < zFloor && percent < 92 {
            return (nil, String(format: "Kein Ausreißer in der Galerie (z=%.1f). Alle Personen ähnlich nah — nicht zugeordnet.", galleryZ))
        }
        if geoAgrees, geoMargin >= 8, percent >= floors.match - 3, margin >= 6 {
            return (bestId, yawNote + String(format: "Print + Maße einig. Abstand %.1f Pkt zu %@.", margin, second))
        }
        if margin >= embedMargin || (percent >= 94 && margin >= 6) {
            return (bestId, yawNote + String(format: "Abstand %.1f Pkt zu %@.", margin, second))
        }
        return (nil, String(format: "%@ %.0f%% und %@ %.0f%% zu nah — nicht zugeordnet.", best, percent, second, percent - margin))
    }

    private static func bestPrintPercent(_ probe: FaceObservation, _ faces: [FaceObservation]) -> Double {
        let full = fullPrintPercent(probe, faces)
        if lowerFaceOccluded(probe), probe.partialVec.count >= 32 || !probe.partialPrint.isEmpty {
            let pv = partialEmbedding(of: probe)
            let pMean = meanPartialVector(faces)
            if pv.count >= 32, pMean.count == pv.count {
                let partial = sigmoidCosine(pv, pMean)
                return MatchMath.combinePrint(full: full, partial: partial, occluded: true, galleryHasPartial: true)
            }
            // Kein Teil-Print in der Galerie: Partial nicht gegen Full-Centroid.
            return MatchMath.combinePrint(full: full, partial: 0, occluded: true, galleryHasPartial: false)
        }
        return full
    }

    private static func fullPrintPercent(_ probe: FaceObservation, _ faces: [FaceObservation]) -> Double {
        let pv = embedding(of: probe)
        let slot = poseSlot(probe)
        let same = faces.filter { poseSlot($0) == slot }
        let slotMean = meanPrintVector(same)
        let allMean = meanPrintVector(faces)
        if pv.count >= 32, slotMean.count == pv.count, same.count >= 1 {
            let a = sigmoidCosine(pv, slotMean)
            if allMean.count == pv.count, same.count < faces.count {
                return 0.72 * a + 0.28 * sigmoidCosine(pv, allMean)
            }
            return a
        }
        if pv.count >= 32, allMean.count == pv.count {
            return sigmoidCosine(pv, allMean)
        }
        guard !probe.featurePrint.isEmpty else { return 0 }
        var scores: [Double] = []
        let pool = same.isEmpty ? faces : same
        for f in pool where !f.featurePrint.isEmpty {
            scores.append(printPercent(probe.featurePrint, f.featurePrint))
        }
        guard !scores.isEmpty else { return 0 }
        scores.sort(by: >)
        if scores.count == 1 { return scores[0] }
        // Nicht max: ein Glückstreffer gegen eine schlechte Referenz tauft Impostoren.
        let k = max(1, (scores.count + 1) / 2)
        let top = scores.prefix(k)
        return top.reduce(0, +) / Double(top.count)
    }

    /// L2-normierter Mittel-Vektor der Galerie-Prints. Unscharfe Refs zählen
    /// mit `capture * sharpness`, nicht 1/n — eine verwackelte Kopie zieht
    /// den Mittelvektor nicht mehr auf Impostor-Niveau.
    static func meanPrintVector(_ faces: [FaceObservation]) -> [Double] {
        let clear = faces.filter { !lowerFaceOccluded($0) }
        let pool = clear.isEmpty ? faces : clear
        var acc: [Double] = []
        var wsum = 0.0
        for f in pool {
            let v = embedding(of: f)
            guard v.count >= 32 else { continue }
            let w = max(0.08, f.quality.capture * (0.35 + 0.65 * max(0, f.quality.sharpness)))
            if acc.isEmpty {
                acc = v.map { $0 * w }
            } else if acc.count == v.count {
                for i in acc.indices { acc[i] += v[i] * w }
            } else { continue }
            wsum += w
        }
        guard wsum > 0, !acc.isEmpty else { return [] }
        let inv = 1.0 / wsum
        for i in acc.indices { acc[i] *= inv }
        return l2normalize(acc)
    }

    /// Live: Slot-Centroid wenn der Pose-Slot Refs hat, sonst Frontal, nie Profil-Mix.
    /// Slot-Hit überspringt den All-Mean (teuer und falsch gegen ¾).
    /// Pale Prints (≥ 90 d) raus, solange frische bleiben — sonst driftet der Name.
    static func liveCentroid(_ faces: [FaceObservation], slot: PoseSlot? = nil, now: Date = Date()) -> [Double] {
        let pale = faces.filter { MatchMath.palePrintDrops(enrolledAt: $0.enrolledAt, now: now) }.count
        let pool: [FaceObservation]
        if pale > 0, pale < faces.count {
            pool = faces.filter { !MatchMath.palePrintDrops(enrolledAt: $0.enrolledAt, now: now) }
        } else {
            pool = faces
        }
        let slotCount = slot.map { s in pool.filter { poseSlot($0) == s }.count } ?? 0
        if let slot, MatchMath.preferSlotCentroid(slotCount: slotCount) {
            let slotMean = meanPrintVector(pool.filter { poseSlot($0) == slot })
            if slotMean.count >= 32 { return slotMean }
        }
        if slot != nil, MatchMath.slotCentroidFallsBackToFrontal(slotCount: slotCount) {
            let front = meanPrintVector(pool.filter { poseSlot($0) == .frontal })
            if front.count >= 32 { return front }
        }
        let all = meanPrintVector(pool)
        let front = meanPrintVector(pool.filter { poseSlot($0) == .frontal })
        if front.count >= 32, all.count == front.count {
            return blendEmbeddings(all, front, alpha: MatchMath.liveCentroidFront)
        }
        return all.isEmpty ? front : all
    }

    /// Teil-Print-Centroid nur aus Masken-Refs. Leeres Array = Galerie hat keinen U-Slot.
    static func meanPartialVector(_ faces: [FaceObservation]) -> [Double] {
        var acc: [Double] = []
        var wsum = 0.0
        for f in faces {
            let v = partialEmbedding(of: f)
            guard v.count >= 32 else { continue }
            let w = max(0.08, f.quality.capture * (0.35 + 0.65 * max(0, f.quality.sharpness)))
            if acc.isEmpty {
                acc = v.map { $0 * w }
            } else if acc.count == v.count {
                for i in acc.indices { acc[i] += v[i] * w }
            } else { continue }
            wsum += w
        }
        guard wsum > 0, !acc.isEmpty else { return [] }
        let inv = 1.0 / wsum
        for i in acc.indices { acc[i] *= inv }
        return l2normalize(acc)
    }

    static func printWeights(_ faces: [FaceObservation]) -> [(id: UUID, weight: Double, slot: String)] {
        faces.map { f in
            let has = f.printVec.count >= 32 || !f.featurePrint.isEmpty
            let w = has ? max(0.08, f.quality.capture * (0.35 + 0.65 * max(0, f.quality.sharpness))) : 0
            return (f.id, w, poseSlot(f).titleDE)
        }
    }

    static func embedding(of face: FaceObservation) -> [Double] {
        if face.printVec.count >= 32 { return face.printVec }
        return printVector(face.featurePrint)
    }

    static func partialEmbedding(of face: FaceObservation) -> [Double] {
        if face.partialVec.count >= 32 { return face.partialVec }
        return printVector(face.partialPrint)
    }

    static func blendEmbeddings(_ old: [Double], _ new: [Double], alpha: Double) -> [Double] {
        guard old.count == new.count, old.count >= 32 else {
            return new.count >= 32 ? l2normalize(new) : old
        }
        let a = min(1, max(0, alpha))
        var out = [Double](repeating: 0, count: old.count)
        for i in old.indices { out[i] = old[i] * (1 - a) + new[i] * a }
        return l2normalize(out)
    }

    private static func l2normalize(_ v: [Double]) -> [Double] {
        var s = 0.0
        for x in v { s += x * x }
        let n = sqrt(s)
        guard n > 1e-12 else { return v }
        return v.map { $0 / n }
    }

    private static func sigmoidCosine(_ a: [Double], _ b: [Double]) -> Double {
        MatchMath.printSigmoid(cosine: cosine(a, b))
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

    static func lowerFaceOccluded(_ face: FaceObservation) -> Bool {
        let eyes = face.strokes.contains { $0.label.hasPrefix("Auge") && $0.points.count >= 4 }
        let mouth = face.strokes.contains { ($0.label == "Mund" || $0.label == "Lippen") && $0.points.count >= 4 }
        return MatchMath.lowerFaceOccluded(eyes: eyes, mouth: mouth)
    }

    private static func upperFaceCrop(_ image: CGImage, box: FaceBox) -> CGImage? {
        var u = box
        u.height = max(8, box.height * 0.56)
        return crop(image, box: u, pad: 0.10)
    }

    /// Apple face-identity print on a natural crop. Never image-print.
    /// Vision aligns internally; strong roll (|θ| ≥ 8°) is deskewed first so
    /// the crop isn't sideways before Vision sees it.
    private static func identityPrint(of image: CGImage?) -> Data? {
        facePrintOnly(of: image)
    }

    private static func rotate(_ image: CGImage, radians: Double) -> CGImage? {
        let w = image.width
        let h = image.height
        guard w > 2, h > 2 else { return nil }
        let c = abs(cos(radians))
        let s = abs(sin(radians))
        let nw = max(w, Int((Double(w) * c + Double(h) * s).rounded(.up)))
        let nh = max(h, Int((Double(w) * s + Double(h) * c).rounded(.up)))
        let color = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil,
            width: nw,
            height: nh,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: color,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        ctx.translateBy(x: CGFloat(nw) / 2, y: CGFloat(nh) / 2)
        ctx.rotate(by: CGFloat(-radians))
        ctx.translateBy(x: -CGFloat(w) / 2, y: -CGFloat(h) / 2)
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
        return ctx.makeImage()
    }

    private static func deskewIfNeeded(_ image: CGImage, face: FaceObservation) -> CGImage {
        guard let eyes = eyeCenters(face) else { return image }
        let roll = MatchMath.eyeRoll(
            left: CGPoint(x: eyes.0.x, y: eyes.0.y),
            right: CGPoint(x: eyes.1.x, y: eyes.1.y)
        )
        guard MatchMath.cropAligns(roll: roll), let spun = rotate(image, radians: roll) else { return image }
        return spun
    }

    private static func facePrintOnly(of image: CGImage?, orientation: CGImagePropertyOrientation = .up) -> Data? {
        guard let image else { return nil }
        guard let req = makeFacePrintRequest() else { return nil }
        let handler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
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

    private static func stampPrints(_ faces: [FaceObservation], from image: CGImage, orientation: CGImagePropertyOrientation = .up, continuity: Bool = false, minSharpness: Double = MatchMath.sharpnessFloor) -> [FaceObservation] {
        let anySharp = faces.contains { !MatchMath.skipPrint(sharpness: $0.quality.sharpness, continuity: continuity) && $0.quality.sharpness >= minSharpness }
        let found = anySharp ? facePrintsInImage(image, orientation: orientation) : []
        var used = Set<Int>()
        return faces.map { face in
            var next = face
            if MatchMath.skipPrint(sharpness: face.quality.sharpness, continuity: continuity) {
                next.featurePrint = Data()
                next.printVec = []
                return next
            }
            var bestI = -1
            var bestIoU = 0.12
            for (i, item) in found.enumerated() where !used.contains(i) {
                let o = iou(item.box, face.box)
                if o > bestIoU {
                    bestIoU = o
                    bestI = i
                }
            }
            if bestI < 0, found.count == 1, faces.count == 1, !used.contains(0) {
                bestI = 0
            }
            if bestI >= 0 {
                used.insert(bestI)
                next.featurePrint = found[bestI].data
                next.printVec = printVector(found[bestI].data)
            } else if let crop = self.crop(image, box: face.box, pad: 0.55),
                      let data = facePrintOnly(of: deskewIfNeeded(crop, face: face), orientation: .up)
            {
                next.featurePrint = data
                next.printVec = printVector(data)
            } else {
                next.featurePrint = Data()
                next.printVec = []
            }
            if lowerFaceOccluded(next) || next.forcedPartial,
               let crop = upperFaceCrop(image, box: face.box),
               let data = facePrintOnly(of: crop, orientation: orientation)
            {
                next.partialPrint = data
                next.partialVec = printVector(data)
            }
            return next
        }
    }

    /// Expliziter U-Slot: oberes Crop auch ohne Auto-Maske.
    static func stampForcedPartial(_ face: FaceObservation, from image: CGImage, orientation: CGImagePropertyOrientation = .up) -> FaceObservation? {
        guard let crop = upperFaceCrop(image, box: face.box),
              let data = facePrintOnly(of: crop, orientation: orientation)
        else { return nil }
        var next = face
        next.partialPrint = data
        next.partialVec = printVector(data)
        next.forcedPartial = true
        return next
    }

    private struct LocatedPrint {
        var box: FaceBox
        var data: Data
    }

    /// Run Apple's face-print on the whole photo so Vision can detect and align itself.
    /// Warped 256px patches made the request fail and silently stored an image-print of the jacket.
    private static func facePrintsInImage(_ image: CGImage, orientation: CGImagePropertyOrientation = .up) -> [LocatedPrint] {
        guard let req = makeFacePrintRequest() else { return [] }
        let handler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
        guard (try? handler.perform([req])) != nil else { return [] }
        let w = Double(image.width)
        let h = Double(image.height)
        var out: [LocatedPrint] = []
        for obs in req.results ?? [] {
            guard let data = extractPrint(obs) else { continue }
            let box: FaceBox
            if let face = obs as? VNFaceObservation {
                box = vnToPixels(face.boundingBox, width: w, height: h)
            } else if let obj = obs as? VNDetectedObjectObservation {
                box = vnToPixels(obj.boundingBox, width: w, height: h)
            } else {
                continue
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

    private static let printVecLock = NSLock()
    private static var printVecCache: [Data: [Double]] = [:]

    private static func printVector(_ data: Data) -> [Double] {
        printVecLock.lock()
        if let hit = printVecCache[data] {
            printVecLock.unlock()
            return hit
        }
        printVecLock.unlock()
        let vals = decodePrintVector(data)
        printVecLock.lock()
        if printVecCache.count > 512 { printVecCache.removeAll(keepingCapacity: true) }
        printVecCache[data] = vals
        printVecLock.unlock()
        return vals
    }

    private static func decodePrintVector(_ data: Data) -> [Double] {
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

    /// Genuine Apple-FacePrint-Cosine typisch 0,62–0,92; Impostoren 0,15–0,50.
    /// Mitte 0,42 hat Impostoren bei 0,45 schon ~58 % gegeben.
    private static func printPercent(_ a: Data, _ b: Data) -> Double {
        guard !a.isEmpty, !b.isEmpty else { return 0 }
        let va = printVector(a)
        let vb = printVector(b)
        if va.count >= 32, vb.count >= 32 {
            guard va.count == vb.count else { return 0 }
            let c = cosine(va, vb)
            return 100.0 / (1.0 + exp(-14.0 * (c - 0.55)))
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
        let cells = 8
        let bins = 10
        guard let ctx = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return [] }
        ctx.interpolationQuality = .medium
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: size, height: size))
        guard let data = ctx.data else { return [] }
        let ptr = data.bindMemory(to: UInt8.self, capacity: size * size)
        var pix = [Double](repeating: 0, count: size * size)
        for i in 0 ..< size * size {
            pix[i] = pow(Double(ptr[i]) / 255, 0.2)
        }
        var dog = pix
        for y in 1 ..< size - 1 {
            for x in 1 ..< size - 1 {
                var s = 0.0
                for dy in -1 ... 1 {
                    for dx in -1 ... 1 { s += pix[(y + dy) * size + x + dx] }
                }
                dog[y * size + x] = pix[y * size + x] - s / 9
            }
        }
        let absMean = max(dog.reduce(0) { $0 + abs($1) } / Double(dog.count), 1e-6)
        dog = dog.map { tanh($0 / absMean) }
        var hist = [Double](repeating: 0, count: cells * cells * bins)
        for y in 1 ..< size - 1 {
            for x in 1 ..< size - 1 {
                let c = dog[y * size + x]
                var code = 0
                let nbs = [
                    dog[y * size + x + 1],
                    dog[(y + 1) * size + x + 1],
                    dog[(y + 1) * size + x],
                    dog[(y + 1) * size + x - 1],
                    dog[y * size + x - 1],
                    dog[(y - 1) * size + x - 1],
                    dog[(y - 1) * size + x],
                    dog[(y - 1) * size + x + 1],
                ]
                for (i, n) in nbs.enumerated() where n >= c { code |= 1 << i }
                var bits = 0
                var v = code
                var trans = 0
                var prev = v & 1
                for _ in 0 ..< 8 {
                    let b = v & 1
                    bits += b
                    if b != prev { trans += 1 }
                    prev = b
                    v >>= 1
                }
                let bin = trans <= 2 ? bits : 9
                let cy = min(cells - 1, y * cells / size)
                let cx = min(cells - 1, x * cells / size)
                hist[(cy * cells + cx) * bins + bin] += 1
            }
        }
        let norm = sqrt(hist.reduce(0) { $0 + $1 * $1 })
        let n = max(norm, 1e-9)
        return hist.map { $0 / n }
    }

    private static func mahalanobisPercent(_ probe: [Double], _ gallery: [[Double]], pooledInv: [[Double]]?) -> Double {
        guard !probe.isEmpty, !gallery.isEmpty else { return 0 }
        if let inv = pooledInv, inv.count == probe.count {
            let mean = averageRaw(gallery)
            guard mean.count == probe.count else { return bestRatioPercent(probe, gallery) }
            var delta = [Double](repeating: 0, count: probe.count)
            for i in 0 ..< probe.count { delta[i] = probe[i] - mean[i] }
            var tmp = [Double](repeating: 0, count: probe.count)
            for i in 0 ..< probe.count {
                for j in 0 ..< probe.count { tmp[i] += inv[i][j] * delta[j] }
            }
            var d2 = 0.0
            for i in 0 ..< probe.count { d2 += delta[i] * tmp[i] }
            return 100.0 / (1.0 + exp(0.85 * (sqrt(max(0, d2)) - 2.2)))
        }
        return bestRatioPercent(probe, gallery)
    }

    private static func pooledInverse(_ samples: [[Double]]) -> [[Double]]? {
        guard let d = samples.first?.count, d > 0, d <= 40, samples.count >= 3 else { return nil }
        let usable = samples.filter { $0.count == d }
        guard usable.count >= 3 else { return nil }
        let mean = averageRaw(usable)
        var cov = Array(repeating: Array(repeating: 0.0, count: d), count: d)
        for s in usable {
            for i in 0 ..< d {
                for j in 0 ..< d {
                    cov[i][j] += (s[i] - mean[i]) * (s[j] - mean[j])
                }
            }
        }
        let n = Double(usable.count)
        for i in 0 ..< d {
            for j in 0 ..< d { cov[i][j] /= n }
            cov[i][i] += 0.05
        }
        return invertMatrix(cov)
    }

    private static func invertMatrix(_ a0: [[Double]]) -> [[Double]]? {
        let n = a0.count
        var a = a0
        var inv = (0 ..< n).map { i in (0 ..< n).map { j in i == j ? 1.0 : 0.0 } }
        for i in 0 ..< n {
            var piv = i
            var best = abs(a[i][i])
            for r in (i + 1) ..< n where abs(a[r][i]) > best {
                best = abs(a[r][i])
                piv = r
            }
            if best < 1e-12 { return nil }
            if piv != i {
                a.swapAt(i, piv)
                inv.swapAt(i, piv)
            }
            let diag = a[i][i]
            for j in 0 ..< n {
                a[i][j] /= diag
                inv[i][j] /= diag
            }
            for r in 0 ..< n where r != i {
                let f = a[r][i]
                for j in 0 ..< n {
                    a[r][j] -= f * a[i][j]
                    inv[r][j] -= f * inv[i][j]
                }
            }
        }
        return inv
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

    private static func ratioSheet(_ n: NamedFace, identityOnly: Bool = false) -> [NamedRatio] {
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
        let rows = [
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
        return identityOnly ? rows.filter(\.identity) : rows
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
        MatchMath.ratioPercent(a, b)
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

    static func iou(_ a: FaceBox, _ b: FaceBox) -> Double {
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

    static func qualityRejects(_ q: FaceQuality, continuity: Bool = false) -> Bool {
        MatchMath.qualityRejects(capture: q.capture, size: q.size, sharpness: q.sharpness, continuity: continuity)
    }

    static func referenceRejected(_ face: FaceObservation, asFirstReference: Bool = false, continuity: Bool = false) -> String? {
        if face.featurePrint.isEmpty {
            return "Kein Face-Print — Referenz würde die Galerie vergiften."
        }
        let floor = MatchMath.activeSharpnessFloor(continuity: continuity)
        if face.quality.sharpness < floor {
            return String(format: "Unscharf %.0f %% — mindestens %.0f %% für eine Referenz.", face.quality.sharpness * 100, floor * 100)
        }
        if face.quality.capture < (asFirstReference ? 0.40 : 0.28) {
            return String(
                format: "Aufnahme %.0f %% — mindestens %.0f %% für eine Referenz.",
                face.quality.capture * 100,
                (asFirstReference ? 0.40 : 0.28) * 100
            )
        }
        // Profil als erste Referenz verdreht den L2-Centroid; spätere ¾-Shots sind ok.
        if asFirstReference, abs(face.quality.yaw) > 0.7 {
            return String(
                format: "Profil (Yaw %.0f°) — erste Referenz muss frontal sein, sonst verdreht der Centroid.",
                face.quality.yaw * 180 / .pi
            )
        }
        if asFirstReference, lowerFaceOccluded(face) {
            return "Maske — erste Referenz muss frei sein, sonst vergiftet der Stoff den Centroid. Extra-Foto ohne Maske."
        }
        return nil
    }

    /// Cosine zweier L2-Embeddings. Öffentlich für Duplikat-Warnung und Labor.
    static func centroidCosine(_ a: [Double], _ b: [Double]) -> Double {
        cosine(a, b)
    }

    /// Höchste Centroid-Ähnlichkeit gegen eine andere Identität. Nil unter 0,88.
    static func duplicateOf(
        face: FaceObservation,
        identities: [Identity],
        faces: [FaceObservation]
    ) -> (Identity, Double)? {
        let v = embedding(of: face)
        guard v.count >= 32 else { return nil }
        var best: (Identity, Double)?
        for ident in identities {
            let refs = faces.filter { ident.faceIds.contains($0.id) }
            let mean = meanPrintVector(refs)
            guard mean.count >= 32 else { continue }
            let c = cosine(v, mean)
            if c > 0.82, c > (best?.1 ?? 0) {
                best = (ident, c)
            }
        }
        return best
    }

    /// Burst-/Tile-Kopien: Cosine > 0,95 gegen schon gesehene Prints raus.
    static func filterIngestDuplicates(_ incoming: [FaceObservation], existing: [FaceObservation]) -> [FaceObservation] {
        var pool: [[Double]] = existing.compactMap { f in
            let v = embedding(of: f)
            return v.count >= 32 ? v : nil
        }
        var kept: [FaceObservation] = []
        kept.reserveCapacity(incoming.count)
        for face in incoming {
            let v = embedding(of: face)
            if v.count >= 32, pool.contains(where: { MatchMath.ingestDuplicate(cosine: MatchMath.cosine(v, $0)) }) {
                continue
            }
            kept.append(face)
            if v.count >= 32 { pool.append(v) }
        }
        return kept
    }

    private static func tinyUnreliable(_ q: FaceQuality, continuity: Bool = false) -> Bool {
        MatchMath.qualityRejects(capture: q.capture, size: q.size, sharpness: q.sharpness, continuity: continuity)
    }

    private static func textureIsReliable(_ q: FaceQuality, continuity: Bool = false) -> Bool {
        q.capture >= 0.28 && q.sharpness >= MatchMath.activeSharpnessFloor(continuity: continuity)
    }

    /// Print is the score. Geometry vetoes a mismatch and may add a small
    /// boost when it agrees — never a 0.25 mix that pulls a 92 % print under
    /// the 1-person soloFloor.
    private static func lookOf(geo: Double, embed: Double = 0, pose: Double = 1, printMeasured: Bool = false) -> Double {
        MatchMath.lookOf(geo: geo, embed: embed, pose: pose, printMeasured: printMeasured)
    }

    /// 1 = frontal, ~0.7 at 45°, 0 at 90°. Vision yaw/pitch are radians.
    /// yaw=0 und frontal=0 ist „keine Pose“, nicht maximales Vertrauen.
    private static func poseWeight(_ q: FaceQuality) -> Double {
        let off = hypot(q.yaw, q.pitch)
        if off < 0.02 {
            let f = clamp01(q.frontal)
            if f <= 0 { return 0.5 }
            return max(f, 0.35)
        }
        return clamp01(cos(min(off, Double.pi / 2)))
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

    /// Live: Distanz-Statistik ohne 4 Jacobi + Floyd–Warshall pro Frame.
    private static func cheapGraphBiomarkers(_ pts: [Point2]) -> [Double] {
        let n = pts.count
        guard n >= 8 else { return [] }
        var sum = 0.0
        var maxd = 1e-9
        var count = 0
        var cx = 0.0
        var cy = 0.0
        for p in pts {
            cx += p.x
            cy += p.y
        }
        cx /= Double(n)
        cy /= Double(n)
        var radial = 0.0
        for p in pts {
            radial += hypot(p.x - cx, p.y - cy)
        }
        radial /= Double(n)
        for i in 0 ..< n {
            for j in (i + 1) ..< n {
                let d = hypot(pts[i].x - pts[j].x, pts[i].y - pts[j].y)
                sum += d
                count += 1
                if d > maxd { maxd = d }
            }
        }
        let mean = count > 0 ? sum / Double(count) : 0
        return l2([mean, maxd, radial, Double(n), mean / maxd])
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
