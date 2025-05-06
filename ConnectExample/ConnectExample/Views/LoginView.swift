//
//  LoginView.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI

enum LoginStatus {
    case loading
    case fallback
    case passkeyTextField
}

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var status: LoginStatus = .loading
    
    var body: some View {
        VStack(spacing: 20) {
            switch status {
            case .loading:
                ProgressView("Checking Authentication...")
            case .fallback:
                FallbackLoginView()
            case .passkeyTextField:
                PasskeyTextFieldView{ email, errrMessage in
                    status = .fallback
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Login")
        .onAppear {
            Task {
                let nextStep = await authViewModel.corbado.isLoginAllowed()
                switch nextStep {
                case .InitTextField(let cuiChallenge):
                    status = .passkeyTextField
                case .InitOneTap(let email):
                    status = .passkeyTextField
                case .InitFallback(let email, let errorMessage):
                    status = .fallback
                default:
                    break
                }
            }
        }
    }
}

struct FallbackLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $authViewModel.email)
                .padding()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("Password", text: $authViewModel.password)
                .textContentType(.password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            Button() {
                authViewModel.signIn()
            } label: {
                Text("Login")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
            }
            .disabled(authViewModel.isLoading)
            
            NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
        }
    }
}

struct PasskeyTextFieldView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var onFallback: (_ email: String?, _ errorMessage: String?) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $authViewModel.email)
                .padding()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            Button() {
                Task {
                    let nextStep = await authViewModel.corbado.loginWithTextField(identifier: "integration-test+Cd7MUL53wR@corbado.com")
                    switch nextStep {
                    case .Done(let session):
                        await authViewModel.handoverSessionToAmplify(session: session)
                    case .InitFallback(let email, let errorMessage):
                        onFallback(email, errorMessage)
                    default:
                        break
                    }
                }
            } label: {
                Text("Login")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
            }
            .disabled(authViewModel.isLoading)
            
            NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
        }
    }
}
