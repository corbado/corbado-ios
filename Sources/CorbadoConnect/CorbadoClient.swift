import OpenAPIClient
import Foundation

enum LoginPasskeyEvent {
    case loginExplicitAbort
    case loginError(_ message: String)
    case loginErrorUnexpected(_ message: String)
    case loginOneTapSwitch
    case loginNoCredentials
    case localUnlock
}

enum AppendPasskeyEvent {
    case appendExplicitAbort
    case appendCredentialExists(_ message: String)
    case appendError(_ message: String)
    case appendErrorUnexpected(_ message: String)
    case appendLearnMore
}

enum ManagePasskeyEvent {
    case manageError(_ message: String)
    case manageCredentialExists(_ message: String)
    case manageErrorUnexpected(_ message: String)
    case manageLearnMore
}

enum LoginSituation: Int, Equatable, Sendable {
    case cboApiNotAvailablePreConditionalAuthenticator = 0
    case clientPasskeyConditionalOperationCancelled = 1
    case clientPasskeyOperationCancelledTooManyTimes = 2
    case passkeyNotAvailablePostConditionalAuthenticator = 3
    case cboApiNotAvailablePostConditionalAuthenticator = 4
    case cboApiNotAvailablePreAuthenticator = 5
    case clientPasskeyOperationCancelled = 6
    case cboApiNotAvailablePostAuthenticator = 7
    case ctApiNotAvailablePostAuthenticator = 8
    case explicitFallbackByUser = 9
    case preAuthenticatorUserNotFound = 10
    case deniedByPartialRollout = 11
    case preAuthenticatorCustomError = 12
    case preAuthenticatorExistingPasskeysNotAvailable = 13
    case preAuthenticatorNoPasskeyAvailable = 14
    case cboApiFallbackOperationError = 15
}

enum AppendSituation: Int, Equatable, Sendable {
    case cboApiNotAvailablePreAuthenticator = 0
    case cboApiNotAvailablePostAuthenticator = 1
    case ctApiNotAvailablePreAuthenticator = 2
    case clientPasskeyOperationCancelled = 3
    case clientExcludeCredentialsMatch = 4
    case deniedByPartialRollout = 5
    case deniedByPasskeyIntel = 6
    case explicitSkipByUser = 7
    case clientPasskeyOperationCancelledSilent = 8
}

enum ManageSituation: Int, Equatable, Sendable {
    case cboApiNotAvailableDuringInitialLoad = 0
    case ctApiNotAvailableDuringInitialLoad = 1
    case cboApiNotAvailableDuringDelete = 2
    case ctApiNotAvailablePreDelete = 3
    case ctApiNotAvailablePreAuthenticator = 4
    case cboApiPasskeysNotSupported = 5
    case cboApiNotAvailablePreAuthenticator = 6
    case cboApiNotAvailablePostAuthenticator = 7
    case clientPasskeyOperationCancelled = 8
    case clientExcludeCredentialsMatch = 9
    case cboApiPasskeysNotSupportedLight = 10
    case unknown = 11
}   

struct Exception {
    let message: String?
    
    init(message: String?) {
        self.message = message
    }
}

/// Custom RequestBuilderFactory that supports configurable timeouts
public class TimeoutRequestBuilderFactory: RequestBuilderFactory {
    private let timeoutInterval: TimeInterval
    
    public init(timeoutInterval: TimeInterval = 30.0) {
        self.timeoutInterval = timeoutInterval
    }
    
    public func getNonDecodableBuilder<T>() -> RequestBuilder<T>.Type {
        return TimeoutURLSessionRequestBuilder<T>.self
    }
    
    public func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type {
        return TimeoutURLSessionDecodableRequestBuilder<T>.self
    }
    
    fileprivate func createURLSessionWithTimeout() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval * 2 // Allow longer for resource timeout
        return URLSession(configuration: configuration)
    }
}

/// Custom URLSessionRequestBuilder that uses timeout configuration
public class TimeoutURLSessionRequestBuilder<T>: URLSessionRequestBuilder<T> {
    
