//
//  PasskeyAppendSuccess.swift
//  ConnectExample
//
//  Created by Martin on 15/5/2025.
//

import SwiftUI

struct PasskeyAppendSuccess: View {
    let onClick: () async -> Void
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack {
            Image("PasskeyAppendSuccess")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 100)
                .padding(.vertical, 30)
            
            Text("Your passkey is stored in iCloud KeyChain.")
                .font(.title2)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
            
            Text("You can now use your finterprint, face or PIN to log in.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            
            PrimaryButton(label: "Continue", isLoading: isLoading, accessibilityIdentifier: "postLoginScreen.continue") {
                isLoading = true
                await onClick()
                isLoading = false
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PasskeyAppendSuccess(onClick: { })
}
