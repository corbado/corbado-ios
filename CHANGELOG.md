# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.3] - 2026-09-11
- Re-run login-init before login-start, and manage-init before passkey-list append and delete, when the init data has expired. A login screen left open for longer than the backend process lifetime previously fell back silently to password login.

## [1.3.2] - 2026-09-07
- Fix signalAllAcceptedCredentials decoding userHandle and credential IDs as standard base64 instead of base64url, which intermittently failed passkey deletion with AuthorizationError
- Make the post-delete Signal API call best-effort so a signal failure no longer fails deletePasskey
- Preserve authorization error classifications and native diagnostics in login telemetry
- Include the failing field, credential index, encoded length, list mode and credential count in Signal API error diagnostics
- Require SimpleAuthenticationServices 1.2.1 for improved authorization error descriptions

## [1.3.0] - 2025-10-01
- Add support for situational appends
- Add support for conditional create
- Add support for signalAllAcceptedCredentials
- Collect device brand

## [1.2.1] - 2025-09-30
- Fix build error (Non-Sendable ASAuthorizationPlatformPublicKeyCredentialDescriptor in parseCredentials)

## [1.2.0] - 2025-07-05
- Bumped SimpleAuthenticationServices to 1.1.0
- Support latest FAPI version

## [1.1.0] - 2025-07-02
### Timeout handling
- Added a default timeout of 10s for all requests going to the Corbado Frontend API

## [1.0.0] - 2025-07-01
### Make feature complete with @corbado/connect-react (web version of this library) 

## [0.1.0] - 2025-06-05

### Added
- Initial release of the Corbado iOS SDK (`CorbadoConnect`).
- Functionality for passkey-based authentication: one-tap login, identifier-first login, and conditional UI.
- Functionality for passkey creation (append) and management (list, delete).
- `ConnectExample` application to demonstrate the SDK's features.
- UI tests for ensuring the quality of the example application and the SDK.
- GitHub Actions workflow for continuous integration.
- `LICENSE` (MIT) and initial `CHANGELOG.md`. 
