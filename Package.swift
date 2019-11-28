// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "VaporToolbox",
    dependencies: [
        // Vapor Cloud clients.
        .package(url: "https://github.com/twof/clients.git", .branch("UpgradeSPM")),

        // Core console protocol.
        .package(url: "https://github.com/vapor/console.git", from: "2.0.0"),
        
        // JSON parsing / serializing.
        .package(url: "https://github.com/vapor/json.git", from: "2.0.0"),
        
        // Vapor web framework.
          .package(url: "https://github.com/vapor/vapor.git", from: "2.0.0"),
        
        // Redis
        .package(url: "https://github.com/vapor/redis.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "VaporToolbox", dependencies: ["Cloud", "Shared"]),
        .target(name: "Executable", dependencies: ["VaporToolbox"]),
        .target(name: "Cloud", dependencies: ["Shared"]),
        .target(name: "Shared", dependencies: ["CloudClients", "Console", "JSON", "Vapor", "Redis"]),
    ]
)
