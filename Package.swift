// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Blake2",
    platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11), .watchOS(.v6)],
    products: [
        .library(
            name: "Blake2",
            targets: ["Blake2"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Blake2",
            dependencies: ["CBlake2"]),
        .target(
            name: "CBlake2",
            dependencies: []
        ),
        .testTarget(
            name: "Blake2Tests",
            dependencies: ["Blake2"])
    ]
)
