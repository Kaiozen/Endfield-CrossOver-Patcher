import SwiftUI

struct ContentView: View {
    @StateObject private var model = AppModel()
    @State private var selection: Section = .setup

    enum Section: String, CaseIterable, Identifiable {
        case setup = "Set Up"
        case repair = "Repair"
        case about = "About"

        var id: String { rawValue }

        var symbol: String {
            switch self {
            case .setup: "wand.and.stars"
            case .repair: "wrench.and.screwdriver"
            case .about: "info.circle"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(
                Section.allCases,
                selection: $selection
            ) { item in
                Label(
                    item.rawValue,
                    systemImage: item.symbol
                )
                .tag(item)
            }
            .navigationSplitViewColumnWidth(
                min: 180,
                ideal: 210
            )
        } detail: {
            switch selection {
            case .setup:
                SetupView(model: model)
            case .repair:
                RepairView(model: model)
            case .about:
                AboutView()
            }
        }
        .frame(
            minWidth: 880,
            minHeight: 640
        )
        .task {
            model.refresh()
        }
    }
}
