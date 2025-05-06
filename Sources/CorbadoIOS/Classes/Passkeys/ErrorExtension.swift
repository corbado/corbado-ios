import Foundation
import AuthenticationServices

enum LoginError: Error {
    case deviceNotSupported
    case decoding
    case encoding
    case unexpectedAuthorizationResponse
    case unknown
}
