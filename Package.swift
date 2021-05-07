// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Blake2b",
    products: [
        .library(
            name: "Blake2b",
            targets: ["Blake2b"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Blake2b",
            dependencies: ["CBlake2b"]),
        .target(
            name: "CBlake2b",
            dependencies: []
        ),
        .testTarget(
            name: "Blake2bTests",
            dependencies: ["Blake2b"])
    ]
)
