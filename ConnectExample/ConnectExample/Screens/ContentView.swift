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
        switch appRouter.path.last {
        case .checking:
            ProgressView()
        case .login:
            LoginView(appRouter: appRouter)
        case .signUp:
            SignUpView()
        case .home:
            HomeView()
        case .profile:
            ProfileView()
        case .postLogin:
            PostLoginView(appRouter: appRouter)
        case .setupTOTP:
            TOTPSetupView()
        default:
            ProgressView()
        }
    }
}
