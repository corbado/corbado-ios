import Foundation
import OpenAPIClient

public struct CorbadoIOS {
    public static func loginInit() async {
        let clientInfo = ClientInformation(
            bluetoothAvailable: true, clientEnvHandle: "", canUsePasskeys: true,
            isUserVerifyingPlatformAuthenticatorAvailable: true,
            isConditionalMediationAvailable: true, isNative: true)
        let req = ConnectLoginInitReq(
            clientInformation: clientInfo, flags: [:], invitationToken: "inv-token-correct")
        let apiConfig = OpenAPIClientAPIConfiguration.shared

        apiConfig.basePath = "https://pro-0204813113833485177.frontendapi.cloud.corbado-staging.io"

        do {
            let rsp = try await CorbadoConnectAPI.connectLoginInit(
                connectLoginInitReq: req, apiConfiguration: apiConfig)

        } catch let apiError as ErrorResponse {
            // This is your typed ErrorResponse from the OpenAPI spec
            print("Caught ErrorResponse:", apiError)
        } catch {
            // Fallback for any other unexpected errors
            print("Unexpected error:", error)
        }
    }
}
