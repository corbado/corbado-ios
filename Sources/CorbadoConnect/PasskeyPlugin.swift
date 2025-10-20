import UIKit
import AuthenticationServices
import SimpleAuthenticationServices
import LocalAuthentication
import Foundation
import Combine

protocol Cancellable {
    func cancel()
}

/// A plugin that encapsulates the interaction with the native Passkey APIs (AuthenticationServices).
public actor PasskeyPlugin {
    @MainActor
    lazy var controller: AuthorizationControllerProtocol = RealAuthorizationController()

    public init() {}
    
    @available(iOS 16.0, *)
    @MainActor
    func authenticate(
        assertionOptions: String,
        conditionalUI: Bool,
        preferImmediatelyAvailableCredentials: Bool
    ) async throws(AuthorizationError) -> String {
        guard let jsonData = assertionOptions.data(using: .utf8) else {
            throw AuthorizationError(type: .decoding, originalError: DecodingError.stringToDataConversionFailed)
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
            platformRequest.allowedCredentials = await parseCredentials(credentials: decoded.publicKey.allowCredentials ?? [])
            requests.append(platformRequest)
            
            var result: AuthorizationResult
            if conditionalUI {
                result = try await controller.authorizeWithAutoFill(requests: requests)
            } else {
                result = try await controller.authorize(requests: requests, preferImmediatelyAvailableCredentials: preferImmediatelyAvailableCredentials)
            }
            
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
                    throw AuthorizationError(type: .encoding)
                }
                
                return jsonString
            default:
                throw AuthorizationError(type: .unknown)
            }
        } catch let error as AuthorizationError {
            throw error
        } catch {
            throw AuthorizationError(type: .unknown, originalError: error)
        }
    }
    
    @available(iOS 16.0, *)
    @MainActor
    func create(attestationOptions: String, completionType: AppendCompletionType) async throws(AuthorizationError) -> String {
        guard let jsonData = attestationOptions.data(using: .utf8) else {
            throw AuthorizationError(type: .decoding, originalError: DecodingError.stringToDataConversionFailed)
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(AttestationRequest.self, from: jsonData)
            
            guard let decodedChallenge = Data.fromBase64Url(decoded.publicKey.challenge) else {
                throw AuthorizationError(type: .decoding)
            }
            
            guard let decodedUserId = Data.fromBase64Url(decoded.publicKey.user.id) else {
                throw AuthorizationError(type: .decoding)
            }
            
            let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: decoded.publicKey.rp.id)
            let platformRequest = platformProvider.createCredentialRegistrationRequest(
                challenge: decodedChallenge,
                name: decoded.publicKey.user.name,
                userID: decodedUserId
            )
            
            if #available(iOS 17.4, *) {
                let excluded = await parseCredentials(credentials: decoded.publicKey.excludeCredentials ?? [])
                platformRequest.excludedCredentials = excluded
            }
            
            if completionType == AppendCompletionType.Conditional {
                if #available(iOS 18.0, *) {
                    platformRequest.requestStyle = .conditional
                } else {
                    throw AuthorizationError(type: .cancelled)
                }
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
                    throw AuthorizationError(type: .encoding)
                }
                
                return jsonString
            default:
                throw AuthorizationError(type: .unknown)
            }
        } catch let error as AuthorizationError {
            throw error
        } catch {
            throw AuthorizationError(type: .unknown, originalError: error)
        }
    }
    
    @MainActor
    func cancelCurrentAuthenticatorOperation() async {
        await controller.cancel()
    }
    
    @MainActor
    func signalAllAcceptedCredentials(rpID: String, userHandle: String, acceptedCredentialIDs: [String]) async throws(AuthorizationError) {
        guard let decodedUserHandle = Data.fromBase64(userHandle) else {
            throw AuthorizationError(type: .decoding)
        }
        
        var decodedAcceptedCredentialIDs: [Data] = []
        for acceptedCredentialID in acceptedCredentialIDs {
            guard let decodedAcceptedCredentialID = Data.fromBase64(acceptedCredentialID) else {
                throw AuthorizationError(type: .decoding)
            }
            decodedAcceptedCredentialIDs.append(decodedAcceptedCredentialID)
        }
        
        try await controller.signalAllAcceptedCredentials(rpID: rpID, userHandle: decodedUserHandle, acceptedCredentialIDs: decodedAcceptedCredentialIDs)
    }
    
    @MainActor
    private func parseCredentials(credentials: [CredentialWithTransports]) -> [ASAuthorizationPlatformPublicKeyCredentialDescriptor] {
        return credentials.compactMap { credential in
            guard let credentialData = Data.fromBase64Url(credential.id) else {
                return nil
            }
            return ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: credentialData)
        }
    }
} 
