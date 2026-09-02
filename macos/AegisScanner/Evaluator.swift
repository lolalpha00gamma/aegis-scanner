import Foundation

enum LabReport {
    static func text(
        faces: [FaceObservation],
        identities: [Identity],
        media: [MediaItem],
        enabled: Set<StrategyID>,
        threshold: Double
    ) -> String {
        var genuine: [Double] = []
        var impostor: [Double] = []
        var lines = ["person,probe,kind,score"]
        var pairScores: [String: [String: [Double]]] = [:]

        for identity in identities {
            let owned = faces.filter { identity.faceIds.contains($0.id) }
            guard owned.count >= 2 else { continue }
            for (i, probe) in owned.enumerated() {
                var held = identities
                if let idx = held.firstIndex(where: { $0.id == identity.id }) {
                    var ids = owned.enumerated().compactMap { $0.offset == i ? nil : $0.element.id }
                    if ids.isEmpty { continue }
                    held[idx].faceIds = ids
                }
                let rows = FaceEngine.match(
                    faces: [probe],
                    identities: held,
                    media: media,
                    threshold: threshold,
                    enabled: enabled
                )
                let versus = rows.first?.hits.first { $0.strategy == .aegis }?.versus ?? []
                let selfP = versus.first { $0.identityId == identity.id }?.percent ?? 0
                genuine.append(selfP)
                lines.append("\(identity.name),\(probe.id.uuidString),genuine,\(fmt(selfP))")
                pairScores[identity.name, default: [:]][identity.name, default: []].append(selfP)
                for v in versus where v.identityId != identity.id {
                    impostor.append(v.percent)
                    let name = held.first { $0.id == v.identityId }?.name ?? "?"
                    lines.append("\(identity.name)→\(name),\(probe.id.uuidString),impostor,\(fmt(v.percent))")
                    pairScores[identity.name, default: [:]][name, default: []].append(v.percent)
                }
            }
        }

        var out: [String] = []
        out.append("Aegis \(AppVersion.display) — Laborbericht")
        out.append("Schwelle \(Int(threshold))  ·  Spuren \(enabled.map(\.label).sorted().joined(separator: ", "))")
        out.append("Genuine-Paare \(genuine.count)  ·  Impostor-Paare \(impostor.count)")
        out.append(stats("Genuine", genuine))
        out.append(stats("Impostor", impostor))
        if !genuine.isEmpty, !impostor.isEmpty {
            out.append(String(format: "Rang-1 (genuine ≥ Schwelle)  %.1f%%", 100 * frac(genuine, threshold)))
            out.append(String(format: "FAR bei Schwelle            %.1f%%", 100 * frac(impostor, threshold)))
            out.append(eerLine(genuine, impostor))
            if impostor.count < 200, let t = MatchMath.tarBootstrap(atFar: 0.001, genuine: genuine, impostor: impostor) {
                out.append(String(
                    format: "TAR @ 0,1 %% FAR  %.1f%%  [%.1f–%.1f]  (n_imp=%d, Bootstrap 95%%)",
                    100 * t.tar, 100 * t.lo, 100 * t.hi, impostor.count
                ))
            } else if let t = MatchMath.tar(atFar: 0.001, genuine: genuine, impostor: impostor) {
                out.append(String(format: "TAR @ 0,1 %% FAR  %.1f%%  (Schwelle %.1f, MatchMath ceil-1)", 100 * t.tar, t.threshold))
            }
            if impostor.count < 200, let t = MatchMath.tarBootstrap(atFar: 0.01, genuine: genuine, impostor: impostor) {
                out.append(String(
                    format: "TAR @ 1 %% FAR    %.1f%%  [%.1f–%.1f]  (n_imp=%d, Bootstrap 95%%)",
                    100 * t.tar, 100 * t.lo, 100 * t.hi, impostor.count
                ))
            } else if let t = MatchMath.tar(atFar: 0.01, genuine: genuine, impostor: impostor) {
                out.append(String(format: "TAR @ 1 %% FAR    %.1f%%  (Schwelle %.1f, MatchMath ceil-1)", 100 * t.tar, t.threshold))
            }
        } else {
            out.append("Zu wenig Referenzen: jede Person braucht mindestens zwei Fotos.")
        }
        var weightLines: [String] = ["person,face,slot,capture,sharpness,weight"]
        for identity in identities {
            let owned = faces.filter { identity.faceIds.contains($0.id) }
            for row in FaceEngine.printWeights(owned) {
                let face = owned.first { $0.id == row.id }
                let cap = face?.quality.capture ?? 0
                let sh = face?.quality.sharpness ?? 0
                weightLines.append(String(
                    format: "%@,%@,%@,%.3f,%.3f,%.3f",
                    identity.name, row.id.uuidString, row.slot, cap, sh, row.weight
                ))
            }
        }
        if weightLines.count > 1 {
            out.append("")
            out.append("Centroid-Gewichte (capture · (0,35 + 0,65·sharpness), Floor 0,08)")
            out.append(contentsOf: weightLines)
        }
        let photos = media.filter { $0.kind == .photo }
        if !photos.isEmpty {
            var rotated = 0
            for item in photos {
                let o = FrameExtractor.exifOrientation(url: item.url)
                if o != 1 { rotated += 1 }
            }
            out.append("EXIF: \(photos.count) Fotos, \(rotated) mit Orientation ≠ 1 (Thumbnails mit Transform).")
        }
        if pairScores.count >= 1 {
            out.append("")
            out.append("Konfusion (mean % Probe → Galerie)")
            let names = identities.map(\.name)
            out.append("probe\\ref\t" + names.joined(separator: "\t"))
            for probe in names {
                var row = [probe]
                for ref in names {
                    let xs = pairScores[probe]?[ref] ?? []
                    row.append(xs.isEmpty ? "—" : String(format: "%.0f", xs.reduce(0, +) / Double(xs.count)))
                }
                out.append(row.joined(separator: "\t"))
            }
        }
        out.append("")
        out.append(lines.joined(separator: "\n"))
        return out.joined(separator: "\n")
    }

    private static func fmt(_ n: Double) -> String { String(format: "%.2f", n) }

    private static func frac(_ xs: [Double], _ t: Double) -> Double {
        guard !xs.isEmpty else { return 0 }
        return Double(xs.filter { $0 >= t }.count) / Double(xs.count)
    }

    private static func stats(_ name: String, _ xs: [Double]) -> String {
        guard !xs.isEmpty else { return "\(name): —" }
        let s = xs.sorted()
        let mean = s.reduce(0, +) / Double(s.count)
        let mid = s[s.count / 2]
        return String(format: "%@  n=%d  mean=%.1f  median=%.1f  min=%.1f  max=%.1f", name, s.count, mean, mid, s.first ?? 0, s.last ?? 0)
    }

    private static func eerLine(_ g: [Double], _ i: [Double]) -> String {
        var best = 1.0
        var at = 78.0
        for t in stride(from: 50.0, through: 96.0, by: 1) {
            let frr = 1 - frac(g, t)
            let far = frac(i, t)
            let e = abs(frr - far)
            if e < best {
                best = e
                at = t
            }
        }
        let frr = 1 - frac(g, at)
        let far = frac(i, at)
        return String(format: "EER ≈ %.1f%% bei Schwelle %.0f (FRR %.1f%% / FAR %.1f%%)", 100 * (frr + far) / 2, at, 100 * frr, 100 * far)
    }
}
