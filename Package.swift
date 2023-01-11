// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-webassembly-interpreter",
    platforms: [
        .macOS(.v12),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "WebAssemblyInterpreter",
            targets: ["WebAssemblyInterpreter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/gibachan/SwiftLEB128.git", from: "0.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "WebAssemblyInterpreterDemo",
            dependencies: ["WebAssemblyInterpreter"]
        ),
        .executableTarget(
            name: "FizzBuzz",
            dependencies: ["WebAssemblyInterpreter"]
        ),
        .target(
            name: "WebAssemblyInterpreter",
            dependencies: ["SwiftLEB128"],
            plugins: ["SwiftLintPlugin"]
        ),
        .testTarget(
            name: "WebAssemblyInterpreterTests",
            dependencies: ["WebAssemblyInterpreter"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "Spec",
            dependencies: ["WebAssemblyInterpreter"],
            resources: [.process("Resources")]
        ),
        .plugin(
            name: "SwiftLintPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "SwiftLintBinary")
            ]
        ),
        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.50.1/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "487c57b5a39b80d64a20a2d052312c3f5ff1a4ea28e3cf5556e43c5b9a184c0c"
        )
    ]
)
