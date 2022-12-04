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
        .target(
            name: "WebAssemblyInterpreter",
            dependencies: ["SwiftLEB128"]
        ),
        .testTarget(
            name: "WebAssemblyInterpreterTests",
            dependencies: ["WebAssemblyInterpreter"],
            resources: [.process("Resources")]
        ),
    ]
)
