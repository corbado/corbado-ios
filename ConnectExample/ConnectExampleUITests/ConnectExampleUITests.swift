import XCTest
import SimpleAuthenticationServices
import SimpleAuthenticationServicesMocks

@MainActor
final class ConnectExampleUITests: XCTestCase {
    var controlServer: ControlServer!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        controlServer.stop()
        controlServer = nil
        
        try super.tearDownWithError()
    }
    
    /*
     - signup with passkey (we simulate a retry after cancelled auto-append)
     - list passkeys
     - sign out and login with one-tap
     - list passkeys
     - append passkey => excludeCredentials
     */
    func testAppendAfterSignUp() async throws {
        let initialScreen = try startApp()
        let email = TestDataFactory.createEmail()
        
        controlServer.createError = .cancelled
        let signUpScreen = initialScreen.navigateToSignUp()
        let postLoginScreen = try await signUpScreen.signUpWithValidData(email: email, phoneNumber: TestDataFactory.phoneNumber, password: TestDataFactory.password)
        
        // here we will get an auto-append, that is cancelled at first but then accepted in a second try
        
        controlServer.createError = nil
        let profileScreen = postLoginScreen.append(expectAutoAppend: false)
        
        let passkeyCount = profileScreen.countNumberOfPasskeys()
        XCTAssertEqual(passkeyCount, 1)
        let loginScreen = profileScreen.signOut()
        
        XCTAssertTrue(loginScreen.awaitState(loginStatus: .passkeyOneTap))
        let profileScreen2 = loginScreen.loginWithOneTap().autoSkip()
        try waitForCondition(timeout: 10) { profileScreen2.countNumberOfPasskeys() == 1}
        
        profileScreen2.appendPasskey()
        XCTAssertEqual(profileScreen2.getErrorMessage(), "You already have a passkey that can be used on this device.")
        XCTAssertEqual(passkeyCount, 1)
    }
    
    /*
     - signup user with TOTP
     - signout and login with TOTP
     - append passkey through passkey-list
     - signout and login with passkey
     - delete passkey
     - signout and login with TOTP
     */
    func testAppendAfterSignUpSkipped() async throws {
        let initialScreen = try startApp()
        let authenticatorApp = AuthenticatorApp()
        let email = TestDataFactory.createEmail()
        
        controlServer.createError = .cancelled
        
        let signUpScreen = initialScreen.navigateToSignUp()
        let postLoginScreen = try await signUpScreen.signUpWithValidData(email: email, phoneNumber: TestDataFactory.phoneNumber, password: TestDataFactory.password)
        let tOTPSetupScreen = postLoginScreen.skipAfterSignUp()
        
        let (profileScreen, setupKey) = try await tOTPSetupScreen.setupTOTP(authenticatorApp: authenticatorApp)
        
        XCTAssertEqual(profileScreen.countNumberOfPasskeys(), 0)
        
        let loginScreen = profileScreen.signOut()
        XCTAssertTrue(loginScreen.awaitState(loginStatus: .passkeyTextField))
        try loginScreen.loginWithIdentifierAndPassword(email: email, password: TestDataFactory.password)
        XCTAssertTrue(loginScreen.awaitState(loginStatus: .fallbackSecondTOTP))
        let code = try await authenticatorApp.getCode(setupKey)
        let profileScreen2 = loginScreen.completeLoginWithTOTP(code: code!).skip()
        
        
        controlServer.createError = nil
        try waitForCondition(timeout: 10) { profileScreen.countNumberOfPasskeys() == 0}
        profileScreen2.appendPasskey()
        try waitForCondition(timeout: 10) { profileScreen.countNumberOfPasskeys() == 1}
        let passkeyId = profileScreen2.getPasskeyIds()[0]
        profileScreen2.signOut()
        
        XCTAssertTrue(loginScreen.awaitState(loginStatus: .passkeyOneTap))
        let profileScreen3 = loginScreen.loginWithOneTap().autoSkip()
        
        try waitForCondition(timeout: 10) { profileScreen3.countNumberOfPasskeys() == 1}
        profileScreen3.deletePasskey(passkeyId: passkeyId, complete: true)
        try waitForCondition(timeout: 10) { profileScreen3.countNumberOfPasskeys() == 0}
        let loginScreen2 = profileScreen3.signOut()
        
        XCTAssertTrue(loginScreen2.awaitState(loginStatus: .passkeyTextField))
        try loginScreen2.loginWithIdentifierAndPassword(email: email, password: TestDataFactory.password)
        XCTAssertTrue(loginScreen2.awaitState(loginStatus: .fallbackSecondTOTP))
        let code2 = try await authenticatorApp.getCode(setupKey)
        _ = loginScreen2.completeLoginWithTOTP(code: code2!).autoSkip()
    }
    
    /*
     - signup with passkey
     - signout and remove one-tap
     - complete login with identifier from text-field
     - expect one passkey on passkey-list
     */
    func testLoginWithTextField() async throws {
        let initialScreen = try startApp()
        let email = TestDataFactory.createEmail()
        
        let signUpScreen = initialScreen.navigateToSignUp()
        let profileScreen = try await signUpScreen.signUpWithValidData(email: email, phoneNumber: TestDataFactory.phoneNumber, password: TestDataFactory.password).append(expectAutoAppend: true)
        let loginScreen = profileScreen.signOut()
        
        loginScreen.switchAccount()
        let profileScreen2 = loginScreen.loginWithIdentifier(email: email).autoSkip()
        try waitForCondition(timeout: 10) { profileScreen2.countNumberOfPasskeys() == 1}
    }
    
    /*
     - signup with passkey
     - signout and expect one-tap
     - cancel one-tap login
     - complete login from error-soft
     */
    func testLoginWithOneTap() async throws {
        let initialScreen = try startApp()
        let email = TestDataFactory.createEmail()
        
        let signUpScreen = initialScreen.navigateToSignUp()
        let loginScreen = try await signUpScreen.signUpWithValidData(email: email, phoneNumber: TestDataFactory.phoneNumber, password: TestDataFactory.password).append(expectAutoAppend: true).signOut()
        XCTAssertTrue(loginScreen.awaitState(loginStatus: .passkeyOneTap))
        
        controlServer.authorizeError = .cancelled
        loginScreen.loginWithOneTapAndCancel()
        XCTAssertTrue(loginScreen.awaitState(loginStatus: .passkeyErrorSoft))
        
        controlServer.authorizeError = nil
        
        let profileScreen2 = loginScreen.loginOnPasskeyErrorSoft().autoSkip()
        try waitForCondition(timeout: 10) { profileScreen2.countNumberOfPasskeys() == 1}
    }
    
    /*
     - signup with passkey
     - signout and remove one-tap
     - wait for overlay login to trigger and expect login to complete
     */
    func testLoginWithOverlay() async throws {
        let initialScreen = try startApp(enableOverlay: true)
        let email = TestDataFactory.createEmail()
        
        // we first create an account with passkey
        let signUpScreen = initialScreen.navigateToSignUp()
                
        let loginScreen = try await signUpScreen.signUpWithValidData(email: email, phoneNumber: TestDataFactory.phoneNumber, password: TestDataFactory.password).append(expectAutoAppend: true).signOut()
        // to get CUI offered, we need to remove OneTap first
        loginScreen.switchAccount()
        let loginScreen2 = loginScreen.navigateToSignUp().navigateToLogin()
        
        let profileScreen = loginScreen2.loginWithOverlay()
        try waitForCondition(timeout: 10) { profileScreen.countNumberOfPasskeys() == 1}
    }
    
    /* 1.2
     - login with a non-existing identifier and expect and error
     */
    func testLoginErrorStates() async throws {
        let initialScreen = try startApp()
        let nonExistingEmail = "integration-test+0000000000@corbado.com"
        
        XCTAssertTrue(initialScreen.awaitState(loginStatus: .passkeyTextField))
        initialScreen.loginWithIdentifierButNoSuccess(email: nonExistingEmail)
        
        XCTAssertTrue(initialScreen.awaitState(loginStatus: .passkeyTextField, errorMessage: "There is no account registered to that email address."))
    }
    
    /* 1.7
     - signup user with TOTP (passkey append must not be offered because of GR)
     - on profile there must be no append button
     - signout and login with TOTP (passkey append must be skipped again)
     */
    func testLoginErrorStatesGradualRollout() async throws {
        let initialScreen = try startApp(filteredByGradualRollout: true)
        let authenticatorApp = AuthenticatorApp()
        let email = TestDataFactory.createEmail()
        
        XCTAssertTrue(initialScreen.awaitState(loginStatus: .fallbackFirst), "Login must init in fallback automatically")
        let signUpScreen = initialScreen.navigateToSignUp()
        
        // append must be skipped automatically
        let tOTPSetupScreen = try await signUpScreen.signUpWithValidData(email: email, phoneNumber: TestDataFactory.phoneNumber, password: TestDataFactory.password).autoSkipAfterSignUp()
        let (profileScreen, setupKey) = try await tOTPSetupScreen.setupTOTP(authenticatorApp: authenticatorApp)
        XCTAssertTrue(profileScreen.visible(timeout: 10.0), "Profile screen must be visible")
        XCTAssertFalse(profileScreen.passkeyAppendPossible(), "passkey append button must be hidden")
        let loginScreen2 = profileScreen.signOut()
        
        try loginScreen2.loginWithIdentifierAndPassword(email: email, password: TestDataFactory.password, fallback: true)
        let code = try await authenticatorApp.getCode(setupKey)
        let profileScreen2 = loginScreen2.completeLoginWithTOTP(code: code!).autoSkip()
        XCTAssertTrue(profileScreen2.visible(timeout: 10.0), "Profile screen must be visible")
    }
        
    /* 1.13
     - signup user with passkey
     - delete passkey
     - signout and let overlay trigger => expect error message because passkey has been deleted
     */
    func testLoginErrorStatesPasskeyDeletedServerSide() async throws {
        let initialScreen = try startApp(enableOverlay: true)
        let email = TestDataFactory.createEmail()
        
        let profileScreen = try await initialScreen
            .navigateToSignUp()
            .signUpWithValidData(email: email, phoneNumber: TestDataFactory.phoneNumber, password: TestDataFactory.password)
            .append(expectAutoAppend: true)
        
        let passkeyId = profileScreen.getPasskeyIds()[0]
        profileScreen.deletePasskey(passkeyId: passkeyId)
        try waitForCondition(timeout: 10) { profileScreen.countNumberOfPasskeys() == 0}
                
        let loginScreen = profileScreen.signOut()
        XCTAssertTrue(loginScreen.awaitState(loginStatus: .fallbackFirst, errorMessage: "You previously deleted this passkey. Use your password to log in instead."))
    }
    
    // - block login-init
    // - block login-start
    // - block login-finish
    func testLoginErrorStatesNetworkBlocking() async throws {
        let initialScreen = try startApp()
        let email = TestDataFactory.createEmail()
        
        let profileScreen = try await initialScreen
            .navigateToSignUp()
            .signUpWithValidData(email: email, phoneNumber: TestDataFactory.phoneNumber, password: TestDataFactory.password)
            .append(expectAutoAppend: true)
        
        // block login-init
        initialScreen.block(blockedUrl: "/connect/login/init")
        let loginScreen = profileScreen.signOut()
        XCTAssertTrue(loginScreen.awaitState(loginStatus: .fallbackFirst), "Login must init in fallback automatically")
        
        // block login-start
        initialScreen.block(blockedUrl: "/connect/login/start")
        loginScreen.navigateToSignUp().navigateToLogin()
        XCTAssertTrue(initialScreen.awaitState(loginStatus: .passkeyOneTap))
        loginScreen.switchAccount()
        loginScreen.loginWithIdentifierButNoSuccess(email: email)
        XCTAssertTrue(initialScreen.awaitState(loginStatus: .fallbackFirst))
        
        // block login-finish
        initialScreen.block(blockedUrl: "/connect/login/finish")
        loginScreen.navigateToSignUp().navigateToLogin()                
        loginScreen.loginWithIdentifier(email: email)
        XCTAssertTrue(initialScreen.awaitState(loginStatus: .fallbackFirst, errorMessage: "Passkey error. Use password to log in.", timeout: 10.0))
        initialScreen.unblock()
        
        // successfull login
        loginScreen.navigateToSignUp().navigateToLogin()
        let profileScreen2 = loginScreen.loginWithIdentifier(email: email).autoSkip()
        XCTAssertTrue(profileScreen2.visible(timeout: 10.0))
    }
    
    func testAppendErrorStatesNetworkBlocking() async throws {
        let initialScreen = try startApp()
        let authenticatorApp = AuthenticatorApp()
        let email = TestDataFactory.createEmail()
        
        controlServer.createError = .cancelled
        let (profileScreen, setupKey) = try await initialScreen
            .navigateToSignUp()
            .signUpWithValidData(email: email, phoneNumber: TestDataFactory.phoneNumber, password: TestDataFactory.password)
            .skipAfterSignUp()
            .setupTOTP(authenticatorApp: authenticatorApp)
        controlServer.createError = nil

        let loginScreen = profileScreen.signOut()
        try loginScreen.loginWithIdentifierAndPassword(email: email, password: TestDataFactory.password)
        let code = try await authenticatorApp.getCode(setupKey)
        
        // block append-init
        initialScreen.block(blockedUrl: "/connect/append/init")
        let postLoginScreen = loginScreen.completeLoginWithTOTP(code: code!)
        let profileScreen2 = postLoginScreen.autoSkip()
        XCTAssertTrue(profileScreen2.visible(timeout: 10.0))
        
        let loginScreen2 = profileScreen2.signOut()
        try loginScreen2.loginWithIdentifierAndPassword(email: email, password: TestDataFactory.password)
        let code2 = try await authenticatorApp.getCode(setupKey)

        // block append-start
        initialScreen.block(blockedUrl: "/connect/append/start")
        let profileScreen3 = loginScreen.completeLoginWithTOTP(code: code2!).autoSkip()
        XCTAssertTrue(profileScreen3.visible(timeout: 10.0))
        
        let loginScreen3 = profileScreen3.signOut()
        try loginScreen3.loginWithIdentifierAndPassword(email: email, password: TestDataFactory.password)
        let code3 = try await authenticatorApp.getCode(setupKey)
        
        // block append-finish
        initialScreen.block(blockedUrl: "/connect/append/finish")
        let profileScreen4 = loginScreen.completeLoginWithTOTP(code: code3!).autoSkip()
        XCTAssertTrue(profileScreen4.visible(timeout: 10.0))        
    }
    
    func testManageErrorStatesNetworkBlocking() async throws {
        let initialScreen = try startApp()
        let email = TestDataFactory.createEmail()
        
        let profileScreen = try await initialScreen
            .navigateToSignUp()
            .signUpWithValidData(email: email, phoneNumber: TestDataFactory.phoneNumber, password: TestDataFactory.password)
            .append(expectAutoAppend: true)
        
        XCTAssertTrue(profileScreen.visible(timeout: 10.0))
        let passkeyCount = profileScreen.countNumberOfPasskeys()
        XCTAssertEqual(passkeyCount, 1)
        
        // block manage-init
        initialScreen.block(blockedUrl: "/connect/manage/init")
        profileScreen.reloadPage()
        XCTAssertTrue(profileScreen.visible(timeout: 10.0))
        
        XCTAssertEqual(profileScreen.getErrorMessage(), "Unable to access passkeys. Check your connection and try again.")
        XCTAssertEqual(profileScreen.getListMessage(), "We were unable to show your list of passkeys due to an error. Try again later.")
        
        // block manage-list
        initialScreen.block(blockedUrl: "/connect/manage/list")
        profileScreen.reloadPage()
        XCTAssertTrue(profileScreen.visible(timeout: 10.0))
        
        XCTAssertEqual(profileScreen.getErrorMessage(), "Unable to access passkeys. Check your connection and try again.")
        XCTAssertEqual(profileScreen.getListMessage(), "We were unable to show your list of passkeys due to an error. Try again later.")

        // block append-start
        initialScreen.block(blockedUrl: "/connect/append/start")
        profileScreen.reloadPage()
        XCTAssertTrue(profileScreen.visible(timeout: 10.0))
        XCTAssertEqual(profileScreen.countNumberOfPasskeys(), 1)
        profileScreen.appendPasskey()
        
        XCTAssertEqual(profileScreen.getErrorMessage(), "Passkey creation failed. Please try again later.")
        XCTAssertEqual(profileScreen.countNumberOfPasskeys(), 1)
        
        // block append-finish (we have to delete the passkey first, otherwise we get an excludeCredentials error)
        profileScreen.deletePasskey(passkeyId: profileScreen.getPasskeyIds()[0], complete: true)
        try waitForCondition(timeout: 10) { profileScreen.countNumberOfPasskeys() == 0}
        
        initialScreen.block(blockedUrl: "/connect/append/finish")
        profileScreen.reloadPage()
        XCTAssertTrue(profileScreen.visible(timeout: 10.0))
        profileScreen.appendPasskey()
        
        XCTAssertEqual(profileScreen.getErrorMessage(), "Passkey creation failed. Please try again later.")
        XCTAssertEqual(profileScreen.getListMessage(), "There is currently no passkey saved for this account.")
        
        // block manage-delete
        initialScreen.block(blockedUrl: "/connect/manage/delete")
        // apppend passkey (to prepare for manage-delete)
        profileScreen.appendPasskey()
        try waitForCondition(timeout: 10) { profileScreen.countNumberOfPasskeys() == 1}
        
        profileScreen.deletePasskey(passkeyId: profileScreen.getPasskeyIds()[0], complete: true)
        XCTAssertEqual(profileScreen.getErrorMessage(), "Passkey deletion failed. Please try again later.")
        XCTAssertEqual(profileScreen.getListMessage(), nil)
        
        // block connectTokenProvider
    }
        
    private func startApp(filteredByGradualRollout: Bool = false, enableOverlay: Bool = false) throws -> LoginScreen {
        controlServer = ControlServer()
        try controlServer.start()
        
        let app = XCUIApplication()
        app.launchArguments += ["-UITestMode"]
        app.launchArguments += ["-ControlServerURL=\(controlServer.baseURL.absoluteString)"]

        if filteredByGradualRollout {
            app.launchArguments += ["-FilteredByGradualRollout"]
        }
        
        if enableOverlay {
            app.launchArguments += ["-EnableOverlay"]
        }
        
        app.launch()
        
        let initialScreen = LoginScreen(app: app)
        
        return initialScreen
    }
}

