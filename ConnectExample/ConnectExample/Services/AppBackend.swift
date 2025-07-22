//
//  AppBackend.swift
//  ConnectExample
//
//  Created by Martin on 12/5/2025.
//

import CorbadoConnect
import Foundation
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore

class AppBackend {
    /// Get connectToken from backend (which gets it from Corbado Backend API)
    static func getConnectToken(connectTokenType: ConnectTokenType, idToken: String) async throws -> String {
        // 1. Set up request
        let urlString = "https://feature-wv.connect-next.playground.corbado.io/connectToken"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestPayload = GetConnectTokenRequest(
            connectTokenType: connectTokenType.rawValue,
            idToken: idToken
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestPayload)
            request.httpBody = jsonData
        } catch {
            throw error
        }

        // 2. Perform request
        let (data, response) = try await URLSession.shared.data(for: request)

        // 3. Check response
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("Error: HTTP Status Code \(statusCode)")
            
            // You might want to try decoding error details from 'data' here if your API
            // provides them or a custom error
            throw URLError(.badServerResponse)
        }

        // 4. Decode the JSON response
        do {
            let decodedResponse = try JSONDecoder().decode(GetConnectTokenResponse.self, from: data)
            return decodedResponse.token
        } catch {
            print("Error decoding JSON response: \(error)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response string: \(responseString)")
            }
            
            throw error
        }
    }
    
    /// Verify signedPasskeyData with backend (which verifies with Corbado Backend API)
    static func verifySignedPasskeyData(signedPasskeyData: String) async throws -> (Bool, String) {
        // 1. Set up request
        let urlString = "https://<your-backend>/auth/verifySignedPasskeyData"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestPayload = VerifySignedPasskeyDataRequest(
            signedPasskeyData: signedPasskeyData
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestPayload)
            request.httpBody = jsonData
        } catch {
            throw error
        }

        // 2. Perform request
        let (data, response) = try await URLSession.shared.data(for: request)

        // 3. Check response
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("Error: HTTP Status Code \(statusCode)")
            
            // You might want to try decoding error details from 'data' here if your API
            // provides them or a custom error
            throw URLError(.badServerResponse)
        }

        // 4. Decode the JSON response
        do {
            let decodedResponse = try JSONDecoder().decode(VerifySignedPasskeyDataResponse.self, from: data)
            return (decodedResponse.success, decodedResponse.sessionId)
        } catch {
            print("Error decoding JSON response: \(error)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response string: \(responseString)")
            }
            
            throw error
        }
    }
    
    static func getIdToken() async -> String? {
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
}

struct GetConnectTokenRequest: Codable {
    let connectTokenType: String
    let idToken: String
}

struct GetConnectTokenResponse: Codable {
    let token: String
}

struct VerifySignedPasskeyDataRequest: Codable {
    let signedPasskeyData: String
}

struct VerifySignedPasskeyDataResponse: Codable {
    let success: Bool
    let sessionId: String
}
