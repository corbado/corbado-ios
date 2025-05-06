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

            TextField("Phone", text: $viewModel.phoneNumber)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Password", text: $viewModel.password)
                .textContentType(.newPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            AnimatedButton(label: "Submit", isLoading: viewModel.primaryLoading) {
                await viewModel.signUp(appRouter: appRouter)
            }
            
            AnimatedButton(label: "AutoFill", isLoading: false) {
                viewModel.autoFill()
            }
            
            NavigationLink("Log in instead", destination: LoginView())
            
            Spacer()
        }
        .padding()
        .navigationTitle("Signup")
    }
}

#Preview {
    SignUpView()
}
