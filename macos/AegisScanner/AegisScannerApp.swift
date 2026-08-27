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
                Button("Erkennen") {
                    Task { await store.scan() }
                }
                .keyboardShortcut("r", modifiers: [.command])
            }
        }
    }
}
