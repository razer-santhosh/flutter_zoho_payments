import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zoho_payments/zoho_payments.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zoho Payments Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _amountController = TextEditingController(text: '100');
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  ZohoEnvironment _selectedEnvironment = ZohoEnvironment.sandbox;
  bool _isInitialized = false;
  bool _isLoading = false;
  
  final ZohoPayments _zohoPayments = ZohoPayments();

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    try {
      final apiKey = dotenv.env['ZOHO_API_KEY'] ?? '';
      final accountId = dotenv.env['ZOHO_ACCOUNT_ID'] ?? '';
      
      if (apiKey.isEmpty || accountId.isEmpty) {
        _showError('Please configure ZOHO_API_KEY and ZOHO_ACCOUNT_ID in .env file');
        return;
      }

      final result = await _zohoPayments.initialize(
        apiKey: apiKey,
        accountId: accountId,
      );

      setState(() {
        _isInitialized = result;
      });

      if (!result) {
        _showError('Failed to initialize Zoho Payments SDK');
      }
    } catch (e) {
      _showError('Initialization error: $e');
    }
  }

  Future<String?> _createPaymentSession() async {
    try {
      final backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';
      final response = await http.post(
        Uri.parse('$backendUrl/api/create-payment-session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': double.parse(_amountController.text),
          'currency': 'INR',
          'customerName': _nameController.text,
          'customerEmail': _emailController.text,
          'customerPhone': _phoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['sessionId'];
      } else {
        _showError('Failed to create payment session');
        return null;
      }
    } catch (e) {
      _showError('Backend connection error: $e');
      return null;
    }
  }

  Future<void> _startPayment() async {
    if (!_isInitialized) {
      _showError('SDK not initialized');
      return;
    }

    if (_amountController.text.isEmpty) {
      _showError('Please enter amount');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create payment session on backend
      final sessionId = await _createPaymentSession();
      if (sessionId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Start payment flow
      final result = await _zohoPayments.startPayment(
        PaymentRequest(
          paymentSessionId: sessionId,
          amount: double.parse(_amountController.text),
          currency: 'INR',
          customerName: _nameController.text,
          customerEmail: _emailController.text,
          customerPhone: _phoneController.text,
          paymentMethod: _selectedPaymentMethod,
          environment: _selectedEnvironment,
        ),
      );

      setState(() {
        _isLoading = false;
      });

      if (result.isSuccess) {
        _showSuccess('Payment successful! ID: ${result.paymentId}');
      } else if (result.isCancelled) {
        _showInfo('Payment cancelled');
      } else {
        _showError('Payment failed: ${result.errorMessage}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Payment error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoho Payments Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SDK Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.error,
                          color: _isInitialized ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(_isInitialized ? 'Initialized' : 'Not initialized'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Environment selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Environment',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<ZohoEnvironment>(
                            title: const Text('Sandbox'),
                            value: ZohoEnvironment.sandbox,
                            groupValue: _selectedEnvironment,
                            onChanged: (value) {
                              setState(() {
                                _selectedEnvironment = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<ZohoEnvironment>(
                            title: const Text('Live'),
                            value: ZohoEnvironment.live,
                            groupValue: _selectedEnvironment,
                            onChanged: (value) {
                              setState(() {
                                _selectedEnvironment = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (INR)',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Customer Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Customer Phone',
                border: OutlineInputBorder(),
                prefixText: '+91 ',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    RadioListTile<PaymentMethod>(
                      title: const Text('UPI'),
                      value: PaymentMethod.upi,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    RadioListTile<PaymentMethod>(
                      title: const Text('Card'),
                      value: PaymentMethod.card,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    RadioListTile<PaymentMethod>(
                      title: const Text('Net Banking'),
                      value: PaymentMethod.netBanking,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _startPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Pay Now',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}