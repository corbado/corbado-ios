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
import CorbadoIOS

@MainActor
class PostLoginViewModel: ObservableObject {
    private let appRouter: AppRouter
    private var corbado: CorbadoIOS = CorbadoIOS.shared
    
    @Published var webViewURL: URL?
    @Published var authError: Error?
    @Published var isLoading = true
    @Published var primaryLoading = false
    @Published var isAuthComplete = false
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    func loadInitialStep() async {
        let nextStep = await corbado.isAppendAllowed {
            return try await getConnectToken()
        }
        
        switch nextStep {
        case .AskUserForAppend(let autoAppend, let appendVariant):
            // TODO: auto-append
            isLoading = false
            
        case .Skip:
            await skipPasskeyCreation()
        }
    }
    
    func createPasskey() async {
        primaryLoading = true
        defer {
            primaryLoading = false
        }
        
        
        let rsp = await corbado.completeAppend()
        appRouter.navigateTo(.home)
    }
    
    func skipPasskeyCreation() async {
        let hasMFA = await hasMFA()
        if !hasMFA {
            appRouter.navigateTo(.setupTOTP)
        } else {
            appRouter.navigateTo(.home)
        }
    }
    
    private func getConnectToken() async throws -> String {
        let urlString = "https://feature-wv.connect-next.playground.corbado.io/connectToken"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Set content type to JSON

        let idToken = await getIdToken()
        let requestPayload = ConnectTokenRequest(connectTokenType: "passkey-append", idToken: idToken!)
        
        do {
            let jsonData = try JSONEncoder().encode(requestPayload)
            request.httpBody = jsonData
        } catch {
            throw error
        }

        // 4. Perform the request
        let (data, response) = try await URLSession.shared.data(for: request)

        // 5. Check the response status code
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            // Handle non-successful status codes
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("Error: HTTP Status Code \(statusCode)")
            // You might want to try decoding error details from 'data' here if your API provides them
            throw URLError(.badServerResponse) // Or a custom error indicating HTTP error
        }

        // 6. Decode the JSON response
        do {
            let decodedResponse = try JSONDecoder().decode(ConnectTokenResponse.self, from: data)
            return decodedResponse.token
        } catch {
            print("Error decoding JSON response: \(error)")
            // Print the raw data for debugging if decoding fails
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response string: \(responseString)")
            }
            throw error // Re-throw decoding error
        }
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

struct ConnectTokenRequest: Codable {
    let connectTokenType: String
    let idToken: String
}

struct ConnectTokenResponse: Codable {
    let token: String
}

