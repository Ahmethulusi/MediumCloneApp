import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../providers/user_provider.dart';
import 'home_screen.dart';

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

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Kullanıcı ID kontrolü
        String userId =
            data.containsKey('userId') && data['userId'] != null
                ? data['userId'].toString()
                : '';

        if (userId.isEmpty) {
          print("🚨 HATA: API userId göndermedi!");
          setState(() {
            _isLoading = false;
          });
          return;
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);

        print("✅ Kullanıcı giriş yaptı, ID: $userId");

        await Provider.of<UserProvider>(
          context,
          listen: false,
        ).fetchUserData(userId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userId: userId)),
        );
      } else {
        print("❌ Giriş başarısız: ${response.body}");
      }
    } catch (error) {
      print("🚨 Hata oluştu: $error");
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
          ],
        ),
      ),
    );
  }
}
