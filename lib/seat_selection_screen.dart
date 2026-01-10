import 'package:flutter/material.dart';
import 'package:bus_ticketing_app/models/bus.dart';
import 'package:bus_ticketing_app/passenger_details_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Bus bus;
  final String date;

  const SeatSelectionScreen({super.key, required this.bus, required this.date});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<int> _selectedSeats = [];
  final List<int> _bookedSeats = [3, 7, 12, 18, 24]; // Dummy booked seats for demo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'SELECT SEATS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Bus Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_bus, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.bus.busNumber,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      widget.date,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLegend(),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Driver Side
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.settings, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSeatGrid(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(Colors.white, Colors.grey[300]!, 'Available'),
        _legendItem(const Color(0xFFFFD700), const Color(0xFFFFD700), 'Selected'),
        _legendItem(const Color(0xFFE0E0E0), const Color(0xFFBDBDBD), 'Booked'),
      ],
    );
  }

  Widget _legendItem(Color color, Color borderColor, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSeatGrid() {
    int totalSeats = widget.bus.capacity;
    int rows = (totalSeats / 4).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSeat(rowIndex * 4 + 1),
              const SizedBox(width: 10),
              _buildSeat(rowIndex * 4 + 2),
              const SizedBox(width: 40), // Aisle
              _buildSeat(rowIndex * 4 + 3),
              const SizedBox(width: 10),
              _buildSeat(rowIndex * 4 + 4),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSeat(int seatNumber) {
    if (seatNumber > widget.bus.capacity) return const SizedBox(width: 45, height: 45);

    bool isBooked = _bookedSeats.contains(seatNumber);
    bool isSelected = _selectedSeats.contains(seatNumber);

    return GestureDetector(
      onTap: isBooked
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  _selectedSeats.remove(seatNumber);
                } else {
                  _selectedSeats.add(seatNumber);
                }
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: isBooked 
              ? Colors.grey[200] 
              : (isSelected ? const Color(0xFFFFD700) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isBooked 
                ? Colors.grey[300]! 
                : (isSelected ? const Color(0xFFFFD700) : const Color(0xFF1A237E).withOpacity(0.2)),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            '$seatNumber',
            style: TextStyle(
              color: isBooked 
                  ? Colors.grey[400] 
                  : (isSelected ? Colors.white : const Color(0xFF1A237E)),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    double totalFare = _selectedSeats.length * widget.bus.price;

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
                  Text(
                    '${_selectedSeats.length} Seats Selected',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹ ${totalFare.toStringAsFixed(2)}',
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
                onPressed: _selectedSeats.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PassengerDetailsScreen(
                              bus: widget.bus,
                              selectedSeats: _selectedSeats,
                              totalFare: totalFare,
                              date: widget.date,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: const Color(0xFF1A237E).withOpacity(0.4),
                ),
                child: const Text(
                  'CONTINUE',
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
