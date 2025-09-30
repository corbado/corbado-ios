// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CorbadoConnect",
    platforms: [
            .iOS(.v15)
        ],
    products: [
        .library(
            name: "CorbadoConnect",
            targets: ["CorbadoConnect"]),
    ],
    dependencies: [        
        //.package(url: "https://github.com/corbado/SimpleAuthenticationServices.git", from: "1.1.0"),
        .package(path: "../SimpleAuthenticationServices")
    ],
    targets: [
        .target(
            name: "CorbadoConnect",
            dependencies: [
                "OpenAPIClient",            
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
