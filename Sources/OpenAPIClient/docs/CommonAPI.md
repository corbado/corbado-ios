# CommonAPI

All URIs are relative to *https://api.corbado.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**unused**](CommonAPI.md#unused) | **GET** /unused/{sessionID} | 


# **unused**
```swift
    open class func unused(sessionID: String, remoteAddress: String? = nil, userAgent: String? = nil, sort: String? = nil, filter: [String]? = nil, page: Int? = nil, pageSize: Int? = nil, completion: @escaping (_ data: AllTypes?, _ error: Error?) -> Void)
```



unused

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let sessionID = "sessionID_example" // String | ID of session
let remoteAddress = "remoteAddress_example" // String | Client's remote address (optional)
let userAgent = "userAgent_example" // String | Client's user agent (optional)
let sort = "sort_example" // String | Field sorting (optional)
let filter = ["inner_example"] // [String] | Field filtering (optional)
let page = 987 // Int | Page number (optional) (default to 1)
let pageSize = 987 // Int | Number of items per page (optional) (default to 10)

CommonAPI.unused(sessionID: sessionID, remoteAddress: remoteAddress, userAgent: userAgent, sort: sort, filter: filter, page: page, pageSize: pageSize) { (response, error) in
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
 **sessionID** | **String** | ID of session | 
 **remoteAddress** | **String** | Client&#39;s remote address | [optional] 
 **userAgent** | **String** | Client&#39;s user agent | [optional] 
 **sort** | **String** | Field sorting | [optional] 
 **filter** | [**[String]**](String.md) | Field filtering | [optional] 
 **page** | **Int** | Page number | [optional] [default to 1]
 **pageSize** | **Int** | Number of items per page | [optional] [default to 10]

### Return type

[**AllTypes**](AllTypes.md)

### Authorization

[projectID](../README.md#projectID)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

