# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2025-10-01
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
