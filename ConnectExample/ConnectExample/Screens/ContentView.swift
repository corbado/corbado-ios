//
//  ContentView.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI

struct ContentView: View {    
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        NavigationStack(path: $appRouter.path) {
            LoginView()
                .navigationDestination(for: AppNavigationPath.self) { destination in
                    switch destination {
                    case .checking:
                        ProgressView()
                    case .login:
                        LoginView()
                    case .signUp:
                        SignUpView()
                    case .home:
                        ProfileView()
                    case .postLogin:
                        PostLoginView(appRouter: appRouter)
                    case .setupTOTP:
                        TOTPSetupView()
                    }
                }
        }            
    }
}
