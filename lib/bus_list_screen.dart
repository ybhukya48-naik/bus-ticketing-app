import 'package:flutter/material.dart';
import 'package:bus_ticketing_app/map_screen.dart';
import 'package:bus_ticketing_app/seat_selection_screen.dart';
import 'package:bus_ticketing_app/services/bus_service.dart';
import 'package:bus_ticketing_app/models/bus.dart';

import 'package:bus_ticketing_app/models/bus_stop.dart';
import 'package:bus_ticketing_app/services/stop_service.dart';

class BusListScreen extends StatefulWidget {
  final String? origin;
  final String? destination;
  final String? date;

  const BusListScreen({super.key, this.origin, this.destination, this.date});

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  late Future<List<Bus>> futureBuses;
  final Map<String, List<BusStop>> _busStopsCache = {};

  @override
  void initState() {
    super.initState();
    futureBuses = fetchBuses();
  }

  Future<List<BusStop>> _getBusStops(Bus bus) async {
    if (_busStopsCache.containsKey(bus.id)) {
      return _busStopsCache[bus.id]!;
    }

    if (bus.routeStopsOrder == null || bus.routeStopsOrder!.isEmpty) {
      return [];
    }

    try {
      final stops = await StopService().fetchStopsByIds(bus.routeStopsOrder!);
      _busStopsCache[bus.id] = stops;
      return stops;
    } catch (e) {
      debugPrint('Error fetching stops for bus ${bus.id}: $e');
      return [];
    }
  }

  Future<List<Bus>> fetchBuses() async {
    final from = widget.origin ?? '';
    final to = widget.destination ?? '';
    // Use the BusService with origin and destination for backend filtering
    return BusService().fetchBuses(
      city: from.isNotEmpty ? from : null,
      origin: from.isNotEmpty ? from : null,
      destination: to.isNotEmpty ? to : null,
    );
  }

  void _selectSeats(Bus bus) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeatSelectionScreen(bus: bus, date: widget.date ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Buses'),
      ),
      body: FutureBuilder<List<Bus>>(
        future: futureBuses,
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
                  ElevatedButton(
                    onPressed: () => setState(() { futureBuses = fetchBuses(); }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Bus bus = snapshot.data![index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        // Top part with Bus Name and Price
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A237E).withOpacity(0.05),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bus.busNumber,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                  Text(
                                    bus.route,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '₹${bus.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Middle part with details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBusDetail(Icons.event_seat, '${bus.availableSeats} Left', 'Seats'),
                              _buildBusDetail(Icons.star, '${bus.rating}', 'Rating'),
                              _buildBusDetail(Icons.location_on, 'Live', 'Track'),
                            ],
                          ),
                        ),
                        // Stops Section
                        FutureBuilder<List<BusStop>>(
                          future: _getBusStops(bus),
                          builder: (context, stopSnapshot) {
                            if (stopSnapshot.hasData && stopSnapshot.data!.isNotEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Stops:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: stopSnapshot.data!.map((stop) {
                                          int index = stopSnapshot.data!.indexOf(stop);
                                          return Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  stop.stopName,
                                                  style: const TextStyle(fontSize: 11, color: Colors.blue),
                                                ),
                                              ),
                                              if (index < stopSnapshot.data!.length - 1)
                                                const Icon(Icons.arrow_right, size: 16, color: Colors.grey),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        // Bottom part with actions
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: () => _selectSeats(bus),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A237E),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('BOOK NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => MapScreen(bus: bus)),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: const BorderSide(color: Color(0xFF1A237E)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Icon(Icons.map_outlined, color: Color(0xFF1A237E)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No buses available for this route.'));
          }
        },
      ),
    );
  }

  Widget _buildBusDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1A237E)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    );
  }
}
