import CoreGraphics
import Foundation

/// Detect → 5-Punkt-Similarity → 112×112. Vertrag jedes funktionierenden
/// Recognizers in der 200-Repo-Liste (InsightFace, SFace, ArcFace, MagFace).
enum FaceAlign {
    static let size = 112

    static func fivePoints(from strokes: [LandmarkStroke]) -> [Point2]? {
        MatchMath.fivePoints(from: strokes)
    }

    static func fivePoints(from face: FaceObservation) -> [Point2]? {
        if let pts = fivePoints(from: face.strokes) { return pts }
        return MatchMath.fivePointsFromNamed(face.namedAligned.isEmpty ? face.aligned : face.namedAligned)
    }

    /// Landmark-Pixel sind top-left. CGContext ist bottom-left — wie `warpEyes`.
    static func warp(_ image: CGImage, points: [Point2], size: Int = FaceAlign.size) -> CGImage? {
        guard points.count >= 5, size >= 48 else { return nil }
        let dstDown = MatchMath.arcfaceTemplate112
        let H = Double(image.height)
        let srcCG = points.prefix(5).map { Point2(x: $0.x, y: H - $0.y) }
        let dstCG = dstDown.map { Point2(x: $0.x, y: Double(size) - $0.y) }
        guard let t = MatchMath.umeyamaSimilarity(src: Array(srcCG), dst: dstCG) else { return nil }
        guard let ctx = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        ctx.interpolationQuality = .high
        // x' = a x - b y + tx ; y' = b x + a y + ty
        ctx.concatenate(CGAffineTransform(a: t.a, b: t.b, c: -t.b, d: t.a, tx: t.tx, ty: t.ty))
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return ctx.makeImage()
    }

    static func warp(_ image: CGImage, face: FaceObservation, size: Int = FaceAlign.size) -> CGImage? {
        guard let pts = fivePoints(from: face) else { return nil }
        return warp(image, points: pts, size: size)
    }
}
