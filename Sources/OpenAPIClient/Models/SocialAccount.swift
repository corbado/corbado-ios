//
// SocialAccount.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

public struct SocialAccount: Sendable, Codable, ParameterConvertible, Hashable {

    public var providerType: SocialProviderType
    public var identifierValue: String
    public var avatarUrl: String
    public var fullName: String

    public init(providerType: SocialProviderType, identifierValue: String, avatarUrl: String, fullName: String) {
        self.providerType = providerType
        self.identifierValue = identifierValue
        self.avatarUrl = avatarUrl
        self.fullName = fullName
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case providerType
        case identifierValue
        case avatarUrl
        case fullName
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(providerType, forKey: .providerType)
        try container.encode(identifierValue, forKey: .identifierValue)
        try container.encode(avatarUrl, forKey: .avatarUrl)
        try container.encode(fullName, forKey: .fullName)
    }
}

