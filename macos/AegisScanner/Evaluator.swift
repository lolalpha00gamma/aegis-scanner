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
                for v in versus where v.identityId != identity.id {
                    impostor.append(v.percent)
                    let name = held.first { $0.id == v.identityId }?.name ?? "?"
                    lines.append("\(identity.name)→\(name),\(probe.id.uuidString),impostor,\(fmt(v.percent))")
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
        } else {
            out.append("Zu wenig Referenzen: jede Person braucht mindestens zwei Fotos.")
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
