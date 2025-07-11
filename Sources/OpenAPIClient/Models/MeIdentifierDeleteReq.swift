//
// MeIdentifierDeleteReq.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

public struct MeIdentifierDeleteReq: Sendable, Codable, ParameterConvertible, Hashable {

    public var identifierID: String

    public init(identifierID: String) {
        self.identifierID = identifierID
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case identifierID
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifierID, forKey: .identifierID)
    }
}

