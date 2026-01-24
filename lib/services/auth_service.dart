import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'package:bus_ticketing_app/services/api_config.dart';

class AuthService {
  final String baseUrl = '${ApiConfig.baseUrl}/auth'; // Updated for central config

  Future<void> warmup() async {
    try {
      // Just a simple GET call to the root to wake up the server
      // Increased timeout for warmup to give it a better chance to complete
      await http.get(Uri.parse(ApiConfig.baseUrl.replaceAll('/api', '/'))).timeout(const Duration(seconds: 30));
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
      ).timeout(const Duration(seconds: 30));

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
    const int maxRetries = 2;

    while (retryCount <= maxRetries) {
      try {
        debugPrint('Attempting registration at: $baseUrl/register (Attempt ${retryCount + 1})');
        final response = await http.post(
          Uri.parse('$baseUrl/register'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({'username': name, 'email': email, 'password': password}),
        ).timeout(const Duration(seconds: 180));

        debugPrint('Registration response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          return null; // Success
        } else if (response.statusCode == 503 || response.statusCode == 504 || response.statusCode == 502) {
          // Server is likely still waking up or busy
          if (retryCount < maxRetries) {
            retryCount++;
            debugPrint('Server busy (Status ${response.statusCode}), retrying in 5 seconds...');
            await Future.delayed(const Duration(seconds: 5));
            continue;
          }
        }
        return response.body;
      } catch (e) {
        debugPrint('Registration error: $e');
        if (e.toString().contains('TimeoutException') || e.toString().contains('Connection failed')) {
          if (retryCount < maxRetries) {
            retryCount++;
            debugPrint('Connection timeout/failure, retrying in 5 seconds...');
            await Future.delayed(const Duration(seconds: 5));
            continue;
          }
          return 'Server is taking too long to respond. It might be waking up. Please wait another minute and try again.';
        }
        return 'Connection error: $e';
      }
    }
    return 'Failed after multiple attempts. Please try again in a few minutes.';
  }
}
