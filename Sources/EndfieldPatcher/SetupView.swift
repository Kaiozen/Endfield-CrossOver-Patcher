import SwiftUI

struct SetupView: View {
    @ObservedObject var model: AppModel
    @State private var showTechnical = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header

                GroupBox {
                    VStack(spacing: 2) {
                        StatusRow(
                            title: "CrossOver Preview",
                            state: model.readiness.crossover
                        )
                        Divider()
                        StatusRow(
                            title: "Arknights Endfield",
                            state: model.readiness.bottle
                        )
                        Divider()
                        StatusRow(
                            title: "GRYPHLINK",
                            state: model.readiness.gryphlink
                        )
                        Divider()
                        StatusRow(
                            title: "Compatibility recipe",
                            state: model.readiness.profile
                        )
                    }
                    .padding(.vertical, 4)
                } label: {
                    Label("Ready to set up?", systemImage: "checklist")
                        .font(.headline)
                }

                if model.readiness.isInstalled {
                    installedCard
                } else {
                    setupAction
                }

                DisclosureGroup(
                    "What will this change?",
                    isExpanded: $showTechnical
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CrossOver Preview itself stays unchanged.")
                        Text(
                            "The app creates a private compatibility runtime for the Arknights Endfield bottle and connects only the GRYPHLINK launcher for this game to it."
                        )
                        Text(
                            "Your other CrossOver bottles keep using the normal CrossOver runtime."
                        )
                        Text(
                            "When Endfield is in Windowed mode, the normal macOS green fullscreen button works too."
                        )
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                }

                messageCards
            }
            .padding(32)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Set Up")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    model.refresh()
                } label: {
                    Label(
                        "Check Again",
                        systemImage: "arrow.clockwise"
                    )
                }

                Button {
                    model.openCrossOver()
                } label: {
                    Label(
                        "Open CrossOver Preview",
                        systemImage: "play.rectangle"
                    )
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 38))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("Endfield for CrossOver")
                .font(.largeTitle.bold())

            Text(
                "If CrossOver Preview, GRYPHLINK, and Endfield are ready, one click handles the rest."
            )
            .font(.title3)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var setupAction: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                model.install()
            } label: {
                HStack {
                    if model.busy {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(
                        model.busy
                            ? model.progressText
                            : "Set Up Endfield"
                    )
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(
                !model.readiness.canInstall ||
                model.busy
            )

            if !model.readiness.canInstall {
                Text(
                    "Install the items marked “Needs attention.” Once they are ready, Set Up Endfield handles the compatibility work automatically."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var installedCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label(
                    "Endfield is set up",
                    systemImage: "checkmark.seal.fill"
                )
                .font(.title3.bold())

                Text(
                    "Daily use is simple: open CrossOver Preview → Arknights Endfield → GRYPHLINK → Play."
                )
                .foregroundStyle(.secondary)

                Text(
                    "Windowed mode also supports the green macOS fullscreen button."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)

                Button("Open CrossOver Preview") {
                    model.openCrossOver()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private var messageCards: some View {
        if let error = model.errorText {
            messageBox(
                title: "Setup stopped safely",
                message: error,
                symbol: "exclamationmark.triangle.fill"
            )
        }

        if let success = model.successText {
            messageBox(
                title: "Done",
                message: success,
                symbol: "checkmark.circle.fill"
            )
        }
    }

    private func messageBox(
        title: String,
        message: String,
        symbol: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.title2)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(message)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
        .padding(16)
        .background(
            .quaternary,
            in: RoundedRectangle(cornerRadius: 12)
        )
        .accessibilityElement(children: .combine)
    }
}
