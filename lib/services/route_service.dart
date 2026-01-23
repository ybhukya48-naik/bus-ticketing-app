import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bus_ticketing_app/models/route_model.dart';

import 'package:bus_ticketing_app/services/api_config.dart';

class RouteService {
  static final String baseUrl = '${ApiConfig.baseUrl}/routes';

  Future<List<BusRoute>> fetchRoutes() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((route) => BusRoute.fromJson(route)).toList();
    } else {
      throw Exception('Failed to load routes');
    }
  }
}
