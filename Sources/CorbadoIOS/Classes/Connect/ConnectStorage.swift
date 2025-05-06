//
//  ConnectStorage.swift
//  CorbadoIOS
//
//  Created by Martin on 5/5/2025.
//

import Foundation

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
    
    private func getStorageKeyClientHandle(projectId: String) -> String {
        return "cbo_client_handle-\(projectId)"
    }
    
    private func getStorageKeyLastLogin(projectId: String) -> String {
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
            userDefaults.set(entry, forKey: key)
        } catch {
            print("Error encoding ClientStateEntry for key '\(key)': \(error)")
        }
    }
    
    func getLastLogin(projectId: String) -> ClientStateEntry<LastLogin>? {
        // Directly get the entry using the standard key
        return getEntry(forKey: getStorageKeyLastLogin(projectId: projectId))
    }
    
    func setLastLogin(projectId: String, lastLogin: LastLogin) {
        // Calls the private setter with localStorage source and current time
        setLastLogin(
            projectId: projectId,
            data: lastLogin,
            source: .localStorage,
            ts: Date().timeIntervalSince1970 // Current timestamp in seconds
        )
    }
    
    /// Private setter for LastLogin, allowing control over source and timestamp.
    private func setLastLogin(projectId: String, data: LastLogin?, source: Source, ts: TimeInterval) {
        let entry = ClientStateEntry<LastLogin>(data: data, source: source, ts: ts)
        setEntry(entry, forKey: getStorageKeyLastLogin(projectId: projectId))
    }
    
    func clearLastLogin(projectId: String) {
        // Sets the data to nil using the private setter
        setLastLogin(
            projectId: projectId,
            data: nil,
            source: .localStorage,
            ts: Date().timeIntervalSince1970
        )
    }
    
    func getClientEnvHandle(projectId: String) -> ClientStateEntry<String>? {
        return getEntry(forKey: getStorageKeyClientHandle(projectId: projectId))
        // Note: Omitted the compatibility check for `cbo_client_handle` key.
        // Add similar fallback logic as for getLastLogin if needed.
    }
    
    func setClientEnvHandle(projectId: String, clientEnvHandle: String) {
        setClientEnvHandle(
            projectId: projectId,
            data: clientEnvHandle,
            source: .localStorage,
            ts: Date().timeIntervalSince1970
        )
    }
    
    /// Private setter for ClientEnvHandle.
    private func setClientEnvHandle(projectId: String, data: String?, source: Source, ts: TimeInterval) {
        let entry = ClientStateEntry<String>(data: data, source: source, ts: ts)
        setEntry(entry, forKey: getStorageKeyClientHandle(projectId: projectId))
    }
    
    // Note: parseClientStateSource functionality is included in the Source enum's `metaSource` computed property.
    // You can access it via `entry.source.metaSource` if you need the "ls" or "url" string.
}
