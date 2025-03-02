import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      String token = jsonResponse['token'];

      // Token'ı local storage'a kaydet
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return true;
    } else {
      return false; // false değişkeni eklendi
    }
  }
}
