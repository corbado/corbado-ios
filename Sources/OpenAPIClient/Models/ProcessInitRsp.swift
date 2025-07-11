//
// ProcessInitRsp.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

/** tbd. */
public struct ProcessInitRsp: Sendable, Codable, ParameterConvertible, Hashable {

    public var newClientEnvHandle: String?
    public var token: String
    public var expiresAt: Int
    public var processResponse: ProcessResponse

    public init(newClientEnvHandle: String? = nil, token: String, expiresAt: Int, processResponse: ProcessResponse) {
        self.newClientEnvHandle = newClientEnvHandle
        self.token = token
        self.expiresAt = expiresAt
        self.processResponse = processResponse
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case newClientEnvHandle
        case token
        case expiresAt
        case processResponse
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(newClientEnvHandle, forKey: .newClientEnvHandle)
        try container.encode(token, forKey: .token)
        try container.encode(expiresAt, forKey: .expiresAt)
        try container.encode(processResponse, forKey: .processResponse)
    }
}

