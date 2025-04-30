import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var username = ""

    var body: some View {
        Group {
            if isLoggedIn {
                ProfileView(username: username) {
                    // Logout callback
                    isLoggedIn = false
                    username = ""
                }
            } else {
                LoginView(username: $username) {
                    // Login callback
                    isLoggedIn = true
                }
            }
        }
        .animation(.easeInOut, value: isLoggedIn)
    }
}

#Preview {
    ContentView()
}
