/// Exception thrown when Zoho Payments operations fail
class ZohoPaymentsException implements Exception {
  /// Error code from the platform
  final String code;

  /// Human-readable error message
  final String message;

  ZohoPaymentsException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'ZohoPaymentsException($code): $message';
}