import Foundation
import OpenAPIClient
import SimpleAuthenticationServices
import Testing
@testable import CorbadoConnect

@MainActor
struct LoginDiagnosticsTests {
    @Test(arguments: [true, false], [AuthorizationErrorType.cancelled, .noPresentationAnchor, .unknown])
    func loginEventsPreserveAuthorizationDiagnostics(withoutIdentifier: Bool, errorType: AuthorizationErrorType) async throws {
        let assertionOptions = #"{"publicKey":{"challenge":"AQ","rpId":"example.com"}}"#
        let factory = StubRequestBuilderFactory(responses: [
            "/v2/connect/login/start": .success(ConnectLoginStartRsp(
                assertionOptions: assertionOptions, isCDA: false, fallbackOperationError: FallbackOperationError(initFallback: false)
            )),
            "/v2/connect/events": .success(())
        ])
        let corbado = Corbado(projectId: UUID().uuidString, frontendApiUrlSuffix: nil)
        await corbado.installTestClient(factory)
        // login-init has been run (valid login-init data) => login-start is called directly
        await corbado.installProcess(ConnectProcess(
            id: "process", frontendApiUrl: "https://example.invalid",
            loginData: ConnectLoginInitData(loginAllowed: true, expiresAt: Date().timeIntervalSince1970 + 1800)
        ))
        let controller = StubAuthorizationController()
        controller.failure = AuthorizationError(type: errorType, originalError: errorType == .unknown ? testNativeError() : nil)
        await corbado.setVirtualAuthorizationController(controller)

        if withoutIdentifier {
            let result = await corbado.loginWithoutIdentifier(cuiChallenge: assertionOptions)
            if errorType == .cancelled {
                guard case .ignore = result else { Issue.record("Cancellation must still be ignored"); return }
            } else {
                guard case .error = result else { Issue.record("Unexpected failure must still return an error"); return }
            }
        } else {
            let result = await corbado.loginWithTextField(identifier: "test@example.com")
            if errorType == .cancelled {
                guard case .initRetry = result else { Issue.record("Cancellation must still allow retry"); return }
            } else {
                guard case .error = result else { Issue.record("Unexpected failure must still return an error"); return }
            }
        }

        #expect(factory.events.count == 1)
        let event = try #require(factory.events.first)
        let expectedEvent: PasskeyEventType = errorType == .cancelled ? .loginError : .loginErrorUnexpected
        #expect(event.parameters["eventType"] as? String == expectedEvent.rawValue)
        let message = try #require(event.parameters["message"] as? String)
        #expect(message.contains("AuthorizationError(type: \(errorType.rawValue)"))
        if errorType == .unknown {
            #expect(message.contains("1004"))
            #expect(message.contains("Native diagnostic detail"))
            #expect(message.contains("TestCredentialProvider"))
            #expect(message.contains("Provider rejected the operation"))
        }
    }
}
