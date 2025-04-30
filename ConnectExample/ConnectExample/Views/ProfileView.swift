//
//  ProfileView.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI

struct ProfileView: View {
    // Access the shared AuthViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 30) {
            Text("Profile")
                .font(.title)

            Text("You are logged in!")

            Button("Log Out") {
                print("Logout button tapped")
                authViewModel.signOut()
                // ContentView will automatically switch back to LoginView
            }
            .buttonStyle(.bordered)
            .tint(.red)

            Spacer() // Push content to the top
        }
        .padding()
        // Set the title for the Navigation Bar
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline) // Or .large
        // Hide the default back button if coming from Login (optional)
        // .navigationBarBackButtonHidden(true)
    }
}
