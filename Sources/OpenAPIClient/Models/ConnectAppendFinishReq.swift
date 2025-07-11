//
// ConnectAppendFinishReq.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

public struct ConnectAppendFinishReq: Sendable, Codable, ParameterConvertible, Hashable {

    public var attestationResponse: String

    public init(attestationResponse: String) {
        self.attestationResponse = attestationResponse
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case attestationResponse
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(attestationResponse, forKey: .attestationResponse)
    }
}

