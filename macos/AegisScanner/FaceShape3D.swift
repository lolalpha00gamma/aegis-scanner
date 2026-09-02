import Foundation

/// Pose-normalized 3D from 2D landmarks. Not a neural 3DMM.
/// Yaw/Pitch (Vision, radians) undo foreshortening and infer a crude depth.
enum FaceShape3D {
    struct P3: Hashable {
        var x: Double
        var y: Double
        var z: Double
    }

    static func descriptor(named: [Point2], yaw: Double, pitch: Double) -> [Double] {
        let pts = lift(named, yaw: yaw, pitch: pitch)
        guard pts.count >= 21 else { return [] }
        let iod = max(dist(pts[19], pts[20]), 1e-6)
        func n(_ a: Int, _ b: Int) -> Double { dist(pts[a], pts[b]) / iod }
        return [
            n(4, 5),
            n(6, 7),
            n(13, 14),
            n(17, 12),
            n(15, 16),
            n(19, 5),
            n(20, 5),
            n(0, 3),
            n(12, 5),
            abs(pts[5].z - pts[19].z) / iod,
            abs(pts[12].z - pts[5].z) / iod,
            n(8, 9),
            n(13, 12),
            n(14, 12),
        ]
    }

    static func lift(_ pts: [Point2], yaw: Double, pitch: Double) -> [P3] {
        guard !pts.isEmpty else { return [] }
        let cx = pts.map(\.x).reduce(0, +) / Double(pts.count)
        let cy = pts.map(\.y).reduce(0, +) / Double(pts.count)
        let cyaw = cos(yaw)
        let cpitch = cos(pitch)
        let sx = abs(cyaw) < 0.25 ? 1 : 1 / cyaw
        let sy = abs(cpitch) < 0.25 ? 1 : 1 / cpitch
        let ty = tan(max(-1.2, min(1.2, yaw)))
        let tp = tan(max(-1.2, min(1.2, pitch)))
        return pts.map { p in
            let x = (p.x - cx) * sx
            let y = (p.y - cy) * sy
            return P3(x: x, y: y, z: x * ty + y * tp)
        }
    }

    private static func dist(_ a: P3, _ b: P3) -> Double {
        hypot(hypot(a.x - b.x, a.y - b.y), a.z - b.z)
    }
}
