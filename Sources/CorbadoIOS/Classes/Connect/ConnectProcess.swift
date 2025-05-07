import Foundation

public typealias Flags = [String: String]

public struct ConnectLoginInitData: Codable {
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

public struct ConnectAppendInitData: Codable {
    public let appendAllowed: Bool
    public let flags: Flags
    public let expiresAt: TimeInterval?
    public var attestationOptions: String?

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

public struct ConnectProcess: Codable {
    public let id: String
    public let frontendApiUrl: String
    public var loginData: ConnectLoginInitData?
    public var appendData: ConnectAppendInitData?
    
    public init(
        id: String,
        frontendApiUrl: String,
        loginData: ConnectLoginInitData? = nil,
        appendData: ConnectAppendInitData? = nil
    ) {
        self.id = id
        self.frontendApiUrl = frontendApiUrl
        self.loginData = loginData
        self.appendData = appendData
    }
    
    public func validLoginData() -> ConnectLoginInitData? {
        guard let data = loginData, let expires = data.expiresAt, expires > Date().timeIntervalSince1970 else {
            return nil
        }
        
        return data
    }

    public func validAppendData() -> ConnectAppendInitData? {
        guard let data = appendData, let expires = data.expiresAt, expires > Date().timeIntervalSince1970 else {
            return nil
        }
        
        return data
    }
}
