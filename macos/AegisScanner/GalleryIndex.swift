import Accelerate
import Foundation

/// 1:N über Identitäts-Centroids. Brute-Force GEMM reicht auf Apple Silicon
/// bis ~200k × 128-d; darüber wäre HNSW der nächste Index, nicht mehr Spuren.
struct GalleryIndex {
    var ids: [UUID]
    var matrix: [Float]
    var dim: Int

    var count: Int { ids.count }

    static func sface(identities: [Identity], faces: [FaceObservation]) -> GalleryIndex {
        build(identities: identities, faces: faces, vecOf: { $0.sfaceVec })
    }

    static func facePrint(identities: [Identity], faces: [FaceObservation]) -> GalleryIndex {
        build(identities: identities, faces: faces, vecOf: { FaceEngine.embedding(of: $0) })
    }

    private static func build(
        identities: [Identity],
        faces: [FaceObservation],
        vecOf: (FaceObservation) -> [Double]
    ) -> GalleryIndex {
        var ids: [UUID] = []
        var rows: [Float] = []
        var dim = 0
        for ident in identities {
            let owned = faces.filter { ident.faceIds.contains($0.id) }
            let mean = MatchMath.qualityCentroid(
                owned.map {
                    (
                        vec: vecOf($0),
                        capture: $0.quality.capture,
                        sharpness: $0.quality.sharpness,
                        frontal: $0.quality.frontal,
                        yaw: $0.quality.yaw
                    )
                }
            )
            guard mean.count >= 64 else { continue }
            if dim == 0 { dim = mean.count }
            guard mean.count == dim else { continue }
            ids.append(ident.id)
            for x in mean { rows.append(Float(x)) }
        }
        return GalleryIndex(ids: ids, matrix: rows, dim: dim)
    }

    func topK(probe: [Double], k: Int) -> [(id: UUID, cosine: Double)] {
        MatchMath.topKCosine(probe: probe, ids: ids, matrix: matrix, dim: dim, k: k)
    }

    func cosine(probe: [Double], id: UUID) -> Double? {
        guard let i = ids.firstIndex(of: id), dim > 0, probe.count == dim else { return nil }
        let row = Array(matrix[(i * dim) ..< ((i + 1) * dim)])
        var acc: Float = 0
        var p = probe.map { Float($0) }
        vDSP_dotpr(row, 1, p, 1, &acc, vDSP_Length(dim))
        return Double(acc)
    }
}
