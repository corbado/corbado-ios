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

public struct ConnectProcess: Codable {
    public let id: String
    public let frontendApiUrl: String
    public let loginData: ConnectLoginInitData?
    
    public init(
        id: String,
        frontendApiUrl: String,
        loginData: ConnectLoginInitData? = nil
    ) {
        self.id = id
        self.frontendApiUrl = frontendApiUrl
        self.loginData = loginData
    }
    
    public func validLoginData() -> ConnectLoginInitData? {
        guard let data = loginData,
              let expires = data.expiresAt,
              expires > Date().timeIntervalSince1970 else {
            return nil
        }
        
        return data
    }

}
