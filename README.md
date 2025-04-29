# CorbadoConnect for iOS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)

`CorbadoConnect` is a native Swift SDK that makes it easy to integrate passkey-based, passwordless authentication into your iOS applications. It provides a high-level API to handle passkey creation, authentication, and management, powered by [Corbado](https://www.corbado.com).

## Features

- ✅ **Simple Passkey Integration:** Abstract away the complexity of the native `AuthenticationServices` framework.
- 🚀 **Multiple Login Flows:** Supports one-tap login, identifier-first login, and Conditional UI.
- 🛠️ **Full Passkey Management:** Allows users to add, list, and delete passkeys from their accounts.
- 📱 **Example App:** Includes a fully-featured example application to demonstrate all features and guide your implementation.
- 🧪 **Testable:** Provides protocols and helpers to make your integration and UI tests easier to write.

## Requirements

- iOS 15.0+
- Xcode 16.0+
- Swift 6.0+

## Installation

You can add `CorbadoConnect` to your project using the Swift Package Manager.

In Xcode, go to **File > Add Package Dependencies...** and enter the repository URL:

```
https://github.com/corbado/corbado-ios.git
```

### Package.swift

Alternatively, you can add it as a dependency in your `Package.swift` file:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    // ...
    dependencies: [
        .package(url: "https://github.com/corbado/corbado-ios.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                .product(name: "CorbadoConnect", package: "corbado-ios")
            ]
        ),
    ]
)
```

## Usage

### 1. Initialization

First, import `CorbadoConnect` and initialize the `Corbado` actor with your Project ID from the [Corbado developer panel](https://app.corbado.com).

```swift
import CorbadoConnect
import SwiftUI

class YourViewModel: ObservableObject {
    private let corbado: Corbado

    init() {
        self.corbado = Corbado(projectId: "pro-YOUR_PROJECT_ID")
    }
}
```

### 2. Login

The login process is stateful. You start by checking what login methods are available and then react to the returned state.

```swift
import CorbadoConnect

func startLogin() async {
    let nextStep = await corbado.isLoginAllowed()

    switch nextStep {
    case .initOneTap(let username):
        // Offer one-tap login to the user.
        print("Starting one-tap login for \(username)...")
        await corbado.loginWithOneTap()
    case .initTextField:
        // Prompt the user for their email or username.
        print("Please enter your username.")
    case .initFallback(let username, let error):
        // Fallback to a different login method, like password.
        print("Passkey login not available.")
    case .done(let session, let username):
        // Login was successful. 
        print("Welcome, \(username)!")
    default:
        break
    }
}
```

### 3. Appending a Passkey

After a user has logged in, you can offer to add a passkey to their account.

```swift
import CorbadoConnect

func offerPasskeyAppend(connectTokenProvider: @escaping () async throws -> String) async {
    let step = await corbado.isAppendAllowed(connectTokenProvider: connectTokenProvider)
    
    if case .askUserForAppend = step {
        // Show a UI to ask the user if they want to create a passkey.
        // If they agree, call completeAppend().
        let status = await corbado.completeAppend()
        if status == .completed {
            print("Successfully created a new passkey!")
        }
    }
}
```
*Note: The `connectTokenProvider` is a closure you implement that gets a short-lived session token from your application's backend. This is required for security.*


## Example App

The repository includes a comprehensive example app in the `ConnectExample` directory. It demonstrates all SDK features, including login, sign up, passkey management, and error handling. We highly recommend running it and using its source code as a reference.

To run the example app, open `ConnectExample/ConnectExample.xcodeproj` and run the `ConnectExample` scheme.

## Repository Structure

- `Sources/CorbadoConnect`: The source code for the `CorbadoConnect` SDK.
- `Sources/OpenAPIClient`: An auto-generated networking client for the Corbado API.
- `ConnectExample`: The example iOS application demonstrating the SDK.
- `Tests`: Unit tests for the `CorbadoConnect` SDK.

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.

## License

`CorbadoConnect` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
