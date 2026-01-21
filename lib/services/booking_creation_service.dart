import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bus_ticketing_app/models/bus.dart';
import 'package:intl/intl.dart';

import 'package:bus_ticketing_app/services/api_config.dart';

class BookingCreationService {
  final String baseUrl = '${ApiConfig.baseUrl}/bookings';

  Future<String> createBooking(Bus bus, int numberOfSeats, String username, String token) async {
    final String bookingDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final double totalPrice = bus.price * numberOfSeats;

    print('Attempting to create booking for $username on bus ${bus.busNumber}');

    print('Booking Request Body: ${json.encode({
      'busNumber': bus.busNumber,
      'route': bus.route,
      'bookingDate': bookingDate,
      'numberOfSeats': numberOfSeats,
      'totalPrice': totalPrice,
      'username': username,
    })}');

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'busNumber': bus.busNumber,
          'route': bus.route,
          'bookingDate': bookingDate,
          'numberOfSeats': numberOfSeats,
          'totalPrice': totalPrice,
          'username': username,
        }),
      );

      print('Booking Response Status: ${response.statusCode}');
      print('Booking Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('qrCodeData')) {
          return responseBody['qrCodeData'];
        } else {
          print('Warning: qrCodeData not found in response, using ID instead');
          return responseBody['id'].toString();
        }
      } else {
        print('Error creating booking: ${response.statusCode} - ${response.body}');
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('Network or parsing error during booking: $e');
      if (e is Exception) rethrow;
      throw Exception('Connection failed: $e');
    }
  }
}