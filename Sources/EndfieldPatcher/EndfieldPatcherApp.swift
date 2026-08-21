import SwiftUI

@main
struct EndfieldPatcherApp: App {
    var body: some Scene {
        WindowGroup("Endfield for CrossOver") {
            ContentView()
        }
        .defaultSize(width: 980, height: 700)
        .commands {
            CommandGroup(replacing: .help) {
                Link(
                    "Project Documentation",
                    destination: URL(
                        string: "https://github.com/Kaiozen/Endfield-CrossOver-Patcher"
                    )!
                )
            }
        }
    }
}
