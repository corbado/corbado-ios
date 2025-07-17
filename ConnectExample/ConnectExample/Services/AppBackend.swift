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
    static func getConnectToken(connectTokenType: ConnectTokenType, idToken: String) async throws -> String {
        let urlString = "https://feature-wv.connect-next.playground.corbado.io/connectToken"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Set content type to JSON

        let requestPayload = ConnectTokenRequest(connectTokenType: connectTokenType.rawValue, idToken: idToken)
        
        do {
            let jsonData = try JSONEncoder().encode(requestPayload)
            request.httpBody = jsonData
            
            let decoded = try JSONDecoder().decode(ConnectTokenRequest.self, from: jsonData)
            print(decoded)
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

struct ConnectTokenRequest: Codable {
    let connectTokenType: String
    let idToken: String
}

struct ConnectTokenResponse: Codable {
    let token: String
}
