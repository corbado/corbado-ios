//
//  LoginView.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appRouter: AppRouter
    
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            switch viewModel.status {
            case .loading:
                ProgressView()
            case .fallbackFirst:
                FallbackLoginView(viewModel: viewModel, appRouter: appRouter)
            case .fallbackSecondTOTP:
                FallbackTOTPView(viewModel: viewModel, appRouter: appRouter)
            case .passkeyTextField:
                PasskeyTextFieldView(viewModel: viewModel, appRouter: appRouter)
            case .passkeyOneTap:
                PasskeyOneTapView(viewModel: viewModel, appRouter: appRouter)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Login")
        .onAppear {
            Task {
                await viewModel.loadInitialStep()
            }
        }
    }
}

struct FallbackLoginView: View {
    @StateObject var viewModel: LoginViewModel
    var appRouter: AppRouter
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $viewModel.email)
                .padding()
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            AnimatedButton(label: "Login", isLoading: viewModel.primaryLoading) {
                await viewModel.loginWithEmailAndPassword(appRouter: appRouter)
            }
            
            NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
        }
    }
}

struct PasskeyTextFieldView: View {
    @StateObject var viewModel: LoginViewModel
    var appRouter: AppRouter
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $viewModel.email)
                .padding()
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            AnimatedButton(label: "Login", isLoading: viewModel.primaryLoading) {
                await viewModel.loginWithPasskeyTextField(appRouter: appRouter)
            }
            
            NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
        }
    }
}

struct FallbackTOTPView: View {
    @StateObject var viewModel: LoginViewModel
    var appRouter: AppRouter
    
    @State private var code = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Provide your TOTP code.").font(.largeTitle)
            
            TextField("6-digit TOTP", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            AnimatedButton(label: "Submit", isLoading: viewModel.primaryLoading) {
                viewModel.verifyTOTP(code: code, appRouter: appRouter)
            }
        }
        .padding()
    }
}

struct PasskeyOneTapView: View {
    @StateObject var viewModel: LoginViewModel
    var appRouter: AppRouter
    
    var body: some View {
        VStack(spacing: 20) {
            AnimatedButton(label: "Login as \(viewModel.email)", isLoading: viewModel.primaryLoading) {
                await viewModel.loginWithPasskeyOneTap(appRouter: appRouter)
            }
            
            AnimatedButton(label: "Switch account", isLoading: false) {
                await viewModel.discardPasskeyOneTap()
            }
            
            NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
        }
    }
}