    override open func createURLSession() -> URLSessionProtocol {
        if let factory = apiConfiguration.requestBuilderFactory as? TimeoutRequestBuilderFactory {
            return factory.createURLSessionWithTimeout()
        }
        return super.createURLSession()
    }
}

/// Custom URLSessionDecodableRequestBuilder that uses timeout configuration
public class TimeoutURLSessionDecodableRequestBuilder<T: Decodable>: URLSessionDecodableRequestBuilder<T> {
    
    override open func createURLSession() -> URLSessionProtocol {
        if let factory = apiConfiguration.requestBuilderFactory as? TimeoutRequestBuilderFactory {
            return factory.createURLSessionWithTimeout()
        }
        return super.createURLSession()
    }
}

struct CorbadoClient {
    let apiConfig: OpenAPIClientAPIConfiguration
    
    init(apiConfig: OpenAPIClientAPIConfiguration) {
        self.apiConfig = apiConfig;
    }
    
    /// Convenience initializer with timeout configuration
    init(apiConfig: OpenAPIClientAPIConfiguration, timeoutInterval: TimeInterval) {
        self.apiConfig = apiConfig
        self.apiConfig.requestBuilderFactory = TimeoutRequestBuilderFactory(timeoutInterval: timeoutInterval)
    }
    
    func loginInit(clientInfo: ClientInformation, invitationToken: String?) async throws(ErrorResponse) -> ConnectLoginInitRsp {
        let req = ConnectLoginInitReq(
            clientInformation: clientInfo,
            flags: [:],
            invitationToken: invitationToken
        )
        
        return try await CorbadoConnectAPI.connectLoginInit(
            connectLoginInitReq: req,
            apiConfiguration: self.apiConfig
        )
    }
    
    func loginStart(identifier: String, source: ConnectLoginStartReq.Source, loadedMs: Int64) async throws(ErrorResponse) -> ConnectLoginStartRsp {
        let reqStart = ConnectLoginStartReq(
            identifier: identifier,
            source: source,
            loadedMs: loadedMs
        )
        
        return try await CorbadoConnectAPI.connectLoginStart(
            connectLoginStartReq: reqStart,
            apiConfiguration: self.apiConfig
        )
    }
    
    func loginFinish(assertionResponse: String, isConditionalUI: Bool) async throws(ErrorResponse) -> ConnectLoginFinishRsp {
        let req = ConnectLoginFinishReq(
            isConditionalUI: isConditionalUI,
            assertionResponse: assertionResponse
        )
        
        return try await CorbadoConnectAPI.connectLoginFinish(
            connectLoginFinishReq: req,
            apiConfiguration: self.apiConfig
        )
    }
    
    func appendInit(clientInfo: ClientInformation, invitationToken: String?) async throws(ErrorResponse) -> ConnectAppendInitRsp {
        let req = ConnectAppendInitReq(
            clientInformation: clientInfo,
            flags: [:],
            invitationToken: invitationToken
        )
        
        return try await CorbadoConnectAPI.connectAppendInit(
            connectAppendInitReq: req,
            apiConfiguration: self.apiConfig
        )
    }
    
    func appendStart(situation: String?, connectToken: String, forcePasskeyAppend: Bool, loadedMs: Int64) async throws(ErrorResponse) -> ConnectAppendStartRsp {
        let req = ConnectAppendStartReq(appendTokenValue: connectToken, forcePasskeyAppend: forcePasskeyAppend, loadedMs: loadedMs, situation: situation)
        
        return try await CorbadoConnectAPI.connectAppendStart(connectAppendStartReq: req, apiConfiguration: self.apiConfig)
    }
    
