import 'package:bus_ticketing_app/services/payment_gateway.dart';

class GPayGateway implements PaymentGateway {
  @override
  void initialize() {
    // TODO: Implement GPay initialization
    print('GPay Gateway Initialized');
  }

  @override
  Future<void> startPayment(double amount, String bookingId) async {
    // TODO: Implement GPay payment logic
    print('Starting GPay payment for $amount with booking ID $bookingId');
    await Future.delayed(const Duration(seconds: 2)); // Simulate payment processing
    print('GPay payment successful');
  }

  @override
  void dispose() {
    // TODO: Implement GPay disposal
    print('GPay Gateway Disposed');
  }
}
