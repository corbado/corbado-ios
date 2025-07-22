//
//  LoginView.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appRouter: AppRouter
    
    @StateObject private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    init(appRouter: AppRouter) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(appRouter: appRouter))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Button {
                Task {
                    await viewModel.incrementInvitationTokenCounter()
                }
            } label: {
                ScreenHeadline(title: "Login", accessibilityIdentifier: "loginScreen.headline")
            }
            .buttonStyle(.plain)
            
            switch viewModel.status {
            case .loading:
                ProgressView()
            case .fallbackFirst:
                FallbackLoginView(viewModel: viewModel)
            case .fallbackSecondTOTP:
                FallbackTOTPView(viewModel: viewModel)
            case .fallbackSecondSMS:
                FallbackSMSView(viewModel: viewModel)
            case .passkeyTextField:
                PasskeyTextFieldView(viewModel: viewModel)
            case .passkeyOneTap:
                PasskeyOneTapView(viewModel: viewModel)
            case .passkeyErrorSoft:
                PasskeyErrorSoftView(viewModel: viewModel)
            case .passkeyErrorHard:
                PasskeyErrorHardView(viewModel: viewModel)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.loadInitialStep()
            }
        }
    }
}

struct FallbackLoginView: View {
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .accessibilityIdentifier("loginScreen.errorMessage")
            }
            
            TextField("Email", text: $viewModel.email)
                .padding()
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .accessibilityIdentifier("loginScreen.conventionalEmail")
            
            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .accessibilityIdentifier("loginScreen.conventionalPassword")
            
            PrimaryButton(label: "Login", isLoading: viewModel.primaryLoading, accessibilityIdentifier: "loginScreen.loginConventional") {
                await viewModel.loginWithEmailAndPassword()
            }
            
            SecondaryButton(label: "Don't have an account? Sign Up", accessibilityIdentifier: "loginScreen.navigateToSignUp") {
                viewModel.navigateToSignUp()
            }
        }
    }
}

struct PasskeyTextFieldView: View {
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .accessibilityIdentifier("loginScreen.errorMessage")
            }
            
            TextField("Email", text: $viewModel.email)
                .padding()
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .accessibilityIdentifier("loginScreen.passkeyEmail")
            
            PrimaryButton(label: "Login", isLoading: viewModel.primaryLoading, accessibilityIdentifier: "loginScreen.loginPasskey") {
                await viewModel.loginWithPasskeyTextField()
            }
            
            SecondaryButton(label: "Don't have an account? Sign Up", accessibilityIdentifier: "loginScreen.navigateToSignUp") {
                viewModel.navigateToSignUp()
            }
        }
    }
}

struct FallbackTOTPView: View {
    @StateObject var viewModel: LoginViewModel
    
    @State private var code = ""
    
    var body: some View {
        VStack(spacing: 20) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .accessibilityIdentifier("loginScreen.errorMessage")
            }
            
            Text("Provide your TOTP code.").font(.title2)
            
            TextField("6-digit TOTP", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .accessibilityIdentifier("loginScreen.totpCode")
            
            PrimaryButton(label: "Submit", isLoading: viewModel.primaryLoading, accessibilityIdentifier: "loginScreen.submitTOTP") {
                viewModel.verifyTOTP(code: code)
            }
        }
        .padding()
    }
}

struct FallbackSMSView: View {
    @StateObject var viewModel: LoginViewModel
    
    @State private var code = ""
    
    var body: some View {
        VStack(spacing: 20) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .accessibilityIdentifier("loginScreen.errorMessage")
            }
            
            Text("Provide your SMS code.").font(.title2)
            
            TextField("6-digit code", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .accessibilityIdentifier("loginScreen.smsCode")
            
            PrimaryButton(label: "Submit", isLoading: viewModel.primaryLoading, accessibilityIdentifier: "loginScreen.submitSMS") {
                viewModel.verifySMS(code: code)
            }
        }
        .padding()
    }
}


struct PasskeyOneTapView: View {
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .accessibilityIdentifier("loginScreen.errorMessage")
            }
            
            PrimaryButton(label: "Login as \(viewModel.email)", isLoading: viewModel.primaryLoading, accessibilityIdentifier: "loginScreen.loginOneTap") {
                await viewModel.loginWithPasskeyOneTap()
            }
            
            PrimaryButton(label: "Switch account", isLoading: false, accessibilityIdentifier: "loginScreen.switchAccount") {
                await viewModel.discardPasskeyOneTap()
            }
            
            SecondaryButton(label: "Don't have an account? Sign Up", accessibilityIdentifier: "loginScreen.navigateToSignUp") {
                viewModel.navigateToSignUp()
            }
        }
    }
}

struct PasskeyErrorSoftView: View {
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Use your passkey to confirm it’s really you")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
                .multilineTextAlignment(.center)
            
            Image("PasskeyAppend")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 120)
                .padding(.vertical, 30)
            
            Text("Your device will ask you for your fingerprint, face or screen lock.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            PrimaryButton(label: "Continue", isLoading: viewModel.primaryLoading, accessibilityIdentifier: "loginScreen.errorSoftContinue") {
                await viewModel.loginWithPasskeyOneTap()
            }
            .padding(.top, 20)
            
            SecondaryButton(label: "Use password instead", accessibilityIdentifier: "loginScreen.errorSoftPassword") {
                viewModel.discardPasskeyLogin()
            }
        }
    }
}

struct PasskeyErrorHardView: View {
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
                .multilineTextAlignment(.center)
            
            Image("PasskeyError")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 120)
                .padding(.vertical, 30)
            
            Text("Login with passkeys was not possible.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            PrimaryButton(label: "Try again", isLoading: viewModel.primaryLoading, accessibilityIdentifier: "loginScreen.errorHardContinue") {
                await viewModel.loginWithPasskeyOneTap()
            }
            .padding(.top, 20)
            
            SecondaryButton(label: "Skip passkey login", accessibilityIdentifier: "loginScreen.errorHardPassword") {
                viewModel.discardPasskeyLogin()
            }
        }
    }
}



struct LoginView_Previews: PreviewProvider {
    struct PreviewConfig: Identifiable {
        let id: String
        let status: LoginStatus
        let displayName: String

        init(status: LoginStatus, displayName: String) {
            self.id = displayName
            self.status = status
            self.displayName = displayName
        }
    }

    // Array of all your preview configurations
    static let previewConfigs: [PreviewConfig] = [
        .init(status: .fallbackFirst, displayName: "FallbackLogin"),
        .init(status: .fallbackSecondTOTP, displayName: "FallbackTOTP"),
        .init(status: .passkeyTextField, displayName: "PasskeyTextField"),
        .init(status: .passkeyOneTap, displayName: "PasskeyOneTap"),
        .init(status: .passkeyErrorSoft, displayName: "PasskeyErrorSoft"),
        .init(status: .passkeyErrorHard, displayName: "PasskeyErrorHard")
    ]

    static var previews: some View {
        // Create the AppRouter once
        let appRouter = AppRouter()

        ForEach(previewConfigs) { config in
            let viewModel = LoginViewModel(appRouter: appRouter)
            viewModel.setupPreview(status: config.status)
            //viewModel.email = "jane@doe.com"

            return LoginView(viewModel: viewModel)
                .previewDisplayName(config.displayName)
                .environmentObject(appRouter)
        }
    }
}
