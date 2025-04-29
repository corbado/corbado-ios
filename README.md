# CorbadoIOSPAckage

A simple Swift Package Manager (SwiftPM) library that provides a `Printer` struct with a `sayHello()` function to print a friendly greeting message. Perfect for integrating into any Swift or iOS project as a runtime utility.

## Features

- Exposes a `Printer.sayHello()` method that prints “👋 Hello from CorbadoIOSPAckage!”
- Lightweight, zero dependencies
- SwiftPM-native; supports iOS and other Swift platforms

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
