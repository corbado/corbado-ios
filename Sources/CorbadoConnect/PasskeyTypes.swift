import SimpleAuthenticationServices

struct AssertionRequest: Codable {
    var publicKey: AssertionRequestPublicKey
}

struct AssertionRequestPublicKey: Codable {
    var challenge: String
    var rpId: String
    var userVerification: String?
    var allowCredentials: [CredentialWithTransports]?
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

struct CredentialWithTransports: Codable {
    var type: String
    var id: String
    var transports: [String]?
}

struct AttestationRequest: Codable {
    var publicKey: AttestationRequestPublicKey
}

struct AttestationRequestPublicKey: Codable {
    var rp: RelyingParty
    var user: User
    var challenge: String
    var timeout: Int
    var pubKeyCredParams: [PubKeyCredParam]
    var authenticatorSelection: AuthenticatorSelection
    var attestation: String
    var excludeCredentials: [CredentialWithTransports]?
}

struct RelyingParty: Codable {
    var name: String
    var id: String
}

struct User: Codable {
    var name: String
    var displayName: String
    var id: String
}

struct PubKeyCredParam: Codable {
    var type: String
    var alg: Int
}

struct AuthenticatorSelection: Codable {
    var residentKey: String
    var userVerification: String
}

struct AttestationResponse: Codable {
    var id: String
    var rawId: String
    var type: String = "public-key"
    var response: AuthenticatorAttestationResponse
}

struct AuthenticatorAttestationResponse: Codable {
    var clientDataJSON: String
    var attestationObject: String
    var transports: [String?]
}

/// A protocol that handles the presentation of the passkey authorization UI.
public typealias AuthorizationControllerProtocol = SimpleAuthenticationServices.AuthorizationControllerProtocol
/// The default implementation of `AuthorizationControllerProtocol`.
public typealias RealAuthorizationController = SimpleAuthenticationServices.RealAuthorizationController 