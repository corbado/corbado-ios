//
//  LoginViewModel.swift
//  ConnectExample
//
//  Created by Martin on 6/5/2025.
//

import SwiftUI
import Amplify
import CorbadoIOS
import AWSCognitoAuthPlugin

enum LoginStatus {
    case loading
    case fallbackFirst
    case fallbackSecondTOTP
    case passkeyTextField
    case passkeyOneTap
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published var status: LoginStatus = .loading
    @Published var email = ""
    @Published var password = ""
    @Published var primaryLoading = false
    @Published var errorMessage: String? = nil
    
    private var corbado: CorbadoIOS = CorbadoIOS.shared
    
    func loadInitialStep() async {
        let nextStep = await corbado.isLoginAllowed()
        switch nextStep {
        case .InitTextField(let cuiChallenge):
            status = .passkeyTextField
        case .InitOneTap(let email):
            self.email = email
            status = .passkeyOneTap
        case .InitFallback(let email, let errorMessage):
            status = .fallbackFirst
        default:
            break
        }
    }
    
    func loginWithEmailAndPassword(appRouter: AppRouter) async {
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
            case .done:
                appRouter.navigateTo(.home)
            case .confirmSignUp:
                errorMessage = "Please confirm your sign up first."
            case .resetPassword:
                errorMessage = "Please reset your password."
            case .confirmSignInWithCustomChallenge, .confirmSignInWithNewPassword, .confirmSignInWithSMSMFACode:
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
    
    func loginWithPasskeyTextField(appRouter: AppRouter) async {
        primaryLoading = true
        defer {
            primaryLoading = false
        }
        
        let nextStep = await corbado.loginWithTextField(identifier: email)
        await completePasskeyLogin(nextStep: nextStep, appRouter: appRouter)
    }
    
    func loginWithPasskeyOneTap(appRouter: AppRouter) async {
        primaryLoading = true
        defer {
            primaryLoading = false
        }
        
        let nextStep = await corbado.loginWithOneTap()
        await completePasskeyLogin(nextStep: nextStep, appRouter: appRouter)
    }

    
    func verifyTOTP(code: String, appRouter: AppRouter) {
        primaryLoading = true
        errorMessage = nil
        
        guard code.count == 6 else {
            errorMessage = "Please provide your TOTP code."
            return
        }
        
        Task {
            do {
                let result = try await Amplify.Auth.confirmSignIn(challengeResponse: code)
                appRouter.navigateTo(.postLogin)
            } catch let amplifyError as AmplifyError {
                errorMessage = amplifyError.localizedDescription
            } catch {
                errorMessage = "An unexpected error occurred during TOTP verification: \(error.localizedDescription)"
            }
            primaryLoading = false
        }
    }

    func discardPasskeyOneTap() {
        email = ""
        status = .passkeyTextField
    }
    
    private func completePasskeyLogin(nextStep: ConnectLoginStep, appRouter: AppRouter) async {
        switch nextStep {
        case .Done(let session):
            let decoded = decodeJwt(token: session)
            guard let username = decoded?["webauthnId"] as? String else {
                print("decoding error")
                
                return
            }
            
            do {
                let option = AWSAuthSignInOptions(authFlowType: .customWithoutSRP)
                let signInResult = try await Amplify.Auth.signIn(username: username as String, options: AuthSignInRequest.Options(pluginOptions: option));
                if case .confirmSignInWithCustomChallenge(_) = signInResult.nextStep {
                    _ = try await Amplify.Auth.confirmSignIn(challengeResponse: session)
                    appRouter.navigateTo(.home)
                }
            } catch let error {
                print("handover error: \(error)")
            }
        case .InitFallback(let email, let errorMessage):
            if let val = errorMessage {
                self.errorMessage = val
            }
            
            if let val = email {
                self.email = val
            }
            
            status = .fallbackFirst
        default:
            break
        }
    }
    
    private func decodeJwt(token: String) -> [String: Any]? {
        let segments = token.components(separatedBy: ".")
        
        
        guard segments.count >= 2 else {
            print("Error: JWT token is not valid, not enough segments.")
            return nil
        }
        
        
        var payloadBase64UrlString = segments[1]
        
        payloadBase64UrlString = payloadBase64UrlString.replacingOccurrences(of: "-", with: "+")
        payloadBase64UrlString = payloadBase64UrlString.replacingOccurrences(of: "_", with: "/")
        
        let requiredPadding = payloadBase64UrlString.count % 4
        if requiredPadding > 0 {
            payloadBase64UrlString += String(repeating: "=", count: 4 - requiredPadding)
        }
        
        guard let payloadData = Data(base64Encoded: payloadBase64UrlString) else {
            print("Error: Could not decode base64 payload string.")
            return nil
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: payloadData, options: [])
            return jsonObject as? [String: Any]
        } catch {
            print("Error: Could not parse JSON from payload data. \(error)")
            return nil
        }
    }
    
}
