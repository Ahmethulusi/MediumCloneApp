import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'forgot_password.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final userData = await AuthService().login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (userData != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = userData['userId']; // veya '_id'
      String role = userData['role']; // 👈 Rolü doğrudan al

      // ✅ SharedPreferences'a kaydet
      await prefs.setString('userId', userId);
      await prefs.setString('role', role);
      await prefs.setInt(
        'sessionStartTime',
        DateTime.now().millisecondsSinceEpoch,
      );

      // ✅ Provider ile kullanıcı verilerini çek
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchUserData(userId);

      // ✅ Rol kontrolü ve yönlendirme
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminHomeScreen(userId: userId),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userId: userId)),
        );
      }
    } else {
      print("❌ Giriş başarısız!");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Giriş Yap")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "E-posta"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Şifre"),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: Text("Giriş Yap")),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text("Hesabın yok mu? Kayıt ol"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text("Şifremi Unuttum"),
            ),
          ],
        ),
      ),
    );
  }
}
