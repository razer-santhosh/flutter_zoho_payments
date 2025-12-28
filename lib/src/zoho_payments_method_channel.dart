import 'package:flutter/services.dart';
import 'zoho_payments_platform_interface.dart';
import 'models/payment_request.dart';
import 'models/payment_result.dart';
import 'exceptions.dart';

/// An implementation of [ZohoPaymentsPlatform] that uses method channels.
class MethodChannelZohoPayments extends ZohoPaymentsPlatform {
  static const MethodChannel _channel = MethodChannel('zoho_payments');

  @override
  Future<bool> initialize({
    required String apiKey,
    required String accountId,
  }) async {
    try {
      final result = await _channel.invokeMethod('initialize', {
        'apiKey': apiKey,
        'accountId': accountId,
      });
      return result == true;
    } on PlatformException catch (e) {
      throw ZohoPaymentsException(
        code: e.code,
        message: e.message ?? 'Failed to initialize Zoho Payments SDK',
      );
    }
  }

  @override
  Future<PaymentResult> startPayment(PaymentRequest request) async {
    try {
      final result = await _channel.invokeMethod(
        'startPayment',
        request.toMap(),
      );
      return PaymentResult.fromMap(result as Map<dynamic, dynamic>);
    } on PlatformException catch (e) {
      throw ZohoPaymentsException(
        code: e.code,
        message: e.message ?? 'Payment failed',
      );
    }
  }
}