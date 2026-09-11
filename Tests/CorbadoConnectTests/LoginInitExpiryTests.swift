import Foundation
import OpenAPIClient
import Testing
@testable import CorbadoConnect

/// The backend removes processes after their lifetime. Login-start with a stale process ID is answered with a silent
/// fallback, so the SDK must re-run login-init when the login-init data has expired (see Corbado.ensureValidLoginProcess).
@MainActor
struct LoginInitExpiryTests {
    private func makeFactory(loginAllowed: Bool) -> StubRequestBuilderFactory {
        StubRequestBuilderFactory(responses: [
            "/v2/connect/login/init": .success(ConnectLoginInitRsp(
                token: "fresh-process", expiresAt: Int64(Date().timeIntervalSince1970) + 1800,
                frontendApiUrl: "https://example.invalid", loginAllowed: loginAllowed, flags: [:]
            )),
            "/v2/connect/login/start": .success(ConnectLoginStartRsp(
                assertionOptions: "", isCDA: false, fallbackOperationError: FallbackOperationError(initFallback: true)
            )),
            "/v2/connect/events": .success(())
        ])
    }

    private func makeCorbado(factory: StubRequestBuilderFactory, loginDataExpiresAt: TimeInterval) async -> Corbado {
        let corbado = Corbado(projectId: UUID().uuidString, frontendApiUrlSuffix: nil)
        await corbado.installTestClient(factory)
        await corbado.installProcess(ConnectProcess(
            id: "stale-process",
            frontendApiUrl: "https://example.invalid",
            loginData: ConnectLoginInitData(loginAllowed: true, expiresAt: loginDataExpiresAt)
        ))

        return corbado
    }

    @Test
    func expiredLoginInitIsRerunBeforeLoginStart() async throws {
        let factory = makeFactory(loginAllowed: true)
        let corbado = await makeCorbado(factory: factory, loginDataExpiresAt: Date().timeIntervalSince1970 - 60)

        let result = await corbado.loginWithTextField(identifier: "test@example.com")

        guard case .initSilentFallback = result else {
            Issue.record("Stubbed login-start answers with a silent fallback")
            return
        }
        #expect(factory.requests.map(\.path) == ["/v2/connect/login/init", "/v2/connect/login/start"])
        #expect(await corbado.process?.id == "fresh-process")
    }

    @Test
    func validLoginInitIsNotRerun() async throws {
        let factory = makeFactory(loginAllowed: true)
        let corbado = await makeCorbado(factory: factory, loginDataExpiresAt: Date().timeIntervalSince1970 + 1800)

        _ = await corbado.loginWithTextField(identifier: "test@example.com")

        #expect(factory.requests.map(\.path) == ["/v2/connect/login/start"])
        #expect(await corbado.process?.id == "stale-process")
    }

    @Test
    func expiredLoginInitWithFallbackSkipsLoginStart() async throws {
        let factory = makeFactory(loginAllowed: false)
        let corbado = await makeCorbado(factory: factory, loginDataExpiresAt: Date().timeIntervalSince1970 - 60)

        let result = await corbado.loginWithTextField(identifier: "test@example.com")

        guard case .initSilentFallback = result else {
            Issue.record("Re-run login-init that denies passkey login must end in a silent fallback")
            return
        }
        #expect(factory.requests.map(\.path) == ["/v2/connect/login/init"])
    }
}
