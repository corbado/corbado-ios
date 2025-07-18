//
//  LoginViewModel.swift
//  ConnectExample
//
//  Created by Martin on 6/5/2025.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import CorbadoConnect
import Factory

enum LoginStatus {
    case loading
    case fallbackFirst
    case fallbackSecondTOTP
    case fallbackSecondSMS
    case passkeyTextField
    case passkeyOneTap
    case passkeyErrorSoft
    case passkeyErrorHard
}

@MainActor
class LoginViewModel: ObservableObject {
    private let appRouter: AppRouter
    @Injected(\.corbadoService) private var corbado: Corbado
    @Injected(\.uiTestConfiguration) private var uiTestConfig: UITestConfiguration

    @Published var status: LoginStatus = .loading
    @Published var email = ""
    @Published var password = ""
    @Published var primaryLoading = false
    @Published var errorMessage: String? = nil
    
    private var initialized = false
    private var invitationTokenCounter = 0
    private var retryCount = 0
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    func setupPreview(status: LoginStatus, email: String = "") {
        initialized = true
        self.status = status
        self.email = email
    }
    
    func loadInitialStep() async {
        if initialized {
            return
        }
        
        initialized = true
        
        let nextStep = await corbado.isLoginAllowed()
        switch nextStep {
        case .initTextField(let cuiChallenge, _):
            status = .passkeyTextField
            
            // to keep UI tests easier to follow, we only activate overlay for some of them
            if let cuiChallenge = cuiChallenge, uiTestConfig.isOverlayEnabled {
                let nextStep = await corbado.loginWithoutIdentifier(cuiChallenge: cuiChallenge, conditionalUI: false) {
                    primaryLoading = true
                }
                
                await completePasskeyLoginWithoutIdentifier(nextStep: nextStep)
            }
            
        case .initOneTap(let email):
            self.email = email
            status = .passkeyOneTap
        case .initFallback(_, _):
            status = .fallbackFirst
        }
    }
    
