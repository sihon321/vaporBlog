// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "sho59",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc"),
        
        // 🐘 Non-blocking, event-driven Swift client for PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/vapor-community/markdown-provider.git", .upToNextMajor(from: "2.0.0")),
        ],
    targets: [
        .target(name: "App",
                dependencies: ["FluentPostgreSQL",
                               "Vapor",
                               "LeafMarkdown",
                               "Leaf",
                               "Authentication"],
                exclude: ["Public"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)


