import Foundation
import Testing
@testable import CorbadoConnect

// The backend sends userHandle and credential IDs base64url-encoded (RFC 4648 §5,
// alphabet with "-" and "_"). These tests pin the decoding behavior the Signal API
// relies on in PasskeyPlugin.signalAllAcceptedCredentials.

@Test func fromBase64UrlDecodesUrlSafeCharacters() {
    // 0xFF 0xEF encodes to "/+8=" in standard base64, "_-8" in base64url
    #expect(Data.fromBase64Url("_-8") == Data([0xFF, 0xEF]))
}

@Test func fromBase64UrlRoundTripsRandomCredentialIDs() {
    for _ in 0..<100 {
        var bytes = [UInt8](repeating: 0, count: 16)
        for i in bytes.indices {
            bytes[i] = UInt8.random(in: .min ... .max)
        }
        let credentialID = Data(bytes)

        #expect(Data.fromBase64Url(credentialID.toBase64URL()) == credentialID)
    }
}

@Test func fromBase64UrlRoundTripsUserHandle() {
    let userHandle = Data("usr-1234567890".utf8)

    #expect(Data.fromBase64Url(userHandle.toBase64URL()) == userHandle)
}

@Test func fromBase64RejectsUrlSafeCharacters() {
    // Standard base64 decoding must not be used for wire data: it rejects "-" and "_"
    #expect(Data.fromBase64("_-8") == nil)
}
