import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bus_ticketing_app/models/user.dart'; // Assuming you have a User model

import 'package:bus_ticketing_app/services/api_config.dart';

class UserService {
  final String baseUrl = '${ApiConfig.baseUrl}/users';

  Future<User> fetchUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<User> updateUserProfile(String token, User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user profile');
    }
  }
}