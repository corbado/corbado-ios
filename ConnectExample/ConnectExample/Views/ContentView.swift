//
//  ContentView.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI

struct ContentView: View {
    // Access the shared AuthViewModel from the environment
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        Group {
            switch viewModel.currentAuthState {
            case .unknown, .checking:                
                ProgressView()
            case .signedOut:
                NavigationView {
                    LoginView()
                }
            case .signedIn:
                NavigationView {
                    ProfileView()
                }
            case .requiresTOTPConfirmation:
                NavigationView {
                    TOTPConfirmationView()
                }
            case .requiresTOTPSetup:
                NavigationView {
                    TOTPSetupView()
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                    Button("OK", role: .cancel) { viewModel.errorMessage = nil }
                }, message: {
                    Text(viewModel.errorMessage ?? "An unknown error occurred.")
                })
                // Optional: Add a loading overlay
                .overlay {
                     if viewModel.isLoading {
                         Color.black.opacity(0.3).ignoresSafeArea()
                         ProgressView("Loading...").tint(.white).foregroundColor(.white)
                     }
                }
    }
}
