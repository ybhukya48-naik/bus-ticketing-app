import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bus_ticketing_app/models/bus_stop.dart';

import 'package:bus_ticketing_app/services/api_config.dart';

class StopService {
  static final String baseUrl = '${ApiConfig.baseUrl}/stops';

  Future<List<BusStop>> fetchStops() async {
    print('Fetching all stops from: $baseUrl');
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        print('Successfully fetched ${jsonResponse.length} stops');
        return jsonResponse.map((stop) => BusStop.fromJson(stop)).toList();
      } else {
        print('Failed to load stops. Status: ${response.statusCode}');
        throw Exception('Failed to load stops');
      }
    } catch (e) {
      print('Error in fetchStops: $e');
      rethrow;
    }
  }

  Future<List<BusStop>> fetchStopsByIds(String ids) async {
    if (ids.isEmpty) return [];
    
    final response = await http.get(Uri.parse('$baseUrl/batch?ids=$ids'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((stop) => BusStop.fromJson(stop)).toList();
    } else {
      throw Exception('Failed to load stops by IDs');
    }
  }

  Future<List<BusStop>> searchStops(String query) async {
    if (query.trim().length < 2) return [];
    
    final response = await http.get(Uri.parse('$baseUrl/search?query=$query'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((stop) => BusStop.fromJson(stop)).toList();
    } else {
      throw Exception('Failed to search stops');
    }
  }
}
