import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: LibraryStore
    @FocusState private var stageFocused: Bool
    @State private var restoreAlert = false

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
        .alert("Backup laden?", isPresented: $restoreAlert) {
            Button("Laden", role: .destructive) { store.restoreFromBackup() }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text(store.restoreWarning())
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .principal) {
            Button {
                store.stepMedia(-1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(store.browseItems.count < 2)
            .help("Vorheriges Bild (←)")
            Text(store.browseItems.isEmpty ? "kein Bild" : "\(store.browseIndex + 1) / \(store.browseItems.count)")
                .font(.caption.monospacedDigit())
                .frame(minWidth: 64)
                .help(store.browseLabel)
            Button {
                store.stepMedia(1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(store.browseItems.count < 2)
            .help("Nächstes Bild (→)")
        }
        ToolbarItemGroup(placement: .primaryAction) {
            Button("Ordner") { store.pickFolder() }
            Button("Live") { store.startLiveFromField() }
            Button("Webcam") { store.startWebcam() }
            if store.liveActive {
                Button("Stop") { store.stopLive() }
            }
            Picker("Kamera", selection: Binding(
                get: { store.cameraChoice },
                set: { store.setCameraChoice($0) }
            )) {
                ForEach(CameraChoice.allCases) { c in
                    Text(c.titleDE).tag(c)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 150)
            .help("Built-in zuerst, sonst Continuity. Analog Helios.")
            if !store.liveFormatChip.isEmpty {
                Text(store.liveFormatChip)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.orange)
                    .help("Capture-Format. BGRA 8 = Continuity tot.")
            }
            Button("Erkennen") { Task { await store.scan() } }
                .disabled(store.busy || store.media.isEmpty)
            if store.busy {
                Button("Abbrechen") { store.cancelScan() }
            }
            if store.canResumeScan, !store.busy {
                Button("Fortsetzen") { store.resumeScan() }
            }
            if store.canRestoreBackup, !store.busy {
                Button("Backup") { restoreAlert = true }
                    .help("Letzte gallery.json.bak laden — nach kaputtem Save.")
            }
            Button("CSV") { store.exportCSV() }
                .disabled(store.matches.isEmpty)
            Button("Labor") { store.exportLab() }
                .disabled(store.identities.count < 1)
            Slider(value: $store.threshold, in: 70 ... 96) { editing in
                if !editing { store.rematch() }
            }
            .frame(width: 110)
            .help(store.floorHint)
            Text(store.floorHint)
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
                .help("Effektiver Floor: Galerie-Größe plus Slider-Bias um 78.")
            if !store.revisionWarning.isEmpty {
                Text(store.revisionWarning)
                    .font(.caption2)
                    .foregroundStyle(.orange)
                    .help(store.revisionWarning)
            }
            Toggle("Anatomie", isOn: $store.showAnatomy)
                .toggleStyle(.button)
            Toggle("NMS", isOn: $store.showNMSDebug)
                .toggleStyle(.button)
                .help("Verworfene Tile-Zwillinge als gestrichelte Quadrate")
            Picker("Orient", selection: Binding(
                get: { store.cameraOrient },
                set: { store.setCameraOrient($0) }
            )) {
                Text("Auto").tag("auto")
                Text("0°").tag("0")
                Text("90°").tag("90")
                Text("180°").tag("180")
                Text("270°").tag("270")
            }
            .pickerStyle(.menu)
            .frame(width: 88)
            .help("Continuity/Desk-View: videoRotationAngle überschreiben, wenn Yaw kippt. Auch vor Webcam-Start.")
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
                    .onSubmit { store.createIdentity() }
                Button("Anlegen", action: store.createIdentity)
                    .keyboardShortcut(.defaultAction)
                    .disabled(store.selectedFace == nil || store.newPersonName.isEmpty)
            }
            HStack {
                Button("Testdaten holen") { store.fetchBenchData() }
                    .disabled(store.busy)
                    .help("Lädt LFW einmalig nach Downloads/AegisBench (~170 MB). Nicht auf GitHub — Lizenz.")
                Button("Test starten") { store.startDefaultBenchmark() }
                    .disabled(store.busy)
                    .help("ident20. Fehlen die Daten, wird zuerst geladen.")
            }
            Button("Anderer Testordner…") { store.pickBenchmark() }
                .disabled(store.busy)
                .help("Eigenen Personen-Ordner wählen.")
            Text(store.benchHint)
                .font(.caption2)
                .foregroundStyle(.secondary)
            if !store.enrollmentHint.isEmpty {
                Text(store.enrollmentHint)
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
            if !store.mergeHint.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Text(store.mergeHint)
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Button("Zusammenführen") { store.acceptMergeHint() }
                        .controlSize(.small)
                }
                .help("Centroid 0,89–0,94. Mehrere Paare: Button mehrmals. Nie still taufen.")
            }
            Text("Anlegen = neue Person (zweites Mal bestätigt, wenn Cosine ≥ 0,82). + = extra Foto derselben Person. Dritter gleicher Slot blockt, solange Frontal oder ¾ fehlt. Live speichert eine Kopie.")
                .font(.caption2)
                .foregroundStyle(.secondary)
            List(store.identities) { identity in
                HStack {
                    VStack(alignment: .leading) {
                        IdentityNameField(store: store, identity: identity)
                        let cov = FaceEngine.poseCoverage(identity: identity, faces: store.faces)
                        Text("\(identity.faceIds.count) Referenzen · \(MatchMath.poseMeter(frontal: cov.frontal, threeQuarter: cov.threeQuarter, profile: cov.profile))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("+") { store.addSelectedTo(identity.id) }
                        .disabled(store.selectedFace == nil)
                        .help("Weitere Aufnahme dieser Person. Live: speichert eine Kopie des aktuellen Frames.")
                    Button("U") { store.addSelectedAsPartial(identity.id) }
                        .disabled(store.selectedFace == nil || identity.faceIds.isEmpty)
                        .help("Als Teil-Print (obere Hälfte / Maske) speichern, auch ohne Auto-Maske.")
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
                        description: Text("Aegis extrahiert Video-Frames, erkennt Gesichter und zeigt Übereinstimmung je Strategie in Prozent. Danach mit ← → durch den Ordner blättern.")
                    )
                } else {
                    ProgressView(store.status)
                }
                if store.browseItems.count > 1 {
                    HStack {
                        Button {
                            store.stepMedia(-1)
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(.black.opacity(0.55))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .help("Vorheriges Bild (←)")
                        Spacer()
                        Button {
                            store.stepMedia(1)
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(.black.opacity(0.55))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .help("Nächstes Bild (→)")
                    }
                    .padding(16)
                    VStack {
                        Spacer()
                        Text(store.browseLabel)
                            .font(.caption.monospaced())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.black.opacity(0.6))
                            .clipShape(Capsule())
                            .padding(.bottom, 12)
                    }
                    .allowsHitTesting(false)
                }
            }
            .focusable()
            .focused($stageFocused)
            .focusEffectDisabled()
            .onAppear { stageFocused = true }
            .onKeyPress(.leftArrow) {
                store.stepMedia(-1)
                return .handled
            }
            .onKeyPress(.rightArrow) {
                store.stepMedia(1)
                return .handled
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
                            let pinned = owner != nil
                            let near = !pinned && ident != nil && (hit?.percent ?? 0) >= store.threshold
                            Button {
                                store.tapOverlay(faceId: face.id)
                            } label: {
                                HStack(spacing: 8) {
                                    Text("\(index + 1)")
                                        .font(.caption.monospacedDigit())
                                        .frame(width: 18)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(pinned ? (owner!.name) : (near ? "Nähe \(ident!.name)" : "nicht zugeordnet"))
                                            .font(.caption)
                                            .lineLimit(1)
                                        Text(String(format: "%.0f%%", hit?.percent ?? 0))
                                            .font(.caption2.monospacedDigit())
                                            .foregroundStyle(pinned ? Color.primary : Color.secondary)
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
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(store.browseItems) { item in
                            Button {
                                if item.kind == .video {
                                    store.selectMedia(store.media.first { $0.parentId == item.id }?.id ?? item.id)
                                } else {
                                    store.selectMedia(item.id)
                                }
                            } label: {
                                MediaThumb(item: item, frames: store.media.filter { $0.parentId == item.id })
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(alignment: .bottom) {
                                        Text(item.name)
                                            .font(.caption2)
                                            .lineLimit(1)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .frame(maxWidth: .infinity)
                                            .background(.black.opacity(0.55))
                                            .foregroundStyle(.white)
                                    }
                                    .overlay {
                                        if store.selectedMediaId == item.id || store.media.contains(where: { $0.parentId == item.id && $0.id == store.selectedMediaId }) {
                                            RoundedRectangle(cornerRadius: 8).stroke(.primary, lineWidth: 2)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                            .id(item.id)
                        }
                    }
                    .padding(10)
                }
                .onChange(of: store.selectedMediaId) { _, _ in
                    let id: UUID?
                    if let item = store.selectedMedia, item.kind == .frame {
                        id = item.parentId
                    } else {
                        id = store.selectedMediaId
                    }
                    if let id {
                        withAnimation { proxy.scrollTo(id, anchor: .center) }
                    }
                }
            }
            .frame(height: 100)
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
        ScrollView {
        VStack(alignment: .leading, spacing: 10) {
            if let face = store.selectedFace {
                let hit = store.selectedHits.first { $0.strategy == store.strategy }
                let owner = store.identities.first { $0.faceIds.contains(face.id) }
                let assignedIdent = owner ?? store.identities.first { $0.id == hit?.identityId }
                let assignedPass = assignedIdent != nil && (owner != nil || ((hit?.measured ?? false) && (hit?.percent ?? 0) >= store.threshold))
                Text(owner != nil ? "REFERENZ" : (assignedPass ? "NÄHE" : "NICHT ZUGEORDNET"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                Text(owner != nil ? (assignedIdent?.name ?? "") : (assignedPass ? "Nähe \(assignedIdent?.name ?? "")" : "kein Match"))
                    .font(.title3)
                if hit?.measured == false {
                    Text("nicht gemessen")
                        .font(.body)
                        .foregroundStyle(.secondary)
                } else {
                    Text(String(format: "%.0f%%", hit?.percent ?? 0))
                        .font(.body.monospacedDigit())
                }
                if owner == nil, assignedPass {
                    Text("Noch keine Referenz. Anlegen für eine neue Person, + nur für ein extra Foto von \(assignedIdent?.name ?? "dieser Person").")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if let note = hit?.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if !assignedPass, let guess = store.identities.first(where: { $0.id == hit?.versus.first?.identityId }) {
                    HStack {
                        Text("Nähe \(guess.name) · Prozent bleibt sichtbar")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("nicht \(guess.name)") {
                            store.rejectGuess(guess.id)
                        }
                        .help("Hard-Negativ: dieses Gesicht ist nicht diese Person.")
                        if store.identities.first(where: { $0.id == guess.id })?.rejectedVecs.isEmpty == false {
                            Button("doch \(guess.name)") {
                                store.clearReject(guess.id)
                            }
                            .help("Hard-Negativ dieser Person löschen.")
                        }
                    }
                }
                Text(String(format: "Qualität %.0f%%  ·  Schärfe %.0f%%  ·  Frontal %.0f%%",
                            face.quality.capture * 100,
                            face.quality.sharpness * 100,
                            face.quality.frontal * 100))
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                if !face.ratioSheet.isEmpty {
                    let refSheet = referenceSheet(for: face)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("VERHÄLTNISSE · IOD = 1")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .tracking(1.2)
                        Text("Unabhängig von Lage, Größe, Mimik")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        ForEach(face.ratioSheet.filter(\.identity), id: \.id) { row in
                            let refVal = refSheet[row.id]
                            let signed: Double = {
                                guard let refVal else { return 0 }
                                return (row.value - refVal) / max(abs(refVal), 0.08)
                            }()
                            HStack {
                                Text(row.label)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                Spacer()
                                Text(String(format: "%.2f", row.value))
                                    .font(.caption.monospacedDigit())
                                if refVal != nil {
                                    Text(abs(signed) < 0.005 ? "±0%" : String(format: "%+.0f%%", signed * 100))
                                        .font(.caption2.monospacedDigit())
                                        .foregroundStyle(abs(signed) < 0.08 ? Color.primary : (abs(signed) < 0.16 ? Color.orange : Color.red))
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                Text("STRATEGIEN")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                    .padding(.top, 4)
                Text("Jede Spur einzeln. Aus = keine Stimme in der Fusion.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                ForEach(StrategyTrack.allCases) { track in
                    let members = StrategyID.allCases.filter { $0.track == track }
                    let allOn = members.allSatisfy { store.enabled.contains($0) }
                    HStack {
                        Text(track.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .tracking(1.1)
                        Spacer()
                        Button(allOn ? "aus" : "an") {
                            store.setTrack(track, on: !allOn)
                        }
                        .font(.caption2)
                    }
                    .padding(.top, 6)
                    ForEach(members) { id in
                        let hit = store.selectedHits.first { $0.strategy == id }
                        let pinnedName = store.identities.first { $0.faceIds.contains(face.id) }?.name
                        let matchName = store.identities.first { $0.id == hit?.identityId }?.name
                        let guess = store.identities.first { $0.id == hit?.versus.first?.identityId }?.name
                        let pct = hit?.percent ?? 0
                        let on = store.enabled.contains(id)
                        let measured = hit?.measured ?? false
                        let pass = pinnedName != nil
                        let name = pinnedName
                            ?? ((matchName != nil && pct >= store.threshold) ? "Nähe \(matchName!)" : (guess.map { "Nähe \($0) · nicht zugeordnet" } ?? "nicht zugeordnet"))
                        HStack(alignment: .top, spacing: 8) {
                            Toggle("", isOn: Binding(
                                get: { store.enabled.contains(id) },
                                set: { store.setEnabled(id, $0) }
                            ))
                            .toggleStyle(.switch)
                            .controlSize(.mini)
                            .labelsHidden()
                            Button {
                                store.strategy = id
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(id.label)
                                            .foregroundStyle(on ? Color.primary : Color.secondary)
                                        Spacer()
                                        if measured {
                                            Text(String(format: "%.0f%%", pct))
                                                .font(.body.monospacedDigit())
                                                .foregroundStyle(pass ? Color.primary : Color.secondary)
                                        } else {
                                            Text("nicht gemessen")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    if measured {
                                        ProgressView(value: min(100, pct), total: 100)
                                            .opacity(on ? 1 : 0.35)
                                    }
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
                            .opacity(on ? 1 : 0.45)
                        }
                    }
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

    private func referenceSheet(for face: FaceObservation) -> [String: Double] {
        let owner = store.identities.first { $0.faceIds.contains(face.id) }
        let target = owner ?? store.identities.first { ident in
            store.selectedHits.first(where: { $0.strategy == store.strategy })?.versus.first?.identityId == ident.id
        }
        guard let target else { return [:] }
        let others = store.faces.filter {
            target.faceIds.contains($0.id) && $0.id != face.id && !$0.ratioSheet.isEmpty
        }
        guard !others.isEmpty else { return [:] }
        var acc: [String: (Double, Double)] = [:]
        for f in others {
            for row in f.ratioSheet where row.identity {
                let cur = acc[row.id] ?? (0, 0)
                acc[row.id] = (cur.0 + row.value, cur.1 + 1)
            }
        }
        var out: [String: Double] = [:]
        for (k, v) in acc { out[k] = v.0 / max(v.1, 1) }
        return out
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
            let ghostOnly = store.ghostFaces().filter { g in !faces.contains { $0.id == g.id } }
            let drawnFaces = faces + ghostOnly
            ZStack(alignment: .topLeading) {
                Image(nsImage: ns)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: dw, height: dh)
                    .offset(x: ox, y: oy)
                ForEach(Array(drawnFaces.enumerated()), id: \.element.id) { _, face in
                    let hit = store.matches.first { $0.faceId == face.id }?.hits.first { $0.strategy == store.strategy }
                    let printHit = store.matches.first { $0.faceId == face.id }?.hits.first { $0.strategy == .featurePrint }
                    let aegisHit = store.matches.first { $0.faceId == face.id }?.hits.first { $0.strategy == .aegis }
                    let owner = store.identities.first { $0.faceIds.contains(face.id) }
                    let ident = owner ?? store.identities.first { $0.id == hit?.identityId }
                    let pct = hit?.percent ?? 0
                    let pinned = owner != nil
                    let near = !pinned && ident != nil && (hit?.measured ?? false) && pct >= store.threshold
                    let selected = store.selectedFaceId == face.id
                    let printDead = face.featurePrint.isEmpty
                    let gallery: [FaceObservation] = {
                        guard let ident else { return [] }
                        return store.faces.filter { ident.faceIds.contains($0.id) && $0.id != face.id }
                    }()
                    let liveCont = store.liveContinuity && item.kind == .live
                    let hint = FaceEngine.overlayHint(face, gallery: gallery, continuity: liveCont)
                    let leftover = store.leftoverHoldNow(faceId: face.id, yawAbs: abs(face.quality.yaw)) != nil
                        && store.tapLockChip(faceId: face.id) == nil
                    let ghost = store.ghostFaceIds().contains(face.id)
                    let kind = MatchMath.overlayBoxKind(selected: selected, pinned: pinned, leftover: leftover, ghost: ghost)
                    let coachDest = owner ?? (store.identities.count == 1 ? store.identities.first : ident)
                    let coach = selected ? FaceEngine.enrollmentCoach(face: face, identity: coachDest, faces: store.faces) : nil
                    let boxColor: Color = {
                        if store.swapFlashing() { return Color.yellow.opacity(0.95) }
                        if store.headCountFlashing() { return Color.cyan.opacity(0.95) }
                        if let tint = MatchMath.leftoverTwinTint(pairCosine: aegisHit?.pairCosine) {
                            return tint == "red" ? Color.red.opacity(0.95) : Color.orange.opacity(0.95)
                        }
                        switch kind {
                        case .selected: return .white
                        case .enrolled: return Color.green.opacity(0.85)
                        case .leftover: return Color.orange.opacity(0.95)
                        case .ghost: return Color.orange.opacity(0.55)
                        case .unmatched: return Color.white.opacity(0.45)
                        }
                    }()
                    let slotRaw = FaceEngine.poseSlot(face).rawValue
                    let slotTone = MatchMath.slotTone(slotRaw)
                    let slotColor: Color = {
                        switch slotTone {
                        case "green": return Color.green
                        case "amber": return Color.orange
                        case "red": return Color.red
                        case "violet": return Color.purple
                        default: return Color.secondary
                        }
                    }()
                    let printLabel: String = {
                        if printDead {
                            return MatchMath.printDeadLabel(
                                capture: face.quality.capture,
                                sharpness: face.quality.sharpness,
                                masked: FaceEngine.lowerFaceOccluded(face),
                                continuity: liveCont
                            )
                        }
                        let printPct = printHit?.percent ?? 0
                        let lookPct = aegisHit?.percent ?? printPct
                        let slot = MatchMath.slotLetter(slotRaw)
                        let tid = MatchMath.trackLabel(face.trackId ?? face.id)
                        var base = "\(tid) · \(slot) · \(MatchMath.lookPrintLabel(printPercent: printPct, look: lookPct))"
                        if let vote = store.voteProgress(faceId: face.id) {
                            base += " · \(vote)"
                        }
                        let drift = store.printDriftSpark(faceId: face.id)
                        if !drift.isEmpty { base += " · \(drift)" }
                        if let axis = store.freezeAxisLabel(faceId: face.id) {
                            base += " · F\(axis)"
                        }
                        if store.swapFlashing() {
                            base += " · SWAP"
                        }
                        if let head = store.headCountFlashText() {
                            base += " · \(head)"
                        }
                        if let still = store.stillProgress(faceId: face.id) {
                            base += " · HALTEN \(Int((still * 100).rounded()))%"
                        }
                        if let sib = MatchMath.siblingBadge(pairCosine: aegisHit?.pairCosine) {
                            base += " · \(sib)"
                        }
                        let note = aegisHit?.note ?? ""
                        if note.contains(MatchMath.liveNameDisagreeNote()) {
                            let lookName = store.identities.first { $0.id == aegisHit?.versus.first?.identityId }?.name
                            let printName = store.identities.first { $0.id == printHit?.versus.first?.identityId }?.name
                            return "\(base) · \(MatchMath.liveNameDisagreeLabel(lookName: lookName, printName: printName))"
                        }
                        if let hold = store.leftoverHoldChip(
                            faceId: face.id,
                            sharpness: face.quality.sharpness,
                            yawAbs: abs(face.quality.yaw)
                        ) {
                            var tail = "\(base) · \(hold)"
                            if let spark = store.leftoverSparkChip(faceId: face.id, yawAbs: abs(face.quality.yaw)) {
                                tail += " · \(spark)"
                            }
                            if let cap = MatchMath.leftoverCaptureChip(face.quality.capture) {
                                tail += " · \(cap)"
                            }
                            if let sharp = MatchMath.leftoverSharpChip(face.quality.sharpness) {
                                tail += " · \(sharp)"
                            }
                            return tail
                        }
                        if let tap = store.tapLockChip(faceId: face.id) {
                            return "\(base) · \(tap)"
                        }
                        if let ae = store.exposureLockChip(faceId: face.id) {
                            return "\(base) · \(ae)"
                        }
                        if let ghostTTL = store.ghostTTLChip(faceId: face.id) {
                            return "\(base) · \(ghostTTL)"
                        }
                        if let pending = store.leftoverAdoptProgress(faceId: face.id) {
                            return "\(base) · leftover \(pending)"
                        }
                        let capped = note.contains(MatchMath.lookOfCapNote())
                        return capped ? "\(base) · \(MatchMath.lookOfCapNote())" : base
                    }()
                    let badge = hint.map { "\(printLabel) · \($0)" } ?? printLabel
                    Button {
                        store.tapOverlay(faceId: face.id, mediaId: item.id)
                    } label: {
                        Rectangle()
                            .stroke(
                                boxColor,
                                style: StrokeStyle(
                                    lineWidth: selected ? 2 : 1.5,
                                    dash: MatchMath.overlayBoxDash(kind)
                                )
                            )
                            .overlay(alignment: .topLeading) {
                                Text(MatchMath.trackLabel(face.trackId ?? face.id))
                                    .font(.caption2.monospacedDigit())
                                    .foregroundStyle(slotColor)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(.black.opacity(0.7))
                                    .offset(x: -4, y: -10)
                            }
                            .overlay(alignment: .topTrailing) {
                                VStack(alignment: .trailing, spacing: 2) {
                                    QualityAmpel(
                                        qualities: face.qualitySpark.isEmpty ? [face.quality] : face.qualitySpark,
                                        continuity: liveCont,
                                        geoMix: hit?.geoMix
                                    )
                                    Text(badge)
                                        .font(.caption2.monospacedDigit())
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1)
                                        .background(
                                            leftover ? Color.orange.opacity(0.78)
                                                : ((hint != nil && printDead) ? Color.red.opacity(0.78) : Color.black.opacity(0.7))
                                        )
                                }
                                .offset(x: 4, y: -10)
                            }
                            .overlay(alignment: .bottomLeading) {
                                if selected || ident != nil || leftover {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(overlayName(faceId: face.id, pinned: pinned, owner: owner, near: near, ident: ident, pct: pct, hit: hit, yawAbs: abs(face.quality.yaw)))
                                            .font(.caption2.monospaced())
                                            .lineLimit(2)
                                        if selected, let coach {
                                            let cov = coachDest.map { FaceEngine.poseCoverage(identity: $0, faces: store.faces) }
                                            let arrow = MatchMath.coachArrow(
                                                haveFrontal: (cov?.frontal ?? 0) > 0,
                                                haveThreeQuarter: (cov?.threeQuarter ?? 0) > 0,
                                                yaw: face.quality.yaw
                                            )
                                            HStack(spacing: 4) {
                                                if let arrow {
                                                    Text(arrow)
                                                        .font(.title3.monospaced())
                                                        .foregroundStyle(.orange)
                                                }
                                                Text(coach)
                                                    .font(.caption2.monospaced())
                                                    .foregroundStyle(.orange)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
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
                    if store.showAnatomy {
                        AnatomyMesh(face: face, scale: scale, selected: selected)
                            .offset(x: ox, y: oy)
                            .allowsHitTesting(false)
                    }
                }
                if store.showNMSDebug {
                    ForEach(Array(store.nmsDropped.enumerated()), id: \.offset) { _, box in
                        Rectangle()
                            .stroke(Color.orange.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            .frame(width: CGFloat(box.width) * scale, height: CGFloat(box.height) * scale)
                            .offset(x: ox + CGFloat(box.x) * scale, y: oy + CGFloat(box.y) * scale)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
        .padding(12)
    }

    private func overlayName(
        faceId: UUID,
        pinned: Bool,
        owner: Identity?,
        near: Bool,
        ident: Identity?,
        pct: Double,
        hit: StrategyHit?,
        yawAbs: Double? = nil
    ) -> String {
        let holdCos = store.leftoverHoldNow(faceId: faceId, yawAbs: yawAbs)
        if !MatchMath.leftoverNameFromHold(
            hasHold: store.leftoverHasHold(faceId: faceId),
            hold: holdCos,
            yawAbs: yawAbs
        ) {
            let hold = store.leftoverHoldChip(faceId: faceId, yawAbs: yawAbs) ?? MatchMath.unknownRejectNote()
            if let spark = store.leftoverSparkChip(faceId: faceId, yawAbs: yawAbs) {
                return "\(store.guestName(for: faceId)) · \(hold) · \(spark)"
            }
            return "\(store.guestName(for: faceId)) · \(hold)"
        }
        if pinned, let owner {
            let held = store.liveHeldIds.contains(faceId)
            if let hold = store.leftoverHoldChip(faceId: faceId, yawAbs: yawAbs) {
                if let spark = store.leftoverSparkChip(faceId: faceId, yawAbs: yawAbs) {
                    return "\(owner.name) \(Int(pct))% · \(hold) · \(spark)"
                }
                return "\(owner.name) \(Int(pct))% · \(hold)"
            }
            return "\(owner.name) \(Int(pct))% · \(MatchMath.trackHoldLabel(held: held))"
        }
        if let pending = store.leftoverAdoptProgress(faceId: faceId) {
            return "leftover \(pending)"
        }
        if near, let ident {
            return "Nähe \(ident.name) \(Int(pct))%"
        }
        if let hit, !hit.measured {
            return "nicht gemessen"
        }
        if let note = hit?.note, !note.isEmpty {
            return MatchMath.overlayNoteFirst(note)
        }
        return "nicht zugeordnet"
    }
}

private struct IdentityNameField: View {
    @ObservedObject var store: LibraryStore
    var identity: Identity
    @State private var draft: String = ""

    var body: some View {
        TextField("Name", text: $draft)
            .textFieldStyle(.plain)
            .font(.body)
            .opacity(MatchMath.printAgePaler(enrolledAt: store.faces.first { identity.faceIds.contains($0.id) }?.enrolledAt) ? 0.55 : 1)
            .onAppear { draft = identity.name }
            .onChange(of: identity.id) { _, _ in draft = identity.name }
            .onChange(of: identity.name) { _, name in
                if draft != name { draft = name }
            }
            .onSubmit { store.renameIdentity(identity.id, to: draft) }
            .help("Return speichert. Gleicher Name zweimal bestätigt den Konflikt.")
    }
}

private struct QualityAmpel: View {
    var qualities: [FaceQuality]
    var continuity: Bool = false
    var geoMix: Double? = nil

    var body: some View {
        let caps = qualities.map(\.capture)
        let sharps = qualities.map(\.sharpness)
        let yaws = qualities.map(\.yaw)
        let lamps = MatchMath.sparkLamps(captures: caps, sharps: sharps, yaws: yaws, continuity: continuity)
        let floorMark = MatchMath.sparkContinuityFloor(sharpness: sharps.min() ?? 0, continuity: continuity)
        HStack(spacing: 3) {
            lamp(lamps.capture, label: "C")
            lamp(lamps.sharpness, label: floorMark ? "S·" : "S")
            lamp(lamps.yaw, label: "Y")
            if let geoMix {
                Text(MatchMath.liveGeoSpark(geoMix))
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.9))
            }
            if let clahe = MatchMath.claheBanner(
                MatchMath.claheNeeded(luma: sharps.min() ?? 1, continuity: continuity, floor: 0.12)
            ) {
                Text(clahe)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 3)
                    .background(Color.orange)
                    .accessibilityLabel("Nacht-Ausgleich")
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(Color.black.opacity(0.72))
        .help(String(
            format: "8-Frame Ampel · Aufnahme %.0f %% · Schärfe %.0f %% · Yaw %.0f°",
            (caps.min() ?? 0) * 100,
            (sharps.min() ?? 0) * 100,
            (yaws.map { abs($0) }.max() ?? 0) * 180 / .pi
        ))
    }

    private func lamp(_ value: MatchMath.Lamp, label: String) -> some View {
        HStack(spacing: 1) {
            Text(MatchMath.lampGlyph(value))
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(color(value))
                .accessibilityLabel(MatchMath.lampPattern(value))
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    private func color(_ value: MatchMath.Lamp) -> Color {
        switch value {
        case .green: return Color.green
        case .amber: return Color.orange
        case .red: return Color.red
        }
    }
}

struct AnatomyMesh: View {
    var face: FaceObservation
    var scale: CGFloat
    var selected: Bool

    var body: some View {
        let strokes = face.strokes.isEmpty
            ? [LandmarkStroke(label: "Punkte", closed: false, points: face.landmarks)]
            : face.strokes
        ZStack(alignment: .topLeading) {
            ForEach(Array(strokes.enumerated()), id: \.offset) { _, stroke in
                Path { path in
                    guard let first = stroke.points.first else { return }
                    path.move(to: CGPoint(x: first.x * scale, y: first.y * scale))
                    for p in stroke.points.dropFirst() {
                        path.addLine(to: CGPoint(x: p.x * scale, y: p.y * scale))
                    }
                }
                .stroke(strokeColor(stroke.label, selected: selected), lineWidth: selected ? 2.2 : 1.2)
            }
            if selected {
                ForEach(Array(face.landmarks.enumerated()), id: \.offset) { _, p in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 3, height: 3)
                        .offset(x: CGFloat(p.x) * scale - 1.5, y: CGFloat(p.y) * scale - 1.5)
                }
                ForEach(labelPoints(face), id: \.label) { item in
                    Text(item.label)
                        .font(.system(size: 10, design: .monospaced))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.black.opacity(0.72))
                        .foregroundStyle(.white)
                        .offset(
                            x: CGFloat(item.point.x) * scale + 4,
                            y: CGFloat(item.point.y) * scale - 10
                        )
                }
            }
        }
    }

    private func strokeColor(_ label: String, selected: Bool) -> Color {
        let base: Color = {
            switch label {
            case "Auge L", "Auge R": return Color.cyan
            case "Braue L", "Braue R": return Color.white
            case "Nase", "Nasenrücken", "Nasenbreite": return Color.yellow
            case "Mund", "Lippen", "Mundbreite": return Color.orange
            case "Kinn": return Color.green
            case "Haaransatz": return Color.gray
            case "Ohr L", "Ohr R": return Color.cyan
            default: return Color.white
            }
        }()
        return selected ? base.opacity(0.95) : base.opacity(0.4)
    }

    private func labelPoints(_ face: FaceObservation) -> [(label: String, point: Point2)] {
        var out: [(String, Point2)] = []
        let wanted = [
            "Auge L", "Auge R", "Nase", "Nasenbreite", "Mund", "Mundbreite",
            "Kinn", "Haaransatz", "Ohr L", "Ohr R", "Braue L", "Braue R",
        ]
        for stroke in face.strokes {
            guard wanted.contains(stroke.label) else { continue }
            guard let mid = stroke.points.dropFirst(stroke.points.count / 2).first ?? stroke.points.first else { continue }
            out.append((stroke.label, mid))
        }
        return out
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
