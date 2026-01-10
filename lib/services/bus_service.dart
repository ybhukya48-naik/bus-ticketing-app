import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bus_ticketing_app/models/bus.dart';

import 'package:bus_ticketing_app/services/api_config.dart';

class BusService {
  static const String baseUrl = '${ApiConfig.baseUrl}/buses';

  Future<List<Bus>> fetchBuses({String? city, String? origin, String? destination}) async {
    var queryParams = <String, String>{};
    if (city != null) queryParams['city'] = city;
    if (origin != null) queryParams['origin'] = origin;
    if (destination != null) queryParams['destination'] = destination;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((bus) => Bus.fromJson(bus)).toList();
    } else {
      throw Exception('Failed to load buses');
    }
  }
}
