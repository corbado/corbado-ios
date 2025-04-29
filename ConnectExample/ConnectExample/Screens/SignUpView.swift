//
//  SignUpView.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var appRouter: AppRouter
    
    @ObservedObject var viewModel: SignUpViewModel = SignUpViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            ScreenHeadline(title: "Create an account", accessibilityIdentifier: "signUpScreen.headline")

            TextField("Phone", text: $viewModel.phoneNumber)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .accessibilityIdentifier("signUpScreen.phoneNumberField")
            
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .accessibilityIdentifier("signUpScreen.emailField")

            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .accessibilityIdentifier("signUpScreen.passwordField")
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            PrimaryButton(label: "Submit", isLoading: viewModel.primaryLoading, accessibilityIdentifier: "signUpScreen.submit") {
                await viewModel.signUp(appRouter: appRouter)
            }
            
            PrimaryButton(label: "AutoFill", isLoading: false, accessibilityIdentifier: "signUpScreen.autofill") {
                viewModel.autoFill()
            }
            
            SecondaryButton(label: "Log in instead", accessibilityIdentifier: "signUpScreen.navigateToLogin") {
                viewModel.navigateToLogin(appRouter: appRouter)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SignUpView()
}
