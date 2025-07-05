//
//  TelemetryCollector.swift
//  CorbadoConnect
//
//  Created by Martin on 14/5/2025.
//

import UIKit
import AuthenticationServices
import LocalAuthentication
import OpenAPIClient

struct PasskeyClientTelemetryData {
    let osName: String
    let osVersion: String
    let appBundleId: String?
    let appVersion: String?
    let appBuildNumber: String?
    let appDisplayName: String
    let deviceOwnerAuth: DeviceOwnerAuth?
    let error: String?
    
    func toNativeMeta() -> NativeMeta {
        var backendDeviceOwnerAuth: NativeMeta.DeviceOwnerAuth?
        if let d = deviceOwnerAuth {
            backendDeviceOwnerAuth = NativeMeta.DeviceOwnerAuth(rawValue: d.rawValue)
        }
        
        return NativeMeta(
            platform: osName,
            platformVersion: osVersion,
            name: appBundleId,
            version: appVersion,
            displayName: appDisplayName,
            build: appBuildNumber,
            deviceOwnerAuth: backendDeviceOwnerAuth,
            error: error
        )
    }
}

enum DeviceOwnerAuth: String {
    case biometrics = "biometrics"
    case code = "code"
    case none = "none"
}

class PasskeyClientTelemetryCollector {
    static func collectData() async -> PasskeyClientTelemetryData {
        let (deviceOwnerAuth, error) = getDeviceOwnerAuthType()
        let appDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        
        return await MainActor.run {
            return PasskeyClientTelemetryData(
                osName: UIDevice.current.systemName,
                osVersion: UIDevice.current.systemVersion,
                appBundleId: Bundle.main.bundleIdentifier,
                appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                appBuildNumber: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
                appDisplayName: appDisplayName,
                deviceOwnerAuth: deviceOwnerAuth,
                error: error
            )
        }
    }
    
    private static func getDeviceOwnerAuthType() -> (DeviceOwnerAuth?, String?) {
        var error: NSError?
        let isDeviceOwnerAuthWithBiometricsSetUp = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if isDeviceOwnerAuthWithBiometricsSetUp {
            return (.biometrics, nil)
        }
        let isDeviceOwnerAuthWithCodeSetUp = LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        if isDeviceOwnerAuthWithCodeSetUp {
            return (DeviceOwnerAuth.code, nil)
        }
        
        if let error = error {
            return (nil, error.localizedDescription)
        }
        
        return (DeviceOwnerAuth.none, nil)
    }
} 
