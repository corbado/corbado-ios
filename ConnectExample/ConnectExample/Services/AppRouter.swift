//
//  AppRouter.swift
//  ConnectExample
//
//  Created by Martin on 6/5/2025.
//

import SwiftUI
import Combine

enum AppNavigationPath: Hashable {
    case login
    case signUp
    case home
    case checking
    case postLogin
    case setupTOTP
}

@MainActor
class AppRouter: ObservableObject {
    @Published var path: [AppNavigationPath] = []
    
    func navigateTo(_ destination: AppNavigationPath) {
        if !path.isEmpty {
            path.removeLast()
        }
        
        path.append(destination)
    }

    func replace(_ destination: AppNavigationPath) {
        if !path.isEmpty {
            path.removeLast()
        }
        
        path.append(destination)
    }

    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeAll()
    }
}
