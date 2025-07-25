//
// FallbackOperationError.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

public struct FallbackOperationError: Sendable, Codable, ParameterConvertible, Hashable {

    public var initFallback: Bool
    public var identifier: String?
    public var error: RequestError?

    public init(initFallback: Bool, identifier: String? = nil, error: RequestError? = nil) {
        self.initFallback = initFallback
        self.identifier = identifier
        self.error = error
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case initFallback
        case identifier
        case error
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(initFallback, forKey: .initFallback)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encodeIfPresent(error, forKey: .error)
    }
}

