import Foundation
import AuthenticationServices

enum LoginError: Error {
    case deviceNotSupported
    case decoding
    case encoding
    case unexpectedAuthorizationResponse
    case unknown
}

enum CreateError: Error {
    case decoding
    case encoding
    case cancelled
    case unknown
    case excludeCredentialsMatch
}

enum ManageError: Error {
    case connecTokenProvider
    case corbadoAPIErrorSilent
    case corabdoAPIError
}

enum DecodingError: Error {
    case stringToDataConversionFailed
}

/// Describes invalid Signal API input without retaining the identifier itself.
enum SignalDecodingError: Error, Sendable, Equatable, CustomStringConvertible {
    case userHandle(encodedLength: Int)
    case acceptedCredentialID(index: Int, encodedLength: Int)

    var description: String {
        switch self {
        case .userHandle(let length):
            return "Invalid base64url: field=userHandle encodedLength=\(length)"
        case .acceptedCredentialID(let index, let length):
            return "Invalid base64url: field=acceptedCredentialIDs index=\(index) encodedLength=\(length)"
        }
    }
}
