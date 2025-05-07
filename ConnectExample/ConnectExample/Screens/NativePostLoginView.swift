//
//  NativePostLoginView.swift
//  ConnectExample
//
//  Created by Martin on 7/5/2025.
//

import SwiftUI

struct NativePostLoginView: View {
    @EnvironmentObject var appRouter: AppRouter
    
    @StateObject var viewModel: PostLoginViewModel

    init(appRouter: AppRouter) {
        _viewModel = StateObject(wrappedValue: PostLoginViewModel(appRouter: appRouter))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                 ProgressView("Loading...")
            } else {
                AnimatedButton(label: "Create passkey", isLoading: viewModel.primaryLoading) {
                    await viewModel.createPasskey()
                }
                
                AnimatedButton(label: "Skip", isLoading: false) {
                    await viewModel.skipPasskeyCreation()
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.loadInitialStep()
            }
        }
    }
}
