import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bus_ticketing_app/models/bus.dart';
import 'package:bus_ticketing_app/models/bus_stop.dart';
import 'package:bus_ticketing_app/services/api_config.dart';

class MapScreen extends StatefulWidget {
  final Bus? bus;

  const MapScreen({super.key, this.bus});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<BusStop> _stops = [];
  bool _isLoading = false;

  final LatLng _center = const LatLng(17.3850, 78.4867); // Hyderabad coordinates

  @override
  void initState() {
    super.initState();
    if (widget.bus != null && widget.bus!.routeStopsOrder != null) {
      _fetchStops(widget.bus!.routeStopsOrder!);
    }
  }

  Future<void> _fetchStops(String stopsOrder) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/stops/batch?ids=$stopsOrder'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<BusStop> stops = data.map((json) => BusStop.fromJson(json)).toList();

        // Sort stops based on the original order string
        List<String> orderList = stopsOrder.split(',');
        stops.sort((a, b) {
          int indexA = orderList.indexOf(a.id.toString());
          int indexB = orderList.indexOf(b.id.toString());
          return indexA.compareTo(indexB);
        });

        setState(() {
          _stops = stops;
          _createMapData();
        });
      }
    } catch (e) {
      print('Error fetching stops: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createMapData() {
    if (_stops.isEmpty) return;

    Set<Marker> markers = {};
    List<LatLng> polylinePoints = [];

    for (int i = 0; i < _stops.length; i++) {
      final stop = _stops[i];
      final position = LatLng(stop.latitude, stop.longitude);
      polylinePoints.add(position);

      markers.add(
        Marker(
          markerId: MarkerId(stop.id.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: stop.stopName,
            snippet: 'Stop ${i + 1}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0 ? BitmapDescriptor.hueGreen : 
            (i == _stops.length - 1 ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue)
          ),
        ),
      );
    }

    Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: polylinePoints,
        color: Colors.blue,
        width: 5,
      ),
    };

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });

    // Move camera to start
    if (polylinePoints.isNotEmpty) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(polylinePoints.first, 13.0));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_stops.isNotEmpty) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(_stops.first.latitude, _stops.first.longitude), 13.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bus != null ? 'Route for ${widget.bus!.busNumber}' : 'Bus Route Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            markers: _markers,
            polylines: _polylines,
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}