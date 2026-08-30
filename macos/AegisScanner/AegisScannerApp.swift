import SwiftUI

@main
struct AegisScannerApp: App {
    @StateObject private var store = LibraryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 980, minHeight: 640)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Ordner scannen…") {
                    store.pickFolder()
                }
                .keyboardShortcut("o", modifiers: [.command])
                Button("Live-Stream…") {
                    store.startLiveFromField()
                }
                .keyboardShortcut("l", modifiers: [.command])
                Button("Webcam") {
                    store.startWebcam()
                }
                Button("Erkennen") {
                    Task { await store.scan() }
                }
                .keyboardShortcut("r", modifiers: [.command])
                Divider()
                Button("Vorheriges Bild") {
                    store.stepMedia(-1)
                }
                .keyboardShortcut(.leftArrow, modifiers: [.command])
                Button("Nächstes Bild") {
                    store.stepMedia(1)
                }
                .keyboardShortcut(.rightArrow, modifiers: [.command])
            }
        }
    }
}
