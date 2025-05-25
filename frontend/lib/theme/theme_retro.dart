import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData retroTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.lightPrimary,
  scaffoldBackgroundColor: AppColors.lightBackground,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.lightPrimary,
    foregroundColor: Colors.white,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.lightPrimary,
    unselectedItemColor: Colors.grey,
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
