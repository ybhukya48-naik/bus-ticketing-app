import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bus_ticketing_app/models/booking.dart';

import 'package:bus_ticketing_app/services/api_config.dart';

class BookingService {
  final String baseUrl = '${ApiConfig.baseUrl}/bookings';

  Future<List<Booking>> fetchBookingHistory(String token) async {
    print('!!! Fetching Booking History from: $baseUrl !!!');
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('!!! Booking History Response Status: ${response.statusCode} !!!');
      print('!!! Booking History Response Body: ${response.body} !!!');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((booking) => Booking.fromJson(booking)).toList();
      } else {
        print('!!! Failed to load booking history. Status: ${response.statusCode} !!!');
        throw Exception('Failed to load booking history');
      }
    } catch (e) {
      print('!!! Error fetching booking history: $e !!!');
      rethrow;
    }
  }
}