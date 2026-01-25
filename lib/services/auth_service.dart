import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'package:bus_ticketing_app/services/api_config.dart';

class AuthService {
  final String baseUrl = '${ApiConfig.baseUrl}/auth'; // Updated for central config

  Future<void> warmup() async {
    try {
      // Waking up the server via the health check endpoint
      final healthUrl = ApiConfig.baseUrl.replaceAll('/api', '/health');
      await http.get(Uri.parse(healthUrl)).timeout(const Duration(seconds: 60));
    } catch (e) {
      debugPrint('Warmup trigger sent: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 60));

      debugPrint('Login response status: ${response.statusCode}');

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
    int retryCount = 0;
    const int maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'username': name, 'email': email, 'password': password}),
        ).timeout(const Duration(seconds: 90));

        if (response.statusCode == 201 || response.statusCode == 200) {
          return null;
        } else {
          final errorData = json.decode(response.body);
          return errorData['message'] ?? 'Registration failed';
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          if (e.toString().contains('TimeoutException')) {
            return 'Server is still waking up. Please try again in a moment.';
          }
          return 'Connection error: ${e.toString()}';
        }
        // Wait a bit before retrying
        await Future.delayed(Duration(seconds: 5 * retryCount));
      }
    }
    return 'Registration failed after multiple attempts';
  }
}
