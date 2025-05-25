import 'package:flutter/material.dart';

final ThemeData softNatureTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF8ED1B2),
  scaffoldBackgroundColor: Color(0xFFFAFFF9),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF8ED1B2),
    foregroundColor: Colors.black,
    centerTitle: true,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF8ED1B2),
    unselectedItemColor: Color(0xFFBDBDBD),
  ),
  cardTheme: CardTheme(
    color: Color(0xFFE0F2E9),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF70C1A7),
      foregroundColor: Colors.black,
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: Color(0xFF4CAF93)),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Color(0xFF5ACB99),
      backgroundColor: Color(0xFFF2FBF8),
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
    bodyLarge: TextStyle(color: Color(0xFF2E2E2E)),
    bodyMedium: TextStyle(color: Color(0xFF2E2E2E)),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Colors.white,
    dividerColor: Colors.white,
    indicatorColor: Color(0xFF8ED1B2),
    unselectedLabelColor: Color(0xFFB3DBC9),
  ),
);
