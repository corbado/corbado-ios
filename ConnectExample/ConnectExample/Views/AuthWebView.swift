import SwiftUI
import WebKit

// No changes needed at the top level imports for this modification

struct AuthWebView: UIViewRepresentable {
    let url: URL
    let callbackURLScheme: String // e.g., "auth"
    let onComplete: (Result<URL, Error>) -> Void // Callback remains essential

    func makeUIView(context: Context) -> WKWebView {
        let wkWebView = WKWebView()
        wkWebView.navigationDelegate = context.coordinator
        return wkWebView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url && !context.coordinator.didLoadInitialURL {
            let request = URLRequest(url: url)
            uiView.load(request)
            context.coordinator.didLoadInitialURL = true
        }
    }
    
    func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        print("Dismantling AuthWebView")
        uiView.stopLoading() // Stop any ongoing network requests
        uiView.navigationDelegate = nil // Break reference cycle with coordinator
        uiView.scrollView.delegate = nil // Break other potential delegate cycles if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: AuthWebView
        var didLoadInitialURL = false

        init(_ parent: AuthWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                print("WebView navigating to: \(url.absoluteString)")
                if url.scheme == parent.callbackURLScheme {
                    parent.onComplete(.success(url))                    
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView failed navigation: \(error.localizedDescription)")
            parent.onComplete(.failure(error))
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
           print("WebView failed provisional navigation: \(error.localizedDescription)")
           let nsError = error as NSError
           if !(nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled) {
               parent.onComplete(.failure(error))
           }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView finished loading a page.")
        }
    }
}

// Custom Error enum remains the same
enum AuthWebViewError: Error, LocalizedError {
    case missingCallbackURL
    
    var errorDescription: String? {
        switch self {
        case .missingCallbackURL:
            return "Authentication returned without a callback URL."
        }
    }
}
