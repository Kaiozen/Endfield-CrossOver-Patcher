import Foundation
import Testing
@testable import EndfieldCore

@Test("supported CrossOver build matches exactly")
func supportedBuild() {
    let info = CrossOverInfo(
        appURL: URL(
            fileURLWithPath: "/tmp/CrossOver Preview.app"
        ),
        shortVersion: "20260717",
        build: "27.0.0.40734"
    )
    #expect(info.matches(.firstRelease))
}

@Test("unsupported CrossOver build is rejected by comparison")
func unsupportedBuild() {
    let info = CrossOverInfo(
        appURL: URL(
            fileURLWithPath: "/tmp/CrossOver Preview.app"
        ),
        shortVersion: "20260731",
        build: "27.0.0.99999"
    )
    #expect(!info.matches(.firstRelease))
}

@Test("synthetic patch profile applies and verifies")
func syntheticPatch() throws {
    let fm = FileManager.default
    let root = fm.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    let wine = root.appendingPathComponent(
        "lib/wine/x86_64-unix",
        isDirectory: true
    )
    try fm.createDirectory(
        at: wine,
        withIntermediateDirectories: true
    )
    defer { try? fm.removeItem(at: root) }

    let file = wine.appendingPathComponent("ntdll.so")
    let source = Data("abcdef".utf8)
    let target = Data("abZZef".utf8)
    try source.write(to: file)

    let profile = PatchProfile(
        format: 1,
        name: "synthetic",
        crossoverVersion: "20260717",
        crossoverBuild: "27.0.0.40734",
        modules: [
            PatchModule(
                relativePath: "x86_64-unix/ntdll.so",
                sourceSHA256: SHA256File.hex(data: source),
                targetSHA256: SHA256File.hex(data: target),
                sourceSize: source.count,
                targetSize: target.count,
                chunks: [
                    PatchChunk(
                        offset: 2,
                        removeCount: 2,
                        replacementBase64:
                            Data("ZZ".utf8)
                            .base64EncodedString()
                    )
                ]
            )
        ]
    )

    try PatchEngine().apply(
        profile: profile,
        toPrivateRoot: root
    )
    #expect(try Data(contentsOf: file) == target)
}

@Test("bottle configuration adds tested settings and removes runtime selectors")
func bottleConfig() throws {
    let fm = FileManager.default
    let file = fm.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    defer { try? fm.removeItem(at: file) }

    try """
    [Bottle]
    "Name" = "Arknights Endfield"

    [EnvironmentVariables]
    "CX_ROOT" = "/bad/root"
    "WINEMSYNC" = "0"
    "SOME_OTHER_VALUE" = "keep-me"

    [End]
    """.write(
        to: file,
        atomically: true,
        encoding: .utf8
    )

    try BottleConfigEditor().apply(to: file)
    let text = try String(
        contentsOf: file,
        encoding: .utf8
    )

    #expect(!text.contains("\"CX_ROOT\""))
    #expect(
        text.contains(
            "\"SOME_OTHER_VALUE\" = \"keep-me\""
        )
    )
    #expect(text.contains("\"WINEMSYNC\" = \"1\""))
    #expect(
        text.contains(
            "\"CX_GRAPHICS_BACKEND\" = \"d3dmetal\""
        )
    )
}

@Test("green button dependency is inserted safely and only once")
func greenButtonMachOLoadCommand() throws {
    var data = Data(repeating: 0, count: 1024)

    func put32(_ value: UInt32, _ offset: Int) {
        data[offset] = UInt8(value & 0xff)
        data[offset + 1] = UInt8((value >> 8) & 0xff)
        data[offset + 2] = UInt8((value >> 16) & 0xff)
        data[offset + 3] = UInt8((value >> 24) & 0xff)
    }

    put32(0xfeedfacf, 0)
    put32(1, 16)
    put32(152, 20)

    let command = 32
    put32(0x19, command)
    put32(152, command + 4)
    put32(1, command + 64)

    let section = command + 72
    put32(512, section + 48)

    let dependency = "@loader_path/EndfieldGreenButton.dylib"

    #expect(try !MachOLoadCommandEditor.hasLoadDylib(data, name: dependency))

    let patched = try MachOLoadCommandEditor.addingLoadDylib(
        data,
        name: dependency
    )

    #expect(patched.count == data.count)
    #expect(try MachOLoadCommandEditor.hasLoadDylib(patched, name: dependency))

    let secondPass = try MachOLoadCommandEditor.addingLoadDylib(
        patched,
        name: dependency
    )
    #expect(secondPass == patched)
}
