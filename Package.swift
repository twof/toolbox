// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "VaporToolbox",
    products: [
        .executable(name: "vapor", targets: ["Executable"]),
        .library(name: "VaporToolbox", targets: ["VaporToolbox"]),
    ],
    dependencies: [
        // Swift Promises, Futures, and Streams.
        .package(url: "https://github.com/vapor/async.git", .branch("beta")),

        // Swift wrapper for Console I/O.
        .package(url: "https://github.com/vapor/console.git", .branch("beta")),

        // Core extensions, type-aliases, and functions that facilitate common tasks.
        .package(url: "https://github.com/vapor/core.git", .branch("beta")),

        // Cryptography modules
        .package(url: "https://github.com/vapor/crypto.git", .branch("beta")),

        // Non-blocking networking for Swift (HTTP and WebSockets).
        .package(url: "https://github.com/vapor/engine.git", .branch("beta")),

        // The Package Manager for the Swift Programming Language
        .package(url: "https://github.com/apple/swift-package-manager.git", .branch("master")),
    ],
    targets: [
        // Executable
        .target(name: "Executable", dependencies: ["Console", "VaporToolbox"]),

        // Toolbox
        .target(name: "VaporToolbox", dependencies: ["Console", "Command", "SwiftPM"]),
        .testTarget(name: "VaporToolboxTests", dependencies: ["VaporToolbox"]),
    ]
)
