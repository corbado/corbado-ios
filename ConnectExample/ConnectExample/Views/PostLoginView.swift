//
//  PostLoginView.swift
//  ConnectExample
//
//  Created by Martin on 4/5/2025.
//

import SwiftUI
import AuthenticationServices

struct PostLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel;
    @State private var isSheetPresent = false
    
    var body: some View {
        VStack {
            
        }
        .onAppear {
            Task {
                await openAuthWebView()
            }
        }
    }
    
    @MainActor
    func openAuthWebView() async {
        guard let idToken = await authViewModel.getIdToken() else {
            return
        }
        
        guard let url = URL(string: "https://feature-wv.connect-next.playground.corbado.io/redirect?token=\(idToken)&redirectUrl=%2Fpost-login-wv") else {
            return
        }
        
        let callbackURLScheme = "auth"
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { callbackURL, error in
            if let error = error {
                // Handle errors
                if let authError = error as? ASWebAuthenticationSessionError,
                   authError.code == .canceledLogin {
                    print("Authentication cancelled by user.")
                } else {
                    print("Authentication failed with error: \(error.localizedDescription)")
                }
            } else if let receivedURL = callbackURL {
                // Handle successful authentication
                print("Authentication successful! Callback URL: \(receivedURL.absoluteString)")
            } else {
                // Should not happen typically, but handle defensively
                 print("Authentication returned without error or URL.")
            }
        
            authViewModel.completePKSetupChecking()
        }
        
        let presentationContextProvider = PresentationContextProvider()
        session.presentationContextProvider = presentationContextProvider
        
        session.start()
    }
}

class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .filter { $0.isKeyWindow }
            .first ?? ASPresentationAnchor()
    }
}
