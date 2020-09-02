// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VaporCSRF",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "VaporCSRF",
            targets: ["VaporCSRF"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "VaporCSRF",
            dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),
        .testTarget(
            name: "VaporCSRFTests",
            dependencies: ["VaporCSRF"]),
    ]
)
