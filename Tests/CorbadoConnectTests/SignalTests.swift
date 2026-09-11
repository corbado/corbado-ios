import Foundation
import OpenAPIClient
import SimpleAuthenticationServices
import Testing
@testable import CorbadoConnect

@MainActor
struct SignalTests {
    @Test func forwardsBase64URLBytesAndEmptyCredentialList() async throws {
        let plugin = PasskeyPlugin()
        let controller = StubAuthorizationController()
        plugin.controller = controller

        try await plugin.signalAllAcceptedCredentials(rpID: "example.com", userHandle: "_-8", acceptedCredentialIDs: ["_-8", "AQ", "AQI"])
        try await plugin.signalAllAcceptedCredentials(rpID: "example.com", userHandle: "AQ", acceptedCredentialIDs: [])

        #expect(controller.signals.count == 2)
        let first = try #require(controller.signals.first)
        #expect(first.rpID == "example.com")
        #expect(first.userHandle == Data([255, 239]))
        #expect(first.credentialIDs == [Data([255, 239]), Data([1]), Data([1, 2])])
        #expect(controller.signals.last?.credentialIDs == [])
    }

    @Test(arguments: [true, false])
    func decodingErrorsIdentifyTheFieldWithoutRetainingIdentifiers(invalidHandle: Bool) async throws {
        let plugin = PasskeyPlugin()
        let controller = StubAuthorizationController()
        plugin.controller = controller
        let invalid = "sensitive-invalid!"
        let expected: SignalDecodingError = invalidHandle
            ? .userHandle(encodedLength: invalid.utf8.count)
            : .acceptedCredentialID(index: 1, encodedLength: invalid.utf8.count)

        do {
            try await plugin.signalAllAcceptedCredentials(
                rpID: "example.com", userHandle: invalidHandle ? invalid : "AQ",
                acceptedCredentialIDs: invalidHandle ? ["AQ"] : ["AQ", invalid]
            )
            Issue.record("Invalid base64url must fail before calling the controller")
        } catch {
            #expect(error.type == .decoding)
            #expect(error.originalError as? SignalDecodingError == expected)
            #expect(error.localizedDescription.contains(expected.description))
            #expect(!error.localizedDescription.contains(invalid))
        }
        #expect(controller.signals.isEmpty)
    }

    @Test(arguments: [PasskeyListMode.Default, .PostAppend, .PostDelete], [true, false])
    func listSurvivesDecodingFailureAndRecordsContext(mode: PasskeyListMode, invalidHandle: Bool) async throws {
        let invalid = "sensitive-invalid!"
        let factory = StubRequestBuilderFactory(responses: [
            "/v2/connect/manage/list": .success(ConnectManageListRsp(
                passkeys: [testPasskey(), testPasskey(credentialID: invalidHandle ? "AQ" : invalid)],
                rpID: "example.com", userID: invalidHandle ? invalid : "AQ", signalAllAcceptedCredentials: true
            )),
            "/v2/connect/events": .success(())
        ])
        let corbado = Corbado(projectId: UUID().uuidString, frontendApiUrlSuffix: nil)
        await corbado.installTestClient(factory)
        let controller = StubAuthorizationController()
        await corbado.setVirtualAuthorizationController(controller)

        let passkeys = try await corbado.getPasskeys(connectTokenProvider: { _ in "test-token" }, mode: mode)

        #expect(passkeys.count == 2)
        #expect(controller.signals.isEmpty)
        #expect(factory.events.count == 1)
        let event = try #require(factory.events.first)
        #expect(event.parameters["eventType"] as? String == PasskeyEventType.manageErrorUnexpected.rawValue)
        let message = try #require(event.parameters["message"] as? String)
        #expect(message.contains("mode=\(mode.rawValue)"))
        #expect(message.contains("acceptedCredentialCount=2"))
        #expect(message.contains("type: decoding"))
        #expect(message.contains(invalidHandle ? "field=userHandle" : "field=acceptedCredentialIDs index=1"))
        #expect(message.contains("encodedLength=18"))
        #expect(!message.contains(invalid))
    }

