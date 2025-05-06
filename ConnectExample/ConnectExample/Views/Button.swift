//
//  Button.swift
//  ConnectExample
//
//  Created by Martin on 6/5/2025.
//

import SwiftUI

struct AnimatedButton: View {
    let label: String
    let isLoading: Bool
    let action: () async -> Void

    @State private var isSpinning = false
    
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
                    .background(Color.blue)
                    .foregroundColor(Color.white)
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
        .disabled(isLoading)
    }
}
