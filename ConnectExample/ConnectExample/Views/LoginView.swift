//
//  LoginView.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI

struct LoginView: View {
    // Access the shared AuthViewModel
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
            
            Spacer()
        }
        .padding()
        .navigationTitle("Login")        
    }
}
