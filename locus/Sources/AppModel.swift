import Foundation
import Combine
import AppKit

@MainActor
final class AppModel: ObservableObject {
    @Published var fixes: [Fix] = []
    @Published var selectedTrackID: String?
    @Published var selectedFix: Fix?
    @Published var intervalSec: Double = 120
    @Published var running = false
    @Published var status = "bereit"
    @Published var cacheNotes: [String] = []
    @Published var pollThisMac = true

    private var timer: Timer?
    private let locator = MacLocator()
    private let store = HistoryStore.shared

    init() {
        var loaded = store.load()
        if loaded.isEmpty {
            loaded = Demo.zurichLoop()
            status = "keine History — Demo-Spur Zürich geladen"
        }
        fixes = loaded
        selectedTrackID = tracks.first?.id
    }

    var tracks: [Track] {
        let g = Dictionary(grouping: fixes, by: \.id)
        return g.keys.sorted().compactMap { id in
            guard let pts = g[id], let first = pts.first else { return nil }
            return Track(id: id, name: first.name, kind: first.kind, points: pts.sorted { $0.timestamp < $1.timestamp })
        }
    }

    var visiblePoints: [Fix] {
        if let id = selectedTrackID {
            return fixes.filter { $0.id == id }.sorted { $0.timestamp < $1.timestamp }
        }
        return fixes.sorted { $0.timestamp < $1.timestamp }
    }

    func start() {
        locator.request()
        running = true
        tick()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: max(15, intervalSec), repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func stop() {
        running = false
        timer?.invalidate()
        timer = nil
        status = "angehalten"
    }

    func tick() {
        var incoming: [Fix] = []
        let snap = FindMyCache.poll()
        cacheNotes = snap.notes
        incoming.append(contentsOf: snap.fixes)
        if pollThisMac, let mac = locator.currentFix() {
            incoming.append(mac)
        }
        let added = store.appendUnique(incoming, into: &fixes)
        store.save(fixes)
        if selectedTrackID == nil {
            selectedTrackID = tracks.first?.id
        }
        status = "\(Date()) · +\(added) · total \(fixes.count)"
    }

    func importJSON(url: URL) {
        guard let data = try? Data(contentsOf: url) else { return }
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        if let arr = try? dec.decode([Fix].self, from: data) {
            _ = store.appendUnique(arr, into: &fixes)
            store.save(fixes)
            status = "Import \(arr.count)"
        }
    }

    func exportJSON(url: URL) {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        enc.dateEncodingStrategy = .iso8601
        guard let data = try? enc.encode(fixes) else { return }
        try? data.write(to: url)
    }
}

enum Demo {
    static func zurichLoop() -> [Fix] {
        let base = Date().addingTimeInterval(-3600)
        let pts: [(Double, Double)] = [
            (47.3769, 8.5417),
            (47.3810, 8.5480),
            (47.3850, 8.5400),
            (47.3780, 8.5350),
            (47.3769, 8.5417),
        ]
        return pts.enumerated().map { i, p in
            Fix(
                id: "demo-zh",
                name: "Demo Zürich",
                kind: .importFile,
                lat: p.0,
                lon: p.1,
                altitude: nil,
                accuracy: 12,
                timestamp: base.addingTimeInterval(Double(i) * 720),
                source: "demo"
            )
        }
    }
}
