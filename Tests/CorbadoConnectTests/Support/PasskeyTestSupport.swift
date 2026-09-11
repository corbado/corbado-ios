import AuthenticationServices
import Foundation
import OpenAPIClient
import SimpleAuthenticationServices
import Testing
@testable import CorbadoConnect

@MainActor
final class StubAuthorizationController: SimpleAuthenticationServices.AuthorizationControllerProtocol {
    struct SignalRequest {
        let rpID: String
        let userHandle: Data
        let credentialIDs: [Data]
    }

    var failure = AuthorizationError(type: .noPresentationAnchor)
    var signalFailure: AuthorizationError?
    private(set) var signals: [SignalRequest] = []

    func authorize(requests: [ASAuthorizationRequest], preferImmediatelyAvailableCredentials: Bool) async throws -> AuthorizationResult {
        throw failure
    }

    func authorizeWithAutoFill(requests: [ASAuthorizationRequest]) async throws -> AuthorizationResult {
        throw failure
    }

    func create(requests: [ASAuthorizationRequest]) async throws -> AuthorizationResult {
        throw failure
    }

    func cancel() async {}

    func signalAllAcceptedCredentials(rpID: String, userHandle: Data, acceptedCredentialIDs: [Data]) async throws(AuthorizationError) {
        signals.append(SignalRequest(rpID: rpID, userHandle: userHandle, credentialIDs: acceptedCredentialIDs))
        if let signalFailure { throw signalFailure }
    }
}

/// Exercises the SDK's request construction and event payloads without network access.
final class StubRequestBuilderFactory: RequestBuilderFactory, @unchecked Sendable {
    struct Request {
        let path: String
        let parameters: [String: Any]
    }

    private let responses: [String: Result<Any, ErrorResponse>]
    private let lock = NSLock()
    private var recordedRequests: [Request] = []

    init(responses: [String: Result<Any, ErrorResponse>]) {
        self.responses = responses
    }

    var requests: [Request] {
        lock.withLock { recordedRequests }
    }

    var events: [Request] {
        requests.filter { $0.path == "/v2/connect/events" }
    }

    func respond(path: String, parameters: [String: any Sendable]) -> Result<Any, ErrorResponse> {
        // The generated client carries the encoded JSON body as a Data parameter.
        let body: [String: Any]
        do {
            let data = try #require(parameters.values.compactMap { $0 as? Data }.first)
            body = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        } catch {
            return .failure(.error(500, nil, nil, error))
        }
        lock.withLock {
            recordedRequests.append(Request(path: path, parameters: body))
        }
        guard let response = responses[path] else {
            Issue.record("Unexpected API call: \(path)")
            return .failure(.error(500, nil, nil, URLError(.badServerResponse)))
        }
        return response
    }

    func getNonDecodableBuilder<T>() -> RequestBuilder<T>.Type { StubRequestBuilder<T>.self }
    func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type { StubRequestBuilder<T>.self }
}

private final class StubRequestBuilder<T>: RequestBuilder<T>, @unchecked Sendable {
    override func execute(completion: @Sendable @escaping (Result<Response<T>, ErrorResponse>) -> Void) -> RequestTask {
        guard let factory = apiConfiguration.requestBuilderFactory as? StubRequestBuilderFactory,
              let path = URL(string: URLString)?.path else {
            Issue.record("Invalid stub request configuration")
            completion(.failure(.error(500, nil, nil, URLError(.badURL))))
            return requestTask
        }
        switch factory.respond(path: path, parameters: parameters ?? [:]) {
        case .success(let body):
            guard let typedBody = body as? T else {
                Issue.record("Unexpected response type for \(path)")
                completion(.failure(.error(500, nil, nil, URLError(.cannotParseResponse))))
                return requestTask
            }
            completion(.success(Response(statusCode: 200, header: [:], body: typedBody, bodyData: nil)))
        case .failure(let error):
            completion(.failure(error))
        }
        return requestTask
    }
}

extension Corbado {
    func installProcess(_ process: ConnectProcess?) {
        self.process = process
    }

    /// Simulates a completed manage-init (valid manage-init data) so follow-up manage calls don't re-run it.
    func installInitializedManageProcess() {
        process = ConnectProcess(
            id: "process", frontendApiUrl: "https://example.invalid",
            manageData: ConnectManageInitData(manageAllowed: true, flags: [:], expiresAt: Date().timeIntervalSince1970 + 1800)
        )
    }

    func installTestClient(_ factory: StubRequestBuilderFactory) {
        client = CorbadoClient(apiConfig: OpenAPIClientAPIConfiguration(
            basePath: "https://example.invalid", requestBuilderFactory: factory
        ))
    }
}

func testPasskey(credentialID: String = "_-8") -> OpenAPIClient.Passkey {
    OpenAPIClient.Passkey(
        id: "remaining-passkey", credentialID: credentialID, attestationType: "none",
        transport: [._internal], backupEligible: true, backupState: true,
        authenticatorAAGUID: "test-aaguid", sourceOS: "iOS", sourceBrowser: "native",
        lastUsed: "2026-09-01T00:00:00Z", created: "2026-09-01T00:00:00Z", status: .active,
        aaguidDetails: AaguidDetails(name: "Test provider", iconLight: "", iconDark: ""),
        createdMs: 0, lastUsedMs: 0, tags: []
    )
}

func testNativeError() -> ASAuthorizationError {
    ASAuthorizationError(.failed, userInfo: [
        NSLocalizedDescriptionKey: "Authorization failed",
        NSDebugDescriptionErrorKey: "Native diagnostic detail",
        NSUnderlyingErrorKey: NSError(domain: "TestCredentialProvider", code: 42, userInfo: [
            NSLocalizedDescriptionKey: "Provider rejected the operation"
        ])
    ])
}
