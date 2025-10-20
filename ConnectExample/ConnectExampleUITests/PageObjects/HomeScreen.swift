import Foundation
import XCTest
import SimpleAuthenticationServicesMocks

@MainActor
class HomeScreen: BaseScreen {
    private lazy var backButton = app.buttons["homeScreen.backButton"]
    private lazy var dummyButton1 = app.buttons["homeScreen.dummyButton1"]
    private lazy var localDebounceTextField = app.textFields["homeScreen.localDebounceTextField"]
    private lazy var bottomSheetContinue = app.buttons["bottomSheet.continueButton"]
    private lazy var headline = app.staticTexts["homeScreen.headline"]
    
    func visible(timeout: TimeInterval = defaultTimeout) -> Bool {
        return headline.waitForExistence(timeout: timeout)
    }
    
    func navigateBackToProfileScreen() -> ProfileScreen {
        backButton.waitAndTap()
        return ProfileScreen(app: app)
    }
    
    func setLocalDebounceDays(_ days: String) {
        localDebounceTextField.waitAndTap()
        localDebounceTextField.typeText(days)
    }
    
    func acceptAutomaticAppend(instant: Bool) {
        // the append-start call needs some time
        sleep(1)
        
        if (!instant) {
            dummyButton1.waitAndTap()
        }
        sleep(3)
    }
    
    func declineAutomaticAppend(controlServer: ControlServer, instant: Bool) {
        controlServer.createError = .cancelled
        
        // the append-start call needs some time
        sleep(1)
        
        if (!instant) {
            dummyButton1.waitAndTap()
        }
        sleep(3)
        controlServer.createError = nil
    }
    
    func acceptBottomSheetAppend() {
        sleep(1)
        bottomSheetContinue.waitAndTap()
        sleep(2)
    }
    
    func declineBottomSheet() {
        _ = bottomSheetContinue.waitForExistence(timeout: defaultTimeout)
        let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        coordinate.tap()
    }
    
    func clickButton1(expectDummyDialog: Bool) {
        // the append-start call needs some time
        sleep(1)
        
        dummyButton1.waitAndTap()
        if expectDummyDialog {
            app.buttons["OK"].waitAndTap()
            sleep(2)
        }
    }
}

