//
// ConfigsAPI.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

open class ConfigsAPI {

    /**
     Get Session Configuration
     
     - parameter apiConfiguration: The configuration for the http request.
     - returns: SessionConfigRsp
     */
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    open class func getSessionConfig(apiConfiguration: OpenAPIClientAPIConfiguration = OpenAPIClientAPIConfiguration.shared) async throws(ErrorResponse) -> SessionConfigRsp {
        return try await getSessionConfigWithRequestBuilder(apiConfiguration: apiConfiguration).execute().body
    }

    /**
     Get Session Configuration
     - GET /v2/session-config
     - Retrieves the session configuration settings
     - Bearer Token:
       - type: http
       - name: bearerAuth
     - API Key:
       - type: apiKey X-Corbado-ProjectID (HEADER)
       - name: projectID
     - parameter apiConfiguration: The configuration for the http request.
     - returns: RequestBuilder<SessionConfigRsp> 
     */
    open class func getSessionConfigWithRequestBuilder(apiConfiguration: OpenAPIClientAPIConfiguration = OpenAPIClientAPIConfiguration.shared) -> RequestBuilder<SessionConfigRsp> {
        let localVariablePath = "/v2/session-config"
        let localVariableURLString = apiConfiguration.basePath + localVariablePath
        let localVariableParameters: [String: any Sendable]? = nil

        let localVariableUrlComponents = URLComponents(string: localVariableURLString)

        let localVariableNillableHeaders: [String: (any Sendable)?] = [
            :
        ]

        let localVariableHeaderParameters = APIHelper.rejectNilHeaders(localVariableNillableHeaders)

        let localVariableRequestBuilder: RequestBuilder<SessionConfigRsp>.Type = apiConfiguration.requestBuilderFactory.getBuilder()

        return localVariableRequestBuilder.init(method: "GET", URLString: (localVariableUrlComponents?.string ?? localVariableURLString), parameters: localVariableParameters, headers: localVariableHeaderParameters, requiresAuthentication: true, apiConfiguration: apiConfiguration)
    }

    /**
     Get User Details Configuration
     
     - parameter apiConfiguration: The configuration for the http request.
     - returns: UserDetailsConfigRsp
     */
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    open class func getUserDetailsConfig(apiConfiguration: OpenAPIClientAPIConfiguration = OpenAPIClientAPIConfiguration.shared) async throws(ErrorResponse) -> UserDetailsConfigRsp {
        return try await getUserDetailsConfigWithRequestBuilder(apiConfiguration: apiConfiguration).execute().body
    }

    /**
     Get User Details Configuration
     - GET /v2/user-details-config
     - Gets configs needed by the UserDetails component
     - Bearer Token:
       - type: http
       - name: bearerAuth
     - API Key:
       - type: apiKey X-Corbado-ProjectID (HEADER)
       - name: projectID
     - parameter apiConfiguration: The configuration for the http request.
     - returns: RequestBuilder<UserDetailsConfigRsp> 
     */
    open class func getUserDetailsConfigWithRequestBuilder(apiConfiguration: OpenAPIClientAPIConfiguration = OpenAPIClientAPIConfiguration.shared) -> RequestBuilder<UserDetailsConfigRsp> {
        let localVariablePath = "/v2/user-details-config"
        let localVariableURLString = apiConfiguration.basePath + localVariablePath
        let localVariableParameters: [String: any Sendable]? = nil

        let localVariableUrlComponents = URLComponents(string: localVariableURLString)

        let localVariableNillableHeaders: [String: (any Sendable)?] = [
            :
        ]

        let localVariableHeaderParameters = APIHelper.rejectNilHeaders(localVariableNillableHeaders)

        let localVariableRequestBuilder: RequestBuilder<UserDetailsConfigRsp>.Type = apiConfiguration.requestBuilderFactory.getBuilder()

        return localVariableRequestBuilder.init(method: "GET", URLString: (localVariableUrlComponents?.string ?? localVariableURLString), parameters: localVariableParameters, headers: localVariableHeaderParameters, requiresAuthentication: true, apiConfiguration: apiConfiguration)
    }
}
