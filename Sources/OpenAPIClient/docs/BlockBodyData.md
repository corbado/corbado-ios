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
**longSession** | **String** | Only given when project environment is dev | [optional] 
**shortSession** | **String** |  | 
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


