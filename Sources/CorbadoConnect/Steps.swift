import Foundation

public typealias ErrorMessage = String
public typealias CUIChallenge = String
public typealias Session = String
public typealias Username = String
public typealias RetryCount = Int

/// A generic authentication error with a code and a message.
public struct AuthError: Sendable, Equatable {
    public let code: String
    public let message: String
}

let defaultErrorMessage = "Passkey error. Use password to log in."
public enum LoginWithoutIdentifierError: LocalizedError, Equatable, Sendable {
    case CorbadoAPIError
    case UnHandledError
    case CustomError(code: String, message: String)
    case PasskeyDeletedOnServer(message: String)
    case ProjectIDMismatch(message: String, wrongProjectName: String?, correctProjectName: String?)
    
    public var errorDescription: String? {
        switch self {
        case .CorbadoAPIError:
            return defaultErrorMessage
        case .UnHandledError:
            return defaultErrorMessage
        case .CustomError(let message, _):
            return message
        case .PasskeyDeletedOnServer(let message):
            return message
        case .ProjectIDMismatch(let message, _, _):
            return message
        }
    }
}

public enum LoginWithIdentifierError: LocalizedError, Equatable, Sendable {
    case CorbadoAPIError
    case UnHandledError
    case CustomError(code: String, message: String)
    case InvalidStateError
    case UserNotFound
    
    public var errorDescription: String? {
        switch self {
        case .CorbadoAPIError:
            return defaultErrorMessage
        case .UnHandledError:
            return defaultErrorMessage
        case .CustomError(let message, _):
            return message
        case .InvalidStateError:
            return defaultErrorMessage
        case .UserNotFound:
            return "No account matches that email."
        }
    }
}

/// Represents the different states of the login process.
public enum ConnectLoginStep: Equatable, Sendable {
    /// The login process should start with a fallback mechanism (e.g., password).
    case initFallback(username: String? = nil, developerDetails: String? = nil)
    /// The user should be prompted to enter their identifier in a text field.
    case initTextField(challenge: String?, developerDetails: String? = nil)
    /// The login process should start with a one-tap action.
    case initOneTap(username: String)
}

public enum ConnectLoginWithIdentifierStatus: Equatable, Sendable {
    /// The login process has successfully completed.
    case done(Session, Username)
    /// The user should be prompted to enter their identifier in a text field.
    case error(error: LoginWithIdentifierError, triggerFallback: Bool, developerDetails: String, username: String? = nil)
    /// The login process should start with a fallback mechanism (e.g., password).
    case initSilentFallback(username: String?, developerDetails: String)
    /// The login process should be retried.
    case initRetry(developerDetails: String)
}

public enum ConnectLoginWithoutIdentifierStatus: Equatable, Sendable {
    case done(Session, Username)
    case error(error: LoginWithoutIdentifierError, triggerFallback: Bool, developerDetails: String, username: String? = nil)
    case initSilentFallback(username: String?, developerDetails: String)
    case ignore(developerDetails: String)
}

/// A boolean indicating if a passkey should be automatically appended.
public typealias autoAppend = Bool

public typealias conditionalAppend = Bool

/// The variant of the append process.
public enum AppendType: Sendable {
    case defaultAppend
}

public struct PasskeyDetails: Equatable, Sendable {
    public let aaguidName: String
    public let iconLight: String
    public let iconDark: String
}

/// Represents the different states of the passkey append process.
public enum ConnectAppendStep: Equatable, Sendable {
    /// The user should be asked if they want to append a new passkey.
    case askUserForAppend(autoAppend = false, appendType: AppendType = .defaultAppend, conditionalAppend = false, customData: [String: String]? = nil)
    /// The append process should be skipped.
    case skip(developerDetails: String)
}

/// Represents the status of a passkey append operation.
public enum ConnectAppendStatus: Equatable, Sendable {
    case completed(passkeyDetails: PasskeyDetails?)
    case cancelled
    case error(developerDetails: String)
    case excludeCredentialsMatch
}

/// A string providing more details about an error.
public typealias ErrorDetails = String

public enum ConnectManageStep: Equatable, Sendable {
    case allowed(passkeys: [Passkey])
    case notAllowed(passkeys: [Passkey])
    case error(developerDetails: String)
}

/// Represents the status of a manage operation (e.g. deleting or appending a passkeys).
public enum ConnectManageStatus: Sendable {
    case done(passkeys: [Passkey])
    case passkeyOperationCancelled
    case passkeyOperationExcludeCredentialsMatch
    case error(developerDetails: String)
}


