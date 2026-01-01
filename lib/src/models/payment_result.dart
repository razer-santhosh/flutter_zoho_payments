/// Status of a payment transaction
enum PaymentStatus {
  /// Payment completed successfully
  success,

  /// Payment failed
  failure,

  /// Payment cancelled by user
  cancelled,
}

/// Represents the result of a payment transaction
class PaymentResult {
  /// Status of the payment
  final PaymentStatus status;

  /// Unique payment ID from Zoho
  final String? paymentId;

  /// Order ID associated with the payment
  final String? orderId;

  /// Payment signature for verification
  final String? signature;

  /// Error code if payment failed
  final String? errorCode;

  /// Human-readable error message
  final String? errorMessage;

  PaymentResult({
    required this.status,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorCode,
    this.errorMessage,
  });

  /// Creates a PaymentResult from a map received from method channel
  factory PaymentResult.fromMap(Map<dynamic, dynamic> map) {
    final statusStr = map['status'] as String;
    PaymentStatus status;

    switch (statusStr) {
      case 'success':
        status = PaymentStatus.success;
        break;
      case 'failure':
        status = PaymentStatus.failure;
        break;
      case 'cancelled':
      default:
        status = PaymentStatus.cancelled;
        break;
    }

    return PaymentResult(
      status: status,
      paymentId: map['paymentId'] as String?,
      orderId: map['orderId'] as String?,
      signature: map['signature'] as String?,
      errorCode: map['errorCode'] as String?,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  /// Checks if the payment was successful
  bool get isSuccess => status == PaymentStatus.success;

  /// Checks if the payment failed
  bool get isFailure => status == PaymentStatus.failure;

  /// Checks if the payment was cancelled
  bool get isCancelled => status == PaymentStatus.cancelled;

  /// Converts this PaymentResult to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last,
      'paymentId': paymentId,
      'orderId': orderId,
      'signature': signature,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
    };
  }
}
