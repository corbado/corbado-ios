import Foundation
import OpenAPIClient

enum LoginIdentifierType: String, Codable {
    case email = "email"
    case phone = "phone"
    case username = "username"
}

enum PasskeyCeremonyType: String, Codable {
    case local = "local"
    case cda = "cda"
    case securityKey = "security-key"
}

struct LastLogin: Codable, Equatable {
    let identifierType: LoginIdentifierType
    let identifierValue: String
    let ceremonyType: PasskeyCeremonyType
    let operationType: String
    
    static func from(passkeyOperation: PasskeyOperation) -> LastLogin? {
        guard let ceremonyType = PasskeyCeremonyType(rawValue: passkeyOperation.ceremonyType.rawValue) else {
            return nil
        }
        
        guard let identifierType = LoginIdentifierType(rawValue: passkeyOperation.identifierType.rawValue) else {
            return nil
        }
                
        return LastLogin(
            identifierType: identifierType,
            identifierValue: passkeyOperation.identifierValue,
            ceremonyType: ceremonyType,
            operationType: passkeyOperation.operationType.rawValue
        )
    }
}

enum Source: String, Codable {
    case localStorage = "LocalStorage"
    case url = "URL"
    case native = "Native"
    
    var metaSource: String {
        switch self {
        case .localStorage: return "ls"
        case .url: return "url"
        case .native: return "native"
        }
    }
}

struct ClientStateEntry<T: Codable & Sendable>: Codable, Sendable {
    let data: T?
    let source: Source
    let ts: TimeInterval
}

struct CombinedData: Codable {
    let clientEnvHandle: ClientStateEntry<String>?
    let lastLogin: ClientStateEntry<LastLogin>?
}

actor ClientStateService: Sendable {
    private let projectId: String
    private let userDefaults: UserDefaults
    
    private lazy var cachedLastLogin: ClientStateEntry<LastLogin>? = getEntryFromUserDefaults(forKey: getStorageKeyLastLogin())
    private lazy var cachedClientEnvHandle: ClientStateEntry<String>?  = getEntryFromUserDefaults(forKey: getStorageKeyClientHandle())
    private lazy var cachedInvitationToken: ClientStateEntry<String>? = getEntryFromUserDefaults(forKey: getStorageKeyInvitationToken())
    
    init(projectId: String) {
        self.projectId = projectId
        self.userDefaults = UserDefaults.standard
    }
    
    func getLastLogin() -> ClientStateEntry<LastLogin>? {
        return cachedLastLogin
    }
    
    func setLastLogin(lastLogin: LastLogin) {
        let entry = ClientStateEntry<LastLogin>(data: lastLogin, source: .native, ts: Date().timeIntervalSince1970)
        self.cachedLastLogin = entry
        setEntryToUserDefaults(entry, forKey: getStorageKeyLastLogin())
    }
    
    func clearLastLogin() {
        self.cachedLastLogin = nil
        removeEntryFromUserDefaults(forKey: getStorageKeyLastLogin())
    }
    
    func getClientEnvHandle() -> ClientStateEntry<String>? {
        return cachedClientEnvHandle
    }
    
    func setClientEnvHandle(clientEnvHandle: String) {
        let entry = ClientStateEntry<String>(
            data: clientEnvHandle,
            source: .localStorage,
            ts: Date().timeIntervalSince1970
        )
        
        self.cachedClientEnvHandle = entry
        setEntryToUserDefaults(entry, forKey: getStorageKeyClientHandle())
    }
    
    func clearClientEnvHandle() {
        self.cachedClientEnvHandle = nil
        removeEntryFromUserDefaults(forKey: getStorageKeyClientHandle())
    }
    
    func getInvitationToken() -> ClientStateEntry<String>? {
        return cachedInvitationToken
    }
    
    func setInvitationToken(invitationToken: String) {
        let entry = ClientStateEntry<String>(data: invitationToken, source: .native, ts: Date().timeIntervalSince1970)
        cachedInvitationToken = entry
        setEntryToUserDefaults(entry, forKey: getStorageKeyInvitationToken())
    }
    
    func clearInvitationToken() {
        self.cachedInvitationToken
        removeEntryFromUserDefaults(forKey: getStorageKeyInvitationToken())
    }
    
    private func getStorageKeyClientHandle() -> String {
        return "cbo_client_handle-\(projectId)"
    }
    
    private func getStorageKeyLastLogin() -> String {
        return "cbo_connect_last_login-\(projectId)"
    }
    
    private func getStorageKeyInvitationToken() -> String {
        return "cbo_connect_invitation_token-\(projectId)"
    }
    
    private func getEntryFromUserDefaults<T: Decodable>(forKey key: String) -> ClientStateEntry<T>? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(ClientStateEntry<T>.self, from: data)
        } catch {
            print("ClientStateService: Error decoding ClientStateEntry for key '\(key)': \(error)")
            return nil
        }
    }

    private func setEntryToUserDefaults<T: Encodable>(_ entry: ClientStateEntry<T>?, forKey key: String) {
        guard let entry = entry else {
            userDefaults.removeObject(forKey: key)
            return
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(entry)
            userDefaults.set(data, forKey: key)
        } catch {
            print("ClientStateService: Error encoding ClientStateEntry for key '\(key)': \(error)")
        }
    }

    private func removeEntryFromUserDefaults(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
} 