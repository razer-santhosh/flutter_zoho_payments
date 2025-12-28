import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'models/payment_request.dart';
import 'models/payment_result.dart';

/// The interface that platform-specific implementations of zoho_payments must implement.
abstract class ZohoPaymentsPlatform extends PlatformInterface {
  /// Constructs a ZohoPaymentsPlatform.
  ZohoPaymentsPlatform() : super(token: _token);

  static final Object _token = Object();

  static late ZohoPaymentsPlatform _instance;

  /// The default instance of [ZohoPaymentsPlatform] to use.
  static ZohoPaymentsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZohoPaymentsPlatform] when
  /// they register themselves.
  static set instance(ZohoPaymentsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initialize the Zoho Payments SDK
  Future<bool> initialize({
    required String apiKey,
    required String accountId,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Start a payment transaction
  Future<PaymentResult> startPayment(PaymentRequest request) {
    throw UnimplementedError('startPayment() has not been implemented.');
  }
}