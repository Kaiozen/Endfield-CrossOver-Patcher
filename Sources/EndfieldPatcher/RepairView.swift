import SwiftUI

struct RepairView: View {
    @ObservedObject var model: AppModel
    @State private var showRemoveConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Repair Endfield")
                        .font(.largeTitle.bold())

                    Text(
                        "Use this if GRYPHLINK stops opening Endfield after a CrossOver, launcher, or menu refresh."
                    )
                    .font(.title3)
                    .foregroundStyle(.secondary)
                }

                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        Label(
                            "Repair checks only the Endfield setup",
                            systemImage:
                                "wrench.and.screwdriver"
                        )
                        .font(.headline)

                        Text(
                            "It verifies the private runtime, tested bottle settings, launch connection, GRYPHLINK helper, and macOS fullscreen button. It does not change other bottles."
                        )
                        .foregroundStyle(.secondary)

                        Button {
                            model.repair()
                        } label: {
                            Label(
                                model.busy
                                    ? model.progressText
                                    : "Check and Repair",
                                systemImage: "cross.case.fill"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(model.busy)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox {
                    VStack(alignment: .leading, spacing: 14) {
                        Label(
                            "Watch the next launch",
                            systemImage: "waveform.path.ecg"
                        )
                        .font(.headline)

                        Text(
                            "If a launch is acting strangely, start the watchdog and then launch Endfield normally from CrossOver. It watches locally for two minutes and records which runtime the Endfield processes actually use."
                        )
                        .foregroundStyle(.secondary)

                        if model.watchingLaunch {
                            HStack {
                                ProgressView()
                                    .controlSize(.small)
                                Text(
                                    "Watching. Launch GRYPHLINK and press Play now."
                                )
                                Spacer()
                                Button(
                                    "Stop",
                                    role: .cancel
                                ) {
                                    model.stopLaunchWatch()
                                }
                            }
                        } else {
                            Button("Watch Next Launch") {
                                model.startLaunchWatch()
                            }
                            .buttonStyle(.bordered)
                        }

                        if let url = model.watchReportURL {
                            Text(url.path)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                    }
                    .padding(.vertical, 4)
                }

                GroupBox {
                    VStack(alignment: .leading, spacing: 14) {
                        Label(
                            "Create a quick support report",
                            systemImage:
                                "doc.text.magnifyingglass"
                        )
                        .font(.headline)

                        Text(
                            "Takes a snapshot of the current setup. Nothing is uploaded automatically."
                        )
                        .foregroundStyle(.secondary)

                        Button("Create Support Report") {
                            model.createSupportReport()
                        }

                        if let url = model.supportReportURL {
                            Text(url.path)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Remove setup")
                        .font(.headline)

                    Text(
                        "Restores the saved GRYPHLINK launcher and moves the private Endfield runtime out of the active path."
                    )
                    .foregroundStyle(.secondary)

                    Button(
                        "Remove Endfield Setup",
                        role: .destructive
                    ) {
                        showRemoveConfirmation = true
                    }
                    .disabled(
                        !model.readiness.isInstalled ||
                        model.busy
                    )
                }

                if let error = model.errorText {
                    Text(error)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(
                            .quaternary,
                            in: RoundedRectangle(
                                cornerRadius: 10
                            )
                        )
                        .textSelection(.enabled)
                }
            }
            .padding(32)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Repair")
        .confirmationDialog(
            "Remove the Endfield-specific setup?",
            isPresented: $showRemoveConfirmation
        ) {
            Button(
                "Remove Setup",
                role: .destructive
            ) {
                model.removeSetup()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "The patcher will restore its saved GRYPHLINK launcher backup. CrossOver Preview itself is not changed."
            )
        }
    }
}
