//
//  Corbado+Login.swift
//  CorbadoConnect
//
//  Created by Martin on 30/4/2025.
//

import Foundation
import SimpleAuthenticationServices
import OpenAPIClient

public extension Corbado {
    // login --------------------------
    /// Determines the next step for the login process (e.g., one-tap, text field, or fallback).
    ///
    /// This method communicates with the Corbado backend to check if login is allowed and what the next step should be (e.g., show a text field, offer one-tap, or use conditional UI).
    /// - Returns: A `ConnectLoginStep` indicating the next action to take.
    func isLoginAllowed() async -> ConnectLoginStep {
        do {
            let clientInfo = await buildClientInfo()
            let invitationToken = await clientStateService.getInvitationToken()
            let res = try await client.loginInit(clientInfo: clientInfo, invitationToken: invitationToken?.data)
            if let clientEnvHandle = res.newClientEnvHandle {
                await clientStateService.setClientEnvHandle(clientEnvHandle: clientEnvHandle)
            }
            
            let loginData = ConnectLoginInitData(
                loginAllowed: res.loginAllowed,
                conditionalUIChallenge: res.conditionalUIChallenge,
                expiresAt: TimeInterval(res.expiresAt)
            )
            
            if let process = process, process.id == res.token {
                self.process = process.copyWith(loginData: loginData)
            } else {
                process = ConnectProcess(
                    id: res.token,
                    frontendApiUrl: res.frontendApiUrl,
                    loginData: loginData
                )
                
                self.client = self.client.copyWith(processId: process?.id)
            }
            
            self.client = self.client.copyWith(processId: process?.id)
            
            return await getConnectLoginStepLoginInit(loginData: loginData)
        } catch {
            return .initFallback()
        }
    }
    
    /// Clears the last login info, preventing one-tap login from being offered.
    func clearOneTap() async {
        Task {
            await client.recordLoginEvent(event: .loginOneTapSwitch)
        }
        
        await clientStateService.clearLastLogin()
    }
    
    /// Attempts to log in the user with a single tap using a stored passkey.
    ///
    /// This should only be called when `isLoginAllowed()` has returned `.initOneTap`.
    /// - Returns: A `ConnectLoginStatus` indicating the result of the login attempt.
    @MainActor
    func loginWithOneTap() async -> ConnectLoginWithIdentifierStatus {
        let lastLogin = await clientStateService.getLastLogin()
        guard let lastLoginData = lastLogin?.data else {
            return .error(error: .InvalidStateError, triggerFallback: true, developerDetails: "One-tap login requested but no last login found.")
        }
        
        return await loginWithIdentifier(identifier: lastLoginData.identifierValue)
    }
    
    /// Initiates a passkey login for the given user identifier (e.g., email or username).
    /// - Parameter identifier: The user's identifier (e.g., email or username).
    /// - Returns: A `ConnectLoginStatus` indicating the result of the login attempt.
    @MainActor
    func loginWithTextField(identifier: String) async -> ConnectLoginWithIdentifierStatus {
        return await loginWithIdentifier(identifier: identifier)
    }
    
    /// Initiates a passkey login without a user identifier, typically for Conditional UI.
    /// - Parameters:
    ///   - cuiChallenge: The conditional UI challenge received from the backend.
    ///   - conditionalUI: A boolean indicating whether to use conditional UI.
    ///   - preferImmediatelyAvailableCredentials: A boolean indicating whether to prefer immediately available credentials.
    ///   - onStart: A closure that is called when the passkey authentication process starts.
    /// - Returns: A `ConnectLoginStatus` indicating the result of the login attempt.
    @MainActor
    func loginWithoutIdentifier(
        cuiChallenge: String,
        conditionalUI: Bool = true,
        preferImmediatelyAvailableCredentials: Bool = true,
        onStart: () async -> Void = {}
    ) async -> ConnectLoginWithoutIdentifierStatus {
        guard #available(iOS 16.0, *) else {
            return .initSilentFallback(username: nil, developerDetails: "passkey login requires at least iOS 16")
        }
        
