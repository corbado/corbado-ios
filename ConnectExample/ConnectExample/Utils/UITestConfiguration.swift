import Foundation
import Factory

protocol UITestConfiguration {
    var isOverlayEnabled: Bool { get }
    var isUITestMode: Bool { get }
}

class DefaultUITestConfiguration: UITestConfiguration {
    private let arguments: [String]
    
    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        self.arguments = arguments
    }
    
    var isOverlayEnabled: Bool {
        return arguments.contains(LaunchArgument.enableOverlay.rawValue)
    }
    
    var isUITestMode: Bool {
        return arguments.contains(LaunchArgument.uiTestMode.rawValue)
    }
}

extension Container {
    var uiTestConfiguration: Factory<UITestConfiguration> {
        self { DefaultUITestConfiguration() }
            .singleton
    }
}
