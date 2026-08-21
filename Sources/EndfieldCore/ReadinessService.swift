import Foundation

public struct ReadinessService: Sendable {
    public init() {}

    public func check(
        paths: EndfieldPaths = EndfieldPaths(),
        profileURL: URL?
    ) -> ReadinessSnapshot {
        let fm = FileManager.default
        let inspector = CrossOverInspector()
        let platform = PlatformInspector()

        let crossover: CheckState
        if !platform.isAppleSilicon {
            crossover = .needsAttention(
                "This release supports Apple Silicon Macs."
            )
        } else if !platform.rosettaCanRunX86() {
            crossover = .needsAttention(
                "Rosetta 2 is needed for this tested CrossOver build. Install Rosetta, then check again."
            )
        } else {
            do {
                let info = try inspector.find(paths: paths)
                crossover = info.matches(.firstRelease)
                    ? .ready
                    : .needsAttention(
                        "Found \(info.shortVersion) / \(info.build). This release supports \(SupportedBuild.firstRelease.shortVersion) / \(SupportedBuild.firstRelease.build)."
                    )
            } catch {
                crossover = .needsAttention(
                    "Install the supported CrossOver Preview build."
                )
            }
        }

        let bottle: CheckState
        if !fm.fileExists(atPath: paths.bottleConfig.path) {
            bottle = .needsAttention(
                "Create a Windows 11 64-bit bottle named Arknights Endfield."
            )
        } else if !fm.fileExists(atPath: paths.endfieldExe.path) {
            bottle = .needsAttention(
                "Open GRYPHLINK in this bottle and install Arknights: Endfield first."
            )
        } else {
            bottle = .ready
        }

        let gryphlinkProgramFound =
            fm.fileExists(atPath: paths.gryphlinkLauncherExe.path) ||
            fm.fileExists(atPath: paths.gryphlinkWindowsShortcut.path)

        let gryphlink: CheckState
        if !gryphlinkProgramFound {
            gryphlink = .needsAttention(
                "Install GRYPHLINK inside the Arknights Endfield bottle."
            )
        } else if !fm.fileExists(
            atPath: paths.gryphlinkHelperExecutable.path
        ) {
            gryphlink = .needsAttention(
                "Open GRYPHLINK once from CrossOver Preview so CrossOver can finish creating its launcher, then check again."
            )
        } else {
            gryphlink = .ready
        }

        let profile: CheckState =
            profileURL != nil
            ? .ready
            : .needsAttention(
                "This copy of Endfield for CrossOver is incomplete. Download the official release again."
            )

        return ReadinessSnapshot(
            crossover: crossover,
            bottle: bottle,
            gryphlink: gryphlink,
            profile: profile,
            isInstalled: fm.fileExists(atPath: paths.stateFile.path)
        )
    }
}
