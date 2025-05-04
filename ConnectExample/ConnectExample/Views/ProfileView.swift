//
//  ProfileView.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI


struct ProfileView: View {
    // Access the shared AuthViewModel
    @EnvironmentObject var viewModel: ProfileViewModel
    @State private var safariURLItem: URL? = nil
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Divider()
                
                HStack() {
                    Text("Email:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(viewModel.email)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Phone:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(viewModel.phoneNumber)
                        .foregroundColor(.secondary)
                }
                
                Button() {
                    viewModel.signOut()
                } label: {
                    Text("Logout")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(8)
                }
                
                Button() {
                    Task {
                        guard let idToken = await viewModel.getIdToken() else {
                            return
                        }
                        
                        guard let url = URL(string: "https://feature-wv.connect-next.playground.corbado.io/redirect?token=\(idToken)&redirectUrl=%2Fpasskey-list-wv") else {
                            return
                        }
                        
                        safariURLItem = url
                    }
                } label: {
                    Text("Passkeys")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(8)
                }
                
                Spacer()
            }
        }
        .padding()
        .navigationTitle("Profile")
        .onAppear {
            Task {
                await viewModel.fetchUserData()
            }
        }
        .sheet(item: $safariURLItem) { url in
            SafariView(url: url)
        }
    }
}

extension URL: Identifiable {
    public var id: URL { return self }
}

#Preview {
    ProfileView().environmentObject(ProfileViewModel())
}
