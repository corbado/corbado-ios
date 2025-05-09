//
//  SignUpViewModel.swift
//  ConnectExample
//
//  Created by Martin on 6/5/2025.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var phoneNumber = "+4915121609839"
    @Published var password = ""
    @Published var primaryLoading = false
    @Published var errorMessage: String? = nil
    
    func autoFill() {
        let randomChars = randomString(10)
        
        self.email = "integration-test+\(String(randomChars))@corbado.com"
        self.phoneNumber = "+4915121609839"
        self.password = "asdfasdf"
    }
    
    func signUp(appRouter: AppRouter) async {
        primaryLoading = true
        defer {
            primaryLoading = false
        }
        
        guard !email.isEmpty, !password.isEmpty, !phoneNumber.isEmpty else {
            errorMessage = "Please enter email, phone and password."
            return
        }
                
        do {
            let randomChars = randomString(10)
            let userAttributes = [
                AuthUserAttribute(.email, value: email),
                AuthUserAttribute(.phoneNumber, value: phoneNumber)
            ]
            
            let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
            let signUpResult = try await Amplify.Auth.signUp(
                username: String(randomChars),
                password: password,
                options: options
            )
            
            if case .completeAutoSignIn(_) = signUpResult.nextStep {
                let _ = try await Amplify.Auth.autoSignIn()
            } else {
                let signInResult = try await Amplify.Auth.signIn(username: email, password: password, options: AuthSignInRequest.Options())
                print(signInResult)
            }
            
            appRouter.navigateTo(.postLogin)
        } catch let authError as AmplifyError {
            errorMessage = authError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func randomString(_ length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomChars = (0..<length).compactMap { _ in letters.randomElement() }
        
        return String(randomChars)
    }
}
