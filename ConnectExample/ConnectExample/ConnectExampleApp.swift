//
//  ConnectExampleApp.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

@main
struct ConnectExampleApp: App {
    let authManager: AuthManager;
    @StateObject var authViewModel: AuthViewModel
    
    init() {
        let manager = AuthManager()
        self.authManager = manager
        
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authManager: manager))
        configureAmplify()
        authViewModel.checkAuthState()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(authViewModel)
        }
    }
    
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure(with: .amplifyOutputs)
        } catch {
            print("Failed to configure Amplify: \(error)")
        }
    }
}
