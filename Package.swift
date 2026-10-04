// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DisableSleep",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "DisableSleep",
            path: "Sources/DisableSleep"
        )
    ]
)
