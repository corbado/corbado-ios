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
import Factory

@main
struct ConnectExampleApp: App {
    @Injected(\.corbadoService) private var corbado: Corbado
    @StateObject private var appRouter = AppRouter()
    
    init() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
        } catch {
            print("Failed to configure Amplify: \(error)")
        }
        
        UITestSetup.setup(for: ProcessInfo.processInfo.arguments)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appRouter)
                .onAppear {
                    Task {
                        await UITestSetup.onAppear(for: ProcessInfo.processInfo.arguments)
                                                
                        do {
                            let session = try await Amplify.Auth.fetchAuthSession()
                            if session.isSignedIn {
#if DEBUG
                                if ProcessInfo.processInfo.arguments.contains(LaunchArgument.uiTestMode.rawValue) {
                                    _ = await Amplify.Auth.signOut()
                                    appRouter.replace(.login)
                                } else {
                                    appRouter.replace(.home)
                                }
#else
                                appRouter.replace(.home)
#endif
                            } else {
                                appRouter.replace(.login)
                            }
                        } catch {
                            print("error")
                        }
                    }
                }
            
            if ProcessInfo.processInfo.arguments.contains(LaunchArgument.uiTestMode.rawValue) {
                UITestNetworkBlockingView()
            }
        }
    }
}

extension Container {
    var corbadoService: Factory<Corbado> {
        self {
            guard let path = Bundle.main.path(forResource: "Corbado", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
                  let projectId = dict["ProjectId"] as? String,
                  let frontendApiUrlSuffix = dict["FrontendApiUrlSuffix"] as? String else {
                fatalError("Corbado.plist not found or configured incorrectly.")
            }
            
            return Corbado(
                projectId: projectId,
                frontendApiUrlSuffix: frontendApiUrlSuffix
            )
        }
        .singleton
    }
}
    
