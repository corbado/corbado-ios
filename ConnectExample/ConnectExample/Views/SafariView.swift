//
//  SafariView.swift
//  ConnectExample
//
//  Created by Martin on 4/5/2025.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    
    let url: URL // The URL to display
    
    // This Coordinator handles the delegate callback for dismissal
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Creates the SFSafariViewController instance
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = context.coordinator // Set the delegate
        return safariVC
    }
    
    // This function is called when SwiftUI state changes, but for minimal
    // presentation, we often don't need to update the Safari VC itself.
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No update needed for the minimal case. If the URL could change
        // dynamically while presented, more logic would go here, but
        // SFSafariViewController isn't really designed for dynamic URL updates.
    }
    
    // Coordinator class to act as the SFSafariViewControllerDelegate
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: SafariView
        
        init(_ parent: SafariView) {
            self.parent = parent
        }
        
        // This delegate method is called when the user taps the "Done" button.
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            print("SafariViewController finished.")
            // We don't have a binding to dismiss directly in the *absolute* minimal
            // version, but the standard way involves a binding (see ContentView below).
            // The `.sheet` or `.fullScreenCover` modifier handles the dismissal
            // when its bound 'isPresented' state becomes false. The delegate
            // callback itself doesn't dismiss it here, it signals that the
            // user requested dismissal.
        }
    }
}
