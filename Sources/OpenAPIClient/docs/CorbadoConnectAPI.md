# CorbadoConnectAPI

All URIs are relative to *https://<project ID>.frontendapi.corbado.io*

Method | HTTP request | Description
------------- | ------------- | -------------
[**connectAppendFinish**](CorbadoConnectAPI.md#connectappendfinish) | **POST** /v2/connect/append/finish | 
[**connectAppendInit**](CorbadoConnectAPI.md#connectappendinit) | **POST** /v2/connect/append/init | 
[**connectAppendStart**](CorbadoConnectAPI.md#connectappendstart) | **POST** /v2/connect/append/start | 
[**connectEventCreate**](CorbadoConnectAPI.md#connecteventcreate) | **POST** /v2/connect/events | 
[**connectLoginFinish**](CorbadoConnectAPI.md#connectloginfinish) | **POST** /v2/connect/login/finish | 
[**connectLoginInit**](CorbadoConnectAPI.md#connectlogininit) | **POST** /v2/connect/login/init | 
[**connectLoginStart**](CorbadoConnectAPI.md#connectloginstart) | **POST** /v2/connect/login/start | 
[**connectManageDelete**](CorbadoConnectAPI.md#connectmanagedelete) | **POST** /v2/connect/manage/delete | 
[**connectManageInit**](CorbadoConnectAPI.md#connectmanageinit) | **POST** /v2/connect/manage/init | 
[**connectManageList**](CorbadoConnectAPI.md#connectmanagelist) | **POST** /v2/connect/manage/list | 
[**connectProcessClear**](CorbadoConnectAPI.md#connectprocessclear) | **POST** /v2/connect/process/clear | 


# **connectAppendFinish**
```swift
    open class func connectAppendFinish(connectAppendFinishReq: ConnectAppendFinishReq, completion: @escaping (_ data: ConnectAppendFinishRsp?, _ error: Error?) -> Void)
```



Finishes an initialized connect passkey append process.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let connectAppendFinishReq = connectAppendFinishReq(attestationResponse: "attestationResponse_example") // ConnectAppendFinishReq | 

CorbadoConnectAPI.connectAppendFinish(connectAppendFinishReq: connectAppendFinishReq) { (response, error) in
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
 **connectAppendFinishReq** | [**ConnectAppendFinishReq**](ConnectAppendFinishReq.md) |  | 

### Return type

[**ConnectAppendFinishRsp**](ConnectAppendFinishRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **connectAppendInit**
```swift
    open class func connectAppendInit(connectAppendInitReq: ConnectAppendInitReq, completion: @escaping (_ data: ConnectAppendInitRsp?, _ error: Error?) -> Void)
```



Initializes a connect process for passkey append.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let connectAppendInitReq = connectAppendInitReq(clientInformation: clientInformation(bluetoothAvailable: false, clientEnvHandle: "clientEnvHandle_example", visitorId: "visitorId_example", canUsePasskeys: false, isUserVerifyingPlatformAuthenticatorAvailable: false, isConditionalMediationAvailable: false, clientCapabilities: clientCapabilities(conditionalCreate: false, conditionalMediation: false, hybridTransport: false, passkeyPlatformAuthenticator: false, userVerifyingPlatformAuthenticator: false), javaScriptHighEntropy: javaScriptHighEntropy(platform: "platform_example", platformVersion: "platformVersion_example", mobile: false), isNative: false, webdriver: false, privateMode: false, clientEnvHandleMeta: clientStateMeta(ts: 123, source: "source_example")), flags: "TODO", invitationToken: "invitationToken_example") // ConnectAppendInitReq | 

CorbadoConnectAPI.connectAppendInit(connectAppendInitReq: connectAppendInitReq) { (response, error) in
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
 **connectAppendInitReq** | [**ConnectAppendInitReq**](ConnectAppendInitReq.md) |  | 

### Return type

[**ConnectAppendInitRsp**](ConnectAppendInitRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **connectAppendStart**
```swift
    open class func connectAppendStart(connectAppendStartReq: ConnectAppendStartReq, completion: @escaping (_ data: ConnectAppendStartRsp?, _ error: Error?) -> Void)
```



Starts an initialized connect passkey append process.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let connectAppendStartReq = connectAppendStartReq(appendTokenValue: "appendTokenValue_example", forcePasskeyAppend: false, loadedMs: 123) // ConnectAppendStartReq | 

CorbadoConnectAPI.connectAppendStart(connectAppendStartReq: connectAppendStartReq) { (response, error) in
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
 **connectAppendStartReq** | [**ConnectAppendStartReq**](ConnectAppendStartReq.md) |  | 

### Return type

[**ConnectAppendStartRsp**](ConnectAppendStartRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **connectEventCreate**
```swift
    open class func connectEventCreate(connectEventCreateReq: ConnectEventCreateReq, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```



Creates a new user generated connect event.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let connectEventCreateReq = connectEventCreateReq(eventType: passkeyEventType(), message: "message_example", challenge: "challenge_example") // ConnectEventCreateReq | 

CorbadoConnectAPI.connectEventCreate(connectEventCreateReq: connectEventCreateReq) { (response, error) in
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
 **connectEventCreateReq** | [**ConnectEventCreateReq**](ConnectEventCreateReq.md) |  | 

### Return type

Void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **connectLoginFinish**
```swift
    open class func connectLoginFinish(connectLoginFinishReq: ConnectLoginFinishReq, completion: @escaping (_ data: ConnectLoginFinishRsp?, _ error: Error?) -> Void)
```



Finishes an initialized connect login process.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let connectLoginFinishReq = connectLoginFinishReq(isConditionalUI: false, assertionResponse: "assertionResponse_example", loadedMs: 123) // ConnectLoginFinishReq | 

CorbadoConnectAPI.connectLoginFinish(connectLoginFinishReq: connectLoginFinishReq) { (response, error) in
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
 **connectLoginFinishReq** | [**ConnectLoginFinishReq**](ConnectLoginFinishReq.md) |  | 

### Return type

[**ConnectLoginFinishRsp**](ConnectLoginFinishRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **connectLoginInit**
```swift
    open class func connectLoginInit(connectLoginInitReq: ConnectLoginInitReq, completion: @escaping (_ data: ConnectLoginInitRsp?, _ error: Error?) -> Void)
```



Initializes a connect process for login.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let connectLoginInitReq = connectLoginInitReq(clientInformation: clientInformation(bluetoothAvailable: false, clientEnvHandle: "clientEnvHandle_example", visitorId: "visitorId_example", canUsePasskeys: false, isUserVerifyingPlatformAuthenticatorAvailable: false, isConditionalMediationAvailable: false, clientCapabilities: clientCapabilities(conditionalCreate: false, conditionalMediation: false, hybridTransport: false, passkeyPlatformAuthenticator: false, userVerifyingPlatformAuthenticator: false), javaScriptHighEntropy: javaScriptHighEntropy(platform: "platform_example", platformVersion: "platformVersion_example", mobile: false), isNative: false, webdriver: false, privateMode: false, clientEnvHandleMeta: clientStateMeta(ts: 123, source: "source_example")), flags: "TODO", invitationToken: "invitationToken_example") // ConnectLoginInitReq | 

CorbadoConnectAPI.connectLoginInit(connectLoginInitReq: connectLoginInitReq) { (response, error) in
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
 **connectLoginInitReq** | [**ConnectLoginInitReq**](ConnectLoginInitReq.md) |  | 

### Return type

[**ConnectLoginInitRsp**](ConnectLoginInitRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **connectLoginStart**
```swift
    open class func connectLoginStart(connectLoginStartReq: ConnectLoginStartReq, completion: @escaping (_ data: ConnectLoginStartRsp?, _ error: Error?) -> Void)
```



Starts an initialized connect login process.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let connectLoginStartReq = connectLoginStartReq(identifier: "identifier_example", source: "source_example", loadedMs: 123, loginConnectToken: "loginConnectToken_example", identifierHintAvailable: false, oneTapMeta: clientStateMeta(ts: 123, source: "source_example")) // ConnectLoginStartReq | 

CorbadoConnectAPI.connectLoginStart(connectLoginStartReq: connectLoginStartReq) { (response, error) in
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
 **connectLoginStartReq** | [**ConnectLoginStartReq**](ConnectLoginStartReq.md) |  | 

### Return type

[**ConnectLoginStartRsp**](ConnectLoginStartRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **connectManageDelete**
```swift
    open class func connectManageDelete(connectManageDeleteReq: ConnectManageDeleteReq, completion: @escaping (_ data: ConnectManageDeleteRsp?, _ error: Error?) -> Void)
```



Deletes a passkey for a user identified by a connect token

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let connectManageDeleteReq = connectManageDeleteReq(connectToken: "connectToken_example", credentialID: "credentialID_example") // ConnectManageDeleteReq | 

CorbadoConnectAPI.connectManageDelete(connectManageDeleteReq: connectManageDeleteReq) { (response, error) in
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
 **connectManageDeleteReq** | [**ConnectManageDeleteReq**](ConnectManageDeleteReq.md) |  | 

### Return type

[**ConnectManageDeleteRsp**](ConnectManageDeleteRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **connectManageInit**
```swift
    open class func connectManageInit(connectManageInitReq: ConnectManageInitReq, completion: @escaping (_ data: ConnectManageInitRsp?, _ error: Error?) -> Void)
```



Initializes a connect process for passkey management.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let connectManageInitReq = connectManageInitReq(clientInformation: clientInformation(bluetoothAvailable: false, clientEnvHandle: "clientEnvHandle_example", visitorId: "visitorId_example", canUsePasskeys: false, isUserVerifyingPlatformAuthenticatorAvailable: false, isConditionalMediationAvailable: false, clientCapabilities: clientCapabilities(conditionalCreate: false, conditionalMediation: false, hybridTransport: false, passkeyPlatformAuthenticator: false, userVerifyingPlatformAuthenticator: false), javaScriptHighEntropy: javaScriptHighEntropy(platform: "platform_example", platformVersion: "platformVersion_example", mobile: false), isNative: false, webdriver: false, privateMode: false, clientEnvHandleMeta: clientStateMeta(ts: 123, source: "source_example")), flags: "TODO", invitationToken: "invitationToken_example") // ConnectManageInitReq | 

CorbadoConnectAPI.connectManageInit(connectManageInitReq: connectManageInitReq) { (response, error) in
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
 **connectManageInitReq** | [**ConnectManageInitReq**](ConnectManageInitReq.md) |  | 

### Return type

[**ConnectManageInitRsp**](ConnectManageInitRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **connectManageList**
```swift
    open class func connectManageList(connectManageListReq: ConnectManageListReq, completion: @escaping (_ data: ConnectManageListRsp?, _ error: Error?) -> Void)
```



Lists all passkeys for a user identifier by a connect token.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let connectManageListReq = connectManageListReq(connectToken: "connectToken_example") // ConnectManageListReq | 

CorbadoConnectAPI.connectManageList(connectManageListReq: connectManageListReq) { (response, error) in
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
 **connectManageListReq** | [**ConnectManageListReq**](ConnectManageListReq.md) |  | 

### Return type

[**ConnectManageListRsp**](ConnectManageListRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **connectProcessClear**
```swift
    open class func connectProcessClear(connectProcessClearReq: ConnectProcessClearReq, completion: @escaping (_ data: ConnectProcessClearRsp?, _ error: Error?) -> Void)
```



Remove process state for a connect process.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let connectProcessClearReq = connectProcessClearReq(processId: "processId_example") // ConnectProcessClearReq | 

CorbadoConnectAPI.connectProcessClear(connectProcessClearReq: connectProcessClearReq) { (response, error) in
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
 **connectProcessClearReq** | [**ConnectProcessClearReq**](ConnectProcessClearReq.md) |  | 

### Return type

[**ConnectProcessClearRsp**](ConnectProcessClearRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

