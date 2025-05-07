import AuthenticationServices
import Foundation

public extension Data {
    /// Same as Data(base64Encoded:), but adds padding automatically (if missing).
    static func fromBase64(_ encoded: String) -> Data? {
        var encoded = encoded
        let remainder = encoded.count % 4
        if remainder > 0 {
            encoded = encoded.padding(
                toLength: encoded.count + 4 - remainder,
                withPad: "=",
                startingAt: 0
            )
        }
        return Data(base64Encoded: encoded)
    }
    
    static func fromBase64Url(_ encoded: String) -> Data? {
        let base64String = base64UrlToBase64(base64Url: encoded)
        return fromBase64(base64String)
    }
    
    private static func base64UrlToBase64(base64Url: String) -> String {
        return base64Url.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
    }
}

public extension String {
    static func fromBase64(_ encoded: String) -> String? {
        if let data = Data.fromBase64(encoded) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

extension Data {
    func toBase64URL() -> String {
        var result = self.base64EncodedString()
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }
}
