import XCTest

@MainActor
class PostLoginScreen: BaseScreen {
    private lazy var appendButton = app.buttons["postLoginScreen.append"]
    private lazy var continueButton = app.buttons["postLoginScreen.continue"]
    private lazy var skipButton = app.buttons["postLoginScreen.skip"]
    private lazy var errorMessage = app.staticTexts["postLoginScreen.errorMessage"]
    
    @discardableResult
    func append(expectAutoAppend: Bool) -> ProfileScreen {
        if !expectAutoAppend {
            appendButton.waitAndTap()
        }
        
        continueButton.waitAndTap(timeout: defaultTimeout)
        
        return ProfileScreen(app: app)
    }
    
    func appendAndCancel() -> Bool {
        appendButton.waitAndTap()
        return errorMessage.waitForExistence(timeout: defaultTimeout)
    }
    
    @discardableResult
    func skipAfterSignUp() -> TOTPSetupScreen {
        skipButton.waitAndTap()
        
        return TOTPSetupScreen(app: app)
    }
    
    @discardableResult
    func autoSkipAfterSignUp() -> TOTPSetupScreen {
        return TOTPSetupScreen(app: app)
    }
    
    @discardableResult
    func skip() -> ProfileScreen {
        skipButton.waitAndTap()
        
        return ProfileScreen(app: app)
    }
    
    @discardableResult
    func autoSkip() -> ProfileScreen {
        return ProfileScreen(app: app)
    }
}
