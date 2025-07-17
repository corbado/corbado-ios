//
//  PostLoginViewModel.swift
//  ConnectExample
//
//  Created by Martin on 6/5/2025.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore
import CorbadoConnect
import Factory

@MainActor
class PostLoginViewModel: ObservableObject {
    @Injected(\.corbadoService) private var corbado: Corbado
    
    private let appRouter: AppRouter
    
    @Published var webViewURL: URL?
    @Published var authError: Error?
    @Published var isLoading = true
    @Published var primaryLoading = false
    @Published var isAuthComplete = false
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
        
    // WEB VIEW ONLY
    func prepareAndLoadAuthWebView() async {
        guard isLoading else { return }
        
        authError = nil
        isAuthComplete = false
        webViewURL = nil
        
        guard let idToken = await getIdToken() else {
            print("Error: Could not get idToken")
            authError = URLError(.userAuthenticationRequired)
            isLoading = false
            return
        }
        
        var components = URLComponents(string: "https://feature-wv.connect-next.playground.corbado.io/redirect")
        components?.queryItems = [
            URLQueryItem(name: "token", value: idToken),
            URLQueryItem(name: "redirectUrl", value: "/post-login-wv")
        ]
        
        guard let url = components?.url else {
            print("Error: Could not construct the URL")
            authError = URLError(.badURL)
            isLoading = false
            return
        }
        
        print("Constructed URL: \(url.absoluteString)")
        
        // Set the URL state and stop initial loading indicator
        self.webViewURL = url
        self.isLoading = false
    }
    
    func handleAuthCompletion(_ result: Result<URL, Error>) {
        isLoading = false
        
        switch result {
        case .success(let receivedURL):
            print("Authentication successful! Callback URL: \(receivedURL.absoluteString)")
            isAuthComplete = true
            authError = nil
            
            guard let status = receivedURL.queryParameterValue(forName: "status") else {
                return
            }
            
            switch status {
            case "complete", "complete-noop":
                appRouter.navigateTo(.home)
            default:
                Task {
                    let hasMFA = await hasMFA()
                    if !hasMFA {
                        appRouter.navigateTo(.setupTOTP)
                    } else {
                        appRouter.navigateTo(.home)
                    }
                }
            }
            
        case .failure(let error):
            print("Authentication failed with error: \(error.localizedDescription)")
            authError = error
            isAuthComplete = false // Ensure completion flag is false on error
        }
        
        webViewURL = nil
    }
    
    private func getIdToken() async -> String? {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                return tokens.idToken
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    private func hasMFA() async -> Bool {
        do {
            let authCognitoPlugin = try Amplify.Auth.getPlugin(for: "awsCognitoAuthPlugin") as? AWSCognitoAuthPlugin
            let preference = try await authCognitoPlugin?.fetchMFAPreference()
            return !(preference?.enabled?.isEmpty ?? true)
        } catch {
            return false
        }
    }
}

extension URL {
    func queryParameterValue(forName name: String) -> String? {
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        guard let queryItems = urlComponents.queryItems else {
            return nil
        }
        
        return queryItems.first(where: { $0.name == name })?.value
    }
}
