//
//  UITestSetup.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import Foundation
import CorbadoConnect
import SimpleAuthenticationServicesMocks
import Factory
import UIKit

public enum LaunchArgument: String {
    case uiTestMode = "-UITestMode"
    case controlServerURL = "-ControlServerURL="
    case filteredByGradualRollout = "-FilteredByGradualRollout"
    case enableOverlay = "-EnableOverlay"
}

@MainActor
class UITestSetup {
    @Injected(\.corbadoService) private static var corbado: Corbado
    
    static func setup(for arguments: [String]) {
        if arguments.contains(LaunchArgument.uiTestMode.rawValue) {
            UIView.setAnimationsEnabled(false)
        }
    }
    
    static func onAppear(for arguments: [String]) async {
        if arguments.contains(LaunchArgument.uiTestMode.rawValue) {
            if let controlServerURL = self.uiTestsControlServer(arguments: arguments) {
                await corbado.setVirtualAuthorizationController(
                    VirtualAuthorizationController(controlServerURL: controlServerURL)
                )
            }
            
            await corbado.clearLocalState()
        }
        
        await corbado.setInvitationToken(token: "inv-token-correct")
        if arguments.contains(LaunchArgument.filteredByGradualRollout.rawValue) {
            await corbado.setInvitationToken(token: "inv-token-negative")
        }
    }
    
    private static func uiTestsControlServer(arguments: [String]) -> URL? {
        if let argumentString = arguments.first(where: { $0.hasPrefix(LaunchArgument.controlServerURL.rawValue) }) {
            let urlValue = argumentString.replacingOccurrences(of: LaunchArgument.controlServerURL.rawValue, with: "")
            return URL(string: urlValue)
        }
        
        return nil
    }
} 
