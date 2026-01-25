import 'package:flutter/material.dart';
import 'package:bus_ticketing_app/bus_list_screen.dart';
import 'package:bus_ticketing_app/models/bus_stop.dart';
import 'package:bus_ticketing_app/services/stop_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  
  List<BusStop> _allStops = [];
  bool _isLoadingStops = true;

  @override
  void initState() {
    super.initState();
    _fetchStops();
  }

  Future<void> _fetchStops() async {
    if (!mounted) return;
    setState(() => _isLoadingStops = true);
    try {
      final stops = await StopService().fetchStops();
      if (!mounted) return;
      setState(() {
        _allStops = stops..sort((a, b) {
          return a.stopName.compareTo(b.stopName);
        });
        _isLoadingStops = false;
      });
    } catch (e) {
      debugPrint('Error fetching stops: $e');
      if (!mounted) return;
      setState(() {
        _allStops = [];
        _isLoadingStops = false;
      });
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    } 

    setState(() => _isLoadingStops = true);
    
    try {
      Position position = await Geolocator.getCurrentPosition();
      
      if (_allStops.isEmpty) {
        await _fetchStops();
      }

      if (_allStops.isNotEmpty) {
        BusStop? nearestStop;
        double minDistance = double.infinity;

        for (var stop in _allStops) {
          double distance = _calculateDistance(
            position.latitude, 
            position.longitude, 
            stop.latitude, 
            stop.longitude
          );
          if (distance < minDistance) {
            minDistance = distance;
            nearestStop = stop;
          }
        }

        if (nearestStop != null) {
          setState(() {
            _sourceController.text = nearestStop!.stopName;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Found nearest stop: ${nearestStop.stopName}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoadingStops = false);
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('home_scaffold'),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'BUS TICKETING',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/userProfile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: const BoxDecoration(
                color: Color(0xFFB71C1C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Where are you\ngoing today?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Search Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (_isLoadingStops)
                            const Center(child: CircularProgressIndicator())
                          else ...[
                            LocationField(
                              key: const ValueKey('source_field'),
                              controller: _sourceController,
                              label: 'Source City/Stop',
                              icon: Icons.location_on_outlined,
                              iconColor: const Color(0xFF1A237E),
                              allStops: _allStops,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.my_location, size: 20),
                                onPressed: _getCurrentLocation,
                                tooltip: 'Locate Me',
                              ),
                            ),
                            const SizedBox(height: 20),
                            LocationField(
                              key: const ValueKey('destination_field'),
                              controller: _destinationController,
                              label: 'Destination City/Stop',
                              icon: Icons.navigation_outlined,
                              iconColor: const Color(0xFFB71C1C),
                              allStops: _allStops,
                            ),
                          ],
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                final source = _sourceController.text;
                                final destination = _destinationController.text;
                                if (source.isNotEmpty && destination.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BusListScreen(
                                        origin: source,
                                        destination: destination,
                                        date: '',
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please select source and destination')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Search Buses',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMenuIcon(
                        Icons.history_rounded,
                        'History',
                        const Color(0xFFE8EAF6),
                        const Color(0xFF1A237E),
                        () => Navigator.pushNamed(context, '/bookingHistory'),
                      ),
                      _buildMenuIcon(
                        Icons.map_outlined,
                        'Live Map',
                        const Color(0xFFFFF9C4),
                        const Color(0xFFFBC02D),
                        () => Navigator.pushNamed(context, '/map'),
                      ),
                      _buildMenuIcon(
                        Icons.account_balance_wallet_outlined,
                        'Payments',
                        const Color(0xFFE1F5FE),
                        const Color(0xFF0288D1),
                        () => Navigator.pushNamed(context, '/payment'),
                      ),
                      _buildMenuIcon(
                        Icons.confirmation_number_outlined,
                        'Offers',
                        const Color(0xFFFCE4EC),
                        const Color(0xFFC2185B),
                        () => {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon, String label, Color bgColor, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class LocationField extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;
  final List<BusStop> allStops;
  final Widget? suffixIcon;

  const LocationField({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.controller,
    required this.allStops,
    this.suffixIcon,
  });

  @override
  State<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      key: ValueKey('autocomplete_${widget.label}'),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return widget.allStops
            .where((stop) => stop.stopName.toLowerCase().contains(textEditingValue.text.toLowerCase()))
            .map((stop) => stop.stopName)
            .toSet()
            .toList();
      },
      onSelected: (String selection) {
        widget.controller.text = selection;
      },
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        // Initial sync
        if (widget.controller.text.isNotEmpty && fieldController.text.isEmpty) {
          fieldController.text = widget.controller.text;
        }

        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          onChanged: (value) {
            widget.controller.text = value;
          },
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(widget.icon, color: widget.iconColor),
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: widget.iconColor.withOpacity(0.5), width: 2),
            ),
          ),
        );
      },
    );
  }
}