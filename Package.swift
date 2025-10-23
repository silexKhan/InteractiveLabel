// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "InteractiveLabel",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "InteractiveLabel",
            targets: ["InteractiveLabel"]),
    ],
    targets: [
        .target(
            name: "InteractiveLabel",
            dependencies: []),
        .testTarget(
            name: "InteractiveLabelTests",
            dependencies: ["InteractiveLabel"]),
    ]
)