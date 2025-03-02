import 'dart:convert';
import 'package:http/http.dart' as http;
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
  String userId = "";
  String name = "";
  String email = "";
  String profileImage = "";

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Tüm kullanıcı bilgilerini temizle
    setState(() {
      _isLoggedIn = false;
      _selectedIndex = 2;
    });
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? storedUserId = prefs.getString('userId');

    if (token != null && storedUserId != null) {
      setState(() {
        _isLoggedIn = true;
        userId = storedUserId;
      });
      await _fetchUserData(
        token,
        storedUserId,
      ); // Kullanıcı bilgilerini güncelle
      setState(() {}); // Arayüzü yenile
    } else {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  Future<void> _fetchUserData(String token, String userId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/users/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('name', data['name']);
      await prefs.setString('email', data['email']);
      await prefs.setString('profileImage', data['profileImage'] ?? "");

      setState(() {
        name = data['name'];
        email = data['email'];
        profileImage =
            data['profileImage'] ?? "https://via.placeholder.com/150";
      });
    } else {
      _logout(); // Hata durumunda çıkış yap
    }
  }

  List<Widget> _getScreens() {
    return [
      ArticleListScreen(),
      ContactsScreen(),
      _isLoggedIn
          ? ProfileScreen(
            updateLoginStatus: _logout,
            name: name,
            email: email,
            profileImage: profileImage,
          )
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
        selectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Ana Sayfa",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Kütüphanen"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hesap"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
