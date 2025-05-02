//
//  AuthViewModel.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import Foundation
import Combine
import Amplify

enum AuthState {
    case unknown      // Initial state
    case checking     // Checking if user is logged in
    case signedOut    // User is definitively signed out
    case signedIn     // User is definitively signed in
    case requiresTOTPConfirmation // User needs to enter TOTP code for login
    case requiresTOTPSetup        // User needs to set up TOTP during signup
}

@MainActor
class AuthViewModel: ObservableObject {
    private let authManager: AuthManager;
    private var cancellables = Set<AnyCancellable>()
    
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var password = ""
    @Published var totpCode = ""
    
    @Published var currentAuthState: AuthState = .signedOut
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    
    init() {
        self.authManager = AuthManager()
        
        listenToAuthEvents()
    }
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }
        print("Attempting sign in for \(email)...")
        isLoading = true
        errorMessage = nil
        totpCode = ""
        
        Task {
            do {
                let signInResult = try await authManager.signIn(email: email, password: password)
                
                print("Sign In Result: \(signInResult.nextStep)")
                
                switch signInResult.nextStep {
                case .confirmSignInWithTOTPCode:
                    currentAuthState = .requiresTOTPConfirmation // Update state to show TOTP view
                    print("Sign in requires TOTP code.")
                case .done:
                    currentAuthState = .signedIn // Sign in successful
                    print("Sign in successful.")
                    clearCredentials()
                case .confirmSignUp:
                    errorMessage = "Please confirm your sign up first." // Or navigate to confirmation view
                    currentAuthState = .signedOut
                case .resetPassword:
                    errorMessage = "Please reset your password." // Or navigate to reset password view
                    currentAuthState = .signedOut
                case .confirmSignInWithCustomChallenge, .confirmSignInWithNewPassword, .confirmSignInWithSMSMFACode:
                    errorMessage = "Unexpected sign in step encountered: \(signInResult.nextStep)"
                    currentAuthState = .signedOut
                default:
                    break
                }
            } catch let authError as AuthError {
                handleAuthError(authError)
                currentAuthState = .signedOut
            } catch {
                errorMessage = "An unexpected error occurred during sign in: \(error.localizedDescription)"
                currentAuthState = .signedOut
            }
            isLoading = false
        }
    }
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !phoneNumber.isEmpty else {
            errorMessage = "Please enter email, phone and password."
            return
        }
        
        Task  {
            do {
                let res = try await authManager.signUp(email: email, password: password, phoneNumber: phoneNumber)
                
                if case .completeAutoSignIn(let session) = res.nextStep {
                    let autoSignInResult = try await Amplify.Auth.autoSignIn()
                    print("Auto sign in result: \(autoSignInResult.isSignedIn)")
                } else {
                    print("Confirm sign up result completed: \(res.isSignUpComplete)")
                }
            } catch let authError as AuthError {
                handleAuthError(authError)
                currentAuthState = .signedOut
            }
        }
    }
    
    func verifyTOTP() {
        isLoading = true
        errorMessage = nil
        
        guard !totpCode.isEmpty, totpCode.count == 6 else {
            errorMessage = "Please provide your TOTP code."
            return
        }
        
        Task {
            do {
                try await authManager.verifyTOTPSignIn(code: totpCode)
            } catch let authError as AuthError {
                handleAuthError(authError)
            } catch {
                errorMessage = "An unexpected error occurred during TOTP verification: \(error.localizedDescription)"
                currentAuthState = .signedOut
            }
            isLoading = false
        }
    }
    
    func initSetupTOTP() async -> TOTPSetupDetails? {
        isLoading = true
        errorMessage = nil
        
        do {
            let details = try await self.authManager.setUpTOTP()
            isLoading = false
            
            return details
        } catch {
            errorMessage = "TOTP could not be initialized. Try again later."
            isLoading = false
            
            return nil
        }
    }
    
    func completeSetupTOTP() async {
        isLoading = true
        errorMessage = nil
        
        guard !totpCode.isEmpty, totpCode.count == 6 else {
            errorMessage = "Please provide your TOTP code."
            return
        }
        
        Task {
            do {
                try await authManager.verifyTOTPSetup(code: totpCode)
            } catch let authError as AuthError {
                handleAuthError(authError)
            } catch {
                errorMessage = "An unexpected error occurred during TOTP verification: \(error.localizedDescription)"
                currentAuthState = .signedOut
            }
            
            isLoading = false
        }
    }
    
    
    func signOut() {
        isLoading = true
        errorMessage = nil
        
        Task {
            await authManager.signOut()
            isLoading = false
        }
    }
    
    func checkAuthState() {
        print("Checking auth state...")
        currentAuthState = .checking
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let session = try await authManager.fetchCurrentAuthSession()
                print("Auth Session Check: isSignedIn = \(session.isSignedIn)")
                if session.isSignedIn {
                    currentAuthState = .signedIn
                } else {
                    currentAuthState = .signedOut
                }
            } catch {
                print("Error checking auth state: \(error)")
                currentAuthState = .signedOut // Assume signed out on error
                // You might want more specific error handling here
            }
            isLoading = false
        }
    }
    
    private func handleAuthError(_ error: AuthError) {
        switch error {
        case .amplifyError(let underlyingError):
            // Try to decode Cognito specific errors for better messages
            if let authError = underlyingError as? AuthError {
                // Handle specific Cognito errors if needed (e.g., UserNotFoundException)
                errorMessage = authError.localizedDescription // Amplify's error description is often useful
            } else {
                errorMessage = underlyingError.localizedDescription
            }
            print("Amplify Auth Error: \(underlyingError)")
        case .operationFailed(let message):
            errorMessage = message
            print("Operation Failed: \(message)")
        case .unexpectedSignInStep(let step):
            errorMessage = "Unexpected sign in step: \(step)"
            print("Error: \(errorMessage!)")
        case .unexpectedSignUpStep(let step):
            errorMessage = "Unexpected sign up step: \(step)"
            print("Error: \(errorMessage!)")
        case .totpSetupFailed(let underlyingError):
            errorMessage = "Failed to initiate TOTP setup: \(underlyingError?.localizedDescription ?? "Unknown error")"
            print("Error: \(errorMessage!)")
        case .totpVerificationFailed(let underlyingError):
            errorMessage = "Failed to verify TOTP code: \(underlyingError?.localizedDescription ?? "Unknown error")"
            print("Error: \(errorMessage!)")
        case .mfaPreferenceUpdateFailed(let underlyingError):
            // This might happen after successful verification but before preference update
            errorMessage = "Verified TOTP, but failed to set as preferred MFA: \(underlyingError?.localizedDescription ?? "Unknown error")"
            print("Error: \(errorMessage!)")
        case .userNotSignedIn:
            errorMessage = "Operation requires user to be signed in."
            print("Error: \(errorMessage!)")
            currentAuthState = .signedOut // Force sign out state
        }
    }
    
    
    private func clearCredentials() {
        email = ""
        phoneNumber = ""
        password = ""
        errorMessage = nil
        totpCode = ""
    }
    
    private func listenToAuthEvents() {
        Amplify.Hub.publisher(for: .auth)
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] payload in
                guard let self = self else { return }
                
                switch payload.eventName {
                case HubPayload.EventName.Auth.signedIn, HubPayload.EventName.Auth.autoSignInAPI:
                    print("User signed in")
                    if self.currentAuthState != .signedIn {
                        Task {
                            self.clearCredentials()
                            
                            let hasMFA = try await self.authManager.getMFAPreference()
                            if !hasMFA {
                                self.currentAuthState = .requiresTOTPSetup
                                return
                            }
                            
                            self.currentAuthState = .signedIn
                        }
                    }
                    
                case HubPayload.EventName.Auth.signedOut:
                    print("User signed out")
                    if self.currentAuthState != .signedOut && self.currentAuthState != .checking {
                        self.currentAuthState = .signedOut
                        self.clearCredentials()
                    }
                    
                default:
                    break
                }
            }.store(in: &cancellables)
    }
}
