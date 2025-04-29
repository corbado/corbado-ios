
//
//  TOTPSetupViewMOdel.swift
//  ConnectExample
//
//  Created by Martin on 6/5/2025.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

struct TOTPSetupDetails {
    let setupUri: URL
    let sharedSecret: String
}

@MainActor
class TOTPSetupViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var totpCode = ""
    @Published var errorMessage: String?
    
    func completeSetupTOTP(appRouter: AppRouter) async {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        guard !totpCode.isEmpty, totpCode.count == 6 else {
            errorMessage = "Please provide your TOTP code."
            return
        }
        
        Task {
            do {
                try await Amplify.Auth.verifyTOTPSetup(code: totpCode)
                let authCognitoPlugin = try Amplify.Auth.getPlugin(for: "awsCognitoAuthPlugin") as? AWSCognitoAuthPlugin
                try await authCognitoPlugin?.updateMFAPreference(sms: .disabled, totp: .enabled)
                
                appRouter.navigateTo(.home)
            } catch let amplifyError as AmplifyError {
                errorMessage = amplifyError.errorDescription
            } catch {
                errorMessage = "An unexpected error occurred during TOTP verification: \(error.localizedDescription)"
            }
        }
    }

    func initSetupTOTP() async -> TOTPSetupDetails? {
        errorMessage = nil
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            let setupResult = try await Amplify.Auth.setUpTOTP()
            let secret = setupResult.sharedSecret
            let _ = await getCurrentUsername()
            let setupUri = try setupResult.getSetupURI(appName: "Corbado iOS")
            return TOTPSetupDetails(setupUri: setupUri, sharedSecret: secret)
        } catch {
            errorMessage = "TOTP could not be initialized. Try again later."
            return nil
        }
    }
    
    private func getCurrentUsername() async -> String? {
        do {
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            if let username = attributes.first(where: { $0.key == .email })?.value {
                return username
            } else if let sub = attributes.first(where: { $0.key == .sub })?.value {
                return sub
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
