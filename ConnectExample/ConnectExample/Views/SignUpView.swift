//
//  SignUpView.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $authViewModel.email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            TextField("Phone", text: $authViewModel.phoneNumber)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("Password", text: $authViewModel.password)
                .textContentType(.password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                        
            Button() {
                authViewModel.signUp()
            } label: {
                Text("Submit")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
                
            }
            .disabled(authViewModel.isLoading)
                        
            Button() {
                    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                    let randomChars = (0..<10).compactMap { _ in letters.randomElement() }
                    authViewModel.email = "integration-test+\(String(randomChars))@corbado.com"
                    authViewModel.phoneNumber = "+4915121609839"
                    authViewModel.password = "asdfasdf"
            } label: {
                Text("Autofill")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
                
            }
            .disabled(authViewModel.isLoading)
            
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
