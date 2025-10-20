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
    let brand: String
    let model: String
    let locale: String
    let screen: ScreenNativeMeta
    let error: String?
    let sdkInitTime: Int64
    
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
            error: error,
            brand: brand,
            model: model,
            locale: locale,
            screen: NativeMetaScreen(widthPoints: screen.widthPoints, heightPoints: screen.heightPoints, scale: screen.scale),
            sdkInitTimeMs: sdkInitTime
        )
    }
}

enum DeviceOwnerAuth: String {
    case biometrics = "biometrics"
    case code = "code"
    case none = "none"
}

struct ScreenNativeMeta {
    let widthPoints: Float
    let heightPoints: Float
    let scale: Float
}

class PasskeyClientTelemetryCollector {
    static func collectData(sdkInitTime: Int64) async -> PasskeyClientTelemetryData {
        let (deviceOwnerAuth, error) = getDeviceOwnerAuthType()
        let appDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        
        let bounds = UIScreen.main.bounds
        let scale = UIScreen.main.scale

        return await MainActor.run {
            return PasskeyClientTelemetryData(
                osName: UIDevice.current.systemName,
                osVersion: UIDevice.current.systemVersion,
                appBundleId: Bundle.main.bundleIdentifier,
                appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                appBuildNumber: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
                appDisplayName: appDisplayName,
                deviceOwnerAuth: deviceOwnerAuth,
                brand: "apple",
                model: modelIdentifier(),
                locale: Locale.current.identifier,
                screen: ScreenNativeMeta(widthPoints: Float(bounds.size.width), heightPoints: Float(bounds.size.height), scale: Float(scale)),
                error: error,
                sdkInitTime: sdkInitTime
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
    
    private static func modelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce(into: "") { acc, elem in
            if let value = elem.value as? Int8, value != 0 {
                acc.append(Character(UnicodeScalar(UInt8(value))))
            }
        }
        
        return identifier
    }
}
