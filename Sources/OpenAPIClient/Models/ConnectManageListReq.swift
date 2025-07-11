//
// ConnectManageListReq.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

public struct ConnectManageListReq: Sendable, Codable, ParameterConvertible, Hashable {

    public var connectToken: String

    public init(connectToken: String) {
        self.connectToken = connectToken
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case connectToken
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(connectToken, forKey: .connectToken)
    }
}

