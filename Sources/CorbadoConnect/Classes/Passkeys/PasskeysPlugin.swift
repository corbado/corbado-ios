import UIKit
import AuthenticationServices
import SimpleAuthenticationServices
import LocalAuthentication
import Foundation
import Combine

protocol Cancellable {
    func cancel()
}

@MainActor
@available(iOS 16.0, *)
public class PasskeysPlugin {
    var inFlightController: Cancellable?
    let controller: AuthorizationControllerProtocol = VirtualAuthorizationController()
    
    public init() {}
    
    @MainActor
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
            
            let result = try await controller.authorize(requests: requests)
            switch result.credential {
            case let typed as PasskeyAssertionCredential:
                let response = AuthenticateResponse(
                    id: typed.credentialID.toBase64URL(),
                    rawId: typed.credentialID.toBase64URL(),
                    type: "public-key",
                    response: AuthenticatorAssertionResponse(
                        clientDataJSON: typed.rawClientDataJSON.toBase64URL(),
                        authenticatorData: typed.rawAuthenticatorData.toBase64URL(),
                        signature: typed.signature.toBase64URL(),
                        userHandle: typed.userID.toBase64URL()
                    )
                )
                
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(response)
                
                guard let jsonString = String(data: encoded, encoding: .utf8) else {
                    throw LoginError.encoding
                }
                
                return jsonString
            default:
                throw LoginError.unknown
            }
        } catch {
            throw LoginError.unknown
        }
    }
    
    @MainActor
    func create(attestationOptions: String) async throws(CreateError) -> String {
        guard let jsonData = attestationOptions.data(using: .utf8) else {
            fatalError("Failed to convert string to data")
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(AttestationRequest.self, from: jsonData)
            
            guard let decodedChallenge = Data.fromBase64Url(decoded.publicKey.challenge) else {
                throw LoginError.decoding
            }
            
            guard let decodedUserId = Data.fromBase64Url(decoded.publicKey.user.id) else {
                throw LoginError.decoding
            }
            
            // Create a platform (on‑device) registration request.
            let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: decoded.publicKey.rp.id)
            let platformRequest = platformProvider.createCredentialRegistrationRequest(
                challenge: decodedChallenge,
                name: decoded.publicKey.user.name,
                userID: decodedUserId
            )
            
            if #available(iOS 17.4, *) {
                let excluded = parseCredentials(credentials: decoded.publicKey.excludeCredentials ?? [])
                platformRequest.excludedCredentials = excluded
            }
                                    
            let result = try await controller.create(requests: [platformRequest])
            switch result.credential {
            case let typed as PasskeyRegistrationCredential:
                let response = AttestationResponse (
                    id: typed.credentialID.toBase64URL(),
                    rawId: typed.credentialID.toBase64URL(),
                    response: AuthenticatorAttestationResponse(
                        clientDataJSON: typed.rawClientDataJSON.toBase64URL(),
                        attestationObject: typed.rawAttestationObject.toBase64URL(),
                        transports: typed.transports.compactMap { $0.toBase64URL() }
                    )
                )
                
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(response)
                
                guard let jsonString = String(data: encoded, encoding: .utf8) else {
                    throw CreateError.encoding
                }
                
                return jsonString
            default:
                throw CreateError.unknown
            }
        } catch {
            throw .unknown
        }

    }
    
    @MainActor
    func cancelCurrentAuthenticatorOperation(completion: @escaping (Result<Void, Error>) -> Void) {
        inFlightController?.cancel()
        completion(.success(()))
    }
    
    private func parseCredentials(credentials: [CredentialWithTransports]) -> [ASAuthorizationPlatformPublicKeyCredentialDescriptor] {
        return credentials.compactMap { credential in
            guard let credentialData = Data.fromBase64Url(credential.id) else {
                return nil
            }
            return ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: credentialData)
        }
    }
}
