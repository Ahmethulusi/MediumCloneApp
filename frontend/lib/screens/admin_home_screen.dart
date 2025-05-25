// screens/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'user_list.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_reports_and_analytic.dart';
import 'category_management_screen.dart';
import 'admin_report_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/app_theme.dart';
import 'admin_theme_list.dart';
import 'reports/statistics.dart';
// import '../providers/user_provider.dart';

class AdminHomeScreen extends StatelessWidget {
  final String userId;

  AdminHomeScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Paneli"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');
              final themeProvider = Provider.of<AppThemeProvider>(
                context,
                listen: false,
              );

              themeProvider.setThemeForAuth();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  171,
                  25,
                  25,
                ), // Butonun arka plan rengi
                foregroundColor: Colors.white, // Yazı (ön plan) rengi
              ),
              icon: Icon(Icons.people),
              label: Text("Kullanıcı Yönetimi"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UsersList()),
                );
              },
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  171,
                  25,
                  25,
                ), // Butonun arka plan rengi
                foregroundColor: Colors.white, // Yazı (ön plan) rengi
              ),
              icon: Icon(Icons.category),
              label: Text("Kategori Yönetimi"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CategoryManagementScreen()),
                );
              },
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  171,
                  25,
                  25,
                ), // Butonun arka plan rengi
                foregroundColor: Colors.white, // Yazı (ön plan) rengi
              ),
              icon: Icon(Icons.analytics),
              label: Text("Raporlar ve Analitik Sayfa"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminStatisticsScreen()),
                );
              },
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  171,
                  25,
                  25,
                ), // Butonun arka plan rengi
                foregroundColor: Colors.white, // Yazı (ön plan) rengi
              ),
              icon: Icon(Icons.report),
              label: Text("Şikayetler ve Rapor Yönetimi"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComplaintManagementScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  171,
                  25,
                  25,
                ), // Butonun arka plan rengi
                foregroundColor: Colors.white, // Yazı (ön plan) rengi
              ),
              icon: Icon(Icons.palette),
              label: Text("Görünüm ve Tema Yönetimi"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ThemeListScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
