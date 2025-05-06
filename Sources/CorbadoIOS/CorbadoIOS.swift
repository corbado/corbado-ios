import Foundation
import OpenAPIClient
import AuthenticationServices

public class CorbadoIOS {
    private var projectId: String
    private var frontendApiUrlSuffix: String
    private var isDebug: Bool
    private var apiConfig: OpenAPIClientAPIConfiguration
    private var clientStateService: ClientStateService
    
    private var process: ConnectProcess?
    private var loginInitCompleted: Date?
    
    public init(projectId: String, frontendApiUrlSuffix: String?, isDebug: Bool?) {
        self.projectId = projectId;
        self.frontendApiUrlSuffix = frontendApiUrlSuffix ?? "frontendapi.cloud.corbado.io"
        self.isDebug = isDebug ?? false
        
        let apiConfig = OpenAPIClientAPIConfiguration.shared
        apiConfig.basePath = "https://\(self.projectId).\(self.frontendApiUrlSuffix)"
        apiConfig.interceptor = CustomOpenAPIInterceptor()
        apiConfig.customHeaders["X-Corbado-Force-Debug"] = "dummy"
        self.apiConfig = apiConfig
        
        self.clientStateService = ClientStateService()
    }
    
    public func isLoginAllowed() async -> ConnectLoginStep {
        let maybeValidLoginData = process?.validLoginData()
        if maybeValidLoginData != nil {
            apiConfig.customHeaders["x-corbado-process-id"] = process!.id
            return getConnectLoginStepLoginInit(loginAllowed: maybeValidLoginData!.loginAllowed)
        }
        
        do {
            let res = try await loginInit()
            
            // TODO: clientEnvHandle, flags
            let loginData = ConnectLoginInitData(loginAllowed: res.loginAllowed, conditionalUIChallenge: res.conditionalUIChallenge, expiresAt: TimeInterval(res.expiresAt))
            process = ConnectProcess(id: res.token, frontendApiUrl: res.frontendApiUrl, loginData: loginData)
            apiConfig.customHeaders["x-corbado-process-id"] = process!.id
            
            return getConnectLoginStepLoginInit(loginAllowed: loginData.loginAllowed)
        } catch {
            return .InitFallback()
        }
    }
    
    @MainActor
    public func loginWithTextField(identifier: String) async -> ConnectLoginStep {
        var loadedMs: Int64 = 0
        if loginInitCompleted != nil {
            loadedMs = Int64(loginInitCompleted!.timeIntervalSince1970)
        }
        
        // TODO: track ClientStateMeta
        do {
            let reqStart = ConnectLoginStartReq(identifier: identifier, source: .textField, loadedMs: loadedMs)
            let rspStart = try await CorbadoConnectAPI.connectLoginStart(connectLoginStartReq: reqStart, apiConfiguration: self.apiConfig)
            
            let plugin = PasskeysPlugin()
            let rspAuthenticate = try await plugin.authenticate(assertionOptions: rspStart.assertionOptions, conditionalUI: false, preferImmediatelyAvailableCredentials: false)
            
            let reqFinish = ConnectLoginFinishReq(isConditionalUI: false, assertionResponse: rspAuthenticate)
            let rspFinish = try await CorbadoConnectAPI.connectLoginFinish(connectLoginFinishReq: reqFinish, apiConfiguration: self.apiConfig)
            
            return .Done(rspFinish.signedPasskeyData)
        } catch let e as ErrorResponse {
            return .InitFallback(identifier, "ErrorResponse")
        } catch let e as LoginError {
            return .InitFallback(identifier, "LoginError")
        } catch let error as Error {
            return .InitFallback(identifier, "Error")
        }
    }
    
    private func getConnectLoginStepLoginInit(loginAllowed: Bool) -> ConnectLoginStep {
        loginInitCompleted = Date()
        
        if !loginAllowed {
            return .InitFallback()
        }
        
        let lastLogin = clientStateService.getLastLogin(projectId: projectId)
        if lastLogin != nil && lastLogin?.data != nil {
            return .InitOneTap(lastLogin!.data!.identifierValue)
        }
        
        // TODO: offer CUI here?
        return .InitTextField()
    }
    
    private func loginInit() async throws(ErrorResponse) -> ConnectLoginInitRsp {
        let clientInfo = ClientInformation(
            bluetoothAvailable: true,
            clientEnvHandle: "",
            canUsePasskeys: true,
            isUserVerifyingPlatformAuthenticatorAvailable:true,
            isConditionalMediationAvailable: true,
            isNative: true
        )
        let req = ConnectLoginInitReq(clientInformation: clientInfo, flags: [:], invitationToken: "inv-token-correct")
        let rsp = try await CorbadoConnectAPI.connectLoginInit(connectLoginInitReq: req, apiConfiguration: self.apiConfig)
        return rsp
    }
}

public class CustomOpenAPIInterceptor: OpenAPIInterceptor {
    public init() {}
    
    public func intercept<T>(urlRequest: URLRequest, urlSession: URLSessionProtocol, requestBuilder: RequestBuilder<T>, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        completion(.success(urlRequest))
    }
    
    public func retry<T>(
        urlRequest: URLRequest,
        urlSession: URLSessionProtocol,
        requestBuilder: RequestBuilder<T>,
        data: Data?,
        response: URLResponse?,
        error: any Error,
        completion: @escaping (OpenAPIInterceptorRetry) -> Void
    ) {
        print("⬇️ Received Error Response or Network Error:")
        print("   For Request URL: \(urlRequest.url?.absoluteString ?? "N/A")")
        print("   Error: \(error.localizedDescription)")

        if let httpResponse = response as? HTTPURLResponse {
            print("   Status Code: \(httpResponse.statusCode)")
            print("   Headers: \(httpResponse.allHeaderFields)")
        }

        if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
            print("   Response Body (if any): \(responseString)")
        } else if data != nil {
            print("   Response Body (if any): Non-UTF8 data, length \(data!.count) bytes")
        }


        // For logging purposes, we usually don't want to retry unless there's a specific strategy.
        // If you just want to log, always call .dontRetry (or .dontRetryWithError if you transform the error)
        completion(.dontRetry)
    }
}