    func appendFinish(attestationResponse: String, completionType: AppendCompletionType, customData: [String: String]? = nil) async throws(ErrorResponse) -> ConnectAppendFinishRsp {
        let completionType = OpenAPIClient.AppendCompletionType(rawValue: completionType.rawValue) ?? OpenAPIClient.AppendCompletionType.manual
        let req = ConnectAppendFinishReq(attestationResponse: attestationResponse, completionType: completionType, customData: customData)
        
        return try await CorbadoConnectAPI.connectAppendFinish(connectAppendFinishReq: req, apiConfiguration: self.apiConfig)
    }
    
    func manageInit(clientInfo: ClientInformation, invitationToken: String?) async throws(ErrorResponse) -> ConnectManageInitRsp {
        let req = ConnectManageInitReq(
            clientInformation: clientInfo,
            flags: [:],
            invitationToken: invitationToken
        )
        
        return try await CorbadoConnectAPI.connectManageInit(connectManageInitReq: req, apiConfiguration: self.apiConfig)
    }
    
    func manageList(connectToken: String, mode: PasskeyListMode) async throws(ErrorResponse) -> ([Passkey], String, String, Bool) {
        let mode = OpenAPIClient.ConnectManageListReq.Mode(rawValue: mode.rawValue) ?? OpenAPIClient.ConnectManageListReq.Mode._default
        let req = ConnectManageListReq(connectToken: connectToken, mode: mode)
        
        let res = try await CorbadoConnectAPI.connectManageList(connectManageListReq: req, apiConfiguration: self.apiConfig)
        let passkeys = res.passkeys.map { item in
            return Passkey(id: item.id, credentialID: item.credentialID, tags: item.tags, sourceOS: item.sourceOS, sourceBrowser: item.sourceBrowser, lastUsedMs: item.lastUsedMs, createdMs: item.createdMs, aaguidDetails: item.aaguidDetails)
        }
        
        return (passkeys, res.rpID, res.userID, res.signalAllAcceptedCredentials)
    }
    
    func manageDelete(connectToken: String, passkeyId: String) async throws(ErrorResponse) -> ConnectManageDeleteRsp {
        let req = ConnectManageDeleteReq(connectToken: connectToken, credentialID: passkeyId)
        
        return try await CorbadoConnectAPI.connectManageDelete(connectManageDeleteReq: req, apiConfiguration: self.apiConfig)
    }
        
    func recordLoginEvent(event: LoginPasskeyEvent, situation: LoginSituation? = nil) async {
        do {
            let baseMessage = situation.map { "situation: \($0.rawValue) " } ?? ""
            
            let req: ConnectEventCreateReq
            
            switch event {
            case .loginExplicitAbort:
                req = ConnectEventCreateReq(eventType: .loginExplicitAbort)
                
            case .loginError(let message):
                req = ConnectEventCreateReq(
                    eventType: .loginError,
                    message: "\(baseMessage)\(message)"
                )
                
            case .loginErrorUnexpected(let message):
                req = ConnectEventCreateReq(
                    eventType: .loginErrorUnexpected,
                    message: "\(baseMessage)\(message)"
                )
                
            case .loginOneTapSwitch:
                req = ConnectEventCreateReq(eventType: .loginOneTapSwitch)
                
            case .loginNoCredentials:
                req = ConnectEventCreateReq(eventType: .loginNoCredentials)
                
            case .localUnlock:
                req = ConnectEventCreateReq(eventType: .localUnlock)
            }
                        
            try? await CorbadoConnectAPI.connectEventCreate(
                connectEventCreateReq: req,
                apiConfiguration: self.apiConfig
            )
        } catch {
            // recording must never fail the main flow
        }
    }
    
