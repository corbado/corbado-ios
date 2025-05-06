//
//  ProfileViewModel.swift
//  ConnectExample
//
//  Created by Martin on 2/5/2025.
//
import SwiftUI
import Amplify
import AWSPluginsCore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    
    func fetchUserData() async {
        isLoading = true
        errorMessage = nil
        
        do {
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
        
        isLoading = false
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
    
    func signOut() {
        Task {
            _ = await Amplify.Auth.signOut()            
        }
    }
}
