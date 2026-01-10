import 'package:flutter/material.dart';
import 'package:bus_ticketing_app/models/bus.dart';
import 'package:bus_ticketing_app/payment_screen.dart';
import 'package:bus_ticketing_app/services/booking_creation_service.dart';
import 'package:bus_ticketing_app/services/auth_service.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final Bus bus;
  final List<int> selectedSeats;
  final double totalFare;
  final String date;

  const PassengerDetailsScreen({
    super.key,
    required this.bus,
    required this.selectedSeats,
    required this.totalFare,
    required this.date,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _ageControllers = [];
  final List<String> _genders = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.selectedSeats.length; i++) {
      _nameControllers.add(TextEditingController());
      _ageControllers.add(TextEditingController());
      _genders.add('Male');
    }
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _ageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _proceedToPayment() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authService = AuthService();
        final token = await authService.getToken();
        final username = await authService.getUsername();

        if (!mounted) return;

        if (token == null || username == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login first')),
          );
          return;
        }

        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        final bookingService = BookingCreationService();
        // Here we pass the number of seats. In a full app, we'd pass passenger details too.
        final bookingId = await bookingService.createBooking(
          widget.bus,
          widget.selectedSeats.length,
          username,
          token,
        );

        if (!mounted) return;

        Navigator.pop(context); // Remove loading

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(bookingId: bookingId),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create booking: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'PASSENGER DETAILS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Journey Summary Mini Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.bus.route,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.date} | ${widget.selectedSeats.length} Seats',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                      ),
                    ],
                  ),
                  const Icon(Icons.directions_bus, color: Colors.white24, size: 30),
                ],
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: widget.selectedSeats.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A237E).withOpacity(0.05),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline, size: 20, color: Color(0xFF1A237E)),
                              const SizedBox(width: 8),
                              Text(
                                'Passenger ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Seat ${widget.selectedSeats[index]}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _nameControllers[index],
                                label: 'Full Name',
                                icon: Icons.badge_outlined,
                                validator: (value) => value!.isEmpty ? 'Enter name' : null,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: _buildTextField(
                                      controller: _ageControllers[index],
                                      label: 'Age',
                                      icon: Icons.cake_outlined,
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value!.isEmpty ? 'Enter age' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: _buildGenderDropdown(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildSummaryPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(int index) {
    return DropdownButtonFormField<String>(
      initialValue: _genders[index],
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.wc_outlined, color: Colors.grey[400], size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
        ),
      ),
      items: ['Male', 'Female', 'Other']
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (value) => setState(() => _genders[index] = value!),
    );
  }

  Widget _buildSummaryPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹ ${widget.totalFare.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF1A237E),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _proceedToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: const Color(0xFF1A237E).withOpacity(0.4),
                ),
                child: const Text(
                  'PAY NOW',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
