//
//  Corbado+Manage.swift
//  CorbadoConnect
//
//  Created by Martin on 30/4/2025.
//

import Foundation
import SimpleAuthenticationServices
import OpenAPIClient

public extension Corbado {
    // manage -------------------------
    /// Checks if a new passkey can be added from a passkey list view.
    ///
    /// This is useful for determining if a "Add new passkey" button should be displayed on a settings or profile screen.
    func isManageAppendAllowed(connectTokenProvider: @Sendable (_: ConnectTokenType) async throws -> String) async -> ConnectManageStep {
        do {
            let allowed = try await manageAllowedStep()
            let passkeys = try await getPasskeys(connectTokenProvider: connectTokenProvider, mode: .Default)
            return allowed ? .allowed(passkeys: passkeys) : .notAllowed(passkeys: passkeys)
        } catch let errorMessage as ErrorResponse {
            let message = errorMessage.serializeToString()
            await client.recordManageEvent(
                event: .manageErrorUnexpected(message),
                situation: .cboApiNotAvailableDuringInitialLoad
            )
            
            return .error(developerDetails: message)
        } catch {
            let message = error.localizedDescription
            await client.recordManageEvent(
                event: .manageErrorUnexpected(message),
                situation: .ctApiNotAvailableDuringInitialLoad
            )
            
            return .error(developerDetails: message)
        }
    }
    
    /// Completes appending a new passkey from a passkey list view.
    ///
    /// This triggers the full passkey creation ceremony.
    /// - Parameter connectTokenProvider: A closure that provides a fresh short-session cookie (as a connect token) from your backend.
    /// - Returns: A `ConnectManageStatus` indicating the result of the append operation.
    @MainActor
    func completePasskeyListAppend(connectTokenProvider: @Sendable (_: ConnectTokenType) async throws -> String) async -> ConnectManageStatus {
        guard #available(iOS 16.0, *) else {
            return .error(developerDetails: "passkey append requires at least iOS 16")
        }
        
        let attestationOptions: String
        do {
            let connectToken = try await connectTokenProvider(ConnectTokenType.PasskeyAppend)
            let resStart = try await client.appendStart(situation: "passkey-list", connectToken: connectToken, forcePasskeyAppend: true, loadedMs: 0)
            
            attestationOptions = resStart.attestationOptions
        } catch let errorResponse as ErrorResponse {
            let message = errorResponse.serializeToString()
            await client.recordManageEvent(
                event: .manageErrorUnexpected(message),
                situation: .cboApiNotAvailablePreAuthenticator
            )
            
            return .error(developerDetails: message)
        } catch let error {
            let message = error.localizedDescription
            await client.recordManageEvent(
                event: .manageErrorUnexpected(message),
                situation: .ctApiNotAvailablePreAuthenticator
            )
            
            return .error(developerDetails: message)
        }
         
