import XCTest

let defaultTimeout = 15.0

@MainActor
class BaseScreen {
    let app: XCUIApplication
    private lazy var networkBlockingTextField = app.textFields["main.networkBlocking"]

    init(app: XCUIApplication) {
        self.app = app
    }
    
    func block(blockedUrl: String) {
        networkBlockingTextField.clearAndTypeText(blockedUrl, submit: true)
    }
    
    func unblock() {
        networkBlockingTextField.clearAndTypeText("", submit: true)
    }
}
