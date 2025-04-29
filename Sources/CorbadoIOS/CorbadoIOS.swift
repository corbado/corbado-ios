import OpenAPIClient

public struct CorbadoIOS {
    /// Calls the async API and returns a greeting once complete.
    /// Note: this must be called from an async context (e.g. inside a `Task { ... }`).
    public static func sayHello() async -> String {
        let req = ConnectAppendFinishReq(attestationResponse: "attestationResponse_example")

        do {
            // ✅ Call the async/throws API directly—no completion handler
            let rsp = try await CorbadoConnectAPI.connectAppendFinish(
                connectAppendFinishReq: req,
                apiConfiguration: .shared
            )
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
