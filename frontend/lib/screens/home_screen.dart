import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/article_list.dart';
import './profile_list.dart';
import './login_screen.dart';
import './profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    setState(() {
      _isLoggedIn = token != null;
    });
  }

  List<Widget> _getScreens() {
    return [
      ArticleListScreen(),
      ContactsScreen(),
      _isLoggedIn
          ? ProfileScreen(updateLoginStatus: _checkLoginStatus)
          : LoginScreen(updateLoginStatus: _checkLoginStatus),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreens()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Makaleler",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Kişiler"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hesap"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
