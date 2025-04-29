# CorbadoIOSPAckage

## Requirements

- Swift 5.7 or later
- Swift Package Manager (built into Swift)
- (Optional) Xcode 14 or later for IDE integration

## Installation

Add `CorbadoIOSPAckage` as a dependency to your SwiftPM package or Xcode project.

### Swift Package Manager

In your `Package.swift`:

```swift
// Example Package.swift snippet
import PackageDescription

let package = Package(
    name: "ExampleApp",
    platforms: [.iOS(.v16)],
    dependencies: [
        .package(url: "https://github.com/YourUsername/CorbadoIOSPAckage.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ExampleApp",
            dependencies: [
                .product(name: "CorbadoIOSPAckage", package: "CorbadoIOSPAckage")
            ]
        ),
    ]
)
