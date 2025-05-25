import 'package:flutter/material.dart';

final ThemeData coralSandTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFFFF6B6B),
  scaffoldBackgroundColor: Color(0xFFFFFDF9),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFFFF6B6B),
    foregroundColor: Colors.white,
    centerTitle: true,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFFFF6B6B),
    unselectedItemColor: Color(0xFF9E9E9E),
  ),
  cardTheme: CardTheme(
    color: Color(0xFFFFEBE5),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFFF8A65),
      foregroundColor: Colors.white,
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: Color(0xFFFF9B87)),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Color(0xFFFF6B6B),
      backgroundColor: Color(0xFFFFF0EB),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFF0F0F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF2C2C2C)),
    bodyMedium: TextStyle(color: Color(0xFF2C2C2C)),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Colors.white,
    dividerColor: Colors.white,
    indicatorColor: Color(0xFFFF6B6B),
    unselectedLabelColor: Color(0xFFFFCFC9),
  ),
);
