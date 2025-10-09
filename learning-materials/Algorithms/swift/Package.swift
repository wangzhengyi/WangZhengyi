// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AlgorithmsSwift",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "AlgorithmsSwift", targets: ["AlgorithmsSwift"])
    ],
    targets: [
        .executableTarget(
            name: "AlgorithmsSwift",
            path: "Sources/AlgorithmsSwift"
        )
    ]
)