    @Test(arguments: [true, false])
    func deleteSurvivesNativeSignalFailureEvenIfTelemetryFails(telemetryFails: Bool) async throws {
        let factory = StubRequestBuilderFactory(responses: [
            "/v2/connect/manage/delete": .success(ConnectManageDeleteRsp(credentialID: "deleted-passkey")),
            "/v2/connect/manage/list": .success(ConnectManageListRsp(
                passkeys: [testPasskey()], rpID: "example.com", userID: "AQ", signalAllAcceptedCredentials: true
            )),
            "/v2/connect/events": telemetryFails ? .failure(.error(503, nil, nil, URLError(.notConnectedToInternet))) : .success(())
        ])
        let corbado = Corbado(projectId: UUID().uuidString, frontendApiUrlSuffix: nil)
        await corbado.installTestClient(factory)
        await corbado.installInitializedManageProcess()
        let controller = StubAuthorizationController()
        controller.signalFailure = AuthorizationError(type: .unknown, originalError: testNativeError())
        await corbado.setVirtualAuthorizationController(controller)

        let result = await corbado.deletePasskey(connectTokenProvider: { _ in "test-token" }, passkeyId: "deleted-passkey")

        guard case .done(let passkeys) = result else {
            Issue.record("Successful deletion must remain successful when signaling or telemetry fails")
            return
        }
        #expect(passkeys.map(\.id) == ["remaining-passkey"])
        #expect(controller.signals.count == 1)
        #expect(factory.requests.map(\.path) == ["/v2/connect/manage/delete", "/v2/connect/manage/list", "/v2/connect/events"])
        #expect(factory.requests[1].parameters["mode"] as? String == "post-delete")
        let message = try #require(factory.events.first?.parameters["message"] as? String)
        #expect(message.contains("mode=post-delete acceptedCredentialCount=1"))
        #expect(message.contains("type: unknown"))
        #expect(message.contains("1004"))
        #expect(message.contains("Native diagnostic detail"))
        #expect(message.contains("TestCredentialProvider"))
    }

    @Test func disabledSignalDoesNotDecodeOrReport() async throws {
        let factory = StubRequestBuilderFactory(responses: [
            "/v2/connect/manage/list": .success(ConnectManageListRsp(
                passkeys: [], rpID: "example.com", userID: "invalid!", signalAllAcceptedCredentials: false
            ))
        ])
        let corbado = Corbado(projectId: UUID().uuidString, frontendApiUrlSuffix: nil)
        await corbado.installTestClient(factory)
        let controller = StubAuthorizationController()
        await corbado.setVirtualAuthorizationController(controller)

        let passkeys = try await corbado.getPasskeys(connectTokenProvider: { _ in "test-token" }, mode: .Default)
        #expect(passkeys.isEmpty)
        #expect(controller.signals.isEmpty)
        #expect(factory.events.isEmpty)
    }

    @Test func failedListRequestStillFailsDeletion() async throws {
        let factory = StubRequestBuilderFactory(responses: [
            "/v2/connect/manage/delete": .success(ConnectManageDeleteRsp(credentialID: "deleted-passkey")),
            "/v2/connect/manage/list": .failure(.error(503, nil, nil, URLError(.notConnectedToInternet))),
            "/v2/connect/events": .success(())
        ])
        let corbado = Corbado(projectId: UUID().uuidString, frontendApiUrlSuffix: nil)
        await corbado.installTestClient(factory)
        await corbado.installInitializedManageProcess()
        let controller = StubAuthorizationController()
        await corbado.setVirtualAuthorizationController(controller)

        let result = await corbado.deletePasskey(connectTokenProvider: { _ in "test-token" }, passkeyId: "deleted-passkey")
        guard case .error = result else {
            Issue.record("A list API failure must not be swallowed by the signal catch")
            return
        }
        #expect(controller.signals.isEmpty)
    }
}
