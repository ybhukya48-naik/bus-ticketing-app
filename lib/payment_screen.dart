import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bus_ticketing_app/services/payment_gateway.dart';
import 'package:bus_ticketing_app/services/payment_gateway_factory.dart';
import 'package:bus_ticketing_app/services/upi_qr_gateway.dart';
import 'package:bus_ticketing_app/services/razorpay_gateway.dart';



class PaymentScreen extends StatefulWidget {
  final String bookingId;

  const PaymentScreen({super.key, required this.bookingId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentGateway? _currentPaymentGateway;
  PaymentGatewayFactory? _selectedPaymentGatewayFactory;
  bool _isLoading = false;

  late List<PaymentGatewayFactory> _gateways;

  @override
  void initState() {
    super.initState();
    _gateways = [
      UpiQrGatewayFactory(),
      RazorpayGatewayFactory(
        onSuccess: (id) => _showSuccessAndNavigate(),
        onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
      ),
      NetBankingGatewayFactory(),
      StripeGatewayFactory(),
      PhonePeGatewayFactory(),
      GPayGatewayFactory(),
      PaytmGatewayFactory(),
    ];
    _selectedPaymentGatewayFactory = _gateways[0]; // Default to UPI QR
    _currentPaymentGateway = _selectedPaymentGatewayFactory?.createGateway(context);
    _currentPaymentGateway?.initialize();
    
    // Auto-generate QR if UPI is selected
    if (_currentPaymentGateway is UpiQrGateway) {
      _processPayment();
    }
  }

  @override
  void dispose() {
    _currentPaymentGateway?.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_currentPaymentGateway != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // For now, a fixed amount. This should come from the booking details.
        await _currentPaymentGateway!.startPayment(100.00, widget.bookingId);
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // If not UPI, navigate to success screen
          if (_currentPaymentGateway is! UpiQrGateway && _currentPaymentGateway is! RazorpayGateway) {
            _showSuccessAndNavigate();
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment error: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
    }
  }

  void _showSuccessAndNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Successful!')),
    );
    // In a real app, you would pass more data to the ticket screen
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A237E).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'PAYMENT AMOUNT',
                      style: TextStyle(
                        color: Colors.white70,
                        letterSpacing: 1.5,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '₹ 100.00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.white24),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Booking ID', style: TextStyle(color: Colors.white70)),
                        Text(
                          widget.bookingId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 16),
              
              // Custom Payment Selector (instead of Dropdown)
              ..._gateways.map((factory) => _buildPaymentOption(factory)),
              
              const SizedBox(height: 24),
              
              // QR Display Area
              if (_isLoading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Preparing secure payment...'),
                    ],
                  ),
                )
              else if (_currentPaymentGateway is UpiQrGateway && (_currentPaymentGateway as UpiQrGateway).upiUrl != null)
                _buildQrSection()
              else
                // Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: const Color(0xFF1A237E),
                      elevation: 8,
                      shadowColor: const Color(0xFFFFD700).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _currentPaymentGateway is UpiQrGateway ? 'GENERATE QR' : 'PAY NOW',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(PaymentGatewayFactory factory) {
    final bool isSelected = _selectedPaymentGatewayFactory == factory;
    String name = factory.runtimeType.toString().replaceAll('GatewayFactory', '');
    IconData icon = Icons.payment;
    Color iconColor = const Color(0xFF1A237E);

    if (factory is RazorpayGatewayFactory) {
      name = 'Razorpay (Card/UPI/Net)';
      icon = Icons.security_rounded;
    } else if (factory is UpiQrGatewayFactory) {
      name = 'PhonePe / GPay (QR Scan)';
      icon = Icons.qr_code_scanner_rounded;
      iconColor = const Color(0xFF3949AB);
    } else if (factory is StripeGatewayFactory) {
      name = 'International Card (Stripe)';
      icon = Icons.credit_card_rounded;
      iconColor = const Color(0xFF6772E5);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPaymentGateway?.dispose();
          _selectedPaymentGatewayFactory = factory;
          _currentPaymentGateway = _selectedPaymentGatewayFactory?.createGateway(context);
          _currentPaymentGateway?.initialize();
          
          if (_currentPaymentGateway is UpiQrGateway) {
            _processPayment();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? iconColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? iconColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: iconColor)
            else
              const Icon(Icons.circle_outlined, color: Colors.black12),
          ],
        ),
      ),
    );
  }

  Widget _buildQrSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: QrImageView(
            data: (_currentPaymentGateway as UpiQrGateway).upiUrl!,
            version: QrVersions.auto,
            size: 200.0,
            errorCorrectionLevel: QrErrorCorrectLevel.H,
            gapless: false,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Scan to pay securely',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Text(
          'Works with GPay, PhonePe, Paytm & more',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showSuccessAndNavigate,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF1A237E), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            icon: const Icon(Icons.check_circle_outline, color: Color(0xFF1A237E)),
            label: const Text(
              'I HAVE PAID',
              style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
