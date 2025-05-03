// screens/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'user_list.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_reports_and_analytic.dart';
import 'category_management_screen.dart';

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
              icon: Icon(Icons.analytics),
              label: Text("Raporlar ve Analitik Sayfa"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminReportsScreen()),
                );
              },
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.report),
              label: Text("Şikayetler ve Rapor Yönetimi"),
              onPressed: () {},
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.palette),
              label: Text("Görünüm ve Tema Yönetimi"),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
