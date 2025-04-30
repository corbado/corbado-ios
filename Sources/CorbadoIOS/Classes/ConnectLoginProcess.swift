import Foundation

typealias Flags = [String: String]

public struct ConnectLoginInitData: Codable {
    public let loginAllowed: Bool
    public let conditionalUIChallenge: String?
    public let flags: Flags
    public let expiresAt: TimeInterval?

    public init(
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


public struct ConnectLoginProcess: Codable {
    public let id: String
    public let projectId: String
    public let frontendApiUrl: String
    public let loginData: ConnectLoginInitData?

    public init(
        id: String,
        projectId: String,
        frontendApiUrl: String,
        loginData: ConnectLoginInitData? = nil
    ) {
        self.id = id
        self.projectId = projectId
        self.frontendApiUrl = frontendApiUrl
        self.loginData = loginData
    }

    private static func storageKey(for projectId: String) -> String {
        return "cbo_connect_login-\(projectId)"
    }

    public func validLoginData() -> ConnectLoginInitData? {
        guard let data = loginData,
              let expires = data.expiresAt,
              expires > Date().timeIntervalSince1970 else {
            return nil
        }
        return data
    }
    
    public func updating(loginData: ConnectLoginInitData?) -> ConnectLoginProcess {
        return ConnectLoginProcess(
            id: id,
            projectId: projectId,
            frontendApiUrl: frontendApiUrl,
            loginData: loginData
        )
    }

    public func persist() {
        let key = ConnectLoginProcess.storageKey(for: projectId)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    /// Load a saved process, or returns nil if none or invalid
    public static func load(from projectId: String) -> ConnectLoginProcess? {
        let key = storageKey(for: projectId)
        guard let jsonData = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        guard let process = try? decoder.decode(ConnectLoginProcess.self, from: jsonData),
              process.isValid() else {
            return nil
        }
        return process
    }

    /// Remove saved process for a project
    public static func clearStorage(for projectId: String) {
        let key = storageKey(for: projectId)
        UserDefaults.standard.removeObject(forKey: key)
    }
}
