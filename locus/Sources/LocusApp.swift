import SwiftUI

@main
struct LocusApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup("Locus") {
            ContentView(model: model)
                .frame(minWidth: 900, minHeight: 620)
        }
    }
}
