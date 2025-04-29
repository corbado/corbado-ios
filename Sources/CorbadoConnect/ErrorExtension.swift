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