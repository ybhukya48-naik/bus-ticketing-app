import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:bus_ticketing_app/bus_list_screen.dart';
import 'package:bus_ticketing_app/services/stop_service.dart';
import 'package:bus_ticketing_app/models/bus_stop.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  DateTime? _selectedDate;
  int _passengers = 1;
  List<BusStop> _allStops = [];
  bool _isLoadingStops = true;

  @override
  void initState() {
    super.initState();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load bus stops: $e')),
      );
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _searchBuses() {
    final String origin = _originController.text;
    final String destination = _destinationController.text;
    final String? date = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null;

    if (origin.isEmpty || destination.isEmpty || date == null) {
      // Show an error or a snackbar if fields are not filled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all booking details.')),
      );
      return;
    }

    // Here you would typically send these details to your backend to search for buses.
    // For now, we'll just print them.
    Navigator.push(context, MaterialPageRoute(builder: (context) => BusListScreen(
      origin: origin,
      destination: destination,
      date: date,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _isLoadingStops
                ? const Center(child: CircularProgressIndicator())
                : Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _allStops
                          .where((stop) => stop.stopName
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()))
                          .map((stop) => stop.stopName);
                    },
                    onSelected: (String selection) {
                      _originController.text = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      // Sync the Autocomplete controller with our _originController
                      if (_originController.text.isNotEmpty && controller.text.isEmpty) {
                        controller.text = _originController.text;
                      }
                      controller.addListener(() {
                        _originController.text = controller.text;
                      });
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Origin',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16.0),
            _isLoadingStops
                ? const SizedBox.shrink()
                : Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _allStops
                          .where((stop) => stop.stopName
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()))
                          .map((stop) => stop.stopName);
                    },
                    onSelected: (String selection) {
                      _destinationController.text = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      // Sync the Autocomplete controller with our _destinationController
                      if (_destinationController.text.isNotEmpty && controller.text.isEmpty) {
                        controller.text = _destinationController.text;
                      }
                      controller.addListener(() {
                        _destinationController.text = controller.text;
                      });
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Destination',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: _selectedDate == null
                        ? 'Select Date'
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Text('Passengers:'),
                Expanded(
                  child: Slider(
                    value: _passengers.toDouble(),
                    min: 1,
                    max: 10, // Max passengers for a single booking
                    divisions: 9,
                    label: _passengers.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _passengers = value.round();
                      });
                    },
                  ),
                ),
                Text(_passengers.toString()),
              ],
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _searchBuses,
              child: const Text('Search Buses'),
            ),
          ],
        ),
      ),
    );
  }
}