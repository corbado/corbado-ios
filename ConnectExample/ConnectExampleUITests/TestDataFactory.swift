import Foundation

struct TestDataFactory {
    static let phoneNumber = "+4915121609839"
    static let password = "asdfasdf"

    static func createEmail() -> String {
        return "integration-test+\(randomString(10))@corbado.com"
    }

    private static func randomString(_ length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomChars = (0..<length).compactMap { _ in letters.randomElement() }
        
        return String(randomChars)
    }
} 
