// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TransferKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TransferKit",
            targets: ["Target2", "TransferKit"]
        ),
    ],
    targets: [
        .target(
            name: "Target2"
        ),
        .target(name: "TransferKit")
    ]
)
