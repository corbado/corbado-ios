# BlockBodyData

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**blockType** | **String** |  | 
**challenge** | **String** |  | 
**identifierValue** | **String** |  | 
**identifierType** | [**LoginIdentifierType**](LoginIdentifierType.md) |  | 
**autoSubmit** | **Bool** |  | 
**passkeyIconSet** | [**PasskeyIconSet**](PasskeyIconSet.md) |  | 
**variant** | **String** |  | 
**loginHint** | **String** |  | [optional] 
**verificationMethod** | [**VerificationMethod**](VerificationMethod.md) |  | 
**identifier** | **String** |  | 
**retryNotBefore** | **Int** |  | [optional] 
**error** | [**RequestError**](RequestError.md) |  | [optional] 
**alternativeVerificationMethods** | [GeneralBlockVerifyIdentifierAlternativeVerificationMethodsInner] |  | 
**isPostLoginVerification** | **Bool** |  | 
**longSession** | **String** | This is only set if the project environment is set to &#39;dev&#39;. If set the UI components will set the longSession in local storage because the cookie dropping will not work in Safari for example (\&quot;third-party cookie\&quot;). | [optional] 
**refreshToken** | **String** | This is only set if the project environment is set to &#39;dev&#39;. If set the UI components will set the longSession in local storage because the cookie dropping will not work in Safari for example (\&quot;third-party cookie\&quot;). | [optional] 
**shortSession** | **String** |  | 
**sessionToken** | **String** |  | 
**passkeyOperation** | [**PasskeyOperation**](PasskeyOperation.md) |  | [optional] 
**identifiers** | [LoginIdentifierWithError] |  | 
**fullName** | [**FullNameWithError**](FullNameWithError.md) |  | [optional] 
**socialData** | [**SocialData**](SocialData.md) |  | 
**conditionalUIChallenge** | **String** |  | [optional] 
**isPhone** | **Bool** |  | 
**isPhoneAvailable** | **Bool** |  | 
**isEmailAvailable** | **Bool** |  | 
**isUsernameAvailable** | **Bool** |  | 
**fieldError** | [**RequestError**](RequestError.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


