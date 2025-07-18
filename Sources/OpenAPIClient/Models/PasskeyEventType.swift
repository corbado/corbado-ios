//
// PasskeyEventType.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

public enum PasskeyEventType: String, Sendable, Codable, CaseIterable {
    case loginExplicitAbort = "login-explicit-abort"
    case loginError = "login-error"
    case loginErrorUntyped = "login-error-untyped"
    case loginErrorUnexpected = "login-error-unexpected"
    case loginOneTapSwitch = "login-one-tap-switch"
    case loginNoCredentials = "login-no-credentials"
    case userAppendAfterCrossPlatformBlacklisted = "user-append-after-cross-platform-blacklisted"
    case userAppendAfterLoginErrorBlacklisted = "user-append-after-login-error-blacklisted"
    case appendCredentialExists = "append-credential-exists"
    case appendExplicitAbort = "append-explicit-abort"
    case appendError = "append-error"
    case appendErrorUnexpected = "append-error-unexpected"
    case appendLearnMore = "append-learn-more"
    case manageErrorUnexpected = "manage-error-unexpected"
    case manageError = "manage-error"
    case manageLearnMore = "manage-learn-more"
    case manageCredentialExists = "manage-credential-exists"
    case localUnlock = "local-unlock"
}
