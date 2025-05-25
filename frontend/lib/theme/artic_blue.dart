import 'package:flutter/material.dart';

final ThemeData articBlueTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF4CBBF0),
  scaffoldBackgroundColor: Color(0xFFFFFFFF),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF4CBBF0),
    foregroundColor: Colors.white,
    centerTitle: true,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF4CBBF0),
    unselectedItemColor: Color(0xFFA6A6A6),
  ),
  cardTheme: CardTheme(
    color: const Color.fromARGB(255, 177, 212, 229),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 47, 121, 155),
      foregroundColor: Colors.white,
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: Colors.lightBlue),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.lightBlueAccent,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
    bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
    bodyMedium: TextStyle(color: Color(0xFF1A1A1A)),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Colors.white,
    dividerColor: Colors.white,
    indicatorColor: Colors.blue,
    unselectedLabelColor: const Color.fromARGB(255, 205, 227, 238),
  ),
);
