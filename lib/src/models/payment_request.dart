/// Represents a payment request to be processed by Zoho Payments
class PaymentRequest {
  /// Unique session ID for the payment transaction
  final String paymentSessionId;

  /// Amount to be charged
  final double amount;

  /// Currency code (default: INR)
  final String currency;

  /// Description of the payment
  final String? description;

  /// Customer's full name
  final String? customerName;

  /// Customer's email address
  final String? customerEmail;

  /// Customer's phone number
  final String? customerPhone;

  /// Preferred payment method
  final PaymentMethod? paymentMethod;

  PaymentRequest({
    required this.paymentSessionId,
    required this.amount,
    this.currency = 'INR',
    this.description,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.paymentMethod,
  });

  /// Converts the payment request to a map for method channel communication
  Map<String, dynamic> toMap() {
    return {
      'paymentSessionId': paymentSessionId,
      'amount': amount,
      'currency': currency,
      'description': description,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod?.toString().split('.').last,
    };
  }
}

/// Available payment methods in Zoho Payments
enum PaymentMethod {
  /// Card payment (Credit/Debit)
  card,
  
  /// Internet banking
  netBanking,
  
  /// UPI payment
  upi,
}