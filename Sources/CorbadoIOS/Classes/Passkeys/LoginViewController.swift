import AuthenticationServices
import LocalAuthentication
import Foundation

public extension Data {
    /// Same as Data(base64Encoded:), but adds padding automatically (if missing).
    static func fromBase64(_ encoded: String) -> Data? {
        var encoded = encoded
        let remainder = encoded.count % 4
        if remainder > 0 {
            encoded = encoded.padding(
                toLength: encoded.count + 4 - remainder,
                withPad: "=",
                startingAt: 0
            )
        }
        return Data(base64Encoded: encoded)
    }
    
    static func fromBase64Url(_ encoded: String) -> Data? {
        let base64String = base64UrlToBase64(base64Url: encoded)
        return fromBase64(base64String)
    }
    
    private static func base64UrlToBase64(base64Url: String) -> String {
        return base64Url.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
    }
}

public extension String {
    static func fromBase64(_ encoded: String) -> String? {
        if let data = Data.fromBase64(encoded) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

extension Data {
    func toBase64URL() -> String {
        var result = self.base64EncodedString()
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }
}

@available(iOS 16.0, *)
class LoginViewController: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, Cancellable {
    public var completion: ((Result<AuthenticateResponse, LoginError>) -> Void)?
    
    init(completion: @escaping ((Result<AuthenticateResponse, LoginError>) -> Void)) {
        self.completion = completion;
    }
    
    func run(requests: [ASAuthorizationRequest], conditionalUI: Bool, preferImmediatelyAvailableCredentials: Bool) {
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        if (conditionalUI) {
            authorizationController.performAutoFillAssistedRequests()
        } else {
            // The `.preferImmediatelyAvailableCredentials` option in `ASAuthorizationController`
            // does not distinguish between `true` and `false` values. If the option is included
            // in the `options` parameter, iOS assumes the behavior is enabled.
            if preferImmediatelyAvailableCredentials {
                authorizationController.performRequests(options: .preferImmediatelyAvailableCredentials)
            } else {
                authorizationController.performRequests()
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let r as ASAuthorizationSecurityKeyPublicKeyCredentialAssertion:
            let response = AuthenticateResponse(
                id: r.credentialID.toBase64URL(),
                rawId: r.credentialID.toBase64URL(),
                type: "public-key",
                response: AuthenticatorAssertionResponse(
                    clientDataJSON: r.rawClientDataJSON.toBase64URL(),
                    authenticatorData: r.rawAuthenticatorData.toBase64URL(),
                    signature: r.signature.toBase64URL(),
                    userHandle: r.userID.toBase64URL()
                )
            )
            
            completion?(.success(response))
            break
        case let r as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            let response = AuthenticateResponse(
                id: r.credentialID.toBase64URL(),
                rawId: r.credentialID.toBase64URL(),
                type: "public-key",
                response: AuthenticatorAssertionResponse(
                    clientDataJSON: r.rawClientDataJSON.toBase64URL(),
                    authenticatorData: r.rawAuthenticatorData.toBase64URL(),
                    signature: r.signature.toBase64URL(),
                    userHandle: r.userID.toBase64URL()
                )
            )
            
            completion?(.success(response))
            break
        default:
            completion?(.failure(LoginError.unexpectedAuthorizationResponse))
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let err = error as? ASAuthorizationError {
            completion?(.failure(LoginError.unknown))
        }
        
        let nsErr = error as NSError
        completion?(.failure(LoginError.unknown))
        return
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let win = UIApplication.shared.delegate?.window ?? nil {
            return win
        }
                
        let keyWin = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        guard let anchor = keyWin else {
            fatalError("No window available for ASAuthorizationController")
        }
        
        return anchor
    }
    
    func cancel() {
        return
    }
}
