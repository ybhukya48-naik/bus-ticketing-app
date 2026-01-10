import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bus_ticketing_app/bus_list_screen.dart';
import 'package:bus_ticketing_app/models/bus_stop.dart';
import 'package:bus_ticketing_app/services/stop_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  DateTime? _selectedDate;
  List<BusStop> _allStops = [];
  bool _isLoadingStops = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    _fetchStops();
  }

  Future<void> _fetchStops() async {
    try {
      final stops = await StopService().fetchStops();
      if (!mounted) return;
      setState(() {
        _allStops = stops..sort((a, b) => a.stopName.compareTo(b.stopName));
        _isLoadingStops = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingStops = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _searchBuses() {
    if (_sourceController.text.isEmpty || _destinationController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusListScreen(
          origin: _sourceController.text,
          destination: _destinationController.text,
          date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'BUS TICKETING',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/userProfile'),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Header with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x401A237E),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello Traveller,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Where are you\ngoing today?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Form Card (Overlapping)
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _isLoadingStops
                            ? const Center(child: CircularProgressIndicator())
                            : _buildLocationField(
                                controller: _sourceController,
                                label: 'Source City',
                                icon: Icons.location_on_outlined,
                                iconColor: const Color(0xFF1A237E),
                              ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Icon(Icons.swap_vert, color: Colors.grey),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                        ),
                        _isLoadingStops
                            ? const SizedBox.shrink()
                            : _buildLocationField(
                                controller: _destinationController,
                                label: 'Destination City',
                                icon: Icons.my_location_outlined,
                                iconColor: const Color(0xFFFFD700),
                              ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date of Journey',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                    Text(
                                      _selectedDate == null ? 'Select Date' : DateFormat('dd MMM, yyyy').format(_selectedDate!),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _searchBuses,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A237E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor: const Color(0xFF1A237E).withOpacity(0.4),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_rounded),
                                SizedBox(width: 8),
                                Text(
                                  'SEARCH BUSES',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
        return _allStops
            .where((stop) => stop.stopName.toLowerCase().contains(textEditingValue.text.toLowerCase()))
            .map((stop) => stop.stopName);
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        if (controller.text.isNotEmpty && fieldController.text.isEmpty) {
          fieldController.text = controller.text;
        }
        fieldController.addListener(() {
          controller.text = fieldController.text;
        });
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(icon, color: iconColor),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: iconColor.withOpacity(0.5), width: 2),
            ),
          ),
        );
      },
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