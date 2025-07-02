import Foundation
import XCTest

@MainActor
class ProfileScreen: BaseScreen {
    private lazy var passkeyListSection = app.staticTexts["profileScreen.passkeySection"]
    private lazy var signOutButton = app.buttons["profileScreen.signOut"]
    private lazy var passkeyAppendButton = app.buttons["profileScreen.appendPasskey"]
    private lazy var confirmPasskeyDeleteButton = app.buttons["Delete"]
    private lazy var reloadButton = app.buttons["profileScreen.reload"]
    
    private lazy var headline = app.staticTexts["profileScreen.headline"]
    private lazy var errorMessage = app.staticTexts["profileScreen.errorMessage"]
    private lazy var listMessage = app.staticTexts["profileScreen.listMessage"]
    
    func visible(timeout: TimeInterval = defaultTimeout) -> Bool {
        return headline.waitForExistence(timeout: timeout)
    }
    
    func appendPasskey(complete: Bool = true) {
        passkeyAppendButton.waitAndTap()
    }
    
    func deletePasskey(passkeyId: String, complete: Bool = true) {
        passkeyDeleteButton(passkeyId: passkeyId).waitAndTap()
        confirmPasskeyDeleteButton.waitAndTap()
    }

    func getErrorMessage() -> String? {
        if !errorMessage.waitForExistence(timeout: defaultTimeout) {
            return nil
        }
        
        return errorMessage.label
    }
    
    func getListMessage() -> String? {
        if !listMessage.waitForExistence(timeout: defaultTimeout) {
            return nil
        }
        
        return listMessage.label
    }

    
    func countNumberOfPasskeys() -> Int {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", "passkeyListEntry")
        let allMatchingElementsQuery = app.descendants(matching: .any).matching(predicate)
        _ = allMatchingElementsQuery.firstMatch.waitForExistence(timeout: defaultTimeout)
        
        return allMatchingElementsQuery.count
    }
    
    func getPasskeyIds() -> [String] {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", "passkeyListEntry")
        let allMatchingElementsQuery = app.descendants(matching: .any).matching(predicate)
        _ = allMatchingElementsQuery.firstMatch.waitForExistence(timeout: defaultTimeout)
        
        return allMatchingElementsQuery.allElementsBoundByIndex.map { $0.identifier }
            .filter { $0.hasPrefix("passkeyListEntry_") }
            .map { $0.replacingOccurrences(of: "passkeyListEntry_", with: "") }
    }
    
    func passkeyAppendPossible() -> Bool {
        return passkeyAppendButton.waitForExistence(timeout: defaultTimeout)
    }
    
    @discardableResult
    func signOut() -> LoginScreen{
        signOutButton.waitAndTap()
        
        return LoginScreen(app: app)
    }
    
    func reloadPage() {
        reloadButton.waitAndTap()
    }
    
    private func passkeyDeleteButton(passkeyId: String) -> XCUIElement {
        let passkeyListEntry = app.buttons["passkeyListEntry_\(passkeyId)"]
        return passkeyListEntry.buttons.firstMatch
    }
}
