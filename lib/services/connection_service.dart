import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bus_ticketing_app/services/api_config.dart';

class ConnectionService {
  static String get baseUrl => ApiConfig.baseUrl.replaceAll('/api', '');

  Future<Map<String, dynamic>> checkConnection() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'status': 'DOWN', 'message': 'Server returned ${response.statusCode}'};
    } catch (e) {
      return {'status': 'DOWN', 'message': 'Error: $e'};
    }
  }
}
