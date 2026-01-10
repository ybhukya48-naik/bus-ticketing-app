import 'package:bus_ticketing_app/services/payment_gateway.dart';

class PhonePeGateway implements PaymentGateway {
  @override
  void initialize() {
    // TODO: Implement PhonePe initialization
    print('PhonePe Gateway Initialized');
  }

  @override
  Future<void> startPayment(double amount, String bookingId) async {
    // TODO: Implement PhonePe payment logic
    print('Starting PhonePe payment for $amount with booking ID $bookingId');
    await Future.delayed(const Duration(seconds: 2)); // Simulate payment processing
    print('PhonePe payment successful');
  }

  @override
  void dispose() {
    // TODO: Implement PhonePe disposal
    print('PhonePe Gateway Disposed');
  }
}
