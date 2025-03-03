import 'package:flutter/material.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

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
      Center(child: Text("Ana Sayfa İçeriği")),
      LibraryScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Ana Sayfa"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Kütüphane"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
