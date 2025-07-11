//
// ConnectManageListRsp.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

public struct ConnectManageListRsp: Sendable, Codable, ParameterConvertible, Hashable {

    public var passkeys: [Passkey]
    public var rpID: String
    public var userID: String

    public init(passkeys: [Passkey], rpID: String, userID: String) {
        self.passkeys = passkeys
        self.rpID = rpID
        self.userID = userID
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case passkeys
        case rpID
        case userID
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(passkeys, forKey: .passkeys)
        try container.encode(rpID, forKey: .rpID)
        try container.encode(userID, forKey: .userID)
    }
}

