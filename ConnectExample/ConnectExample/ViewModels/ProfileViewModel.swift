//
//  ProfileViewModel.swift
//  ConnectExample
//
//  Created by Martin on 2/5/2025.
//
import SwiftUI
import Amplify
import AWSPluginsCore
import CorbadoConnect
import Factory

struct ConnectTokenError: LocalizedError {
    let message: String
    
    var errorDescription: String? { message }
}

@MainActor
class ProfileViewModel: ObservableObject {
    @Injected(\.corbadoService) private var corbado: Corbado
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var listMessage: String?
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var passkeys: [Passkey] = []
    @Published var passkeyToDelete: Passkey?
    @Published var passkeyAppendAllowed: Bool = false
    
    private var initialized = false
    
    func setupPreview() {
        email = "john.doe@corbado.com"
        phoneNumber = "+4915121609839"
        passkeyAppendAllowed = true
        passkeys = [
            /*
            Passkey(id: "String", credentialID: "String", attestationType: "String", transport: [], backupEligible: true, backupState: true, authenticatorAAGUID: "String", sourceOS: "iOS", sourceBrowser: "io.corbado.example", lastUsed: Date().formatted(), created: Date().formatted(), status: .active, aaguidDetails: AaguidDetails(
                name: "iCloud Keychain",
                iconLight: "String",
                iconDark: "String"
            )),*/
        ]
    }
    
    func fetchUserData() async {
        isLoading = true
        defer {
            isLoading = false
        }
        errorMessage = nil
        passkeys = []
        
        do {
            // fetch Amplify data
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            attributes.forEach { attr in
                switch attr.key {
                case .email:
                    email = attr.value
                case .phoneNumber:
                    phoneNumber = attr.value
                default:
                    break
                }
            }
        } catch {
            errorMessage = "Could not fetch userAttributes: \(error)"
        }
        
        let manageStep = await corbado.isManageAppendAllowed(connectTokenProvider: connectTokenProvider)
        switch manageStep {
            case .allowed(let passkeys):
                self.passkeys = passkeys
                passkeyAppendAllowed = true
            case .notAllowed(let passkeys):
                self.passkeys = passkeys
                passkeyAppendAllowed = false
            case .error(let error):
                errorMessage = "Unable to access passkeys. Check your connection and try again."
        }
        
        if errorMessage != nil {
            listMessage = "We were unable to show your list of passkeys due to an error. Try again later."
        } else if passkeys.isEmpty {
            listMessage = "There is currently no passkey saved for this account."
        } else {
            listMessage = nil
        }
    }
    
    func appendPasskey() async {
        errorMessage = nil
        
        let appendStatus = await corbado.completePasskeyListAppend(connectTokenProvider: connectTokenProvider)
        switch appendStatus {
        case .done(let passkeys):
            self.passkeys = passkeys
        case .passkeyOperationCancelled:
            errorMessage = "Passkey append cancelled."
        case .error(_):
            errorMessage = "Passkey creation failed. Please try again later."
        case .passkeyOperationExcludeCredentialsMatch:
            errorMessage = "You already have a passkey that can be used on this device."
        }
        
        if passkeys.isEmpty {
            listMessage = "There is currently no passkey saved for this account."
        } else {
            listMessage = nil
        }
    }
    
    func getIdToken() async -> String? {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                return tokens.idToken
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    func signOut(appRouter: AppRouter) {
        Task {
            await corbado.clearProcess()
            _ = await Amplify.Auth.signOut()
            appRouter.navigateTo(.login)
        }
    }
    
    @MainActor
    func deletePasskey(passkey: Passkey) async {
        errorMessage = nil
        
        let deleteStatus = await corbado.deletePasskey(connectTokenProvider: connectTokenProvider, passkeyId: passkey.id)
        switch deleteStatus {
        case .done(let passkeys):
            self.passkeys = passkeys
        case .error(let error):
            errorMessage = "Passkey deletion failed. Please try again later."
        default:
            errorMessage = "Unexpected delete passkey status"
        }
        
        if passkeys.isEmpty {
            listMessage = "There is currently no passkey saved for this account."
        } else {
            listMessage = nil
        }
    }
    
    @Sendable
    private func connectTokenProvider(connectTokenType: ConnectTokenType) async throws -> String {
        let idToken = await getIdToken()
        guard let idToken = idToken else {
            throw ConnectTokenError(message: "")
        }
        
        do {
            return try await AppBackend.getConnectToken(connectTokenType: connectTokenType, idToken: idToken)
        } catch {
            throw ConnectTokenError(message: "")
        }
    }
}
