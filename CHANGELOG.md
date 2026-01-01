# Changelog

## 0.2.5 - 2026-01-01

### Changed
- Updated version to 0.2.5

## 0.2.4 - 2026-01-01

### Fixed
- Fixed Dart formatting issues in exceptions.dart and payment_request.dart
- Improved code formatting compliance for pub.dev scoring

## 0.2.3 - 2025-12-28

### Changed
- Migrated all build.gradle files to Kotlin DSL (build.gradle.kts)
- Modernized build configuration with type-safe Kotlin syntax
- Updated documentation to support both Groovy and Kotlin DSL
- Fixed circular import in main library file

## 0.2.2 - 2025-12-28

### Fixed
- Added Zoho Maven repository (https://maven.zohodl.com) to plugin build configuration
- Resolved SDK dependency resolution issues
- Updated documentation with repository setup instructions

## 0.2.1 - 2025-12-28

### Fixed
- Added missing `registerWith()` static method for Dart-only plugin registration
- Fixed duplicate class definition
- Resolved plugin initialization issues

## 0.2.0 - 2025-12-28

### Added
- Environment configuration support (sandbox/live) as parameter
- Lifecycle observer for better back button handling during payment
- Default to sandbox environment for safety

### Changed
- Package name from com.yourcompany to com.flutter
- Environment is now configurable per payment request

## 0.1.0 - 2025-12-28

### Initial Release
- Android platform support for Zoho Payments SDK
- Support for UPI, Card, and Net Banking payment methods
- Initialize SDK with API key and Account ID
- Start payment flow with customizable payment request
- Comprehensive error handling and result callbacks
- Type-safe Dart API with null safety support
- Example application demonstrating usage