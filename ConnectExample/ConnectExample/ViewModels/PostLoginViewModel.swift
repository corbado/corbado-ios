//
//  PostLoginViewModel.swift
//  ConnectExample
//
//  Created by Martin on 6/5/2025.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore
import CorbadoConnect
import Factory

enum Status {
    case loading
    case passkeyAppend
    case passkeyAppended
}

@MainActor
class PostLoginViewModel: ObservableObject {
    @Injected(\.corbadoService) private var corbado: Corbado
    
    private let appRouter: AppRouter
    private var initialized = false
    
    @Published var state: Status = .loading
    @Published var primaryLoading = false
    @Published var errorMessage: String?
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    func setupPreview() {
        state = .passkeyAppend
        initialized = true
    }
    
    func loadInitialStep() async {
        if initialized {
            return
        }
        
        let nextStep = await corbado.isAppendAllowed { _ in
            return try await getConnectToken()
        }
        
        switch nextStep {
        case .askUserForAppend(let autoAppend, _):
            state = .passkeyAppend
            
            if autoAppend {
                await createPasskey(autoAppend: true)
            }
            
        case .skip:
            await skipPasskeyCreation()
        }
        
        initialized = true
    }
    
    func createPasskey(autoAppend: Bool = false) async {
        primaryLoading = true
        defer {
            primaryLoading = false
        }
        
        
        let rsp = await corbado.completeAppend()
        switch rsp {
        case .completed:
            state = .passkeyAppended
        case .cancelled:
            if !autoAppend {
                errorMessage = "You have cancelled setting up your passkey. Please try again."
            }
            
            // if the append has been initiated automatically, we don't show an error message
        case .excludeCredentialsMatch:
            appRouter.navigateTo(.home)
        case .error:
            appRouter.navigateTo(.home)
        }
    }
    
    func navigateAfterPasskeyAppend() {
        appRouter.navigateTo(.home)
    }
    
    func skipPasskeyCreation() async {
        let hasMFA = await hasMFA()
        if !hasMFA {
            appRouter.navigateTo(.setupTOTP)
        } else {
            appRouter.navigateTo(.home)
        }
    }
    
    private func getConnectToken() async throws -> String {
        let idToken = await AppBackend.getIdToken()
        return try await AppBackend.getConnectToken(connectTokenType: ConnectTokenType.PasskeyAppend, idToken: idToken!)
    }
    
    private func hasMFA() async -> Bool {
        do {
            let authCognitoPlugin = try Amplify.Auth.getPlugin(for: "awsCognitoAuthPlugin") as? AWSCognitoAuthPlugin
            let preference = try await authCognitoPlugin?.fetchMFAPreference()
            return !(preference?.enabled?.isEmpty ?? true)
        } catch {
            return false
        }
    }
}
