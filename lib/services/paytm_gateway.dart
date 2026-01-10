import 'package:bus_ticketing_app/services/payment_gateway.dart';

class PaytmGateway implements PaymentGateway {
  @override
  void initialize() {
    // TODO: Implement Paytm initialization
    print('Paytm Gateway Initialized');
  }

  @override
  Future<void> startPayment(double amount, String bookingId) async {
    // TODO: Implement Paytm payment logic
    print('Starting Paytm payment for $amount with booking ID $bookingId');
    await Future.delayed(const Duration(seconds: 2)); // Simulate payment processing
    print('Paytm payment successful');
  }

  @override
  void dispose() {
    // TODO: Implement Paytm disposal
    print('Paytm Gateway Disposed');
  }
}
