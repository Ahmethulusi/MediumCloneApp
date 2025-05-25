import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'homepage.dart';
import 'saved_articles.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _getScreens() {
    return [
      HomePage(),
      NotificationsScreen(userId: widget.userId),
      SavedArticlesScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? sessionStartTime = prefs.getInt('sessionStartTime');

    if (sessionStartTime != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      int sessionDuration = 3600000; // 1 saat

      if (currentTime - sessionStartTime >= sessionDuration) {
        await prefs.remove('userId');
        await prefs.remove('sessionStartTime');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSession();
    Future.microtask(() => _checkAdminMessages(widget.userId));
  }

  Future<void> _checkAdminMessages(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/admin/messages/unread/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = data['messages'];

        if (messages != null && messages.isNotEmpty) {
          final firstMsg = messages[0];
          await _showAdminMessageModal(firstMsg['content']);
          await http.patch(
            Uri.parse(
              'http://localhost:8000/api/admin/messages/mark-read/${firstMsg['_id']}',
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Mesaj kontrol hatası: $e');
    }
  }

  Future<void> _showAdminMessageModal(String message) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("📬 Admin Mesajı"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Tamam"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreens()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.account_box), label: ""),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
