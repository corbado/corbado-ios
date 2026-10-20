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
    /// Omitted when the OS does not report it (below iOS 16.6).
    var authenticatorAttachment: String?
    var clientExtensionResults: ClientExtensionResults
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
    /// Omitted when the OS does not report it (below iOS 16.6).
    var authenticatorAttachment: String?
    var clientExtensionResults: ClientExtensionResults
}

struct AuthenticatorAttestationResponse: Codable {
    var clientDataJSON: String
    var attestationObject: String
    var transports: [String]
}

/// WebAuthn client extension outputs in their JSON form (binary values base64url encoded).
/// Encodes as `{}` when AuthenticationServices reports no outputs.
struct ClientExtensionResults: Codable, Equatable {
    struct LargeBlob: Codable, Equatable {
        var supported: Bool?
        var blob: String?
        var written: Bool?
    }

    struct PRF: Codable, Equatable {
        struct Values: Codable, Equatable {
            var first: String
            var second: String?
        }

        var enabled: Bool?
        var results: Values?
    }

    var largeBlob: LargeBlob?
    var prf: PRF?

    init(largeBlob: LargeBlob? = nil, prf: PRF? = nil) {
        self.largeBlob = largeBlob
        self.prf = prf
    }

    init(_ results: PasskeyClientExtensionResults) {
        largeBlob = results.largeBlob.map {
            LargeBlob(supported: $0.supported, blob: $0.blob?.toBase64URL(), written: $0.written)
        }
        prf = results.prf.map { prf in
            PRF(
                enabled: prf.enabled,
                results: prf.first.map { PRF.Values(first: $0.toBase64URL(), second: prf.second?.toBase64URL()) }
            )
        }
    }
}

/// A protocol that handles the presentation of the passkey authorization UI.
public typealias AuthorizationControllerProtocol = SimpleAuthenticationServices.AuthorizationControllerProtocol
/// The default implementation of `AuthorizationControllerProtocol`.
public typealias RealAuthorizationController = SimpleAuthenticationServices.RealAuthorizationController 