import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_panel.dart';
import 'login_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userRole;
  int _selectedIndex = 0;

  List<Widget> _getScreens() {
    return [
      Center(child: Text("Ana Sayfa İçeriği")),
      LibraryScreen(userId: widget.userId),
      Text("Kaydedilenler"),
      ProfileScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    if (userRole == "admin" && index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminPanelScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? sessionStartTime = prefs.getInt('sessionStartTime');

    if (sessionStartTime != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      int sessionDuration = 3600000; // 1 saat

      if (currentTime - sessionStartTime >= sessionDuration) {
        // Oturum süresi doldu, çıkış yap
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
    _checkSession(); // Sayfa yüklendiğinde oturumu kontrol et
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString("role");
    });
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
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.account_box), label: ""),

          if (userRole == "admin")
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: "",
            ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
