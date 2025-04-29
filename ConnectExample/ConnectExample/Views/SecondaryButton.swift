//
//  Button.swift
//  ConnectExample
//
//  Created by Martin on 6/5/2025.
//

import SwiftUI

struct SecondaryButton: View {
    let label: String
    let isLoading: Bool
    let accessibilityIdentifier: String
    let action: () async -> Void

    @State private var isSpinning = false
    
    init(label: String, isLoading: Bool = false, accessibilityIdentifier: String = "", action: @escaping () async -> Void) {
        self.label = label
        self.isLoading = isLoading
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            ZStack {
                Text(label)
                    .opacity(isLoading ? 0 : 1)
                    .padding()
                    .frame(maxWidth: .infinity)                    
                    .foregroundColor(Color.black)
                    .cornerRadius(8)
                    
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .rotationEffect(.degrees(isSpinning ? 360 : 0))
                        .onAppear {
                            withAnimation(
                                Animation.linear(duration: 1)
                                    .repeatForever(autoreverses: false)
                            ) {
                                isSpinning = true
                            }
                        }
                }
            }            
        }
        .accessibilityIdentifier(accessibilityIdentifier)
        .disabled(isLoading)
    }
}
