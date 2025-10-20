import OpenAPIClient
import Foundation

/// Details of the authenticator used to create the passkey.
public typealias AaguidDetails = OpenAPIClient.AaguidDetails

/// Represents a passkey credential stored on the device or in the cloud.
public struct Passkey: Sendable, Equatable, Identifiable, Hashable {
    public var id: String
    public var credentialID: String
    public var tags: [String]
    public var sourceOS: String
    public var sourceBrowser: String
    public var lastUsedMs: Int64
    public var createdMs: Int64
    public var aaguidDetails: AaguidDetails
}

/// The type of operation that requires a short-lived session token (connect token).
public enum ConnectTokenType: String, Sendable, Encodable {
    case PasskeyAppend = "passkey-append"
    case PasskeyList = "passkey-list"
    case PasskeyDelete = "passkey-delete"
} 

public enum AppendCompletionType: String, Sendable, Encodable, Equatable {
    case Auto = "auto"
    case Conditional = "conditional"
    case Manual = "manual"
    case ManualRetry = "manual-retry"
}

public struct AppendSituationType: Hashable, Sendable, Encodable, Equatable {
    public let rawValue: String
    public let localDebounce: TimeInterval
    
    public init(rawValue: String, localDebounce: TimeInterval = 86400) {
        self.rawValue = rawValue
        self.localDebounce = localDebounce
    }
    
    public static let postLogin = AppendSituationType(rawValue: "post-login", localDebounce: 0)
    public static let passkeyList = AppendSituationType(rawValue: "passkey-list", localDebounce: 0)
}

public enum PasskeyListMode: String, Sendable, Encodable {
    case Default = "default"
    case PostDelete = "post-delete"
    case PostAppend = "post-append"
}
