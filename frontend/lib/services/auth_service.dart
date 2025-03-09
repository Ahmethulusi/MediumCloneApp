import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class AuthService {
  final String baseUrl = "http://localhost:8000/api/auth";

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      await prefs.setString("userId", data["userId"]);
      await prefs.setString("role", data["role"]);
      return true;
    }
    return false;
  }

  Future<bool> register(
    String name,
    String email,
    String password, {
    String role = "author",
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", data["userId"]);
      await prefs.setString("role", data["role"]);
      return true;
    }
    return false;
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      print("📩 Forgot Password API Yanıtı: ${response.statusCode}");
      print("📝 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("❌ Forgot Password API Hatası: $e");
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse("$baseUrl/reset-password/$token"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"password": newPassword}),
    );

    return response.statusCode == 200;
  }
}
