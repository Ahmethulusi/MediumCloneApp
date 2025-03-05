import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  String name = "";
  String email = "";
  String profileImage = "https://via.placeholder.com/150";
  bool isLoading = true;

  Future<void> fetchUserData(String userId) async {
    isLoading = true;
    notifyListeners(); // UI'yi güncelle

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/users/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        name = data['name'] ?? "Bilinmeyen Kullanıcı";
        email = data['email'] ?? "Bilinmeyen Email";
        profileImage =
            data['profileImage'] != null &&
                    data['profileImage'].toString().isNotEmpty
                ? data['profileImage'].toString()
                : "https://via.placeholder.com/150";

        print("Kullanıcı verisi güncellendi: $name, $email, $profileImage");
      }
    } catch (error) {
      print("Kullanıcı verisi alınamadı: $error");
    }

    isLoading = false;
    notifyListeners(); // Güncellemeleri bildir
  }
}
