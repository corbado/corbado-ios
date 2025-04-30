# AuthAPI

All URIs are relative to *https://<project ID>.frontendapi.corbado.io*

Method | HTTP request | Description
------------- | ------------- | -------------
[**blockSkip**](AuthAPI.md#blockskip) | **POST** /v2/auth/block/skip | 
[**eventCreate**](AuthAPI.md#eventcreate) | **POST** /v2/auth/events | 
[**identifierUpdate**](AuthAPI.md#identifierupdate) | **POST** /v2/auth/identifier/update | 
[**identifierVerifyFinish**](AuthAPI.md#identifierverifyfinish) | **POST** /v2/auth/identifier/verify/finish | 
[**identifierVerifyStart**](AuthAPI.md#identifierverifystart) | **POST** /v2/auth/identifier/verify/start | 
[**identifierVerifyStatus**](AuthAPI.md#identifierverifystatus) | **GET** /v2/auth/identifier/verify/status | 
[**loginInit**](AuthAPI.md#logininit) | **POST** /v2/auth/login/init | 
[**passkeyAppendFinish**](AuthAPI.md#passkeyappendfinish) | **POST** /v2/auth/passkey/append/finish | 
[**passkeyAppendStart**](AuthAPI.md#passkeyappendstart) | **POST** /v2/auth/passkey/append/start | 
[**passkeyLoginFinish**](AuthAPI.md#passkeyloginfinish) | **POST** /v2/auth/passkey/login/finish | 
[**passkeyLoginStart**](AuthAPI.md#passkeyloginstart) | **POST** /v2/auth/passkey/login/start | 
[**passkeyMediationFinish**](AuthAPI.md#passkeymediationfinish) | **POST** /v2/auth/passkey/mediation/finish | 
[**processComplete**](AuthAPI.md#processcomplete) | **POST** /v2/auth/process/complete | 
[**processGet**](AuthAPI.md#processget) | **GET** /v2/auth/process | 
[**processInit**](AuthAPI.md#processinit) | **POST** /v2/auth/process/init | 
[**processReset**](AuthAPI.md#processreset) | **POST** /v2/auth/process/reset | 
[**signupInit**](AuthAPI.md#signupinit) | **POST** /v2/auth/signup/init | 
[**socialVerifyCallback**](AuthAPI.md#socialverifycallback) | **GET** /v2/auth/social/verify/callback | 
[**socialVerifyFinish**](AuthAPI.md#socialverifyfinish) | **POST** /v2/auth/social/verify/finish | 
[**socialVerifyStart**](AuthAPI.md#socialverifystart) | **POST** /v2/auth/social/verify/start | 


# **blockSkip**
```swift
    open class func blockSkip(completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


AuthAPI.blockSkip() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **eventCreate**
```swift
    open class func eventCreate(eventCreateReq: EventCreateReq, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```



Creates a new user generated complete event.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let eventCreateReq = eventCreateReq(eventType: passkeyEventType(), challenge: "challenge_example") // EventCreateReq | 

AuthAPI.eventCreate(eventCreateReq: eventCreateReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **eventCreateReq** | [**EventCreateReq**](EventCreateReq.md) |  | 

### Return type

Void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **identifierUpdate**
```swift
    open class func identifierUpdate(identifierUpdateReq: IdentifierUpdateReq, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let identifierUpdateReq = identifierUpdateReq(identifierType: loginIdentifierType(), value: "value_example") // IdentifierUpdateReq | 

AuthAPI.identifierUpdate(identifierUpdateReq: identifierUpdateReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **identifierUpdateReq** | [**IdentifierUpdateReq**](IdentifierUpdateReq.md) |  | 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **identifierVerifyFinish**
```swift
    open class func identifierVerifyFinish(identifierVerifyFinishReq: IdentifierVerifyFinishReq, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let identifierVerifyFinishReq = identifierVerifyFinishReq(code: "code_example", identifierType: loginIdentifierType(), verificationType: verificationMethod(), isNewDevice: false) // IdentifierVerifyFinishReq | 

AuthAPI.identifierVerifyFinish(identifierVerifyFinishReq: identifierVerifyFinishReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **identifierVerifyFinishReq** | [**IdentifierVerifyFinishReq**](IdentifierVerifyFinishReq.md) |  | 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **identifierVerifyStart**
```swift
    open class func identifierVerifyStart(identifierVerifyStartReq: IdentifierVerifyStartReq, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let identifierVerifyStartReq = identifierVerifyStartReq(identifierType: loginIdentifierType(), verificationType: verificationMethod()) // IdentifierVerifyStartReq | 

AuthAPI.identifierVerifyStart(identifierVerifyStartReq: identifierVerifyStartReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **identifierVerifyStartReq** | [**IdentifierVerifyStartReq**](IdentifierVerifyStartReq.md) |  | 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **identifierVerifyStatus**
```swift
    open class func identifierVerifyStatus(completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


AuthAPI.identifierVerifyStatus() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginInit**
```swift
    open class func loginInit(loginInitReq: LoginInitReq, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let loginInitReq = loginInitReq(identifierValue: "identifierValue_example", isPhone: false) // LoginInitReq | 

AuthAPI.loginInit(loginInitReq: loginInitReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginInitReq** | [**LoginInitReq**](LoginInitReq.md) |  | 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **passkeyAppendFinish**
```swift
    open class func passkeyAppendFinish(passkeyAppendFinishReq: PasskeyAppendFinishReq, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let passkeyAppendFinishReq = passkeyAppendFinishReq(signedChallenge: "signedChallenge_example") // PasskeyAppendFinishReq | 

AuthAPI.passkeyAppendFinish(passkeyAppendFinishReq: passkeyAppendFinishReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **passkeyAppendFinishReq** | [**PasskeyAppendFinishReq**](PasskeyAppendFinishReq.md) |  | 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **passkeyAppendStart**
```swift
    open class func passkeyAppendStart(passkeyAppendStartReq: PasskeyAppendStartReq, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let passkeyAppendStartReq = passkeyAppendStartReq(clientInformation: clientInformation(bluetoothAvailable: false, clientEnvHandle: "clientEnvHandle_example", visitorId: "visitorId_example", canUsePasskeys: false, isUserVerifyingPlatformAuthenticatorAvailable: false, isConditionalMediationAvailable: false, clientCapabilities: clientCapabilities(conditionalCreate: false, conditionalMediation: false, hybridTransport: false, passkeyPlatformAuthenticator: false, userVerifyingPlatformAuthenticator: false), javaScriptHighEntropy: javaScriptHighEntropy(platform: "platform_example", platformVersion: "platformVersion_example", mobile: false), isNative: false, webdriver: false, privateMode: false, clientEnvHandleMeta: clientStateMeta(ts: 123, source: "source_example"))) // PasskeyAppendStartReq | 

AuthAPI.passkeyAppendStart(passkeyAppendStartReq: passkeyAppendStartReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **passkeyAppendStartReq** | [**PasskeyAppendStartReq**](PasskeyAppendStartReq.md) |  | 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **passkeyLoginFinish**
```swift
    open class func passkeyLoginFinish(passkeyLoginFinishReq: PasskeyLoginFinishReq, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let passkeyLoginFinishReq = passkeyLoginFinishReq(signedChallenge: "signedChallenge_example") // PasskeyLoginFinishReq | 

AuthAPI.passkeyLoginFinish(passkeyLoginFinishReq: passkeyLoginFinishReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **passkeyLoginFinishReq** | [**PasskeyLoginFinishReq**](PasskeyLoginFinishReq.md) |  | 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **passkeyLoginStart**
```swift
    open class func passkeyLoginStart(passkeyLoginStartReq: PasskeyLoginStartReq, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let passkeyLoginStartReq = passkeyLoginStartReq(clientInformation: clientInformation(bluetoothAvailable: false, clientEnvHandle: "clientEnvHandle_example", visitorId: "visitorId_example", canUsePasskeys: false, isUserVerifyingPlatformAuthenticatorAvailable: false, isConditionalMediationAvailable: false, clientCapabilities: clientCapabilities(conditionalCreate: false, conditionalMediation: false, hybridTransport: false, passkeyPlatformAuthenticator: false, userVerifyingPlatformAuthenticator: false), javaScriptHighEntropy: javaScriptHighEntropy(platform: "platform_example", platformVersion: "platformVersion_example", mobile: false), isNative: false, webdriver: false, privateMode: false, clientEnvHandleMeta: clientStateMeta(ts: 123, source: "source_example"))) // PasskeyLoginStartReq | 

AuthAPI.passkeyLoginStart(passkeyLoginStartReq: passkeyLoginStartReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **passkeyLoginStartReq** | [**PasskeyLoginStartReq**](PasskeyLoginStartReq.md) |  | 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **passkeyMediationFinish**
```swift
    open class func passkeyMediationFinish(passkeyMediationFinishReq: PasskeyMediationFinishReq, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let passkeyMediationFinishReq = passkeyMediationFinishReq(signedChallenge: "signedChallenge_example") // PasskeyMediationFinishReq | 

AuthAPI.passkeyMediationFinish(passkeyMediationFinishReq: passkeyMediationFinishReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **passkeyMediationFinishReq** | [**PasskeyMediationFinishReq**](PasskeyMediationFinishReq.md) |  | 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **processComplete**
```swift
    open class func processComplete(completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


AuthAPI.processComplete() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **processGet**
```swift
    open class func processGet(preferredBlock: BlockType? = nil, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let preferredBlock = blockType() // BlockType |  (optional)

AuthAPI.processGet(preferredBlock: preferredBlock) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **preferredBlock** | [**BlockType**](.md) |  | [optional] 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **processInit**
```swift
    open class func processInit(processInitReq: ProcessInitReq, completion: @escaping (_ data: ProcessInitRsp?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let processInitReq = processInitReq(clientInformation: clientInformation(bluetoothAvailable: false, clientEnvHandle: "clientEnvHandle_example", visitorId: "visitorId_example", canUsePasskeys: false, isUserVerifyingPlatformAuthenticatorAvailable: false, isConditionalMediationAvailable: false, clientCapabilities: clientCapabilities(conditionalCreate: false, conditionalMediation: false, hybridTransport: false, passkeyPlatformAuthenticator: false, userVerifyingPlatformAuthenticator: false), javaScriptHighEntropy: javaScriptHighEntropy(platform: "platform_example", platformVersion: "platformVersion_example", mobile: false), isNative: false, webdriver: false, privateMode: false, clientEnvHandleMeta: clientStateMeta(ts: 123, source: "source_example")), passkeyAppendShown: 123, optOutOfPasskeyAppendAfterHybrid: false, preferredBlock: blockType()) // ProcessInitReq | 

AuthAPI.processInit(processInitReq: processInitReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **processInitReq** | [**ProcessInitReq**](ProcessInitReq.md) |  | 

### Return type

[**ProcessInitRsp**](ProcessInitRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **processReset**
```swift
    open class func processReset(completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


AuthAPI.processReset() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **signupInit**
```swift
    open class func signupInit(signupInitReq: SignupInitReq, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let signupInitReq = signupInitReq(fullName: "fullName_example", identifiers: [loginIdentifier(type: loginIdentifierType(), identifier: "identifier_example")]) // SignupInitReq | 

AuthAPI.signupInit(signupInitReq: signupInitReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **signupInitReq** | [**SignupInitReq**](SignupInitReq.md) |  | 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **socialVerifyCallback**
```swift
    open class func socialVerifyCallback(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


AuthAPI.socialVerifyCallback() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

Void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **socialVerifyFinish**
```swift
    open class func socialVerifyFinish(body: JSONValue, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let body = "TODO" // JSONValue | 

AuthAPI.socialVerifyFinish(body: body) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | **JSONValue** |  | 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **socialVerifyStart**
```swift
    open class func socialVerifyStart(socialVerifyStartReq: SocialVerifyStartReq, completion: @escaping (_ data: ProcessResponse?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let socialVerifyStartReq = socialVerifyStartReq(providerType: socialProviderType(), redirectUrl: "redirectUrl_example", authType: authType()) // SocialVerifyStartReq | 

AuthAPI.socialVerifyStart(socialVerifyStartReq: socialVerifyStartReq) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **socialVerifyStartReq** | [**SocialVerifyStartReq**](SocialVerifyStartReq.md) |  | 

### Return type

[**ProcessResponse**](ProcessResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

