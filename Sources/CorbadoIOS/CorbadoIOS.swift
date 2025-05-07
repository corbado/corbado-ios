import Foundation
import OpenAPIClient
import AuthenticationServices
import Factory

@MainActor
final public class CorbadoIOS {
    private var projectId: String = ""
    private var frontendApiUrlSuffix: String = ""
    private var isDebug: Bool = false
    private var apiConfig: OpenAPIClientAPIConfiguration = OpenAPIClientAPIConfiguration.shared
    private var clientStateService: ClientStateService?
    private var configured = false
    
    private var process: ConnectProcess?
    private var loginInitCompleted: Date?
    private var appendInitLoaded: Date?
        
    public static let shared = Container.shared.corbado()
    
    nonisolated init() {}
    
    public func configure(
        projectId: String,
        frontendApiUrlSuffix: String?,
        isDebug: Bool?
    ) {
        self.projectId = projectId;
        self.frontendApiUrlSuffix = frontendApiUrlSuffix ?? "frontendapi.cloud.corbado.io"
        self.isDebug = isDebug ?? false
        
        apiConfig.basePath = "https://\(self.projectId).\(self.frontendApiUrlSuffix)"
        apiConfig.customHeaders["X-Corbado-Force-Debug"] = "dummy"
        
        clientStateService = ClientStateService(projectId: projectId)
        
        configured = true
    }
    
    public func isLoginAllowed() async -> ConnectLoginStep {
        let maybeValidLoginData = process?.validLoginData()
        if maybeValidLoginData != nil {
            apiConfig.customHeaders["x-corbado-process-id"] = process!.id
            return getConnectLoginStepLoginInit(
                loginAllowed: maybeValidLoginData!.loginAllowed
            )
        }
        
        do {
            let res = try await loginInit()
            
            // TODO: clientEnvHandle, flags
            let loginData = ConnectLoginInitData(
                loginAllowed: res.loginAllowed,
                conditionalUIChallenge: res.conditionalUIChallenge,
                expiresAt: TimeInterval(res.expiresAt)
            )
            process = ConnectProcess(
                id: res.token,
                frontendApiUrl: res.frontendApiUrl,
                loginData: loginData
            )
            apiConfig.customHeaders["x-corbado-process-id"] = process!.id
            
            return getConnectLoginStepLoginInit(
                loginAllowed: loginData.loginAllowed
            )
        } catch {
            return .InitFallback()
        }
    }
    
    public func isAppendAllowed(connectTokenProvider: () async throws -> String) async -> ConnectAppendStep {
        let appendAllowed = await appendAllowedStep1()
        if !appendAllowed {
            return .Skip
        }
        
        do {
            let connectToken = try await connectTokenProvider()
            let resStart = try await appendStart(connectToken: connectToken)
            
            if resStart.attestationOptions.count == 0 {
                return .Skip
            }
            
            process?.appendData?.attestationOptions = resStart.attestationOptions
            
            // for now, we only support default
            return .AskUserForAppend(resStart.autoAppend, .Default)
        } catch {
            return .Skip
        }
    }
    
    public func completeAppend() async -> ConnectAppendStatus {
        guard let attestationOptions = process?.appendData?.attestationOptions else {
            return .Error
        }
        
        do {
            let plugin = PasskeysPlugin()
            let rspAuthenticate = try await plugin.create(attestationOptions: attestationOptions)

            let resFinish = try await appendFinish(attestationResponse: rspAuthenticate)
            
            let lastLogin = LastLogin.from(passkeyOperation: resFinish.passkeyOperation)
            if lastLogin != nil {
                self.clientStateService!.setLastLogin(lastLogin: lastLogin!)
            }
            
            return .Completed
        } catch {
            return .Error
        }
    }
    
    public func loginWithOneTap() async -> ConnectLoginStep {
        // get oneTap data from process
        let lastLogin = clientStateService!.getLastLogin()
        guard let lastLoginData = lastLogin?.data else {
            print("you can only use loginWithOneTap when isLoginAllowed has returned .InitOneTap")
            return .InitFallback(nil, "unexpected")
        }
        
        return await loginWithIdentifier(identifier: lastLoginData.identifierValue)
    }

    public func loginWithTextField(identifier: String) async -> ConnectLoginStep {
        return await loginWithIdentifier(identifier: identifier)
    }
    
