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
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      await prefs.setString("userId", data["userId"]);
      return true;
    }
    return false;
  }
}
