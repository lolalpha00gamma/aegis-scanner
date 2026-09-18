import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var model: AppModel
    @State private var importPresented = false
    @State private var exportPresented = false

    var body: some View {
        NavigationSplitView {
            List(selection: $model.selectedTrackID) {
                ForEach(model.tracks) { t in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(t.name).font(.headline)
                        Text("\(t.kind.label) · \(t.points.count) Punkte")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .tag(Optional(t.id))
                }
            }
            .navigationTitle("Spuren")
            .frame(minWidth: 220)
        } detail: {
            VStack(spacing: 0) {
                toolbar
                MapPane(
                    points: model.visiblePoints,
                    selected: model.selectedFix,
                    onSelect: { model.selectedFix = $0 }
                )
                pointTable
            }
        }
        .onAppear { if !model.running { model.start() } }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Button(model.running ? "Stop" : "Start") {
                model.running ? model.stop() : model.start()
            }
            Stepper("Intervall \(Int(model.intervalSec))s", value: $model.intervalSec, in: 30...3600, step: 30)
            Toggle("Dieser Mac", isOn: $model.pollThisMac)
            Button("Jetzt") { model.tick() }
            Button("Import JSON") { importPresented = true }
            Button("Export JSON") { exportPresented = true }
            Spacer()
            Text(model.status).font(.caption).foregroundStyle(.secondary)
        }
        .padding(8)
        .fileImporter(isPresented: $importPresented, allowedContentTypes: [.json]) { result in
            if case .success(let url) = result { model.importJSON(url: url) }
        }
        .fileExporter(isPresented: $exportPresented, document: JSONDoc(fixes: model.fixes), contentType: .json, defaultFilename: "locus-history") { _ in }
    }

    private var pointTable: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !model.cacheNotes.isEmpty {
                Text(model.cacheNotes.joined(separator: " · "))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
            }
            List(model.visiblePoints.reversed(), selection: $model.selectedFix) { p in
                HStack {
                    Text(p.timeLabel).font(.system(.body, design: .monospaced))
                    Text(String(format: "%.5f, %.5f", p.lat, p.lon))
                    Spacer()
                    Text(p.source).foregroundStyle(.secondary)
                }
                .tag(Optional(p))
            }
            .frame(height: 180)
        }
    }
}

struct JSONDoc: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var fixes: [Fix]
    init(fixes: [Fix]) { self.fixes = fixes }
    init(configuration: ReadConfiguration) throws { fixes = [] }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        enc.dateEncodingStrategy = .iso8601
        return FileWrapper(regularFileWithContents: try enc.encode(fixes))
    }
}
