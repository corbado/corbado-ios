import Foundation
import SimpleAuthenticationServices
import Testing
@testable import CorbadoConnect

private let assertionOptions = #"{"publicKey":{"challenge":"AQID","rpId":"example.com"}}"#
private let attestationOptions = #"""
{"publicKey":{"rp":{"name":"Example","id":"example.com"},"user":{"name":"user","displayName":"User","id":"AQ"},
"challenge":"AQID","timeout":60000,"pubKeyCredParams":[{"type":"public-key","alg":-7}],
"authenticatorSelection":{"residentKey":"required","userVerification":"preferred"},"attestation":"none"}}
"""#

private func jsonObject(_ string: String) throws -> [String: Any] {
    try #require(JSONSerialization.jsonObject(with: Data(string.utf8)) as? [String: Any])
}

@MainActor
struct CredentialSerializationTests {
    @available(iOS 16.0, *)
    @Test func assertionCarriesAttachmentAndExtensionResults() async throws {
        let plugin = PasskeyPlugin()
        let controller = StubAuthorizationController()
        controller.result = AuthorizationResult(credential: PasskeyAssertionCredential(
            credentialID: Data([1, 2]),
            rawClientDataJSON: Data([3]),
            rawAuthenticatorData: Data([4]),
            signature: Data([5]),
            userID: Data([255, 239]),
            attachment: .crossPlatform,
            clientExtensionResults: PasskeyClientExtensionResults(
                largeBlob: .init(blob: Data([255, 254])),
                prf: .init(first: Data([251, 255]), second: nil)
            )
        ))
        plugin.controller = controller

        let json = try jsonObject(try await plugin.authenticate(
            assertionOptions: assertionOptions, conditionalUI: false, preferImmediatelyAvailableCredentials: false
        ))

        #expect(json["id"] as? String == "AQI")
        #expect(json["rawId"] as? String == "AQI")
        #expect(json["type"] as? String == "public-key")
        #expect(json["authenticatorAttachment"] as? String == "cross-platform")
        let response = try #require(json["response"] as? [String: Any])
        #expect(response["userHandle"] as? String == "_-8")
        let extensions = try #require(json["clientExtensionResults"] as? [String: Any])
        #expect((extensions["largeBlob"] as? [String: Any])?["blob"] as? String == "__4")
        let prf = try #require(extensions["prf"] as? [String: Any])
        #expect(prf["enabled"] == nil)
        let results = try #require(prf["results"] as? [String: Any])
        #expect(results["first"] as? String == "-_8")
        #expect(results["second"] == nil)
    }

    @available(iOS 16.0, *)
    @Test func assertionWithoutReportedValuesSendsEmptyExtensionsAndNoAttachment() async throws {
        let plugin = PasskeyPlugin()
        let controller = StubAuthorizationController()
        controller.result = AuthorizationResult(credential: PasskeyAssertionCredential(
            credentialID: Data([1]), rawClientDataJSON: Data([2]), rawAuthenticatorData: Data([3]),
            signature: Data([4]), userID: Data([5])
        ))
        plugin.controller = controller

        let json = try jsonObject(try await plugin.authenticate(
            assertionOptions: assertionOptions, conditionalUI: true, preferImmediatelyAvailableCredentials: false
        ))

        #expect(json["authenticatorAttachment"] == nil)
        let extensions = try #require(json["clientExtensionResults"] as? [String: Any])
        #expect(extensions.isEmpty)
    }

    @available(iOS 16.0, *)
    @Test func registrationSendsPlainTransportNamesAndAttachment() async throws {
        let plugin = PasskeyPlugin()
        let controller = StubAuthorizationController()
        controller.result = AuthorizationResult(credential: PasskeyRegistrationCredential(
            credentialID: Data([1, 2]),
            rawClientDataJSON: Data([3]),
            rawAttestationObject: Data([4]),
            transports: ["usb", "nfc", "ble"].map { Data($0.utf8) },
            attachment: .platform,
            clientExtensionResults: PasskeyClientExtensionResults(
                largeBlob: .init(supported: true),
                prf: .init(enabled: true)
            )
        ))
        plugin.controller = controller

        let json = try jsonObject(try await plugin.create(attestationOptions: attestationOptions, completionType: .Manual))

        #expect(json["type"] as? String == "public-key")
        #expect(json["authenticatorAttachment"] as? String == "platform")
        let response = try #require(json["response"] as? [String: Any])
        #expect(response["transports"] as? [String] == ["usb", "nfc", "ble"])
        let extensions = try #require(json["clientExtensionResults"] as? [String: Any])
        #expect((extensions["largeBlob"] as? [String: Any])?["supported"] as? Bool == true)
        let prf = try #require(extensions["prf"] as? [String: Any])
        #expect(prf["enabled"] as? Bool == true)
        #expect(prf["results"] == nil)
    }

    @available(iOS 16.0, *)
    @Test func registrationWithoutTransportsKeepsEmptyList() async throws {
        let plugin = PasskeyPlugin()
        let controller = StubAuthorizationController()
        controller.result = AuthorizationResult(credential: PasskeyRegistrationCredential(
            credentialID: Data([1]), rawClientDataJSON: Data([2]), rawAttestationObject: Data([3]), transports: []
        ))
        plugin.controller = controller

        let json = try jsonObject(try await plugin.create(attestationOptions: attestationOptions, completionType: .Manual))

        let response = try #require(json["response"] as? [String: Any])
        #expect(response["transports"] as? [String] == [])
        #expect(json["authenticatorAttachment"] == nil)
        #expect((json["clientExtensionResults"] as? [String: Any])?.isEmpty == true)
    }
}
