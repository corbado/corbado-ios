//
//  NativePostLoginView.swift
//  ConnectExample
//
//  Created by Martin on 7/5/2025.
//

import SwiftUI

struct PostLoginView: View {
    @EnvironmentObject var appRouter: AppRouter
    
    @StateObject var viewModel: PostLoginViewModel

    init(appRouter: AppRouter) {
        _viewModel = StateObject(wrappedValue: PostLoginViewModel(appRouter: appRouter))
    }
    
    init(viewModel: PostLoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            switch viewModel.state {
                case .loading:
                 ProgressView("Loading...")
            case .passkeyAppend:
                ScreenHeadline(title: "Simplify your Sign In", accessibilityIdentifier: "postLoginScreen.headline")

                Text("Create a passkey")
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.top, 5)

                if viewModel.errorMessage != nil {
                    Text(viewModel.errorMessage!)
                        .foregroundColor(.red)
                        .accessibilityIdentifier("postLoginScreen.errorMessage")
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                }

                Image("PasskeyAppend")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 120)
                    .padding(.vertical, 30)
                
                Text("Sign in easily now with your fingerprint, face, or PIN. Sync across your devices.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                PrimaryButton(label: "Create passkey", isLoading: viewModel.primaryLoading, accessibilityIdentifier: "postLoginScreen.append") {
                    await viewModel.createPasskey()
                }
                .padding(.top, 20)
                
                SecondaryButton(label: "Skip", isLoading: false, accessibilityIdentifier: "postLoginScreen.skip") {
                    await viewModel.skipPasskeyCreation()
                }
                
                Spacer()
            case .passkeyAppended:
                ScreenHeadline(title: "Passkey Created Successfully", accessibilityIdentifier: "postLoginScreen.headline")
                
                PasskeyAppendSuccess {
                    viewModel.navigateAfterPasskeyAppend()
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

#Preview {
    let viewModel = PostLoginViewModel(appRouter: AppRouter())
    viewModel.setupPreview()
    
    return PostLoginView(viewModel: viewModel)
}
