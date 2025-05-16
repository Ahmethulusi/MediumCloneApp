import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  String _name = "";
  String _email = "";
  String _profileImage = "";
  String _jobTitle = "";
  String _bio = "";

  List<Map<String, dynamic>> _publicStories = [];
  List<Map<String, dynamic>> _draftStories = [];

  List<Map<String, dynamic>> get publicStories => _publicStories;
  List<Map<String, dynamic>> get draftStories => _draftStories;

  List<Map<String, dynamic>> _userStories = [];
  List<Map<String, dynamic>> get userStories => _userStories;
  String get name => _name;
  String get email => _email;
  String get profileImage => _profileImage;
  String get jobTitle => _jobTitle;
  String get bio => _bio;
  // List get publicStories => publicStories;
  // List get draftStories => draftStories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData(String userId) async {
    print("📩 Kullanıcı verileri alınıyor..."); // Debugging
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/users/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _name = data['name'];
        _email = data['email'];
        _profileImage = data['profileImage'] ?? "";
        _jobTitle = data['jobTitle'] ?? "";
        _bio = data['bio'] ?? "";

        print("✅ Kullanıcı verisi güncellendi: $_profileImage"); // Debugging

        notifyListeners();
      } else {
        print("❌ Kullanıcı verisi alınamadı: ${response.body}");
      }
    } catch (e) {
      print("🚨 Hata oluştu: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserStories(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/articles/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> stories = data['stories'] ?? [];

        _publicStories = [];
        _draftStories = [];

        for (var story in stories) {
          final Map<String, dynamic> storyMap = Map<String, dynamic>.from(
            story,
          );
          final status = storyMap['status'];

          if (status == 'public') {
            _publicStories.add(storyMap);
          } else {
            _draftStories.add(storyMap);
          }
        }

        notifyListeners();
      } else {
        print("❌ Makale verisi alınamadı: ${response.body}");
      }
    } catch (e) {
      print("🚨 Hata oluştu: $e");
    }
  }

  void updateProfileImage(String newImageUrl) {
    _profileImage = newImageUrl;
    notifyListeners();
  }
}
