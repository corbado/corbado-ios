import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appRouter: AppRouter
    
    @StateObject var viewModel = ProfileViewModel()
    
    @State private var passkeyWebViewURL: URL?
    @State private var webViewError: Error?

    private let passkeyCallbackScheme = "auth" // << EXAMPLE - CHANGE IF NEEDED

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            if viewModel.isLoading {
                ProgressView("Loading Profile...") // More descriptive text
            } else {
                Divider()

                // --- Existing Profile Info ---
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
                 // --- End Existing Profile Info ---

                 // Display web view error if one occurred
                 if let error = webViewError {
                     Text("Passkey Management Error: \(error.localizedDescription)")
                         .foregroundColor(.red)
                         .font(.caption)
                         .padding(.vertical, 5)
                 }


                Button() {
                    viewModel.signOut(appRouter: appRouter)
                } label: {
                    Text("Logout")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(8)
                }
                
                PrimaryButton(label: "Passkey append", isLoading: false, accessibilityIdentifier: "nativate-to-passkey-append") {
                    appRouter.navigateTo(.postLogin)
                }

                if let url = passkeyWebViewURL {
                    AuthWebView(
                        url: url,
                        callbackURLScheme: passkeyCallbackScheme,
                        onComplete: handlePasskeyWebViewCompletion
                    )
                } else {
                    // Fallback if URL is somehow nil when sheet is shown
                    VStack {
                         Text("Error: Invalid URL for Passkey Management.")
                    }
                }

                Spacer()
            }
        }
        .padding()
        .onAppear {
            // Clear any previous web view errors when the view appears
            webViewError = nil
            Task {
                await viewModel.fetchUserData()
                await prepareAndShowPasskeyWebView()
            }
        }
    }

    @MainActor
    func prepareAndShowPasskeyWebView() async {
        webViewError = nil // Clear previous errors
        guard let idToken = await viewModel.getIdToken() else {
            print("Error: Could not get idToken for passkey management")
            webViewError = URLError(.userAuthenticationRequired) // Or a custom error
            return
        }

        // Construct the specific URL for passkey management
        var components = URLComponents(string: "https://feature-wv.connect-next.playground.corbado.io/redirect")
        components?.queryItems = [
            URLQueryItem(name: "token", value: idToken),
            URLQueryItem(name: "redirectUrl", value: "/passkey-list-wv") // The specific internal redirect path
        ]

        guard let url = components?.url else {
            print("Error: Could not construct the passkey management URL")
            webViewError = URLError(.badURL) // Or a custom error
            return
        }

        print("Passkey Management URL: \(url.absoluteString)")

        // Set the state to trigger the sheet presentation
        self.passkeyWebViewURL = url
    }

    // Handles the result from the AuthWebView completion callback
    @MainActor
    private func handlePasskeyWebViewCompletion(_ result: Result<URL, Error>) {
        // The sheet is automatically dismissed by the binding update in AuthWebView's Coordinator

        switch result {
        case .success(let receivedURL):
            // Handle successful callback (if applicable)
            print("Passkey management finished successfully. Callback URL: \(receivedURL.absoluteString)")
            // Do you need to do anything with the URL? Often just success is enough.
            // Maybe refresh profile data?
             Task { await viewModel.fetchUserData() } // Example: Refresh data after success

        case .failure(let error):
            // Handle errors
             print("Passkey management failed or was cancelled with error: \(error.localizedDescription)")
             // Don't overwrite error if it was just a cancellation
             let nsError = error as NSError
             if !(nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled) {
                 webViewError = error // Store error to display it
             }
        }
    }
}

#Preview {
    ProfileView().environmentObject(ProfileViewModel())
}
