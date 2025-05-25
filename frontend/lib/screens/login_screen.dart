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
import 'interest_selection_screen.dart';
import '../theme/app_theme.dart';

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
      if (userData['isBanned'] == true) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text("Hesabınız Banlandı"),
                content: Text("Bu hesap yöneticiler tarafından banlanmıştır."),
                actions: [
                  TextButton(
                    child: Text("Tamam"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
        );
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = userData['userId'];
      String role = userData['role'];
      String token = userData['token'];

      await prefs.setString('userId', userId);
      await prefs.setString('role', role);
      await prefs.setString("token", token);
      await prefs.setInt(
        'sessionStartTime',
        DateTime.now().millisecondsSinceEpoch,
      );

      if (!mounted) return;

      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchUserData(userId);

      if (!mounted) return;

      final themeProvider = Provider.of<AppThemeProvider>(
        context,
        listen: false,
      );
      await themeProvider.loadUserTheme(userId); // 🎯 tema yükleniyor

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHomeScreen(userId: userId)),
        );
      } else {
        if (userData['showInterestScreen'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => InterestSelectionScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(userId: userId)),
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(" Başarıyla Giriş Yapıldı!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(" Giriş Başarısız!"),
          backgroundColor: Colors.red,
        ),
      );
      print("❌ Giriş başarısız!");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Giriş Yap")),
      body: Padding(
        padding: EdgeInsets.all(50.0),
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },

              child: Text("Kayıt ol"),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text("Şifremi \nUnuttum"),
            ),
          ],
        ),
      ),
    );
  }
}
