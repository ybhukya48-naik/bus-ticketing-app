import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bus_ticketing_app/models/bus.dart';

import 'package:bus_ticketing_app/services/api_config.dart';

class BusService {
  static final String baseUrl = '${ApiConfig.baseUrl}/buses';

  Future<List<Bus>> fetchBuses({String? city, String? origin, String? destination}) async {
    var queryParams = <String, String>{};
    if (city != null) queryParams['city'] = city;
    if (origin != null) queryParams['origin'] = origin;
    if (destination != null) queryParams['destination'] = destination;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    print('Fetching buses from: $uri');
    
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        print('Successfully fetched ${jsonResponse.length} buses');
        return jsonResponse.map((bus) => Bus.fromJson(bus)).toList();
      } else {
        print('Failed to load buses. Status: ${response.statusCode}');
        throw Exception('Failed to load buses');
      }
    } catch (e) {
      print('Error in fetchBuses: $e');
      rethrow;
    }
  }

  Future<Bus> fetchBusById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Bus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load bus with ID: $id');
    }
  }
}
