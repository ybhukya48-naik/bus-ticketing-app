import 'package:bus_ticketing_app/services/payment_gateway.dart';

class NetBankingGateway implements PaymentGateway {
  @override
  void initialize() {
    print('Net Banking Gateway Initialized');
  }

  @override
  Future<void> startPayment(double amount, String bookingId) async {
    print('Starting Net Banking payment for $amount with booking ID $bookingId');
    // Simulate redirecting to a bank page
    await Future.delayed(const Duration(seconds: 2));
    print('Net Banking payment successful');
  }

  @override
  void dispose() {
    print('Net Banking Gateway Disposed');
  }
}
