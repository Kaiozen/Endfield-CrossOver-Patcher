// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "EndfieldCrossOverPatcher",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "EndfieldCore", targets: ["EndfieldCore"]),
        .executable(name: "EndfieldPatcher", targets: ["EndfieldPatcher"]),
        .executable(name: "EndfieldMenuHelper", targets: ["EndfieldMenuHelper"]),
    ],
    targets: [
        .target(name: "EndfieldCore"),
        .executableTarget(name: "EndfieldPatcher", dependencies: ["EndfieldCore"]),
        .executableTarget(name: "EndfieldMenuHelper"),
        .testTarget(name: "EndfieldCoreTests", dependencies: ["EndfieldCore"]),
    ]
)
