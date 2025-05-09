//
//  ConnectExampleApp.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import CorbadoConnect

@main
struct ConnectExampleApp: App {
    @StateObject private var appRouter = AppRouter()
    
    init() {
        configureAmplify()
        Corbado.shared.configure(projectId: "pro-1045460453059053120", frontendApiUrlSuffix: "frontendapi.cloud.corbado-staging.io", isDebug: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appRouter)
                .onAppear {
                    Task {
                        do {
                            let session = try await Amplify.Auth.fetchAuthSession()
                            if session.isSignedIn {
                                appRouter.replace(.home)
                            }
                        } catch {
                            print("error")
                        }
                    }
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