        let rspAuthenticate: String
        do {
            rspAuthenticate = try await passkeysPlugin.authenticate(
                assertionOptions: cuiChallenge,
                conditionalUI: conditionalUI,
                preferImmediatelyAvailableCredentials: preferImmediatelyAvailableCredentials
            )
            await onStart()
        } catch {
            switch error.type {
            case .cancelled:
                await client.recordLoginEvent(
                    event: .loginError(error.originalError?.localizedDescription ?? "-"),
                    situation: .clientPasskeyConditionalOperationCancelled
                )
                
                return .ignore(developerDetails: "User cancelled the operation.")
            case .noCredentialsAvailable:
                await client.recordLoginEvent(
                    event: .loginNoCredentials,
                    situation: .clientPasskeyConditionalOperationCancelled
                )
                
                return .ignore(developerDetails: "No local credentials available for login.")
            default:
                await client.recordLoginEvent(
                    event: .loginErrorUnexpected(error.originalError?.localizedDescription ?? "-"),
                    situation: .cboApiNotAvailablePostConditionalAuthenticator
                )
                
                return .error(error: .UnHandledError, triggerFallback: true, developerDetails: "An unhandled error occurred. Please report this as a GitHub issue \(error.localizedDescription)")
            }
        }
            
        
        do {
            let rspFinish = try await client.loginFinish(assertionResponse: rspAuthenticate, isConditionalUI: true)
            if let error = rspFinish.fallbackOperationError, let handled = Corbado.handleFallbackOperationErrorForLoginWithoutIdentifier(error) {
                return handled
            }
            
            guard let passkeyOperation = rspFinish.passkeyOperation else {
                // we don't need tracking for this case (this would be visible in the backend)
                return .error(error: .CorbadoAPIError, triggerFallback: true, developerDetails: "The login finish call did not return a passkey operation. This is unexpected behavior.")
            }
            
            if let lastLogin = LastLogin.from(passkeyOperation: passkeyOperation) {
                await self.clientStateService.setLastLogin(lastLogin: lastLogin)
            }
            
            return .done(rspFinish.signedPasskeyData, passkeyOperation.identifierValue)
        } catch {
            let details = error.serializeToString()
            await client.recordLoginEvent(
                event: .loginErrorUnexpected(details),
                situation: .cboApiNotAvailablePostConditionalAuthenticator
            )
            
            return .error(error: .UnHandledError, triggerFallback: true, developerDetails: details)
        }
    }
    
    public func loginRecordExplicitAbort() async {
        await client.recordLoginEvent(event: .loginExplicitAbort)
    }
    
    // helpers ----------------------
    @MainActor
    internal func loginWithIdentifier(identifier: String, preferImmediatelyAvailableCredentials: Bool? = nil) async -> ConnectLoginWithIdentifierStatus {
        guard #available(iOS 16.0, *) else {
            return .initSilentFallback(username: identifier, developerDetails: "passkey login requires at least iOS 16")
        }
                
        let (assertionOptions, effectivePreferImmediatelyAvailableCredentials): (String, Bool)
        do {
            let rspStart = try await client.loginStart(identifier: identifier, source: .textField, loadedMs: 0)
            if let handled = Corbado.handleFallbackOperationErrorForLoginWithIdentifier(rspStart.fallbackOperationError) {
                return handled
            }
            
            assertionOptions = rspStart.assertionOptions
            if let fromPrefs = preferImmediatelyAvailableCredentials {
                effectivePreferImmediatelyAvailableCredentials = fromPrefs
            } else if let fromBackend = rspStart.preferImmediatelyAvailable {
                effectivePreferImmediatelyAvailableCredentials = fromBackend
            } else {
                effectivePreferImmediatelyAvailableCredentials = false
            }
        } catch {
            let details = error.serializeToString()
            await client.recordLoginEvent(
                event: .loginErrorUnexpected(details),
                situation: .cboApiNotAvailablePreAuthenticator
            )
            
            return .initSilentFallback(username: identifier, developerDetails: details)
        }
        
        let rspAuthenticate: String
        do {
            rspAuthenticate = try await passkeysPlugin.authenticate(
                assertionOptions: assertionOptions,
                conditionalUI: false,
                preferImmediatelyAvailableCredentials: effectivePreferImmediatelyAvailableCredentials
            )
        } catch let error as AuthorizationError {
            switch error.type {
            case .cancelled:
                await client.recordLoginEvent(
                    event: .loginError(error.originalError?.localizedDescription ?? "-"),
                    situation: .clientPasskeyOperationCancelled
                )
                
                return .initRetry(developerDetails: "User cancelled the operation. Consider allowing a retry.")
            case .noCredentialsAvailable:
                await client.recordLoginEvent(
                    event: .loginNoCredentials,
                    situation: .clientPasskeyOperationCancelled
                )
                
                return .initSilentFallback(username: identifier, developerDetails: "No local credentials available for login.")
            default:
                await client.recordLoginEvent(
                    event: .loginErrorUnexpected(error.originalError?.localizedDescription ?? "-"),
                    situation: .cboApiNotAvailablePostAuthenticator
                )
                
                return .error(error: .UnHandledError, triggerFallback: true, developerDetails: "An unhandled error occurred. Please report this as a GitHub issue \(error.localizedDescription)")
            }
        }
            
        do {
            let rspFinish = try await client.loginFinish(assertionResponse: rspAuthenticate, isConditionalUI: false)
            if let error = rspFinish.fallbackOperationError, let handled = Corbado.handleFallbackOperationErrorForLoginWithIdentifier(error) {
                return handled
            }
            
            guard let passkeyOperation = rspFinish.passkeyOperation, let lastLogin = LastLogin.from(passkeyOperation: passkeyOperation) else {
                // we don't need tracking for this case (this would be visible in the backend)
                return .error(error: .CorbadoAPIError, triggerFallback: true, developerDetails: "The login finish call did not return a passkey operation. This is unexpected behavior.", username: identifier)
            }
            
            await self.clientStateService.setLastLogin(lastLogin: lastLogin)
            
            return .done(rspFinish.signedPasskeyData, passkeyOperation.identifierValue)
        } catch {
            let details = error.serializeToString()
            await client.recordLoginEvent(
                event: .loginErrorUnexpected(details),
                situation: .cboApiNotAvailablePostAuthenticator
            )
            
            return .error(error: .UnHandledError, triggerFallback: true, developerDetails: details, username: identifier)
        }
    }
    
    internal static func handleFallbackOperationErrorForLoginWithIdentifier(_ fallbackOperationError: FallbackOperationError) -> ConnectLoginWithIdentifierStatus? {
        let error = fallbackOperationError.error
        let identifier = fallbackOperationError.identifier
        
        // The backend did not return a successful response, but it did not return an error code either.
        // We can either react with a silent fallback or an ignore.
        if error == nil {
            return fallbackOperationError.initFallback ? 
                .initSilentFallback(
                    username: identifier,
                    developerDetails: "A post-auth operation error occurred during a login call. A silent fallback is triggered because no error code was provided."
                ) : nil
        }
        
        guard let error = error else { return nil }
        
        switch error.code {
        case "no_cbo_user":
            return .initSilentFallback(
                username: identifier,
                developerDetails: "This user interacts with a passkey component for the very first time. There can't be a passkey yet, so we trigger a silent fallback."
            )
            
        case "user_not_found":
            return .error(
                error: .UserNotFound,
                triggerFallback: false,
                developerDetails: "The user tried to log in with an identifier that does not match any account. The user can correct the identifier in the text field and try again.",
                username: identifier
            )
            
        case "identifier_not_whitelisted":
            return .initSilentFallback(
                username: identifier,
                developerDetails: "The project is currently in gradual rollout phase. The user tried to log in with an identifier that is not whitelisted yet. A silent fallback is triggered."
            )
            
        case "unexpected_error":
            return .error(
                error: .CorbadoAPIError,
                triggerFallback: true,
                developerDetails: "An unexpected error occurred during a login call. This is a generic error that is not handled by the SDK. Please report this as a GitHub issue.",
                username: identifier
            )
            
        default:
            let customError = LoginWithIdentifierError.CustomError(code: error.code, message: error.message)
            let developerDetails = "A login call returned an error that is not handled by the SDK. This is a custom error defined in one of your actions."
            
            return .error(
                error: customError,
                triggerFallback: fallbackOperationError.initFallback,
                developerDetails: developerDetails,
                username: identifier
            )
        }
    }
    
    internal static func handleFallbackOperationErrorForLoginWithoutIdentifier(_ fallbackOperationError: FallbackOperationError) -> ConnectLoginWithoutIdentifierStatus? {
        let error = fallbackOperationError.error
        
        // The backend did not return a successful response, but it did not return an error code either.
        // We can either react with a silent fallback or an ignore.
        if error == nil {
            return fallbackOperationError.initFallback ?
                .initSilentFallback(
                    username: fallbackOperationError.identifier,
                    developerDetails: "A post-auth operation error occurred during a login finish call."
                ) :
                .ignore(
                    developerDetails: "A post-auth operation error occurred during a login finish call."
                )
        }
        
        guard let error = error else { return nil }
        
        switch error.code {
        case "cui_credential_deleted":
            return .error(
                error: .PasskeyDeletedOnServer(message: error.message),
                triggerFallback: true,
                developerDetails: "The user tried to log in with a passkey that was deleted on the server."
            )
            
        case "cui_alternative_project_id":
            // Parse the error message using regex to extract project names
            let regex = try? NSRegularExpression(pattern: "This passkey is linked to a (.+) account. Try again with your (.+) passkeys.", options: [])
            let nsString = error.message as NSString
            let results = regex?.matches(in: error.message, options: [], range: NSRange(location: 0, length: nsString.length))
            
            var wrongProjectName: String? = nil
            var correctProjectName: String? = nil
            
            if let match = results?.first, match.numberOfRanges == 3 {
                wrongProjectName = nsString.substring(with: match.range(at: 1))
                correctProjectName = nsString.substring(with: match.range(at: 2))
            }
            
            return .error(
                error: .ProjectIDMismatch(
                    message: error.message,
                    wrongProjectName: wrongProjectName,
                    correctProjectName: correctProjectName
                ),
                triggerFallback: true,
                developerDetails: "You configured multiple projects with the same RPID. The user tried to log in with a passkey that is associated with a different project ID than the one configured in the SDK."
            )
            
        default:
            let customError = LoginWithoutIdentifierError.CustomError(code: error.code, message: error.message)
            let developerDetails = "The login finish call returned an error that is not handled by the SDK. This is a custom error defined in one of your actions."
            
            return .error(
                error: customError,
                triggerFallback: fallbackOperationError.initFallback,
                developerDetails: developerDetails,
                username: fallbackOperationError.identifier
            )
        }
    }
    
    internal func getConnectLoginStepLoginInit(loginData: ConnectLoginInitData) async -> ConnectLoginStep {
        loginInitCompleted = Date()
        
        if !loginData.loginAllowed {
            return .initFallback()
        }
        
        
        if useOneTap, let lastLoginData = await clientStateService.getLastLogin()?.data {
            return .initOneTap(username: lastLoginData.identifierValue)
        }
        
        return .initTextField(challenge: loginData.conditionalUIChallenge)
    }
} 

extension ErrorResponse {
    func serializeToString() -> String {
        return "request error: \(self.statusCode) \(self.localizedDescription)"
    }
}