        do {
            let rspAuthenticate = try await passkeysPlugin.create(attestationOptions: attestationOptions, completionType: .Manual)
            let resFinish = try await client.appendFinish(attestationResponse: rspAuthenticate, completionType: .Manual)
            
            if let lastLogin = LastLogin.from(passkeyOperation: resFinish.passkeyOperation) {
                await self.clientStateService.setLastLogin(lastLogin: lastLogin)
            }
            
            let passkeys = try await getPasskeys(connectTokenProvider: connectTokenProvider, mode: .PostAppend)
            return .done(passkeys: passkeys)
        } catch let error as AuthorizationError {
            switch error.type {
            case .cancelled:
                await client.recordAppendEvent(
                    event: .appendError(error.localizedDescription),
                    situation: .clientPasskeyOperationCancelled
                )
                
                return .passkeyOperationCancelled
            case .excludeCredentialsMatch:
                await client.recordAppendEvent(
                    event: .appendCredentialExists(error.localizedDescription),
                    situation: .clientExcludeCredentialsMatch
                )
                
                return .passkeyOperationExcludeCredentialsMatch
                
            default:
                await client.recordAppendEvent(
                    event: .appendErrorUnexpected(error.localizedDescription),
                    situation: .cboApiNotAvailablePostAuthenticator
                )
                
                return .error(developerDetails: error.localizedDescription)
            }
        }  catch let errorResponse as ErrorResponse {
            let message = errorResponse.serializeToString()
            await client.recordManageEvent(
                event: .manageErrorUnexpected(message),
                situation: .cboApiNotAvailablePostAuthenticator
            )
            
            return .error(developerDetails: message)
        } catch let error {
            let message = error.localizedDescription
            await client.recordManageEvent(
                event: .manageErrorUnexpected(message),
                situation: .cboApiNotAvailablePostAuthenticator
            )
            
            return .error(developerDetails: message)
        }
    }
    
    /// Deletes a passkey from the user's account.
    /// - Parameters:
    ///   - connectTokenProvider: A closure that provides a fresh short-session cookie (as a connect token) from your backend.
    ///   - passkeyId: The ID of the passkey to be deleted.
    /// - Returns: A `ManageDeleteStatus` indicating the result of the deletion.
    func deletePasskey(connectTokenProvider: @Sendable (_: ConnectTokenType) async throws -> String, passkeyId: String) async -> ConnectManageStatus {
        do {
            let connectToken = try await connectTokenProvider(ConnectTokenType.PasskeyDelete)
            let res = try await client.manageDelete(connectToken: connectToken, passkeyId: passkeyId)
            await clientStateService.clearLastLogin()
            let passkeys = try await getPasskeys(connectTokenProvider: connectTokenProvider, mode: .PostDelete)
                
            return .done(passkeys: passkeys)
        }  catch let errorResponse as ErrorResponse {
            let message = errorResponse.serializeToString()
            await client.recordManageEvent(
                event: .manageErrorUnexpected(message),
                situation: .cboApiNotAvailableDuringDelete
            )
            
            return .error(developerDetails: message)
        } catch let error {
            let message = error.localizedDescription
            await client.recordManageEvent(
                event: .manageErrorUnexpected(message),
                situation: .ctApiNotAvailablePreDelete
            )
            
            return .error(developerDetails: message)
        }
    }
    
    func manageRecordLearnMoreEvent() async {
        await client.recordManageEvent(event: .manageLearnMore)
    }
    
    internal func manageAllowedStep() async throws(ErrorResponse) -> Bool {
        let clientInfo = await buildClientInfo()
        let invitationToken = await clientStateService.getInvitationToken()?.data
        let res = try await client.manageInit(clientInfo: clientInfo, invitationToken: invitationToken)
        if let clientEnvHandle = res.newClientEnvHandle {
            await clientStateService.setClientEnvHandle(clientEnvHandle: clientEnvHandle)
        }
        
        let manageData = ConnectManageInitData(
            manageAllowed: res.manageAllowed,
            flags: [:],
            expiresAt: TimeInterval(res.expiresAt)
        )
        
        
        if let process = process, process.id == res.processID {
            self.process = process.copyWith(manageData: manageData)
        } else {
            process = ConnectProcess(
                id: res.processID,
                frontendApiUrl: res.frontendApiUrl,
                manageData: manageData
            )
            
            self.client = self.client.copyWith(processId: process?.id)
        }
        
        return manageData.manageAllowed
    }
    
    /// Retrieves the list of passkeys for the current user.
    /// - Parameter connectTokenProvider: A closure that provides a fresh short-session cookie (as a connect token) from your backend.
    /// - Returns: A `ManageListStatus` containing either the list of passkeys or an error.
    internal func getPasskeys(connectTokenProvider: @Sendable (_: ConnectTokenType) async throws -> String, mode: PasskeyListMode) async throws -> [Passkey] {
        let connectToken = try await connectTokenProvider(ConnectTokenType.PasskeyList)
        let (passkeys, rpID, userHandle, signalAllAcceptedCredentials) = try await client.manageList(connectToken: connectToken, mode: mode)
        if signalAllAcceptedCredentials {
            let acceptedCredentialIDs = passkeys.map { passkey in
                return passkey.credentialID
            }
                        
            try await passkeysPlugin.signalAllAcceptedCredentials(rpID: rpID, userHandle: userHandle, acceptedCredentialIDs: acceptedCredentialIDs)
        }
        
        return passkeys
    }
}
