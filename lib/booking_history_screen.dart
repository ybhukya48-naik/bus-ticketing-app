import 'package:flutter/material.dart';
import 'package:bus_ticketing_app/models/booking.dart';
import 'package:bus_ticketing_app/services/booking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late Future<List<Booking>> futureBookings = Future.value([]);
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchBookings();
  }

  Future<void> _loadTokenAndFetchBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    print('!!! Loading Booking History for token: ${_token != null ? "FOUND" : "NOT FOUND"} !!!');

    if (_token != null) {
      setState(() {
        futureBookings = BookingService().fetchBookingHistory(_token!);
      });
    } else {
      print('!!! No token found in SharedPreferences !!!');
      setState(() {
        futureBookings = Future.error('User not logged in');
      });
    }
  }

  void _downloadTicket(Booking booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading E-Ticket for ${booking.busNumber}...')),
    );
    // Simulation of PDF generation
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-Ticket saved to downloads!')),
      );
    });
  }

  void _cancelBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ticket?'),
        content: const Text('Are you sure you want to cancel this ticket? 20% cancellation charges may apply.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cancellation request submitted!')),
              );
            },
            child: const Text('YES, CANCEL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: FutureBuilder<List<Booking>>(
        future: futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                ],
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Booking booking = snapshot.data![index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Ticket Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A237E),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              booking.busNumber,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'CONFIRMED',
                                style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Ticket Body
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.route, color: Color(0xFF1A237E), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    booking.route,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildBookingInfo('DATE', booking.bookingDate),
                                _buildBookingInfo('SEATS', '${booking.numberOfSeats}'),
                                _buildBookingInfo('PRICE', '₹${booking.totalPrice.toStringAsFixed(0)}'),
                              ],
                            ),
                            if (booking.qrCodeData != null && booking.qrCodeData!.isNotEmpty) ...[
                              const Divider(height: 32),
                              GestureDetector(
                                onTap: () => _showQrDialog(booking),
                                child: Column(
                                  children: [
                                    QrImageView(
                                      data: booking.qrCodeData!,
                                      version: QrVersions.auto,
                                      size: 100.0,
                                    ),
                                    const Text('Tap to enlarge QR', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Ticket Actions
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => _downloadTicket(booking),
                                icon: const Icon(Icons.file_download_outlined, size: 20),
                                label: const Text('TICKET'),
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFF1A237E)),
                              ),
                            ),
                            Container(width: 1, height: 20, color: Colors.grey[300]),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => _cancelBooking(booking),
                                icon: const Icon(Icons.cancel_outlined, size: 20),
                                label: const Text('CANCEL'),
                                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No bookings found. Start your journey today!'));
          }
        },
      ),
    );
  }

  Widget _buildBookingInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  void _showQrDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Boarding Pass QR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              QrImageView(
                data: booking.qrCodeData!,
                version: QrVersions.auto,
                size: 250.0,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}