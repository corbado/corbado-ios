import UIKit
import SafariServices

class YourViewController: UIViewController {

    // Example function to trigger opening the URL
    func openLinkInSafariVC(urlString: String) {

        // 2. Create a URL object from the string.
        // Use guard let for safe unwrapping, as URL(string:) can return nil for invalid URLs.
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL string: \(urlString)")
            // Optionally show an alert to the user here
            // let alert = UIAlertController(title: "Error", message: "Could not open the link.", preferredStyle: .alert)
            // alert.addAction(UIAlertAction(title: "OK", style: .default))
            // present(alert, animated: true)
            return
        }

        // Optional Check: SFSafariViewController works best with http/https URLs.
        // You might want to add a check, although it often handles other schemes gracefully.
        guard ["http", "https"].contains(url.scheme?.lowercased()) else {
             print("Error: SFSafariViewController primarily supports http/https URLs.")
             // Handle other URL schemes differently if needed (e.g., using UIApplication.shared.open)
             return
        }

        // 3. Create an instance of SFSafariViewController with the URL.
        let safariViewController = SFSafariViewController(url: url)

        // --- Optional Configuration ---
        // You can customize the appearance slightly (e.g., button colors)
        // safariViewController.preferredControlTintColor = .systemBlue

        // You can set a delegate to be notified when the user dismisses it
        // safariViewController.delegate = self // Make YourViewController conform to SFSafariViewControllerDelegate

        // --- End Optional Configuration ---


        // 4. Present the SFSafariViewController modally.
        self.present(safariViewController, animated: true, completion: nil)
    }

    // --- Example Usage (e.g., inside a button action) ---
    @IBAction func didTapOpenLinkButton(_ sender: UIButton) {
        openLinkInSafariVC(urlString: "https://www.apple.com")
    }

    // --- Example Usage (e.g., in viewDidLoad) ---
    override func viewDidLoad() {
        super.viewDidLoad()
        // Example: Open the link immediately when the view loads
        // Be careful doing this automatically, ensure it makes sense for the user experience.
        openLinkInSafariVC(urlString: "https://developer.apple.com")
    }
}
