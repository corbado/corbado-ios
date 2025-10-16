import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingNotification = false
    @State private var notificationMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            ScreenHeadline(title: "Home", accessibilityIdentifier: "homeScreen.headline")
            
            Text("Welcome to the CorbadoConnect iOS demo app")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .accessibilityIdentifier("homeScreen.subtitle")
            
            Divider()
            
            HStack(spacing: 15) {
                DummyButton(number: 1) { number in
                    if viewModel.isButton1PasskeyActive {
                        Task {
                            await viewModel.passkeyActiveButtonClicked()
                        }
                    } else {
                        notificationMessage = "Button \(number) clicked"
                        showingNotification = true
                    }
                }
                
                DummyButton(number: 2) { number in
                    if viewModel.isButton2PasskeyActive {
                        Task {
                            await viewModel.passkeyActiveButtonClicked()
                        }
                    } else {
                        notificationMessage = "Button \(number) clicked"
                        showingNotification = true
                    }
                }
                
                DummyButton(number: 3) { number in
                    if viewModel.isButton3PasskeyActive {
                        Task {
                            await viewModel.passkeyActiveButtonClicked()
                        }
                    } else {
                        notificationMessage = "Button \(number) clicked"
                        showingNotification = true
                    }
                }
            }
            .padding(.horizontal)
            
            PrimaryButton(label: "Navigate to Profile", isLoading: false, accessibilityIdentifier: "homeScreen.navigateToProfile") {
                appRouter.navigateTo(.profile)
            }
            
            Spacer()
        }
        .padding()
        .alert("Notification", isPresented: $showingNotification) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(notificationMessage)
        }
        .sheet(isPresented: $viewModel.showingBottomSheet) {
            BottomSheetView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

struct DummyButton: View {
    let number: Int
    let action: (Int) -> Void
    
    var body: some View {
        Button {
            action(number)
        } label: {
            Text("\(number)")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(8)
        }
        .accessibilityIdentifier("homeScreen.dummyButton\(number)")
    }
}

struct BottomSheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Simplify your sign in")
                        .font(.title2)
                        .fontWeight(.bold)
                        .accessibilityIdentifier("bottomSheet.title")
                    
                    Text("Create a passkey")
                        .font(.headline)
                        .accessibilityIdentifier("bottomSheet.subtitle")
                    
                    Text("Sign in easily now with your fingerprint, face, or PIN. Sync across your devices.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("bottomSheet.description")
                }
                
                Image("PasskeyAppend")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            }
            .padding(.horizontal)
            .padding(.top)
            
            PrimaryButton(label: "Continue", isLoading: false, accessibilityIdentifier: "bottomSheet.continueButton") {
                dismiss()
                await viewModel.completePasskeyAppend(autoAppend: false)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppRouter())
}

