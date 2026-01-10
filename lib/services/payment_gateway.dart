abstract class PaymentGateway {
  void initialize();
  Future<void> startPayment(double amount, String bookingId);
  void dispose();
}