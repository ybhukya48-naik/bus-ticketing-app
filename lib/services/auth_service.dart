import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bus_ticketing_app/services/api_config.dart';

class AuthService {
  final String baseUrl = '${ApiConfig.baseUrl}/auth'; // Updated for central config

  Future<bool> login(String username, String password) async {

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );



      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final String token = responseBody['token'];
        final String username = responseBody['username'];
        await _saveAuthData(token, username);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _removeAuthData();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> _saveAuthData(String token, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('username', username);
  }

  Future<void> _removeAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('username');
  }

  Future<String?> register(String name, String email, String password) async {

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': name, 'email': email, 'password': password}),
      );



      if (response.statusCode == 200) {
        return null; // Success
      } else {
        // Try to parse the error message from the response body
        return response.body;
      }
    } catch (e) {
      return 'Connection error: Could not reach the server.';
    }
  }
}
