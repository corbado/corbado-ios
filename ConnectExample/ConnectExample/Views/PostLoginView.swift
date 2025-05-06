import SwiftUI
// No need for AuthenticationServices here anymore for the session
// Keep if needed for other parts of AuthViewModel

struct PostLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var webViewURL: URL? // URL to load
    @State private var authError: Error? // To display errors if needed
    @State private var isLoading = true // Indicate initial loading state
    @State private var isAuthComplete = false // Track if the web flow finished

    private let callbackURLScheme = "auth"

    var body: some View {
        VStack {
            if isLoading {
                 ProgressView("Checking Authentication...")
                     .onAppear { // Trigger the process when the ProgressView appears
                         Task {
                             await prepareAndLoadAuthWebView()
                         }
                     }
            } else if let error = authError {
                // Display error state
                Text("Authentication Failed: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
                Button("Retry") {
                    // Reset state and try again
                    isLoading = true
                    authError = nil
                    isAuthComplete = false
                    webViewURL = nil // Ensure webview is removed before retry
                    // Task { await prepareAndLoadAuthWebView() } // Re-trigger directly or rely on onAppear of ProgressView
                }
            } else if let url = webViewURL, !isAuthComplete {
                // Display the WebView
                 AuthWebView(
                    url: url,
                    callbackURLScheme: callbackURLScheme,
                    onComplete: handleAuthCompletion
                 )
                 // Important: Give the WebView a frame, otherwise it might have zero size
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .ignoresSafeArea(.container, edges: .bottom) // Optional: Extend to bottom edge
                 
            } else if isAuthComplete {
                 // Display success state or navigate away
                 Text("Authentication Complete!")
                     .padding()
                 // Add further navigation or UI updates here
            } else {
                 // Fallback / Initial state before loading starts (optional)
                 Text("Initializing...")
            }
        }
        // REMOVED: .sheet modifier
        // REMOVED: .onAppear { Task { await prepareAndLoadAuthWebView() } } -> Moved to ProgressView's onAppear
    }

    @MainActor
    func prepareAndLoadAuthWebView() async {
        // Ensure we don't run this multiple times if already loading/loaded
        guard isLoading else { return }

        authError = nil
        isAuthComplete = false
        webViewURL = nil // Reset URL

        guard let idToken = await authViewModel.getIdToken() else {
            print("Error: Could not get idToken")
            authError = URLError(.userAuthenticationRequired)
            isLoading = false // Stop loading, show error
            return
        }

        var components = URLComponents(string: "https://feature-wv.connect-next.playground.corbado.io/redirect")
        components?.queryItems = [
            URLQueryItem(name: "token", value: idToken),
            URLQueryItem(name: "redirectUrl", value: "/post-login-wv")
        ]

        guard let url = components?.url else {
            print("Error: Could not construct the URL")
            authError = URLError(.badURL)
            isLoading = false // Stop loading, show error
            return
        }

        print("Constructed URL: \(url.absoluteString)")

        // Set the URL state and stop initial loading indicator
        self.webViewURL = url
        self.isLoading = false
    }

    @MainActor
    private func handleAuthCompletion(_ result: Result<URL, Error>) {
        isLoading = false // Ensure loading indicator is off
        
        switch result {
        case .success(let receivedURL):
            print("Authentication successful! Callback URL: \(receivedURL.absoluteString)")
            isAuthComplete = true // Mark as complete to change UI
            authError = nil
            // Process receivedURL if needed
        case .failure(let error):
             print("Authentication failed with error: \(error.localizedDescription)")
             authError = error // Store error to display it
             isAuthComplete = false // Ensure completion flag is false on error
        }
        
        // Remove the webview URL so it disappears from the view hierarchy
        // Do this *after* setting isAuthComplete or authError so the correct state shows
        webViewURL = nil

        // Call the view model's completion check
        authViewModel.completePKSetupChecking()
    }
}
