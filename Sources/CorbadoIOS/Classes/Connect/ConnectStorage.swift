//
//  ConnectStorage.swift
//  CorbadoIOS
//
//  Created by Martin on 5/5/2025.
//

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

struct ClientStateEntry<T: Codable>: Codable {
    let data: T?
    let source: Source
    let ts: TimeInterval
}

struct CombinedData: Codable {
    let clientEnvHandle: ClientStateEntry<String>?
    let lastLogin: ClientStateEntry<LastLogin>?
}

struct ClientStateService {
    private let userDefaults = UserDefaults.standard
    private let projectId: String
    
    init(projectId: String) {
        self.projectId = projectId
    }
    
    private func getStorageKeyClientHandle() -> String {
        return "cbo_client_handle-\(projectId)"
    }
    
    private func getStorageKeyLastLogin() -> String {
        return "cbo_connect_last_login-\(projectId)"
    }
    
    private func getEntry<T: Decodable>(forKey key: String) -> ClientStateEntry<T>? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(ClientStateEntry<T>.self, from: data)
        } catch {
            print("Error decoding ClientStateEntry for key '\(key)': \(error)")
            return nil
        }
    }
    
    private func setEntry<T: Encodable>(_ entry: ClientStateEntry<T>?, forKey key: String) {
        guard let entry = entry else {
            userDefaults.removeObject(forKey: key)
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(entry)
            userDefaults.set(data, forKey: key)
        } catch {
            print("Error encoding ClientStateEntry for key '\(key)': \(error)")
        }
    }
    
    func getLastLogin() -> ClientStateEntry<LastLogin>? {
        return getEntry(forKey: getStorageKeyLastLogin())
    }
    
    func setLastLogin(lastLogin: LastLogin) {
        let entry = ClientStateEntry<LastLogin>(data: lastLogin, source: .native, ts: Date().timeIntervalSince1970)
        setEntry(entry, forKey: getStorageKeyLastLogin())
    }
    
    /// Private setter for LastLogin, allowing control over source and timestamp.
    private func setLastLogin(data: LastLogin?, source: Source, ts: TimeInterval) {
        let entry = ClientStateEntry<LastLogin>(data: data, source: source, ts: ts)
        setEntry(entry, forKey: getStorageKeyLastLogin())
    }
    
    func clearLastLogin() {
        // Sets the data to nil using the private setter
        setLastLogin(
            data: nil,
            source: .localStorage,
            ts: Date().timeIntervalSince1970
        )
    }
    
    func getClientEnvHandle() -> ClientStateEntry<String>? {
        return getEntry(forKey: getStorageKeyClientHandle())
        // Note: Omitted the compatibility check for `cbo_client_handle` key.
        // Add similar fallback logic as for getLastLogin if needed.
    }
    
    func setClientEnvHandle(clientEnvHandle: String) {
        setClientEnvHandle(
            data: clientEnvHandle,
            source: .localStorage,
            ts: Date().timeIntervalSince1970
        )
    }
    
    /// Private setter for ClientEnvHandle.
    private func setClientEnvHandle(data: String?, source: Source, ts: TimeInterval) {
        let entry = ClientStateEntry<String>(data: data, source: source, ts: ts)
        setEntry(entry, forKey: getStorageKeyClientHandle())
    }
    
    // Note: parseClientStateSource functionality is included in the Source enum's `metaSource` computed property.
    // You can access it via `entry.source.metaSource` if you need the "ls" or "url" string.
}