    func recordAppendEvent(event: AppendPasskeyEvent, situation: AppendSituation? = nil) async {
        do {
            let baseMessage = situation.map { "situation: \($0.rawValue) " } ?? ""
            
            let req: ConnectEventCreateReq
            
            switch event {
            case .appendExplicitAbort:
                req = ConnectEventCreateReq(eventType: .appendExplicitAbort)
                
            case .appendCredentialExists(let message):
                req = ConnectEventCreateReq(
                    eventType: .appendCredentialExists,
                    message: "\(baseMessage)\(message)"
                )
                
            case .appendError(let message):
                req = ConnectEventCreateReq(
                    eventType: .appendError,
                    message: "\(baseMessage)\(message)"
                )
                
            case .appendErrorUnexpected(let message):
                req = ConnectEventCreateReq(
                    eventType: .appendErrorUnexpected,
                    message: "\(baseMessage)\(message)"
                )
                
            case .appendLearnMore:
                req = ConnectEventCreateReq(eventType: .appendLearnMore)
            }
                        
            try? await CorbadoConnectAPI.connectEventCreate(
                connectEventCreateReq: req,
                apiConfiguration: self.apiConfig
            )
        } catch {
            // recording must never fail the main flow
        }
    }
    
    func recordManageEvent(event: ManagePasskeyEvent, situation: ManageSituation? = nil) async {
        do {
            let baseMessage = situation.map { "situation: \($0.rawValue) " } ?? ""
            
            let req: ConnectEventCreateReq
            
            switch event {
            case .manageError(let message):
                req = ConnectEventCreateReq(
                    eventType: .manageError,
                    message: "\(baseMessage)\(message)"
                )
                
            case .manageErrorUnexpected(let message):
                req = ConnectEventCreateReq(
                    eventType: .manageErrorUnexpected,
                    message: "\(baseMessage)\(message)"
                )
                
            case .manageLearnMore:
                req = ConnectEventCreateReq(eventType: .manageLearnMore)
                
            case .manageCredentialExists(let message):
                req = ConnectEventCreateReq(
                    eventType: .manageCredentialExists,
                    message: "\(baseMessage)\(message)"
                )
            }
                        
            try? await CorbadoConnectAPI.connectEventCreate(
                connectEventCreateReq: req,
                apiConfiguration: self.apiConfig
            )
        } catch {
            // recording must never fail the main flow
        }
    }
    
    func copyWith(interceptor: OpenAPIInterceptor? = nil, processId: String? = nil, timeoutInterval: TimeInterval? = nil) -> CorbadoClient {
        let apiConfig = self.apiConfig
        
        if let interceptor = interceptor {
            apiConfig.interceptor = interceptor
        }
        
        if let processId = processId {
            apiConfig.customHeaders["x-corbado-process-id"] = processId
        }
        
        if let timeoutInterval = timeoutInterval {
            apiConfig.requestBuilderFactory = TimeoutRequestBuilderFactory(timeoutInterval: timeoutInterval)
        }
        
        return CorbadoClient(apiConfig: apiConfig)
    }
}

public class BlockingOpenAPIInterceptor: OpenAPIInterceptor {
    let urlToBlock: String
    
    public init(urlToBlock: String) {
        self.urlToBlock = urlToBlock
    }
    
    public func intercept<T>(urlRequest: URLRequest, urlSession: URLSessionProtocol, requestBuilder: RequestBuilder<T>, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        guard let url = urlRequest.url, urlToBlock.count > 0 else {
            completion(.success(urlRequest))
            return
        }
        
        if url.absoluteString.contains(urlToBlock) {
            completion(.failure(ErrorResponse.error(504, nil, nil, NSError())))
            return
        }
        
        completion(.success(urlRequest))
    }
    
    public func retry<T>(urlRequest: URLRequest, urlSession: URLSessionProtocol, requestBuilder: RequestBuilder<T>, data: Data?, response: URLResponse?, error: Error, completion: @escaping (OpenAPIInterceptorRetry) -> Void) {
        completion(OpenAPIInterceptorRetry.dontRetry)
    }
}

extension ErrorResponse {
    var statusCode: Int? {
        if case let .error(code, _, _, _) = self { return code }
        return nil
    }
    var data: Data? {
        if case let .error(_, data, _, _) = self { return data }
        return nil
    }
    var urlResponse: URLResponse? {
        if case let .error(_, _, response, _) = self { return response }
        return nil
    }
    var underlyingError: Error? {
        if case let .error(_, _, _, error) = self { return error }
        return nil
    }
} 
