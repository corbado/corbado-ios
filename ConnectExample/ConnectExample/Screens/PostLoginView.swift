import SwiftUI

@MainActor
struct PostLoginView: View {
    @EnvironmentObject var appRouter: AppRouter
    
    @StateObject var viewModel: PostLoginViewModel

    private let callbackURLScheme = "auth"

    init(appRouter: AppRouter) {
        _viewModel = StateObject(wrappedValue: PostLoginViewModel(appRouter: appRouter))
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                 ProgressView("Checking Authentication...")
                     .onAppear {
                         Task {
                             await viewModel.prepareAndLoadAuthWebView()
                         }
                     }
            } else if let error = viewModel.authError {
                Text("Authentication Failed: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else if let url = viewModel.webViewURL, !viewModel.isAuthComplete {
                 AuthWebView(
                    url: url,
                    callbackURLScheme: callbackURLScheme,
                    onComplete: viewModel.handleAuthCompletion
                 )
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .ignoresSafeArea(.container, edges: .bottom) // Optional: Extend to bottom edge
                 
            } else if viewModel.isAuthComplete {
                 Text("Authentication Complete!")
                     .padding()
            } else {
                 Text("Initializing...")
            }
        }
    }
}
