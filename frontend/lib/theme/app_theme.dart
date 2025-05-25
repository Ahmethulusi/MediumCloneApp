import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'artic_blue.dart';
import 'soft_nature.dart';
import 'coral_sand.dart';
import 'theme_light.dart';

enum AppThemeType { Light, ArcticBlue, CoralSand, SoftNature }

class AppThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = lightTheme;
  AppThemeType? _themeType = AppThemeType.Light;

  ThemeData get theme => _currentTheme;
  AppThemeType? get themeType => _themeType;

  /// Statik temalardan birini uygular
  Future<void> setTheme(AppThemeType type) async {
    switch (type) {
      case AppThemeType.ArcticBlue:
        _currentTheme = articBlueTheme;
        break;
      case AppThemeType.CoralSand:
        _currentTheme = coralSandTheme;
        break;
      case AppThemeType.SoftNature:
        _currentTheme = softNatureTheme;
        break;
      default:
        _currentTheme = lightTheme;
    }

    _themeType = type;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeIndex', type.index); // kaydet
  }

  void setThemeForAuth() {
    _currentTheme = ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      primaryColor: Colors.teal,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardTheme: const CardTheme(color: Colors.white, elevation: 3),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE0F2F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
      ),
    );
    _themeType = null;
    notifyListeners();
  }

  void applyThemeFromJson(Map<String, dynamic> data) {
    final components = data['components'];
    if (components == null) {
      print("❌ Geçersiz tema verisi");
      return;
    }

    _currentTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: HexColor(components['primaryColor']),
      scaffoldBackgroundColor: HexColor(components['scaffoldBackgroundColor']),
      appBarTheme: AppBarTheme(
        backgroundColor: HexColor(components['appBarColor']),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: HexColor(components['bottomNavSelected']),
        unselectedItemColor: HexColor(components['bottomNavUnselected']),
        backgroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: HexColor(components['cardColor']),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: HexColor(components['textColor'])),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HexColor(components['inputFill']),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor(components['buttonBackground']),
          foregroundColor: Colors.white,
        ),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: HexColor(components['tabSelected']),
        unselectedLabelColor: HexColor(components['tabUnselected']),
        indicatorColor: HexColor(components['tabSelected']),
      ),
    );

    _themeType = null; // özel tema olduğundan statik temalardan değil
    notifyListeners();
  }

  /// Veritabanından gelen özel tema (JSON) yüklendiğinde
  Future<void> loadUserTheme(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/themes/user/$userId/theme'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _currentTheme = ThemeData(
          brightness: Brightness.light,
          primaryColor: HexColor(data['components']['primaryColor']),
          scaffoldBackgroundColor: HexColor(
            data['components']['scaffoldBackgroundColor'],
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: HexColor(data['components']['appBarColor']),
            foregroundColor: Colors.white,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: HexColor(
              data['components']['bottomNavSelected'],
            ),
            unselectedItemColor: HexColor(
              data['components']['bottomNavUnselected'],
            ),
            backgroundColor: Colors.white,
          ),
          cardTheme: CardTheme(
            color: HexColor(data['components']['cardColor']),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(
              color: HexColor(data['components']['textColor']),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: HexColor(data['components']['inputFill']),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromARGB(255, 44, 154, 125),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        );

        notifyListeners();
      } else {
        print("❌ Tema alınamadı: ${response.body}");
      }
    } catch (e) {
      print("🚨 Tema alma hatası: $e");
    }
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // alpha channel
    }
    return int.parse(hexColor, radix: 16);
  }
}
