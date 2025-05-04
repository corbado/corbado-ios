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
    @StateObject var authViewModel: AuthViewModel = AuthViewModel()
    @StateObject var profileViewModel: ProfileViewModel = ProfileViewModel()
    
    init() {
        configureAmplify()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(profileViewModel)
                .onAppear {
                    authViewModel.checkAuthState()
                }
        }
    }
    
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
        } catch {
            print("Failed to configure Amplify: \(error)")
        }
    }
}

