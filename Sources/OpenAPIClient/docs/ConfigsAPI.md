# ConfigsAPI

All URIs are relative to *https://<project ID>.frontendapi.corbado.io*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getSessionConfig**](ConfigsAPI.md#getsessionconfig) | **GET** /v2/session-config | 
[**getUserDetailsConfig**](ConfigsAPI.md#getuserdetailsconfig) | **GET** /v2/user-details-config | 


# **getSessionConfig**
```swift
    open class func getSessionConfig(completion: @escaping (_ data: SessionConfigRsp?, _ error: Error?) -> Void)
```



tbd

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


ConfigsAPI.getSessionConfig() { (response, error) in
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

[**SessionConfigRsp**](SessionConfigRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserDetailsConfig**
```swift
    open class func getUserDetailsConfig(completion: @escaping (_ data: UserDetailsConfigRsp?, _ error: Error?) -> Void)
```



Gets configs needed by the UserDetails component

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient


ConfigsAPI.getUserDetailsConfig() { (response, error) in
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

[**UserDetailsConfigRsp**](UserDetailsConfigRsp.md)

### Authorization

[bearerAuth](../README.md#bearerAuth), [projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

