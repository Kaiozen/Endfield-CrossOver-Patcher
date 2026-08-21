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
                "The first release supports Apple Silicon Macs."
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

        let bottle: CheckState =
            fm.fileExists(atPath: paths.bottleConfig.path)
            ? .ready
            : .needsAttention(
                "Create a Windows 11 64-bit bottle named Arknights Endfield."
            )

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
                "GRYPHLINK is installed. Open CrossOver Preview once and open the Arknights Endfield bottle so CrossOver can finish creating its launcher, then check again."
            )
        } else {
            gryphlink = .ready
        }

        let profile: CheckState =
            profileURL != nil
            ? .ready
            : .needsAttention(
                "This development build is waiting for the reviewed R11 compatibility profile."
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
