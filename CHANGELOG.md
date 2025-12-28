# Changelog

## 0.2.0 - 2024-12-28

### Added
- Environment configuration support (sandbox/live) as parameter
- Lifecycle observer for better back button handling during payment
- Default to sandbox environment for safety

### Changed
- Package name from com.yourcompany to com.flutter
- Environment is now configurable per payment request

## 0.1.0 - 2024-12-28

### Initial Release
- Android platform support for Zoho Payments SDK
- Support for UPI, Card, and Net Banking payment methods
- Initialize SDK with API key and Account ID
- Start payment flow with customizable payment request
- Comprehensive error handling and result callbacks
- Type-safe Dart API with null safety support
- Example application demonstrating usage