import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:bus_ticketing_app/services/payment_gateway.dart';
import 'package:http/http.dart' as http;

import 'package:bus_ticketing_app/services/api_config.dart';

class StripeGateway implements PaymentGateway {
  final BuildContext context;

  StripeGateway(this.context);

  @override
  void initialize() {
    // Stripe.publishableKey will be set globally in main.dart
  }

  @override
  Future<void>  startPayment(double amount, String bookingId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/stripe/create-payment-intent');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (amount * 100).toInt(), // amount in cents
          'currency': 'usd',
          'bookingId': bookingId,
        }),
      );

      final responseData = json.decode(response.body);
      final clientSecret = responseData['clientSecret'];

      if (clientSecret != null) {
        // Initialize the payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Bus Ticketing App',
            style: context.mounted && Theme.of(context).brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
          ),
        );

        // Present the payment sheet
        await Stripe.instance.presentPaymentSheet();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stripe payment successful!')),
          );
        }
      } else {
        throw Exception('Failed to get client secret from backend');
      }
    } catch (e) {
      print('Error initiating Stripe payment: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stripe payment failed: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose Stripe resources if any
  }
}