    func loginWithEmailAndPassword() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }
        
        errorMessage = nil
        primaryLoading = true
        defer {
            primaryLoading = false
        }
        
        do {
            let signInResult = try await Amplify.Auth.signIn(username: email, password: password, options: AuthSignInRequest.Options())
            switch signInResult.nextStep {
            case .confirmSignInWithTOTPCode:
                status = .fallbackSecondTOTP
            case .confirmSignInWithSMSMFACode:
                status = .fallbackSecondSMS
            case .done:
                appRouter.navigateTo(.home)
            case .confirmSignUp:
                errorMessage = "Please confirm your sign up first."
            case .resetPassword:
                errorMessage = "Please reset your password."
            case .confirmSignInWithCustomChallenge, .confirmSignInWithNewPassword:
                errorMessage = "Unexpected sign in step encountered: \(signInResult.nextStep)"
            default:
                break
            }
        } catch let amplifyError as AmplifyError {
            errorMessage = amplifyError.errorDescription
        } catch {
            errorMessage = "An unexpected error occurred during sign in: \(error.localizedDescription)"
        }
    }
    
    func navigateToSignUp() {
        appRouter.navigateTo(.signUp)
    }
    
    func loginWithPasskeyTextField() async {
        primaryLoading = true
        defer {
            primaryLoading = false
        }
        
        guard !email.isEmpty else {
            errorMessage = "Enter your email address."
            return
        }
        
        let nextStep = await corbado.loginWithTextField(identifier: email)
        await completePasskeyLoginWithIdentifier(nextStep: nextStep)
    }
    
    func loginWithPasskeyOneTap() async {
        primaryLoading = true
        defer {
            primaryLoading = false
        }
        
        let nextStep = await corbado.loginWithOneTap()
        await completePasskeyLoginWithIdentifier(nextStep: nextStep)
    }

    func verifyTOTP(code: String) {
        primaryLoading = true
        errorMessage = nil
        
        defer {
            primaryLoading = false
        }
        
        guard code.count == 6 else {
            errorMessage = "Please provide your TOTP code."
            return
        }
        
        Task {
            do {
                _ = try await Amplify.Auth.confirmSignIn(challengeResponse: code)
                appRouter.navigateTo(.postLogin)
            } catch let amplifyError as AmplifyError {
                errorMessage = amplifyError.errorDescription
            } catch {
                errorMessage = "An unexpected error occurred during TOTP verification: \(error.localizedDescription)"
            }
        }
    }
    
    func verifySMS(code: String) {
        primaryLoading = true
        errorMessage = nil
        
        defer {
            primaryLoading = false
        }
        
        guard code.count == 6 else {
            errorMessage = "Please provide your SMS code."
            return
        }
        
        Task {
            do {
                _ = try await Amplify.Auth.confirmSignIn(challengeResponse: code)
                appRouter.navigateTo(.postLogin)
            } catch let amplifyError as AmplifyError {
                errorMessage = amplifyError.errorDescription
            } catch {
                errorMessage = "An unexpected error occurred during TOTP verification: \(error.localizedDescription)"
            }
        }
    }

    func discardPasskeyOneTap() async {
        await corbado.clearOneTap()
        email = ""
        status = .passkeyTextField
    }
    
    func discardPasskeyLogin() {
        status = .fallbackFirst
    }
    
    func incrementInvitationTokenCounter() async {
        invitationTokenCounter += 1
        
        if invitationTokenCounter > 8 {
            await corbado.setInvitationToken(token: "inv-token-correct")
        }
    }
    
    private func completePasskeyLoginWithoutIdentifier(nextStep: ConnectLoginWithoutIdentifierStatus) async {
        primaryLoading = true
        defer {
            primaryLoading = false
        }
        
        switch nextStep {
        case .done(let session, let username):
            await signInWithCustomToken(signedPasskeyData: session, username: username)
            
        case .ignore(_):
            // we could start CUI here
            return
            
        case .initSilentFallback(let email, _):
            if let email = email {
                self.email = email
            }
            
            status = .fallbackFirst
            
        case .error(let error, let triggerFallback, _, let username):
            if triggerFallback {
                status = .fallbackFirst
            }
            
            if let username = username {
                self.email = username
            }
             
            switch error {
            case .PasskeyDeletedOnServer(let message):
                errorMessage = message
            default:
                errorMessage = "Passkey error. Use password to log in."
            }
        }
    }
    
    private func completePasskeyLoginWithIdentifier(nextStep: ConnectLoginWithIdentifierStatus) async {
        primaryLoading = true
        defer {
            primaryLoading = false
        }
        
        switch nextStep {
        case .done(let signedPasskeyData, let username):
            await signInWithCustomToken(signedPasskeyData: signedPasskeyData, username: username)
        case .initSilentFallback(let email, _):
            if let email = email {
                self.email = email
            }
            
            status = .fallbackFirst
        case .error(let error, let triggerFallback, _, let username):
            if triggerFallback {
                status = .fallbackFirst
            }
            
            if let username = username {
                self.email = username
            }
             
            switch error {
            case .UserNotFound:
                errorMessage = "There is no account registered to that email address."
            default:
                errorMessage = "Passkey error. Use password to log in."
            }
            
        case .initRetry:
            retryCount += 1
            if let val = errorMessage {
                self.errorMessage = val
            }

            if retryCount > 5 {
                status = .fallbackFirst
            } else if retryCount > 1 {
                status = .passkeyErrorHard
            } else {
                status = .passkeyErrorSoft
            }
        }
    }
    
    private func signInWithCustomToken(signedPasskeyData: String, username: String) async {
        do {
            let option = AWSAuthSignInOptions(authFlowType: .customWithoutSRP)
            let signInResult = try await Amplify.Auth.signIn(username: username, options: AuthSignInRequest.Options(pluginOptions: option));
            if case .confirmSignInWithCustomChallenge(_) = signInResult.nextStep {
                _ = try await Amplify.Auth.confirmSignIn(challengeResponse: signedPasskeyData)
                appRouter.navigateTo(.home)
            }
        } catch let error {
            print("handover error: \(error)")
        }
    }
}
