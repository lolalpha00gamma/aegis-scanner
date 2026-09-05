import Foundation

/// Pose-normalisierte 2D-Maße. Kein 3DMM, keine erfundene Tiefe.
/// Yaw/Pitch (Vision, Radiant) machen nur die Entzerrung `1/cos` —
/// der frühere z = x·tan(yaw)+y·tan(pitch)-Lift lag in der Bildebene
/// und hat den Deskriptor nur anisotrop umskaliert.
enum FaceShape3D {
    static func descriptor(named: [Point2], yaw: Double, pitch: Double) -> [Double] {
        let pts = undistort(named, yaw: yaw, pitch: pitch)
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
            n(8, 9),
            n(13, 12),
            n(14, 12),
        ]
    }

    static func undistort(_ pts: [Point2], yaw: Double, pitch: Double) -> [Point2] {
        guard !pts.isEmpty else { return [] }
        let cx = pts.map(\.x).reduce(0, +) / Double(pts.count)
        let cy = pts.map(\.y).reduce(0, +) / Double(pts.count)
        let cyaw = cos(yaw)
        let cpitch = cos(pitch)
        let sx = abs(cyaw) < 0.25 ? 1 : 1 / abs(cyaw)
        let sy = abs(cpitch) < 0.25 ? 1 : 1 / abs(cpitch)
        return pts.map { p in
            Point2(x: (p.x - cx) * sx, y: (p.y - cy) * sy)
        }
    }

    private static func dist(_ a: Point2, _ b: Point2) -> Double {
        hypot(a.x - b.x, a.y - b.y)
    }
}
