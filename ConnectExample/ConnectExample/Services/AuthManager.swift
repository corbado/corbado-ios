//
//  AuthManager.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import Foundation
import Amplify
import AWSCognitoAuthPlugin

enum AuthError: Error {
    case amplifyError(Error)
    case operationFailed(String)
    case unexpectedSignInStep(AuthSignInStep)
    case unexpectedSignUpStep(AuthSignUpStep)
    case totpSetupFailed(Error?)
    case totpVerificationFailed(Error?)
    case mfaPreferenceUpdateFailed(Error?)
    case userNotSignedIn
}

struct TOTPSetupDetails {
    let setupUri: URL
    let sharedSecret: String
}

class AuthManager {
    static let shared = AuthManager()
    
    private let isLoggedInKey = "isUserLoggedInKey"
    
    private(set) var isLoggedIn: Bool = false {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: isLoggedInKey)
            print("AuthManager saved isLoggedIn=\(isLoggedIn) to UserDefaults")
        }
    }
    
    func fetchCurrentAuthSession() async throws -> AuthSession {
        do {
            return try await Amplify.Auth.fetchAuthSession()
        } catch {
            throw AuthError.amplifyError(error)
        }
    }
    
    func signIn(email: String, password: String) async throws -> AuthSignInResult {
        do {
            let options = AuthSignInRequest.Options() // Add options if needed
            let signInResult = try await Amplify.Auth.signIn(username: email, password: password, options: options)
            return signInResult
        } catch {
            throw AuthError.amplifyError(error)
        }
    }

    // Sign In - Step 2 (Confirm TOTP Code)
    func confirmSignIn(totpCode: String) async throws -> AuthSignInResult {
        do {
            let result = try await Amplify.Auth.confirmSignIn(challengeResponse: totpCode)
            return result
        } catch {
            throw AuthError.amplifyError(error)
        }
    }

    // Sign Up - Step 1 (Email/Password)
    func signUp(email: String, password: String) async throws -> AuthSignUpResult {
        do {
            let userAttributes = [AuthUserAttribute(.email, value: email)]
            let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
            let signUpResult = try await Amplify.Auth.signUp(
                username: email,
                password: password,
                options: options
            )
            return signUpResult
        } catch {
            throw AuthError.amplifyError(error)
        }
    }

    // Sign Up - Step 2 (Initiate TOTP Setup)
    // This returns the URI/secret needed to display the QR code or setup key.
    func setUpTOTP() async throws -> TOTPSetupDetails {
        do {
            let setupResult = try await Amplify.Auth.setUpTOTP()
            // Extract the necessary details. The exact structure might vary slightly
            // depending on Amplify version, but typically involves a shared secret
            // and potentially a helper method to generate the URI.
            let secret = setupResult.sharedSecret
                
            let username = try await getCurrentUsername() // Get username for the URI
            let setupUri = try setupResult.getSetupURI(appName: "YourAppName") // Use Amplify's helper

            return TOTPSetupDetails(setupUri: setupUri, sharedSecret: secret)
        } catch let error as AuthError {
             throw error // Re-throw specific auth errors
        } catch {
             throw AuthError.totpSetupFailed(error)
        }
    }

    // Sign Up - Step 3 (Verify TOTP Code after user scans QR/enters key)
    func verifyTOTPSetup(code: String) async throws {
        do {
            try await Amplify.Auth.verifyTOTPSetup(code: code)
            // After successful verification, set TOTP as the preferred MFA method
            // This ensures it's actually used for future logins.
            try await updateMFAPreference(totp: .enabled, sms: .notPreferred) // Or .disabled if SMS not configured
        } catch {
            throw AuthError.totpVerificationFailed(error)
        }
    }

    // Helper to update MFA preferences
    func updateMFAPreference(totp: MFAPreference, sms: MFAPreference?) async throws {
        do {
            let authCognitoPlugin = try Amplify.Auth.getPlugin(for: "awsCognitoAuthPlugin") as? AWSCognitoAuthPlugin
            try await authCognitoPlugin?.updateMFAPreference(sms: sms, totp: totp)
        } catch {
            throw AuthError.mfaPreferenceUpdateFailed(error)
        }
    }
    
    
    private func getCurrentUsername() async throws -> String {
        /*
        do {
            // Fetch attributes, including the username (often the 'sub' or 'username' attribute)
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            if let username = attributes.first(where: { $0.key == .username })?.value {
                 return username
            } else if let sub = attributes.first(where: { $0.key == .sub })?.value {
                 return sub // Often 'sub' is the unique identifier used internally
            } else {
                // Fallback or handle error if username cannot be determined
                 throw AuthError.operationFailed("Could not determine username for TOTP setup.")
            }
        } catch {
             throw AuthError.amplifyError(error)
        }*/
        return ""
    }


    // Sign Out
    func signOut() async {
        _ = await Amplify.Auth.signOut() // Doesn't typically throw for simple sign out
    }

}
