import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel: ProfileViewModel
    @State var showingDeleteConfirmation = false
    
    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    init() {
        _viewModel = StateObject(wrappedValue: ProfileViewModel())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            if viewModel.isLoading {
                ProgressView("Loading Profile...")
            } else {
                ScreenHeadline(title: "Profile", accessibilityIdentifier: "profileScreen.headline")
                
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
                
                PrimaryButton(label: "Logout", isLoading: false, accessibilityIdentifier: "profileScreen.signOut") {
                    viewModel.signOut(appRouter: appRouter)
                }
                
                VStack(alignment: .leading, spacing: 10) { 
                    Text("Passkeys")
                        .font(.headline)
                        .padding(.top)
                        .accessibilityIdentifier("profileScreen.passkeySection")
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .accessibilityIdentifier("profileScreen.errorMessage")
                    }
                    
                    Divider()
                    
                    if let listMessage = viewModel.listMessage {
                        Text(listMessage)
                            .padding()
                            .accessibilityIdentifier("profileScreen.listMessage")
                    } else {
                        ForEach(viewModel.passkeys) { passkey in
                            PasskeyListEntry(
                                passkey: passkey,
                                onDelete: {
                                    showingDeleteConfirmation = true
                                    viewModel.passkeyToDelete = passkey
                                }
                            )
                        }
                        .confirmationDialog(
                            "Are you sure you want to delete this passkey?", // Title
                            isPresented: $showingDeleteConfirmation,
                            titleVisibility: .visible // Or .automatic
                        ) {
                            Button("Delete", role: .destructive) {
                                guard let passkeyToDelete = viewModel.passkeyToDelete else {
                                    return
                                }
                                
                                Task {
                                    await viewModel.deletePasskey(passkey: passkeyToDelete)
                                }
                            }
                            
                            Button("Cancel", role: .cancel) {
                                showingDeleteConfirmation = false
                                viewModel.passkeyToDelete = nil
                            }
                        } message: {
                            Text("This action cannot be undone.")
                        }
                    }
                    
                    if viewModel.passkeyAppendAllowed {
                        PrimaryButton(label: "Create passkey", isLoading: false, accessibilityIdentifier: "profileScreen.appendPasskey") {
                            Task {
                                await viewModel.appendPasskey()
                            }
                        }
                    }
                    
                    Divider()
                    
                    PrimaryButton(label: "Reload", isLoading: false, accessibilityIdentifier: "profileScreen.reload") {
                        Task {
                            await viewModel.fetchUserData()
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.fetchUserData()
            }
        }
    }
}

#Preview {
    let viewModel = ProfileViewModel()
    viewModel.setupPreview()
    
    return ProfileView(viewModel: viewModel)
}
