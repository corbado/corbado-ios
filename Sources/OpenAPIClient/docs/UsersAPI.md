# UsersAPI

All URIs are relative to *https://<project ID>.frontendapi.corbado.io*

Method | HTTP request | Description
------------- | ------------- | -------------
[**currentUserDelete**](UsersAPI.md#currentuserdelete) | **DELETE** /v2/me | 
[**currentUserGet**](UsersAPI.md#currentuserget) | **GET** /v2/me | 
[**currentUserIdentifierCreate**](UsersAPI.md#currentuseridentifiercreate) | **POST** /v2/me/identifier | 
[**currentUserIdentifierDelete**](UsersAPI.md#currentuseridentifierdelete) | **DELETE** /v2/me/identifier | 
[**currentUserIdentifierUpdate**](UsersAPI.md#currentuseridentifierupdate) | **PATCH** /v2/me/identifier | 
[**currentUserIdentifierVerifyFinish**](UsersAPI.md#currentuseridentifierverifyfinish) | **POST** /v2/me/identifier/verify/finish | 
[**currentUserIdentifierVerifyStart**](UsersAPI.md#currentuseridentifierverifystart) | **POST** /v2/me/identifier/verify/start | 
[**currentUserPasskeyAppendFinish**](UsersAPI.md#currentuserpasskeyappendfinish) | **POST** /v2/me/passkeys/append/finish | 
[**currentUserPasskeyAppendStart**](UsersAPI.md#currentuserpasskeyappendstart) | **POST** /v2/me/passkeys/append/start | 
[**currentUserPasskeyDelete**](UsersAPI.md#currentuserpasskeydelete) | **DELETE** /v2/me/passkeys/{credentialID} | 
[**currentUserPasskeyGet**](UsersAPI.md#currentuserpasskeyget) | **GET** /v2/me/passkeys | 
[**currentUserSessionLogout**](UsersAPI.md#currentusersessionlogout) | **POST** /v2/me/logout | 
[**currentUserSessionRefresh**](UsersAPI.md#currentusersessionrefresh) | **POST** /v2/me/refresh | 
[**currentUserUpdate**](UsersAPI.md#currentuserupdate) | **PATCH** /v2/me | 


# **currentUserDelete**
```swift
    open class func currentUserDelete(completion: @escaping (_ data: GenericRsp?, _ error: Error?) -> Void)
```



Deletes current user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


UsersAPI.currentUserDelete() { (response, error) in
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

[**GenericRsp**](GenericRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentUserGet**
```swift
    open class func currentUserGet(completion: @escaping (_ data: MeRsp?, _ error: Error?) -> Void)
```



Gets current user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


UsersAPI.currentUserGet() { (response, error) in
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

[**MeRsp**](MeRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentUserIdentifierCreate**
```swift
    open class func currentUserIdentifierCreate(meIdentifierCreateReq: MeIdentifierCreateReq, completion: @escaping (_ data: GenericRsp?, _ error: Error?) -> Void)
```



Creates an identifier

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let meIdentifierCreateReq = meIdentifierCreateReq(identifierType: loginIdentifierType(), value: "value_example") // MeIdentifierCreateReq | 

UsersAPI.currentUserIdentifierCreate(meIdentifierCreateReq: meIdentifierCreateReq) { (response, error) in
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
 **meIdentifierCreateReq** | [**MeIdentifierCreateReq**](MeIdentifierCreateReq.md) |  | 

### Return type

[**GenericRsp**](GenericRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentUserIdentifierDelete**
```swift
    open class func currentUserIdentifierDelete(meIdentifierDeleteReq: MeIdentifierDeleteReq, completion: @escaping (_ data: GenericRsp?, _ error: Error?) -> Void)
```



Deletes an identifier

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let meIdentifierDeleteReq = meIdentifierDeleteReq(identifierID: "identifierID_example") // MeIdentifierDeleteReq | 

UsersAPI.currentUserIdentifierDelete(meIdentifierDeleteReq: meIdentifierDeleteReq) { (response, error) in
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
 **meIdentifierDeleteReq** | [**MeIdentifierDeleteReq**](MeIdentifierDeleteReq.md) |  | 

### Return type

[**GenericRsp**](GenericRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentUserIdentifierUpdate**
```swift
    open class func currentUserIdentifierUpdate(meIdentifierUpdateReq: MeIdentifierUpdateReq, completion: @escaping (_ data: GenericRsp?, _ error: Error?) -> Void)
```



Modifies an identifier (only permitted for username; identifierID will change)

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let meIdentifierUpdateReq = meIdentifierUpdateReq(identifierID: "identifierID_example", identifierType: loginIdentifierType(), value: "value_example") // MeIdentifierUpdateReq | 

UsersAPI.currentUserIdentifierUpdate(meIdentifierUpdateReq: meIdentifierUpdateReq) { (response, error) in
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
 **meIdentifierUpdateReq** | [**MeIdentifierUpdateReq**](MeIdentifierUpdateReq.md) |  | 

### Return type

[**GenericRsp**](GenericRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentUserIdentifierVerifyFinish**
```swift
    open class func currentUserIdentifierVerifyFinish(meIdentifierVerifyFinishReq: MeIdentifierVerifyFinishReq, completion: @escaping (_ data: GenericRsp?, _ error: Error?) -> Void)
```



Verifies challenge

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let meIdentifierVerifyFinishReq = meIdentifierVerifyFinishReq(identifierID: "identifierID_example", code: "code_example") // MeIdentifierVerifyFinishReq | 

UsersAPI.currentUserIdentifierVerifyFinish(meIdentifierVerifyFinishReq: meIdentifierVerifyFinishReq) { (response, error) in
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
 **meIdentifierVerifyFinishReq** | [**MeIdentifierVerifyFinishReq**](MeIdentifierVerifyFinishReq.md) |  | 

### Return type

[**GenericRsp**](GenericRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentUserIdentifierVerifyStart**
```swift
    open class func currentUserIdentifierVerifyStart(meIdentifierVerifyStartReq: MeIdentifierVerifyStartReq, completion: @escaping (_ data: GenericRsp?, _ error: Error?) -> Void)
```



Creates challenge (only email otp and phone otp supported for now)

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let meIdentifierVerifyStartReq = meIdentifierVerifyStartReq(identifierID: "identifierID_example", clientInformation: clientInformation(bluetoothAvailable: false, clientEnvHandle: "clientEnvHandle_example", visitorId: "visitorId_example", canUsePasskeys: false, isUserVerifyingPlatformAuthenticatorAvailable: false, isConditionalMediationAvailable: false, clientCapabilities: clientCapabilities(conditionalCreate: false, conditionalMediation: false, hybridTransport: false, passkeyPlatformAuthenticator: false, userVerifyingPlatformAuthenticator: false), javaScriptHighEntropy: javaScriptHighEntropy(platform: "platform_example", platformVersion: "platformVersion_example", mobile: false), isNative: false, webdriver: false, privateMode: false, clientEnvHandleMeta: clientStateMeta(ts: 123, source: "source_example"))) // MeIdentifierVerifyStartReq | 

UsersAPI.currentUserIdentifierVerifyStart(meIdentifierVerifyStartReq: meIdentifierVerifyStartReq) { (response, error) in
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
 **meIdentifierVerifyStartReq** | [**MeIdentifierVerifyStartReq**](MeIdentifierVerifyStartReq.md) |  | 

### Return type

[**GenericRsp**](GenericRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentUserPasskeyAppendFinish**
```swift
    open class func currentUserPasskeyAppendFinish(mePasskeysAppendFinishReq: MePasskeysAppendFinishReq, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```



Finishes passkey append for current user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let mePasskeysAppendFinishReq = mePasskeysAppendFinishReq(attestationResponse: "attestationResponse_example", clientInformation: clientInformation(bluetoothAvailable: false, clientEnvHandle: "clientEnvHandle_example", visitorId: "visitorId_example", canUsePasskeys: false, isUserVerifyingPlatformAuthenticatorAvailable: false, isConditionalMediationAvailable: false, clientCapabilities: clientCapabilities(conditionalCreate: false, conditionalMediation: false, hybridTransport: false, passkeyPlatformAuthenticator: false, userVerifyingPlatformAuthenticator: false), javaScriptHighEntropy: javaScriptHighEntropy(platform: "platform_example", platformVersion: "platformVersion_example", mobile: false), isNative: false, webdriver: false, privateMode: false, clientEnvHandleMeta: clientStateMeta(ts: 123, source: "source_example"))) // MePasskeysAppendFinishReq | 

UsersAPI.currentUserPasskeyAppendFinish(mePasskeysAppendFinishReq: mePasskeysAppendFinishReq) { (response, error) in
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
 **mePasskeysAppendFinishReq** | [**MePasskeysAppendFinishReq**](MePasskeysAppendFinishReq.md) |  | 

### Return type

Void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentUserPasskeyAppendStart**
```swift
    open class func currentUserPasskeyAppendStart(mePasskeysAppendStartReq: MePasskeysAppendStartReq, completion: @escaping (_ data: MePasskeysAppendStartRsp?, _ error: Error?) -> Void)
```



Starts passkey append for current user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let mePasskeysAppendStartReq = mePasskeysAppendStartReq(clientInformation: clientInformation(bluetoothAvailable: false, clientEnvHandle: "clientEnvHandle_example", visitorId: "visitorId_example", canUsePasskeys: false, isUserVerifyingPlatformAuthenticatorAvailable: false, isConditionalMediationAvailable: false, clientCapabilities: clientCapabilities(conditionalCreate: false, conditionalMediation: false, hybridTransport: false, passkeyPlatformAuthenticator: false, userVerifyingPlatformAuthenticator: false), javaScriptHighEntropy: javaScriptHighEntropy(platform: "platform_example", platformVersion: "platformVersion_example", mobile: false), isNative: false, webdriver: false, privateMode: false, clientEnvHandleMeta: clientStateMeta(ts: 123, source: "source_example"))) // MePasskeysAppendStartReq | 

UsersAPI.currentUserPasskeyAppendStart(mePasskeysAppendStartReq: mePasskeysAppendStartReq) { (response, error) in
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
 **mePasskeysAppendStartReq** | [**MePasskeysAppendStartReq**](MePasskeysAppendStartReq.md) |  | 

### Return type

[**MePasskeysAppendStartRsp**](MePasskeysAppendStartRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentUserPasskeyDelete**
```swift
    open class func currentUserPasskeyDelete(credentialID: String, completion: @escaping (_ data: MePasskeyDeleteRsp?, _ error: Error?) -> Void)
```



Delete current user's passkeys

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let credentialID = "credentialID_example" // String | Credential ID from passkeys

UsersAPI.currentUserPasskeyDelete(credentialID: credentialID) { (response, error) in
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
 **credentialID** | **String** | Credential ID from passkeys | 

### Return type

[**MePasskeyDeleteRsp**](MePasskeyDeleteRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentUserPasskeyGet**
```swift
    open class func currentUserPasskeyGet(completion: @escaping (_ data: MePasskeyRsp?, _ error: Error?) -> Void)
```



Gets current user's passkeys

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


UsersAPI.currentUserPasskeyGet() { (response, error) in
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

[**MePasskeyRsp**](MePasskeyRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentUserSessionLogout**
```swift
    open class func currentUserSessionLogout(completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```



Performs session logout

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


UsersAPI.currentUserSessionLogout() { (response, error) in
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

# **currentUserSessionRefresh**
```swift
    open class func currentUserSessionRefresh(completion: @escaping (_ data: MeRefreshRsp?, _ error: Error?) -> Void)
```



Performs session refresh

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


UsersAPI.currentUserSessionRefresh() { (response, error) in
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

[**MeRefreshRsp**](MeRefreshRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentUserUpdate**
```swift
    open class func currentUserUpdate(meUpdateReq: MeUpdateReq, completion: @escaping (_ data: GenericRsp?, _ error: Error?) -> Void)
```



Updates current user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let meUpdateReq = meUpdateReq(fullName: "fullName_example") // MeUpdateReq | 

UsersAPI.currentUserUpdate(meUpdateReq: meUpdateReq) { (response, error) in
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
 **meUpdateReq** | [**MeUpdateReq**](MeUpdateReq.md) |  | 

### Return type

[**GenericRsp**](GenericRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

