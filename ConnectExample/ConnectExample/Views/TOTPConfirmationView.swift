//
//  TOTPConfirmationView.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI

struct TOTPConfirmationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Provide your TOTP code.").font(.largeTitle)
            
            TextField("6-digit TOTP", text: $authViewModel.totpCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            Button("Submit") {
                authViewModel.verifyTOTP()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(8)
            .disabled(authViewModel.isLoading)
        }
    }
}

#Preview {
    TOTPConfirmationView()
}
