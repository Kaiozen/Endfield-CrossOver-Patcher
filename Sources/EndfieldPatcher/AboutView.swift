import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.largeTitle.bold())

                    Text("Made by Kaiozen")
                        .font(.title3.bold())

                    Text(
                        "I made this so getting Endfield running through CrossOver doesn't have to be a pile of Terminal steps."
                    )
                    .foregroundStyle(.secondary)
                }

                GroupBox("Biggest credit") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("❤️ stoicswe / Endfield_FineWine")
                            .font(.title3.bold())

                        Text(
                            "This app would not exist without the original Endfield_FineWine work that got Endfield running on Apple Silicon through CrossOver. I turned that setup into a one-click app, but the compatibility research deserves the credit."
                        )
                        .foregroundStyle(.secondary)

                        Link(
                            "Open Endfield_FineWine on GitHub",
                            destination: URL(
                                string: "https://github.com/stoicswe/Endfield_FineWine"
                            )!
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }

                GroupBox("Supported CrossOver") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CrossOver Preview 20260717")
                            .font(.headline)
                        Text("Build 27.0.0.40734")
                            .foregroundStyle(.secondary)
                        Text(
                            "Apple Silicon • Rosetta 2 • D3DMetal • MSync • DirectX 11"
                        )
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("Privacy") {
                    Text(
                        "No telemetry and no automatic uploads. Support reports stay on your Mac unless you choose to share them."
                    )
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
                }

                GroupBox("Not an official game app") {
                    Text(
                        "This is my independent project. It is not made or endorsed by Gryphline, Hypergryph, CodeWeavers, Apple, or an anti-cheat company. You provide your own CrossOver, launcher, and game."
                    )
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
                }
            }
            .padding(32)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("About")
    }
}