    private func loginWithIdentifier(identifier: String) async -> ConnectLoginStep {
        var loadedMs: Int64 = 0
        if loginInitCompleted != nil {
            loadedMs = Int64(loginInitCompleted!.timeIntervalSince1970)
        }
        
        // TODO: track ClientStateMeta
        do {
            let reqStart = ConnectLoginStartReq(
                identifier: identifier,
                source: .textField,
                loadedMs: loadedMs
            )
            let rspStart = try await CorbadoConnectAPI.connectLoginStart(
                connectLoginStartReq: reqStart,
                apiConfiguration: self.apiConfig
            )
            
            let plugin = PasskeysPlugin()
            let rspAuthenticate = try await plugin.authenticate(
                assertionOptions: rspStart.assertionOptions,
                conditionalUI: false,
                preferImmediatelyAvailableCredentials: false
            )
            
            let reqFinish = ConnectLoginFinishReq(
                isConditionalUI: false,
                assertionResponse: rspAuthenticate
            )
            let rspFinish = try await CorbadoConnectAPI.connectLoginFinish(
                connectLoginFinishReq: reqFinish,
                apiConfiguration: self.apiConfig
            )
            
            let lastLogin = LastLogin.from(passkeyOperation: rspFinish.passkeyOperation)
            if lastLogin != nil {
                self.clientStateService!.setLastLogin(lastLogin: lastLogin!)
            }
            
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
        
        let lastLogin = clientStateService!.getLastLogin()
        if lastLogin != nil && lastLogin?.data != nil {
            return .InitOneTap(lastLogin!.data!.identifierValue)
        }
        
        // TODO: offer CUI here?
        return .InitTextField()
    }
    
    private func appendAllowedStep1() async -> Bool {
        appendInitLoaded = Date()
        
        /*
        let maybeValidAppendData = process?.validAppendData()
        if maybeValidAppendData != nil {
            apiConfig.customHeaders["x-corbado-process-id"] = process!.id
            return maybeValidAppendData!.appendAllowed
        }
        */
                    
        do {
            let res = try await appendInit()
            
            // TODO: clientEnvHandle, flags
            let appendData = ConnectAppendInitData(
                appendAllowed: res.appendAllowed,
                expiresAt: TimeInterval(res.expiresAt)
            )
            
            if process != nil && process?.id == res.processID {
                process?.appendData = appendData
            } else {
                process = ConnectProcess(
                    id: res.processID,
                    frontendApiUrl: res.frontendApiUrl,
                    appendData: appendData
                )
                
                apiConfig.customHeaders["x-corbado-process-id"] = process!.id
            }
            
            return appendData.appendAllowed
        } catch {
            return false
        }
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
        
        let req = ConnectLoginInitReq(
            clientInformation: clientInfo,
            flags: [:],
            invitationToken: "inv-token-correct"
        )
        
        return try await CorbadoConnectAPI.connectLoginInit(
            connectLoginInitReq: req,
            apiConfiguration: self.apiConfig
        )
    }
    
    private func appendInit() async throws(ErrorResponse) -> ConnectAppendInitRsp {
        let clientInfo = ClientInformation(
            bluetoothAvailable: true,
            clientEnvHandle: "",
            canUsePasskeys: true,
            isUserVerifyingPlatformAuthenticatorAvailable:true,
            isConditionalMediationAvailable: true,
            isNative: true
        )

        let req = ConnectAppendInitReq(clientInformation: clientInfo, flags: [:])
        
        return try await CorbadoConnectAPI.connectAppendInit(
            connectAppendInitReq: req,
            apiConfiguration: self.apiConfig
        )
    }
    
    private func appendStart(connectToken: String) async throws(ErrorResponse) -> ConnectAppendStartRsp {
        var loadedMs: Int64 = 0
        if appendInitLoaded != nil {
            loadedMs = Int64(appendInitLoaded!.timeIntervalSince1970)
        }

        let req = ConnectAppendStartReq(appendTokenValue: connectToken, loadedMs: loadedMs)
        
        return try await CorbadoConnectAPI.connectAppendStart(connectAppendStartReq: req, apiConfiguration: self.apiConfig)
    }
    
    private func appendFinish(attestationResponse: String) async throws(ErrorResponse) -> ConnectAppendFinishRsp {
        let req = ConnectAppendFinishReq(attestationResponse: attestationResponse)
        
        return try await CorbadoConnectAPI.connectAppendFinish(connectAppendFinishReq: req, apiConfiguration: self.apiConfig)
    }
}

extension Container {
    var corbado: Factory<CorbadoIOS> {
        self { CorbadoIOS() }.singleton
    }
}
