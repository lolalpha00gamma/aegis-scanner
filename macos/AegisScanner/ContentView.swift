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
        .navigationTitle("Aegis \(AppVersion.display)")
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button("Ordner") { store.pickFolder() }
            Button("Live") { store.startLiveFromField() }
            Button("Webcam") { store.startWebcam() }
            if store.liveActive {
                Button("Stop") { store.stopLive() }
            }
            Button("Erkennen") { Task { await store.scan() } }
                .disabled(store.busy || store.media.isEmpty)
            Button("CSV") { store.exportCSV() }
                .disabled(store.matches.isEmpty)
            Slider(value: $store.threshold, in: 70 ... 96)
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
            TextField("rtsp:// oder http://kamera/…", text: $store.liveURLText)
                .textFieldStyle(.roundedBorder)
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
                        faces: store.faces.filter { $0.mediaId == item.id }.sorted {
                            $0.box.x + $0.box.y * 0.15 < $1.box.x + $1.box.y * 0.15
                        },
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
            let onImage = store.faces.filter { $0.mediaId == store.selectedMediaId }.sorted {
                $0.box.x + $0.box.y * 0.15 < $1.box.x + $1.box.y * 0.15
            }
            if !onImage.isEmpty {
                Divider()
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(Array(onImage.enumerated()), id: \.element.id) { index, face in
                            let hit = store.matches.first { $0.faceId == face.id }?.hits.first { $0.strategy == store.strategy }
                            let owner = store.identities.first { $0.faceIds.contains(face.id) }
                            let ident = owner ?? store.identities.first { $0.id == hit?.identityId }
                            let assigned = ident != nil && (owner != nil || (hit?.percent ?? 0) >= store.threshold)
                            Button {
                                store.selectedFaceId = face.id
                            } label: {
                                HStack(spacing: 8) {
                                    Text("\(index + 1)")
                                        .font(.caption.monospacedDigit())
                                        .frame(width: 18)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(assigned ? (ident?.name ?? "offen") : "nicht zugeordnet")
                                            .font(.caption)
                                            .lineLimit(1)
                                        Text(String(format: "%.0f%%", hit?.percent ?? 0))
                                            .font(.caption2.monospacedDigit())
                                            .foregroundStyle(assigned ? Color.primary : Color.secondary)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .frame(minHeight: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(store.selectedFaceId == face.id ? Color.primary : Color.secondary.opacity(0.3))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(10)
                }
                .frame(height: 68)
            }
            Divider()
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(store.media.filter { $0.kind != .frame }) { item in
                        Button {
                            if item.kind == .video {
                                store.selectMedia(store.media.first { $0.parentId == item.id }?.id ?? item.id)
                            } else {
                                store.selectMedia(item.id)
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
                                store.selectMedia(frame.id)
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
                let hit = store.selectedHits.first { $0.strategy == store.strategy }
                let owner = store.identities.first { $0.faceIds.contains(face.id) }
                let assignedIdent = owner ?? store.identities.first { $0.id == hit?.identityId }
                let assignedPass = assignedIdent != nil && (owner != nil || (hit?.percent ?? 0) >= store.threshold)
                Text(owner != nil ? "REFERENZ" : (assignedPass ? "ZUGEORDNET" : "NICHT ZUGEORDNET"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                Text(assignedPass ? (assignedIdent?.name ?? "") : "kein Match")
                    .font(.title3)
                Text(String(format: "%.0f%%", hit?.percent ?? 0))
                    .font(.body.monospacedDigit())
                if let note = hit?.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if !assignedPass, let guess = store.identities.first(where: { $0.id == hit?.versus.first?.identityId }) {
                    Text("Nähe \(guess.name) · Prozent bleibt sichtbar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(String(format: "Qualität %.0f%%  ·  Schärfe %.0f%%  ·  Frontal %.0f%%",
                            face.quality.capture * 100,
                            face.quality.sharpness * 100,
                            face.quality.frontal * 100))
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Text("STRATEGIEN")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                    .padding(.top, 4)
                ForEach(StrategyID.allCases) { id in
                    let hit = store.selectedHits.first { $0.strategy == id }
                    let assigned = store.identities.first { $0.id == hit?.identityId }?.name
                    let guess = store.identities.first { $0.id == hit?.versus.first?.identityId }?.name
                    let pass = assigned != nil && (hit?.percent ?? 0) >= store.threshold
                    let name = pass
                        ? (assigned ?? "")
                        : (guess.map { "Nähe \($0) · nicht zugeordnet" } ?? "nicht zugeordnet")
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
                                    .foregroundStyle(pass ? Color.primary : Color.secondary)
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
                if let versus = store.selectedHits.first(where: { $0.strategy == store.strategy })?.versus, versus.count > 1 {
                    let gap = (versus.first?.percent ?? 0) - (versus.dropFirst().first?.percent ?? 0)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("UNTERSCHEIDUNG")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .tracking(1.2)
                        ForEach(versus, id: \.identityId) { row in
                            let name = store.identities.first { $0.id == row.identityId }?.name ?? "—"
                            let isHit = assignedPass && row.identityId == hit?.identityId
                            HStack {
                                Text(isHit ? name : "\(name) · Nähe")
                                    .font(.caption)
                                    .foregroundStyle(isHit ? Color.primary : Color.secondary)
                                Spacer()
                                Text(String(format: "%.0f%%", row.percent))
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(isHit ? Color.primary : Color.secondary)
                            }
                        }
                        Text(String(format: "Abstand %.1f Pkt", gap))
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 6)
                }
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
                ForEach(Array(faces.enumerated()), id: \.element.id) { index, face in
                    let hit = store.matches.first { $0.faceId == face.id }?.hits.first { $0.strategy == store.strategy }
                    let ident = store.identities.first { $0.id == hit?.identityId }
                    let pct = hit?.percent ?? 0
                    let pass = pct >= store.threshold && ident != nil
                    let selected = store.selectedFaceId == face.id
                    Button {
                        store.selectedFaceId = face.id
                        store.selectedMediaId = item.id
                    } label: {
                        Rectangle()
                            .stroke(selected ? Color.white : (pass ? Color.green.opacity(0.85) : Color.white.opacity(0.45)), lineWidth: selected ? 2 : 1.5)
                            .overlay(alignment: .topLeading) {
                                Text("\(index + 1)")
                                    .font(.caption2.monospacedDigit())
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(.black.opacity(0.7))
                                    .offset(x: -4, y: -10)
                            }
                            .overlay(alignment: .bottomLeading) {
                                if selected {
                                    Text(pass ? "\(ident!.name) \(Int(pct))%" : "nicht zugeordnet")
                                        .font(.caption2.monospaced())
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(.black.opacity(0.7))
                                        .offset(y: 16)
                                }
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
