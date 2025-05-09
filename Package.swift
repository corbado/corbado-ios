// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CorbadoConnect",
    platforms: [
            .iOS(.v16)
        ],
    products: [
        .library(
            name: "CorbadoConnect",
            targets: ["CorbadoConnect"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", from: "2.0.0"),
        .package(name: "SimpleAuthenticationServices", path: "../SimpleAuthenticationServices"),
    ],
    targets: [
        .target(
            name: "CorbadoConnect",
            dependencies: [
                "OpenAPIClient",
                .product(name: "Factory", package: "Factory"),
                .product(name: "SimpleAuthenticationServices", package: "SimpleAuthenticationServices")
            ]
        ),
        .testTarget(
            name: "CorbadoConnectTests",
            dependencies: ["CorbadoConnect"]
        ),
        .target(
            name: "OpenAPIClient"
        ),
    ]
)
