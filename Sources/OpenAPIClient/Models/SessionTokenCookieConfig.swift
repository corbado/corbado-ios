//
// SessionTokenCookieConfig.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

public struct SessionTokenCookieConfig: Sendable, Codable, ParameterConvertible, Hashable {

    public enum SameSite: String, Sendable, Codable, CaseIterable {
        case lax = "lax"
        case strict = "strict"
        case _none = "none"
    }
    public var domain: String
    public var secure: Bool
    public var sameSite: SameSite
    public var path: String
    public var lifetimeSeconds: Int

    public init(domain: String, secure: Bool, sameSite: SameSite, path: String, lifetimeSeconds: Int) {
        self.domain = domain
        self.secure = secure
        self.sameSite = sameSite
        self.path = path
        self.lifetimeSeconds = lifetimeSeconds
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case domain
        case secure
        case sameSite
        case path
        case lifetimeSeconds
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(domain, forKey: .domain)
        try container.encode(secure, forKey: .secure)
        try container.encode(sameSite, forKey: .sameSite)
        try container.encode(path, forKey: .path)
        try container.encode(lifetimeSeconds, forKey: .lifetimeSeconds)
    }
}

