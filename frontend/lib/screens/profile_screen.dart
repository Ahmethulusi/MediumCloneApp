import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback updateLoginStatus;

  ProfileScreen({required this.updateLoginStatus});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Çıkış ikonu
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('token'); // Token'ı sil
              await prefs.setBool('isLoggedIn', false); // Giriş durumunu kaldır
              // Kullanıcı çıkış yaptığında login ekranı yerine hesap sekmesini güncelle
              updateLoginStatus();
            },
          ),
        ],
      ),
      body: Center(child: Text("Profil Sayfası")),
    );
  }
}
