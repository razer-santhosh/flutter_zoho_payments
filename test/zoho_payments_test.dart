import 'package:flutter_test/flutter_test.dart';
import 'package:zoho_payments/zoho_payments.dart';

void main() {
  group('ZohoPayments', () {
    test('PaymentRequest creates correct map', () {
      final request = PaymentRequest(
        paymentSessionId: 'test_session',
        amount: 100.0,
        currency: 'INR',
        customerName: 'Test User',
        customerEmail: 'test@example.com',
        customerPhone: '1234567890',
        paymentMethod: PaymentMethod.upi,
        environment: ZohoEnvironment.sandbox,
      );

      final map = request.toMap();

      expect(map['paymentSessionId'], 'test_session');
      expect(map['amount'], 100.0);
      expect(map['currency'], 'INR');
      expect(map['customerName'], 'Test User');
      expect(map['customerEmail'], 'test@example.com');
      expect(map['customerPhone'], '1234567890');
      expect(map['paymentMethod'], 'upi');
      expect(map['environment'], 'sandbox');
    });

    test('PaymentResult parses success correctly', () {
      final result = PaymentResult.fromMap({
        'status': 'success',
        'paymentId': 'pay_123',
        'orderId': 'order_456',
        'signature': 'sig_789',
      });

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.isCancelled, false);
      expect(result.paymentId, 'pay_123');
      expect(result.orderId, 'order_456');
      expect(result.signature, 'sig_789');
    });

    test('PaymentResult parses failure correctly', () {
      final result = PaymentResult.fromMap({
        'status': 'failure',
        'errorCode': 'ERR_001',
        'errorMessage': 'Payment failed',
      });

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.isCancelled, false);
      expect(result.errorCode, 'ERR_001');
      expect(result.errorMessage, 'Payment failed');
    });

    test('PaymentResult parses cancelled correctly', () {
      final result = PaymentResult.fromMap({
        'status': 'cancelled',
        'errorMessage': 'User cancelled payment',
      });

      expect(result.isSuccess, false);
      expect(result.isFailure, false);
      expect(result.isCancelled, true);
      expect(result.errorMessage, 'User cancelled payment');
    });
  });
}