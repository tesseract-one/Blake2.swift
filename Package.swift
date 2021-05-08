// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Blake2",
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
