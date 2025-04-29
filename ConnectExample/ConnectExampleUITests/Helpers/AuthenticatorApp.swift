import SwiftOTP
import Foundation

struct WrappedTOTP {
  let totp: TOTP
  var nextBoundary: Date
}

public actor AuthenticatorApp {
  private var existing: [String: WrappedTOTP] = [:]

  /// Register a new setup key. Returns the *current* TOTP immediately,
  /// and schedules the next valid time at the period boundary.
  func addBySetupKey(_ setupKey: String) -> String? {
    guard
      let secretData = base32DecodeToData(setupKey),
      let totp = TOTP(secret: secretData)
    else {
      return nil
    }

    let now = Date()
    guard let code = totp.generate(time: now) else { return nil }

      let boundary = Date.nextBoundary(after: now, period: TimeInterval(totp.timeInterval))
    existing[setupKey] = WrappedTOTP(totp: totp, nextBoundary: boundary)
    return code
  }

  /// Gets you the *next* code. If you call this too early, it will suspend
  /// until the next TOTP period starts, then return a brand-new code.
  func getCode(_ setupKey: String) async throws -> String? {
    guard var wrapped = existing[setupKey] else {
      return nil
    }

    let now = Date()
    if now < wrapped.nextBoundary {
      let interval = wrapped.nextBoundary.timeIntervalSince(now)
      let nanos = UInt64((interval * 1_000_000_000).rounded())
      print("sleeping \(interval) s → \(nanos) ns")
      try await Task.sleep(nanoseconds: nanos)
    }

    let then = Date()
    guard let code = wrapped.totp.generate(time: then) else { return nil }

    // schedule for *exactly* the next boundary
    let next = Date.nextBoundary(after: then, period: TimeInterval(wrapped.totp.timeInterval))
    wrapped.nextBoundary = next
    existing[setupKey] = wrapped

    return code
  }
}

// helper extension:
extension Date {
  static func nextBoundary(after date: Date, period: TimeInterval) -> Date {
    let t = date.timeIntervalSince1970
    let periods = floor(t / period)
    let next = (periods + 1) * period
    return Date(timeIntervalSince1970: next)
  }
}
