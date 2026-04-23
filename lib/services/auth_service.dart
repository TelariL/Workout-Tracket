import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  static const baseUrl = "http://10.0.2.2:8000";

  /// REGISTER
  static Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "password": password,
      }),
    );

    return response.statusCode == 200;
  }


  /// LOGIN
  static Future<bool> login({
    required String username,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/token"),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "username": username,
        "password": password,
      },
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      final token = data["access_token"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      await prefs.setBool("isLoggedIn", true);

      return true;
    }

    return false;
  }


  /// LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }


  /// GET TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
}