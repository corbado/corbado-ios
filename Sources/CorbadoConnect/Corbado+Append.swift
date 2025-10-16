//
//  Corbado+Append.swift
//  CorbadoConnect
//
//  Created by Martin on 30/4/2025.
//

import Foundation
import SimpleAuthenticationServices
import OpenAPIClient

public extension Corbado {
    // append -------------------------
    /// Checks if the user is allowed to append a new passkey to their account.
    ///
    /// This is typically called after a user has successfully logged in and you want to offer them the option to add a passkey.
    /// - Parameter connectTokenProvider: A closure that provides a fresh short-session cookie (as a connect token) from your backend.
    /// - Returns: A `ConnectAppendStep` indicating whether the user can be asked to append a passkey.
    func isAppendAllowed(connectTokenProvider: (_: ConnectTokenType) async throws -> String, situation: AppendSituationType? = nil) async -> ConnectAppendStep {
        let appendAllowed = await appendAllowedStep1(situation: situation?.rawValue)
        if !appendAllowed {
            return .skip(developerDetails: "append not allowed by gradual rollout")
        }
        
        do {
            let connectToken = try await connectTokenProvider(ConnectTokenType.PasskeyAppend)
            
            let resStart = try await client.appendStart(situation: situation?.rawValue, connectToken: connectToken, forcePasskeyAppend: false, loadedMs: 0)
            if resStart.attestationOptions.count == 0 {
                return .skip(developerDetails: "append not allowed by passkey intel")
            }
            
            self.process = process?.copyWith(attestationOptions: resStart.attestationOptions)
            
            // for now, we only support default
            return .askUserForAppend(resStart.autoAppend, appendType: .defaultAppend, resStart.conditionalAppend, customData: resStart.customData)
        } catch let errorMessage as ErrorResponse {
            let message = errorMessage.serializeToString()
            await client.recordAppendEvent(
                event: .appendErrorUnexpected(message),
                situation: .cboApiNotAvailablePreAuthenticator
            )
            
            return .skip(developerDetails: message)
        } catch {
            let message = error.localizedDescription
            await client.recordAppendEvent(
                event: .appendErrorUnexpected(message),
                situation: .ctApiNotAvailablePreAuthenticator
            )
            
            return .skip(developerDetails: message)
        }
    }
    
    /// Completes the process of appending a new passkey.
    ///
    /// This should be called after `isAppendAllowed` has returned `.askUserForAppend` and the user has confirmed they want to create a passkey.
    /// - Returns: A `ConnectAppendStatus` indicating the result of the append operation.
    @MainActor
    func completeAppend(completionType: AppendCompletionType = .Manual, customData: [String: String]? = nil) async -> ConnectAppendStatus {
        guard #available(iOS 16.0, *) else {
            return .error(developerDetails: "passkey append requires at least iOS 16")
        }
        
        guard let attestationOptions = await process?.attestationOptions else {
            return .error(developerDetails: "attestation options are missing or empty")
        }
        
        do {
            let rspAuthenticate = try await passkeysPlugin.create(attestationOptions: attestationOptions, completionType: completionType)
            
            let resFinish = try await client.appendFinish(attestationResponse: rspAuthenticate, completionType: completionType, customData: customData)
            
            if let lastLogin = LastLogin.from(passkeyOperation: resFinish.passkeyOperation) {
                await self.clientStateService.setLastLogin(lastLogin: lastLogin)
            }
            
            var passkeyDetails: PasskeyDetails? = nil
            if let aaguidDetails = resFinish.passkeyOperation.aaguidDetails {
                passkeyDetails = PasskeyDetails(aaguidName: aaguidDetails.name, iconLight: aaguidDetails.iconLight, iconDark: aaguidDetails.iconDark)
            }
            
            return .completed(passkeyDetails: passkeyDetails)
        } catch let error as AuthorizationError {
            switch error.type {
            case .cancelled:
                await client.recordAppendEvent(
                    event: .appendError(error.localizedDescription),
                    situation: .clientPasskeyOperationCancelled
                )
                
                return .cancelled
            case .excludeCredentialsMatch:
                await client.recordAppendEvent(
                    event: .appendCredentialExists(error.localizedDescription),
                    situation: .clientExcludeCredentialsMatch
                )
                
                return .excludeCredentialsMatch
            default:
                let message = error.localizedDescription
                await client.recordAppendEvent(
                    event: .appendErrorUnexpected(message),
                    situation: .cboApiNotAvailablePostAuthenticator
                )
                
                return .error(developerDetails: message)
            }
        } catch let errorMessage as ErrorResponse {
            let message = errorMessage.serializeToString()
            await client.recordAppendEvent(
                event: .appendErrorUnexpected(message),
                situation: .cboApiNotAvailablePostAuthenticator
            )
            
            return .error(developerDetails: message)
        } catch {
            let message = error.localizedDescription
            await client.recordAppendEvent(
                event: .appendErrorUnexpected(message),
                situation: .cboApiNotAvailablePostAuthenticator
            )

            return .error(developerDetails: message)
        }
    }
    
    func appendRecordExplicitAbortEvent() async {
        await client.recordAppendEvent(event: .appendExplicitAbort)
    }
    
    func appendRecordLearnMoreEvent() async {
        await client.recordAppendEvent(event: .appendLearnMore)
    }
    
    internal func appendAllowedStep1(situation: String?) async -> Bool {
        do {
            let clientInfo = await buildClientInfo()
            let invitationToken = await clientStateService.getInvitationToken()?.data
            let res = try await client.appendInit(clientInfo: clientInfo, invitationToken: invitationToken)
            if let clientEnvHandle = res.newClientEnvHandle {
                await clientStateService.setClientEnvHandle(clientEnvHandle: clientEnvHandle)
            }
            
            let appendData = ConnectAppendInitData(
                appendAllowed: res.appendAllowed,
                expiresAt: TimeInterval(res.expiresAt)
            )
            
            if let process = process, process.id == res.processID {
                self.process = process.copyWith(appendData: appendData)
            } else {
                process = ConnectProcess(
                    id: res.processID,
                    frontendApiUrl: res.frontendApiUrl,
                    appendData: appendData
                )
                
                self.client = self.client.copyWith(processId: process?.id)
            }
            
            return appendData.appendAllowed
        } catch {
            Task {
                await client.recordAppendEvent(event: .appendErrorUnexpected(error.serializeToString()))
            }
            
            return false
        }
    }
}

