import 'dart:convert';
import 'package:bus_ticketing_app/services/payment_gateway.dart';
import 'package:bus_ticketing_app/services/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class UpiQrGateway implements PaymentGateway {
  String? _upiUrl;
  String? _qrImageUrl;
  
  String? get upiUrl => _upiUrl;
  String? get qrImageUrl => _qrImageUrl;

  @override
  void initialize() {
    debugPrint('UPI QR Gateway Initialized');
  }

  @override
  Future<void> startPayment(double amount, String bookingId) async {
    try {
      // Fetch dynamic UPI QR from backend (Razorpay)
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/razorpay/create-qr'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (amount * 100).toInt(), // Amount in paise
          'bookingId': bookingId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _upiUrl = data['upi_url'];
        _qrImageUrl = data['payment_url'];
        debugPrint('Generated Razorpay UPI Link: $_upiUrl');
      } else {
        throw Exception('Failed to generate QR: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error generating UPI QR: $e');
      // Fallback to static QR if backend fails (optional)
      _upiUrl = "upi://pay?pa=paytmqr281005050101150897621438@paytm&pn=Bus%20Ticketing&am=${amount.toStringAsFixed(2)}&cu=INR";
    }
  }

  @override
  void dispose() {
    debugPrint('UPI QR Gateway Disposed');
  }
}
