// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UMe",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "Authentication", targets: ["Authentication"]),
        .library(name: "Discovery", targets: ["Discovery"]),
        .library(name: "Commerce", targets: ["Commerce"])
    ],
    dependencies: [
        // External dependencies will go here
    ],
    targets: [
        .target(name: "Core", path: "Sources/Core"),
        .target(name: "DesignSystem", path: "Sources/DesignSystem"),
        .target(name: "Authentication", dependencies: ["Core", "DesignSystem"], path: "Sources/Features/Authentication"),
        .target(name: "Discovery", dependencies: ["Core", "DesignSystem"], path: "Sources/Features/Discovery"),
        .target(name: "Commerce", dependencies: ["Core", "DesignSystem"], path: "Sources/Features/Commerce"),
        
        // Tests
        .testTarget(name: "CoreTests", dependencies: ["Core"]),
        .testTarget(name: "DesignSystemTests", dependencies: ["DesignSystem"])
    ]
)
