import Foundation
import SimpleAuthenticationServices
import AuthenticationServices
import OpenAPIClient

let defaultAuthError = AuthError(code: "unavailable", message: "Passkey error. Use password to log in.")

/// The primary actor for interacting with the Corbado passkey APIs.
///
/// This actor provides methods for passkey-based authentication, registration, and management.
/// It handles the communication with the Corbado backend and the device's passkey services.
public actor Corbado {
    internal var projectId: String = ""
    internal var frontendApiUrlSuffix: String = ""
    internal var useOneTap: Bool
    
    internal var clientStateService: ClientStateService
    private var configured = false
    internal var passkeysPlugin: PasskeyPlugin
    internal var client: CorbadoClient
    
    internal var process: ConnectProcess?
    internal var loginInitCompleted: Date?
    internal var appendInitLoaded: Date?
    
    /// Initializes a new instance of the Corbado SDK.
    ///
    /// - Parameters:
    ///   - projectId: Your Corbado project ID.
    ///   - frontendApiUrlSuffix: The suffix of the frontend API URL. Defaults to "frontendapi.cloud.corbado.io".
    ///   - useOneTap: A boolean indicating whether to use one-tap login. Defaults to true.
    public init(
        projectId: String,
        frontendApiUrlSuffix: String?,
        useOneTap: Bool = true
    ) {
        self.projectId = projectId;
        self.frontendApiUrlSuffix = frontendApiUrlSuffix ?? "frontendapi.cloud.corbado.io"
        self.useOneTap = useOneTap
        
        let apiConfig = OpenAPIClientAPIConfiguration.shared
        apiConfig.basePath = "https://\(self.projectId).\(self.frontendApiUrlSuffix)"
        client = CorbadoClient(apiConfig: apiConfig)
        
        clientStateService = ClientStateService(projectId: projectId)
        passkeysPlugin = PasskeyPlugin()
        
        configured = true
    }
    
    // control ------------------------
    /// Clears all locally stored SDK state.
    public func clearLocalState() async {
        await clientStateService.clearLastLogin()
        await clientStateService.clearClientEnvHandle()
        await clientStateService.clearInvitationToken()
    }
    
    /// Sets an invitation token for upcoming registration flows.
    /// - Parameter token: The invitation token.
    public func setInvitationToken(token: String) async {
        await clientStateService.setInvitationToken(invitationToken: token)
    }
    
    /// Clears the current authentication or registration process state.
    public func clearProcess() {
        process = nil
    }
    
    /// Sets a custom interceptor for the API client, useful for testing.
    /// - Parameter apiConfigInterceptor: The interceptor to set.
    public func setApiInterceptor(apiConfigInterceptor: OpenAPIInterceptor?) {
        self.client = self.client.copyWith(interceptor: apiConfigInterceptor)
    }
    
    /// Sets a virtual authorization controller for mocking passkey flows during UI tests.
    ///
    /// This allows you to mock the passkey authentication flow during UI tests.
    /// - Parameter v: The virtual authorization controller.
    @MainActor
    public func setVirtualAuthorizationController(_ v: AuthorizationControllerProtocol) async {
        await passkeysPlugin.controller = v
    }
    
    /// Cancels any ongoing passkey operation.
    @MainActor
    public func cancelOngoingPasskeyOperation() async {
        await passkeysPlugin.cancelCurrentAuthenticatorOperation()
    }
    
    public func recordLocalUnlock() async {
        await client.recordLoginEvent(event: .localUnlock)
    }
        
    internal func buildClientInfo() async -> ClientInformation {
        let clientEnvHandleEntry = await clientStateService.getClientEnvHandle()
        var clientStateMeta: ClientStateMeta?
        if let e = clientEnvHandleEntry {
            clientStateMeta = ClientStateMeta(ts: Int64(e.ts * 1000.0), source: .native)
        }
        
        return ClientInformation(
            clientEnvHandle: clientEnvHandleEntry?.data,
            isNative: true,
            clientEnvHandleMeta: clientStateMeta,
            nativeMeta: await PasskeyClientTelemetryCollector.collectData().toNativeMeta()
        )
    }
}
