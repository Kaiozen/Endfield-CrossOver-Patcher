import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.largeTitle.bold())
                    Text(
                        "A small compatibility tool with one job: make Endfield launch normally from CrossOver Preview."
                    )
                    .font(.title3)
                    .foregroundStyle(.secondary)
                }

                GroupBox("Special thanks") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("❤️ stoicswe / Endfield_FineWine")
                            .font(.title3.bold())

                        Text(
                            "This project would not exist without the original Endfield_FineWine compatibility research and first known working Endfield-on-Apple-Silicon CrossOver setup."
                        )
                        .foregroundStyle(.secondary)

                        Link(
                            "Visit Endfield_FineWine on GitHub",
                            destination: URL(
                                string: "https://github.com/stoicswe/Endfield_FineWine"
                            )!
                        )
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.vertical, 4)
                }

                GroupBox("Privacy") {
                    Text(
                        "No telemetry. No automatic log uploads. Support reports stay on your Mac until you choose to share them."
                    )
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
                }

                GroupBox("Supported build") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CrossOver Preview 20260717")
                        Text("Build 27.0.0.40734")
                            .foregroundStyle(.secondary)
                        Text(
                            "Apple Silicon · Rosetta 2 · D3DMetal · MSync · DirectX 11"
                        )
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("Independent project") {
                    Text(
                        "Not affiliated with Gryphline, Hypergryph, Tencent, CodeWeavers, Apple, or an anti-cheat vendor. You provide your own legitimate CrossOver, launcher, and game."
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
