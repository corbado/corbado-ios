import XCTest

enum LoginStatus {
    case fallbackFirst
    case fallbackSecondTOTP
    case passkeyTextField
    case passkeyOneTap
    case passkeyErrorSoft
    case passkeyErrorHard
}

@MainActor
class LoginScreen: BaseScreen {
    private lazy var navigateToSignUpButton = app.buttons["loginScreen.navigateToSignUp"]
    private lazy var switchAccountButton = app.buttons["loginScreen.switchAccount"]
    private lazy var loginConventionalButton = app.buttons["loginScreen.loginConventional"]
    private lazy var loginPasskeyButton = app.buttons["loginScreen.loginPasskey"]
    private lazy var loginPasskeyOneTapButton = app.buttons["loginScreen.loginOneTap"]
    private lazy var submitTOTPButton = app.buttons["loginScreen.submitTOTP"]
    private lazy var passwordSaveNotNowButton = app.buttons["Not Now"]
    private lazy var loginPasskeyErrorSoftButton = app.buttons["loginScreen.errorSoftContinue"]
    private lazy var loginPasskeyErrorHardButton = app.buttons["loginScreen.errorHardContinue"]
    
    private lazy var conventionalEmailTextField = app.textFields["loginScreen.conventionalEmail"]
    private lazy var conventionalPasswordTextField = app.secureTextFields["loginScreen.conventionalPassword"]
    private lazy var passkeyEmailTextField = app.textFields["loginScreen.passkeyEmail"]
    private lazy var totpCodeTextField = app.textFields["loginScreen.totpCode"]
    
    private lazy var errorMessage = app.staticTexts["loginScreen.errorMessage"]
    
    @discardableResult
    func navigateToSignUp() -> SignUpScreen {
        navigateToSignUpButton.waitAndTap()
        return SignUpScreen(app: app)
    }
    
    func switchAccount() {
        switchAccountButton.waitAndTap()
    }
    
    func awaitState(loginStatus: LoginStatus, errorMessage: String? = nil, timeout: TimeInterval = defaultTimeout) -> Bool {
        var errorMessageMatches = true
        var loginStatusMatches = true
        
        switch loginStatus {
        case .fallbackFirst:
            loginStatusMatches = loginConventionalButton.waitForExistence(timeout: timeout)
        case .passkeyOneTap:
            loginStatusMatches = loginPasskeyOneTapButton.waitForExistence(timeout: timeout)
        case .passkeyTextField:
            loginStatusMatches = loginPasskeyButton.waitForExistence(timeout: timeout)
        case .fallbackSecondTOTP:
            loginStatusMatches = submitTOTPButton.waitForExistence(timeout: timeout)
        case .passkeyErrorSoft:
            loginStatusMatches = loginPasskeyErrorSoftButton.waitForExistence(timeout: timeout)
        case .passkeyErrorHard:
            loginStatusMatches = loginPasskeyErrorHardButton.waitForExistence(timeout: timeout)
        }
        
        if let errorMessage = errorMessage {
            errorMessageMatches = self.errorMessage.label == errorMessage
        }
        
        return loginStatusMatches && errorMessageMatches
    }
    
    @discardableResult
    func loginWithOneTap() -> PostLoginScreen {
        loginPasskeyOneTapButton.waitAndTap()
        
        return PostLoginScreen(app: app)
    }
    
    func loginWithOneTapAndCancel() {
        loginPasskeyOneTapButton.waitAndTap()
    }
    
    @discardableResult
    func loginOnPasskeyErrorSoft() -> PostLoginScreen {
        loginPasskeyErrorSoftButton.waitAndTap()
        
        return PostLoginScreen(app: app)
    }
    
    @discardableResult
    func loginOnPasskeyErrorHard() -> PostLoginScreen {
        loginPasskeyErrorHardButton.waitAndTap()
        
        return PostLoginScreen(app: app)
    }
    
    @discardableResult
    func loginWithIdentifier(email: String) -> PostLoginScreen {
        passkeyEmailTextField.waitAndTap()
        passkeyEmailTextField.typeText(email)
        loginPasskeyButton.waitAndTap()
        
        return PostLoginScreen(app: app)
    }
    
    @discardableResult
    func loginWithOverlay() -> ProfileScreen {
        return ProfileScreen(app: app)
    }
    
    func loginWithIdentifierButNoSuccess(email: String) {
        passkeyEmailTextField.waitAndTap()
        passkeyEmailTextField.typeText(email)
        loginPasskeyButton.waitAndTap()
    }
    
    func loginWithIdentifierAndPassword(email: String, password: String, fallback: Bool = false) throws {
        if fallback {
            conventionalEmailTextField.waitAndTap()
            conventionalEmailTextField.typeText(email)

            conventionalPasswordTextField.waitAndTap()
            conventionalPasswordTextField.typeText(password)
            loginConventionalButton.waitAndTap()
        } else {
            passkeyEmailTextField.waitAndTap()
            passkeyEmailTextField.typeText(email)

            loginPasskeyButton.waitAndTap()
            if !awaitState(loginStatus: .fallbackFirst, timeout: defaultTimeout) {
                throw XCTestError(.failureWhileWaiting)
            }
                        
            conventionalPasswordTextField.waitAndTap()
            conventionalPasswordTextField.typeText(password)
            loginConventionalButton.waitAndTap()
        }
        
        passwordSaveNotNowButton.waitAndTapWithRetry(timeout: defaultTimeout)
    }
    
    @discardableResult
    func completeLoginWithTOTP(code: String) -> PostLoginScreen {
        totpCodeTextField.waitAndTap()
        totpCodeTextField.typeText(code)

        submitTOTPButton.waitAndTap()
        
        return PostLoginScreen(app: app)
    }
}
