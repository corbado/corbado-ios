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
        // Release prerequisite: replace this PR revision with from: "1.3.2" once published.
        .package(url: "https://github.com/corbado/SimpleAuthenticationServices.git", revision: "55b5f050a773dafe1de9a3950d87ccb993fd625b"),
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
