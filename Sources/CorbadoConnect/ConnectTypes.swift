//
//  Types.swift
//  CorbadoConnect
//
//  Created by testing on 26/5/2025.
//
import OpenAPIClient

/// Details of the authenticator used to create the passkey.
public typealias AaguidDetails = OpenAPIClient.AaguidDetails

/// Represents a passkey credential stored on the device or in the cloud.
public struct Passkey: Sendable, Equatable, Identifiable, Hashable {
    public var id: String
    public var tags: [String]
    public var sourceOS: String
    public var sourceBrowser: String
    public var lastUsedMs: Int64
    public var createdMs: Int64
    public var aaguidDetails: AaguidDetails
}

/// The type of operation that requires a short-lived session token (connect token).
public enum ConnectTokenType: String, Sendable, Encodable {
    case PasskeyAppend = "passkey-append"
    case PasskeyList = "passkey-list"
    case PasskeyDelete = "passkey-delete"
} 
