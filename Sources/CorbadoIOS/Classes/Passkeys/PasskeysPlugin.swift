//
//  Passkeys.swift
//  CorbadoIOS
//
//  Created by Martin on 6/5/2025.
//

import UIKit
import AuthenticationServices
import LocalAuthentication
import Foundation
import Combine

@MainActor
protocol Cancellable {
    func cancel()
}

struct AllowedCredential: Codable {
    var type: String
    var id: String
    var transports: [String?]
}

struct AssertionRequest: Codable {
    var publicKey: AssertionRequestPublicKey
}

struct AssertionRequestPublicKey: Codable {
    var challenge: String
    var rpId: String
    var userVerification: String
    var allowCredentials: [AllowedCredential]
}

struct AuthenticateResponse: Codable {
    var id: String
    var rawId: String
    var type: String
    var response: AuthenticatorAssertionResponse
}

struct AuthenticatorAssertionResponse: Codable {
    var clientDataJSON: String
    var authenticatorData: String
    var signature: String
    var userHandle: String
}

@available(iOS 16.0, *)
@MainActor
public class PasskeysPlugin: NSObject {
    var inFlightController: Cancellable?
    let lock = NSLock()
    
    func authenticate(
        assertionOptions: String,
        conditionalUI: Bool,
        preferImmediatelyAvailableCredentials: Bool
    ) async throws(LoginError) -> String {
        guard let jsonData = assertionOptions.data(using: .utf8) else {
            fatalError("Failed to convert string to data")
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(AssertionRequest.self, from: jsonData)
            
            guard let decodedChallenge = Data.fromBase64Url(decoded.publicKey.challenge) else {
                throw LoginError.decoding
            }
            
            var requests: [ASAuthorizationRequest] = []
            let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: decoded.publicKey.rpId)
            let platformRequest = platformProvider.createCredentialAssertionRequest(challenge: decodedChallenge)
            platformRequest.allowedCredentials = parseCredentials(credentials: decoded.publicKey.allowCredentials)
            requests.append(platformRequest)
            
            let result = try await withCheckedThrowingContinuation{ (continuation: CheckedContinuation<AuthenticateResponse, Error>) in
                let controller = LoginViewController { result in
                    switch result {
                    case .success(let resp):   continuation.resume(returning: resp)
                    case .failure(let err):    continuation.resume(throwing: err)
                    }
                }
                inFlightController = controller
                
                DispatchQueue.main.async {
                    controller.run(
                        requests: requests,
                        conditionalUI: false,
                        preferImmediatelyAvailableCredentials: false
                    )
                }
            }
            
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(result)
            
            guard let jsonString = String(data: encoded, encoding: .utf8) else {
                throw LoginError.encoding
            }
            
            return jsonString
        } catch {
            throw LoginError.unknown
        }
    }
    
    @MainActor
    func cancelCurrentAuthenticatorOperation(completion: @escaping (Result<Void, Error>) -> Void) {
        inFlightController?.cancel()
        completion(.success(()))
    }
    
    private func parseCredentials(credentials: [AllowedCredential]) -> [ASAuthorizationPlatformPublicKeyCredentialDescriptor] {
        return credentials.compactMap { credential in
            guard let credentialData = Data.fromBase64Url(credential.id) else {
                return nil
            }
            return ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: credentialData)
        }
    }
}
