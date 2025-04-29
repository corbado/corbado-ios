@MainActor
class SignUpScreen: BaseScreen {
    lazy var emailTextField = app.textFields["signUpScreen.emailField"]
    lazy var phoneNumberTextField = app.textFields["signUpScreen.phoneNumberField"]
    lazy var passwordTextField = app.secureTextFields["signUpScreen.passwordField"]
    
    lazy var submitButton = app.buttons["signUpScreen.submit"]
    lazy var passwordSaveNotNowButton = app.buttons["Not Now"]
    lazy var navigateToLoginButton = app.buttons["signUpScreen.navigateToLogin"]
    
    @discardableResult
    func signUpWithValidData(email: String, phoneNumber: String, password: String) async throws -> PostLoginScreen {
        emailTextField.waitAndTap()
        emailTextField.typeText(email)
        
        phoneNumberTextField.waitAndTap()
        phoneNumberTextField.typeText(phoneNumber)
        
        passwordTextField.waitAndTap()
        passwordTextField.typeText(password)
                     
        submitButton.waitAndTap()
        passwordSaveNotNowButton.waitAndTapWithRetry(timeout: 5.0)
        
        return PostLoginScreen(app: app)
    }
    
    @discardableResult
    func navigateToLogin() -> LoginScreen {
        navigateToLoginButton.waitAndTap()
        return LoginScreen(app: app)
    }
}
