import Foundation
import XCTest

@MainActor
class TOTPSetupScreen: BaseScreen {
    lazy var setupButton = app.buttons["totpSetupScreen.complete"]
    lazy var totpCodeTextField = app.textFields["totpSetupScreen.totpCode"]
    lazy var setupKey = app.staticTexts["totpSetupScreen.setupKey"]
    
    func setupTOTP(authenticatorApp: AuthenticatorApp) async throws -> (ProfileScreen, String) {
        _ = setupKey.waitForExistence(timeout: 2)
        let setupKeyValue = setupKey.label
        let code = await authenticatorApp.addBySetupKey(setupKeyValue)
        guard let code = code else {
            throw XCTestError(.failureWhileWaiting)
        }

        totpCodeTextField.clearAndTypeText(code)
        setupButton.waitAndTap()
        
        return (ProfileScreen(app: app), setupKeyValue)
    }
}
