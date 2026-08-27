import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: LibraryStore

    var body: some View {
        NavigationSplitView {
            identityList
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } content: {
            stage
                .navigationSplitViewColumnWidth(min: 420, ideal: 640)
        } detail: {
            strategyList
                .navigationSplitViewColumnWidth(min: 260, ideal: 300, max: 360)
        }
        .toolbar { toolbar }
        .navigationTitle("Aegis")
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button("Ordner") { store.pickFolder() }
            Button("Erkennen") { Task { await store.scan() } }
                .disabled(store.busy || store.media.isEmpty)
            Button("CSV") { store.exportCSV() }
                .disabled(store.matches.isEmpty)
            Slider(value: $store.threshold, in: 50 ... 92)
                .frame(width: 110)
                .help("Schwelle")
        }
    }

    private var identityList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IDENTITÄTEN")
                .font(.caption)
                .foregroundStyle(.secondary)
                .tracking(1.4)
            HStack {
                TextField("Name", text: $store.newPersonName)
                    .textFieldStyle(.roundedBorder)
                Button("Anlegen", action: store.createIdentity)
                    .disabled(store.selectedFace == nil || store.newPersonName.isEmpty)
            }
            List(store.identities) { identity in
                HStack {
                    VStack(alignment: .leading) {
                        Text(identity.name)
                        Text("\(identity.faceIds.count) Referenzen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("+") { store.addSelectedTo(identity.id) }
                        .disabled(store.selectedFace == nil)
                    Button(role: .destructive) { store.removeIdentity(identity.id) } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
            }
            Text(store.status)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding(16)
    }

    private var stage: some View {
        VStack(spacing: 0) {
            ZStack {
                Color(nsColor: .windowBackgroundColor)
                if let item = store.selectedMedia, let preview = item.preview {
                    FaceOverlay(
                        image: preview,
                        item: item,
                        faces: store.faces.filter { $0.mediaId == item.id },
                        store: store
                    )
                } else if store.media.isEmpty {
                    ContentUnavailableView(
                        "Ordner oder Dateien wählen",
                        systemImage: "faceid",
                        description: Text("Aegis extrahiert Video-Frames, erkennt Gesichter und zeigt Übereinstimmung je Strategie in Prozent.")
                    )
                } else {
                    ProgressView(store.status)
                }
            }
            Divider()
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(store.media.filter { $0.kind != .frame }) { item in
                        Button {
                            if item.kind == .video {
                                store.selectedMediaId = store.media.first { $0.parentId == item.id }?.id ?? item.id
                            } else {
                                store.selectedMediaId = item.id
                            }
                        } label: {
                            MediaThumb(item: item, frames: store.media.filter { $0.parentId == item.id })
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay {
                                    if store.selectedMediaId == item.id || store.media.contains(where: { $0.parentId == item.id && $0.id == store.selectedMediaId }) {
                                        RoundedRectangle(cornerRadius: 8).stroke(.primary, lineWidth: 2)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
            }
            .frame(height: 92)
            let frames = store.media.filter { $0.kind == .frame && $0.parentId == (store.selectedMedia?.kind == .frame ? store.selectedMedia?.parentId : store.selectedMedia?.id) }
            if !frames.isEmpty {
                Divider()
                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        ForEach(frames) { frame in
                            Button {
                                store.selectedMediaId = frame.id
                            } label: {
                                if let img = frame.preview {
                                    Image(nsImage: NSImage(cgImage: img, size: NSSize(width: img.width, height: img.height)))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 96, height: 56)
                                        .clipped()
                                        .overlay {
                                            if store.selectedMediaId == frame.id {
                                                Rectangle().stroke(.primary, lineWidth: 2)
                                            }
                                        }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(10)
                }
                .frame(height: 76)
            }
        }
    }

    private var strategyList: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let face = store.selectedFace {
                Text("STRATEGIEN")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                Text(String(format: "Qualität %.0f%%  ·  Schärfe %.0f%%  ·  Frontal %.0f%%",
                            face.quality.capture * 100,
                            face.quality.sharpness * 100,
                            face.quality.frontal * 100))
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                ForEach(StrategyID.allCases) { id in
                    let hit = store.selectedHits.first { $0.strategy == id }
                    let name = store.identities.first { $0.id == hit?.identityId }?.name ?? "—"
                    let pct = hit?.percent ?? 0
                    Button {
                        store.strategy = id
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(id.label)
                                Spacer()
                                Text(String(format: "%.0f%%", pct))
                                    .font(.body.monospacedDigit())
                                    .foregroundStyle(pct >= store.threshold ? Color.primary : Color.secondary)
                            }
                            ProgressView(value: min(100, pct), total: 100)
                            Text(name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(store.strategy == id ? Color.primary : Color.secondary.opacity(0.25))
                        )
                    }
                    .buttonStyle(.plain)
                    .help(id.blurb)
                }
                let aegis = store.selectedHits.first { $0.strategy == .aegis }?.percent ?? 0
                let photos = store.selectedHits.first { $0.strategy == .photosStyle }?.percent ?? 0
                let delta = aegis - photos
                VStack(alignment: .leading, spacing: 4) {
                    Text("VORSPRUNG GEGEN FOTOS-STIL")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    Text(String(format: "%@%.1f", delta >= 0 ? "+" : "", delta))
                        .font(.largeTitle.italic())
                    Text("Prozentpunkte auf diesem Gesicht. Aegis hält schwierige Frames.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            } else {
                ContentUnavailableView("Kein Gesicht", systemImage: "viewfinder")
            }
            Spacer()
        }
        .padding(16)
    }
}

struct FaceOverlay: View {
    var image: CGImage
    var item: MediaItem
    var faces: [FaceObservation]
    @ObservedObject var store: LibraryStore

    var body: some View {
        GeometryReader { geo in
            let ns = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
            let scale = min(geo.size.width / CGFloat(image.width), geo.size.height / CGFloat(image.height))
            let dw = CGFloat(image.width) * scale
            let dh = CGFloat(image.height) * scale
            let ox = (geo.size.width - dw) / 2
            let oy = (geo.size.height - dh) / 2
            ZStack(alignment: .topLeading) {
                Image(nsImage: ns)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: dw, height: dh)
                    .offset(x: ox, y: oy)
                ForEach(faces) { face in
                    let hit = store.matches.first { $0.faceId == face.id }?.hits.first { $0.strategy == store.strategy }
                    let ident = store.identities.first { $0.id == hit?.identityId }
                    let pct = hit?.percent ?? 0
                    let pass = pct >= store.threshold && ident != nil
                    Button {
                        store.selectedFaceId = face.id
                        store.selectedMediaId = item.id
                    } label: {
                        Rectangle()
                            .stroke(store.selectedFaceId == face.id ? Color.white : (pass ? Color.green.opacity(0.85) : Color.white.opacity(0.45)), lineWidth: 1.5)
                            .overlay(alignment: .topLeading) {
                                Text(ident != nil && pass ? "\(ident!.name) \(Int(pct))%" : "\(Int(pct))%")
                                    .font(.caption2.monospaced())
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(.black.opacity(0.55))
                                    .offset(y: -16)
                            }
                    }
                    .buttonStyle(.plain)
                    .frame(
                        width: CGFloat(face.box.width) * scale,
                        height: CGFloat(face.box.height) * scale
                    )
                    .offset(
                        x: ox + CGFloat(face.box.x) * scale,
                        y: oy + CGFloat(face.box.y) * scale
                    )
                }
            }
        }
        .padding(12)
    }
}

struct MediaThumb: View {
    var item: MediaItem
    var frames: [MediaItem]
    var body: some View {
        if let img = item.preview ?? frames.first?.preview {
            Image(nsImage: NSImage(cgImage: img, size: NSSize(width: img.width, height: img.height)))
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: item.kind == .video ? "film" : "photo")
        }
    }
}
