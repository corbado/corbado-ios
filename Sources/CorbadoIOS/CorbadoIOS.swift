import Foundation
import OpenAPIClient

public struct CorbadoIOS {
    /// Calls the async API and returns a greeting once complete.
    /// Note: this must be called from an async context (e.g. inside a `Task { ... }`).
    public static func sayHello() async -> String {
        let clientInfo = ClientInformation(bluetoothAvailable: true, clientEnvHandle: "", visitorId: "", canUsePasskeys: true, isUserVerifyingPlatformAuthenticatorAvailable: true, isConditionalMediationAvailable: true, isNative: true)
        let req = ConnectManageInitReq(clientInformation: clientInfo, flags: [:]);
        let apiConfig = OpenAPIClientAPIConfiguration.shared;
        
        apiConfig.basePath = "https://pro-6098554880495367876.frontendapi.cloud.corbado.io"
        
        do {
            // ✅ Call the async/throws API directly—no completion handler
            let rsp = try await CorbadoConnectAPI.connectManageInit(connectManageInitReq: req,apiConfiguration: apiConfig)
            dump(rsp)
        } catch let apiError as ErrorResponse {
            // This is your typed ErrorResponse from the OpenAPI spec
            print("Caught ErrorResponse:", apiError)
        } catch {
            // Fallback for any other unexpected errors
            print("Unexpected error:", error)
        }

        return "👋 Hello from CorbadoIOS!"
    }
}
