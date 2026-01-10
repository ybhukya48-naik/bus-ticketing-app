import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:bus_ticketing_app/services/payment_gateway.dart';
import 'package:bus_ticketing_app/services/api_config.dart';
import 'package:http/http.dart' as http;

class RazorpayGateway implements PaymentGateway {
  late Razorpay _razorpay;
  final BuildContext context;
  final Function(String)? onSuccess;
  final Function(String)? onError;

  RazorpayGateway(this.context, {this.onSuccess, this.onError});

  @override
  void initialize() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("RAZORPAY SUCCESS: ${response.paymentId}");
    
    // Verify payment on backend
    try {
      final verifyUrl = Uri.parse('${ApiConfig.baseUrl}/razorpay/verify-payment');
      await http.post(
        verifyUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'razorpay_payment_id': response.paymentId,
          'razorpay_order_id': response.orderId,
          'razorpay_signature': response.signature,
        }),
      );
    } catch (e) {
      debugPrint("Verification failed: $e");
    }

    if (onSuccess != null) {
      onSuccess!(response.paymentId ?? "SUCCESS");
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("RAZORPAY ERROR: ${response.code} - ${response.message}");
    if (onError != null) {
      onError!(response.message ?? "Payment Failed");
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Failed: ${response.message}")),
        );
      }
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("RAZORPAY EXTERNAL WALLET: ${response.walletName}");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("External Wallet Selected: ${response.walletName}")),
      );
    }
  }

  @override
  Future<void> startPayment(double amount, String bookingId) async {
    try {
      // 1. Create order on backend
      final orderUrl = Uri.parse('${ApiConfig.baseUrl}/razorpay/create-order');
      final response = await http.post(
        orderUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (amount * 100).toInt(), // Amount in paise
          'bookingId': bookingId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create order on backend');
      }

      final orderData = json.decode(response.body);
      final orderId = orderData['orderId'];
      final keyId = orderData['keyId'];

      // 2. Open Razorpay Checkout
      var options = {
        'key': keyId,
        'amount': orderData['amount'],
        'order_id': orderId,
        'name': 'Bus Ticketing',
        'description': 'Booking ID: $bookingId',
        'timeout': 300,
        'prefill': {
          'contact': '9876543210',
          'email': 'user@example.com',
        },
        'external': {
          'wallets': ['paytm']
        },
        'send_sms_hash': true,
        'retry': {'enabled': true, 'max_count': 4},
      };

      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error starting Razorpay: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting payment: $e')),
        );
      }
    }
  }
}
