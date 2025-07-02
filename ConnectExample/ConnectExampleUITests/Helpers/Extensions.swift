import XCTest

extension XCUIElement {
    func waitAndTap(timeout: TimeInterval = 10.0) {
        XCTAssertTrue(self.waitForExistence(timeout: timeout), "\(self.description) did not exist after \(timeout)s")
        XCTAssertTrue(self.isHittable, "\(self.description) was not hittable")
        self.tap()
    }
    
    func waitAndTapWithRetry(timeout: TimeInterval = 3.0) {
        waitAndTap(timeout: timeout)
        
        if self.waitForExistence(timeout: 0.5) {
            waitAndTap(timeout: 0.5)
        }
    }

    
    func clearAndTypeText(_ text: String, submit: Bool = false) {
        self.tap()
        
        if let currentText1 = self.value as? String, !currentText1.isEmpty {
            clearText()
            
            if let currentText2 = self.value as? String, !currentText2.isEmpty {
                clearText()
            }
        }
        
        self.typeText(text)
        
        if submit {
            self.typeText(XCUIKeyboardKey.return.rawValue)
        }
    }
    
    private func clearText() {
        let selectAll = XCUIApplication().menuItems["Select All"]
        self.press(forDuration: 1.0)
        if selectAll.waitForExistence(timeout: 1) {
            selectAll.tap()
        }
        
        guard let stringValue = (self.value as? String), !stringValue.isEmpty else {
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}

extension XCTestCase {
    /// Waits for a specified duration, repeatedly checking a condition until it's met or the timeout is reached.
    ///
    /// - Parameters:
    ///   - description: A string to display in the test log for this expectation.
    ///   - timeout: The maximum time to wait for the condition to be met.
    ///   - pollingInterval: The time interval between condition checks. Defaults to 0.1 seconds.
    ///   - condition: A closure that returns `true` when the desired condition is met, `false` otherwise.
    /// - Throws: An error if the timeout is reached before the condition is met.
    func waitForCondition(
        _ description: String = "Wait for condition",
        timeout: TimeInterval = 10.0,
        pollingInterval: TimeInterval = 0.25, // How often to check
        condition: @escaping () -> Bool
    ) throws {
        let expectation = XCTestExpectation(description: description)
        let startTime = Date()

        // Start a timer or a loop to check the condition
        Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { timer in
            if condition() {
                expectation.fulfill()
                timer.invalidate()
            } else if Date().timeIntervalSince(startTime) >= timeout {
                // Timeout reached, but condition not met. Invalidate timer.
                // The wait(for:timeout:) below will handle the timeout failure.
                timer.invalidate()
                // Optionally, fulfill the expectation here if you want to control the failure message
                // differently, but letting wait(for:timeout:) timeout is standard.
            }
        }

        // Wait for the expectation to be fulfilled or for the timeout
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)

        if result != .completed {
            // If the result is not .completed, it means it timed out (or was interrupted).
            // We can throw a more specific error or let XCTest's timeout message suffice.
            let failureReason = "Timed out after \(timeout) seconds waiting for \(description)."
            // You could create a custom error type here
            throw NSError(domain: "XCTestCase.waitForCondition", code: 0, userInfo: [NSLocalizedDescriptionKey: failureReason])
        }
    }
}
