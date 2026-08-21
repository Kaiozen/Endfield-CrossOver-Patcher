import AppKit
import EndfieldCore
import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published var readiness = ReadinessSnapshot(
        crossover: .checking,
        bottle: .checking,
        gryphlink: .checking,
        profile: .checking,
        isInstalled: false
    )

    @Published var busy = false
    @Published var checkingReadiness = false
    @Published var progressText = "Checking your Mac"
    @Published var errorText: String?
    @Published var successText: String?
    @Published var supportReportURL: URL?
    @Published var watchingLaunch = false
    @Published var watchReportURL: URL?

    let paths = EndfieldPaths()

    private var watchTask: Task<Void, Never>?
    private var readinessTask: Task<Void, Never>?

    init() {
        // Intentionally empty.
        //
        // Do not run readiness checks here. The checks include a short
        // subprocess used to verify Rosetta. Waiting for that subprocess
        // while SwiftUI is constructing this StateObject can create an
        // AttributeGraph cycle on macOS 26.
    }

    func refresh() {
        readinessTask?.cancel()

        let paths = self.paths
        let profileURL = AppResources.profileURL

        checkingReadiness = true
        errorText = nil

        readinessTask = Task { [weak self] in
            let snapshot = await Task.detached(
                priority: .userInitiated
            ) {
                ReadinessService().check(
                    paths: paths,
                    profileURL: profileURL
                )
            }.value

            guard !Task.isCancelled else { return }

            guard let self else { return }
            self.readiness = snapshot
            self.checkingReadiness = false
        }
    }

    func openCrossOver() {
        do {
            let info = try CrossOverInspector().find(
                paths: paths
            )
            NSWorkspace.shared.open(info.appURL)
        } catch {
            errorText = human(error)
        }
    }

    func install() {
        guard let profile = AppResources.profileURL else {
            errorText = human(
                EndfieldError.missingProfile
            )
            return
        }

        guard let helper = AppResources.menuHelperURL else {
            errorText =
                "This build is missing its Endfield launcher helper. Rebuild the app from a clean source checkout."
            return
        }

        let paths = self.paths

        runBackground {
            try InstallService().install(
                profileURL: profile,
                bundledMenuHelper: helper,
                paths: paths,
                progress: { [weak self] text in
                    Task { @MainActor in
                        self?.progressText = text
                    }
                }
            )

            return "Endfield is ready. Open CrossOver Preview, choose Arknights Endfield, then open GRYPHLINK."
        }
    }

    func repair() {
        guard let profile = AppResources.profileURL else {
            errorText = human(
                EndfieldError.missingProfile
            )
            return
        }

        guard let helper = AppResources.menuHelperURL else {
            errorText =
                "This build is missing its Endfield launcher helper."
            return
        }

        let paths = self.paths

        runBackground {
            try RepairService().repair(
                profileURL: profile,
                bundledMenuHelper: helper,
                paths: paths,
                progress: { [weak self] text in
                    Task { @MainActor in
                        self?.progressText = text
                    }
                }
            )

            return "Repair finished. Try GRYPHLINK again from CrossOver Preview."
        }
    }

    func createSupportReport() {
        let paths = self.paths

        Task {
            do {
                let url = try await Task.detached(
                    priority: .utility
                ) {
                    try DiagnosticsService().createReport(
                        paths: paths
                    )
                }.value

                supportReportURL = url
                NSWorkspace.shared.activateFileViewerSelecting(
                    [url]
                )
            } catch {
                errorText = human(error)
            }
        }
    }

    func startLaunchWatch() {
        guard !watchingLaunch else { return }

        watchingLaunch = true
        watchReportURL = nil
        errorText = nil

        let paths = self.paths

        watchTask = Task {
            do {
                let url = try await Task.detached(
                    priority: .utility
                ) {
                    try await LaunchWatchService().watch(
                        paths: paths,
                        duration: 120
                    )
                }.value

                watchReportURL = url
                watchingLaunch = false

                NSWorkspace.shared.activateFileViewerSelecting(
                    [url]
                )
            } catch is CancellationError {
                watchingLaunch = false
            } catch {
                watchingLaunch = false
                errorText = human(error)
            }
        }
    }

    func stopLaunchWatch() {
        watchTask?.cancel()
        watchTask = nil
        watchingLaunch = false
    }

    func removeSetup() {
        let paths = self.paths

        runBackground {
            try UninstallService().remove(
                paths: paths
            )

            return "The Endfield-specific setup was removed and the saved GRYPHLINK launcher was restored."
        }
    }

    private func runBackground(
        _ operation: @escaping @Sendable () throws -> String
    ) {
        guard !busy else { return }

        busy = true
        errorText = nil
        successText = nil

        Task {
            do {
                let message = try await Task.detached(
                    priority: .userInitiated,
                    operation: operation
                ).value

                successText = message
                refresh()
            } catch {
                errorText = human(error)
            }

            busy = false
        }
    }

    private func human(_ error: Error) -> String {
        (error as? LocalizedError)?.errorDescription ??
            error.localizedDescription
    }
}
