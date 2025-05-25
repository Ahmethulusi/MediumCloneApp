import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../theme/app_theme.dart';
// import '../providers/user_provider.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  List<dynamic> themes = [];
  String? selectedThemeId;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndThemes();
  }

  Future<void> _loadUserIdAndThemes() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId != null) {
      await Future.wait([_fetchAvailableThemes(), _fetchUserSelectedTheme()]);
    }
  }

  Future<void> _fetchAvailableThemes() async {
    final res = await http.get(Uri.parse('http://localhost:8000/api/themes/'));

    if (res.statusCode == 200) {
      setState(() {
        themes = json.decode(res.body);
      });
    } else {
      print("❌ Tema listesi alınamadı: ${res.body}");
    }
  }

  Future<void> _fetchUserSelectedTheme() async {
    final res = await http.get(
      Uri.parse('http://localhost:8000/api/themes/user/$userId/theme'),
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        selectedThemeId = data['_id'];
      });
    } else {
      print("❌ Kullanıcının teması alınamadı: ${res.body}");
    }
  }

  Future<void> _setUserTheme(String themeId) async {
    final res = await http.patch(
      Uri.parse('http://localhost:8000/api/themes/user/$userId/theme'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"themeId": themeId}),
    );

    if (res.statusCode == 200) {
      setState(() {
        selectedThemeId = themeId;
      });
      final responseData = json.decode(res.body);
      final theme = responseData['theme']; // burada 'theme' olmalı

      final provider = Provider.of<AppThemeProvider>(context, listen: false);
      provider.applyThemeFromJson(theme);
    } else {
      print("❌ Tema güncellenemedi: ${res.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tema Ayarları"), centerTitle: true),
      body:
          themes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  final id = theme['_id'];
                  final name = theme['name'];

                  return RadioListTile<String>(
                    title: Text(name),
                    value: id,
                    groupValue: selectedThemeId,
                    onChanged: (val) {
                      if (val != null) _setUserTheme(val);
                    },
                  );
                },
              ),
    );
  }
}
