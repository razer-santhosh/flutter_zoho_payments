library flutter_zoho_payments;

import 'src/zoho_payments_platform_interface.dart';
import 'src/zoho_payments_method_channel.dart';

export 'src/models/payment_request.dart';
export 'src/models/payment_result.dart';
export 'src/models/zoho_environment.dart';
export 'src/exceptions.dart';

/// Main class for interacting with Zoho Payments SDK
class ZohoPayments {
  static final ZohoPayments _instance = ZohoPayments._internal();
  
  factory ZohoPayments() => _instance;
  
  ZohoPayments._internal() {
    ZohoPaymentsPlatform.instance = MethodChannelZohoPayments();
  }

  /// Initialize the Zoho Payments SDK with your API credentials
  ///
  /// [apiKey] - Your Zoho Payments API key
  /// [accountId] - Your Zoho Payments account ID
  /// 
  /// Returns `true` if initialization is successful
  /// 
  /// Throws [ZohoPaymentsException] if initialization fails
  /// 
  /// Example:
  /// ```dart
  /// final zohoPayments = ZohoPayments();
  /// await zohoPayments.initialize(
  ///   apiKey: 'your_api_key',
  ///   accountId: 'your_account_id',
  /// );
  /// ```
  Future<bool> initialize({
    required String apiKey,
    required String accountId,
  }) {
    return ZohoPaymentsPlatform.instance.initialize(
      apiKey: apiKey,
      accountId: accountId,
    );
  }

  /// Start a payment transaction
  ///
  /// [request] - The payment request containing transaction details
  /// 
  /// Returns a [PaymentResult] with the outcome of the transaction
  /// 
  /// Throws [ZohoPaymentsException] if the payment process fails
  /// 
  /// Example:
  /// ```dart
  /// final result = await zohoPayments.startPayment(
  ///   PaymentRequest(
  ///     paymentSessionId: 'session_id_from_backend',
  ///     amount: 100.0,
  ///     currency: 'INR',
  ///     customerName: 'John Doe',
  ///     customerEmail: 'john@example.com',
  ///     paymentMethod: PaymentMethod.upi,
  ///   ),
  /// );
  /// 
  /// if (result.isSuccess) {
  ///   print('Payment successful: ${result.paymentId}');
  /// }
  /// ```
  Future<PaymentResult> startPayment(PaymentRequest request) {
    return ZohoPaymentsPlatform.instance.startPayment(request);
  }
}