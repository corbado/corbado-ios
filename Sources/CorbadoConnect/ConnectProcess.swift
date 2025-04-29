import Foundation

/// A dictionary for passing flags.
public typealias Flags = [String: String]

/// The data returned after a login initialization call.
public struct ConnectLoginInitData: Codable, Sendable {
    public let loginAllowed: Bool
    public let conditionalUIChallenge: String?
    public let flags: Flags
    public let expiresAt: TimeInterval?

    init(
        loginAllowed: Bool,
        conditionalUIChallenge: String? = nil,
        flags: Flags = [:],
        expiresAt: TimeInterval? = nil
    ) {
        self.loginAllowed = loginAllowed
        self.conditionalUIChallenge = conditionalUIChallenge
        self.flags = flags
        self.expiresAt = expiresAt
    }
}

/// The data returned after an append initialization call.
public struct ConnectAppendInitData: Codable, Sendable {
    public let appendAllowed: Bool
    public let flags: Flags
    public let expiresAt: TimeInterval?

    init(
        appendAllowed: Bool,
        flags: Flags = [:],
        expiresAt: TimeInterval? = nil
    ) {
        self.appendAllowed = appendAllowed
        self.flags = flags
        self.expiresAt = expiresAt
    }
}

/// The data returned after a manage initialization call.
public struct ConnectManageInitData: Codable, Sendable {
    public let manageAllowed: Bool
    public let flags: Flags
    public let expiresAt: TimeInterval?
}

/// Represents the state of an ongoing authentication or registration process.
public struct ConnectProcess: Codable, Sendable {
    public let id: String
    public let frontendApiUrl: String
    public let loginData: ConnectLoginInitData?
    public let appendData: ConnectAppendInitData?
    public let manageData: ConnectManageInitData?
    public let attestationOptions: String?
    
    public init(
        id: String,
        frontendApiUrl: String,
        loginData: ConnectLoginInitData? = nil,
        appendData: ConnectAppendInitData? = nil,
        manageData: ConnectManageInitData? = nil,
        attestationOptions: String? = nil
    ) {
        self.id = id
        self.frontendApiUrl = frontendApiUrl
        self.loginData = loginData
        self.appendData = appendData
        self.manageData = manageData
        self.attestationOptions = attestationOptions
    }
    
    /// Creates a new `ConnectProcess` with updated values.
    public func copyWith(
        loginData: ConnectLoginInitData? = nil,
        appendData: ConnectAppendInitData? = nil,
        manageData: ConnectManageInitData? = nil,
        attestationOptions: String? = nil
    ) -> ConnectProcess {
        return ConnectProcess(
            id: id,
            frontendApiUrl: frontendApiUrl,
            loginData: loginData,
            appendData: appendData,
            manageData: manageData,
            attestationOptions: attestationOptions
        )
    }
    
    /// Returns the login data if it is still valid.
    public func validLoginData() -> ConnectLoginInitData? {
        guard let data = loginData, let expires = data.expiresAt, expires > Date().timeIntervalSince1970 else {
            return nil
        }
        
        return data
    }

    /// Returns the append data if it is still valid.
    public func validAppendData() -> ConnectAppendInitData? {
        guard let data = appendData, let expires = data.expiresAt, expires > Date().timeIntervalSince1970 else {
            return nil
        }
        
        return data
    }
} 
