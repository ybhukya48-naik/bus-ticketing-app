import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bus_ticketing_app/models/bus_stop.dart';

import 'package:bus_ticketing_app/services/api_config.dart';

class StopService {
  static const String baseUrl = '${ApiConfig.baseUrl}/stops';

  Future<List<BusStop>> fetchStops() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((stop) => BusStop.fromJson(stop)).toList();
    } else {
      throw Exception('Failed to load stops');
    }
  }
}
