import 'package:firstflutterproject/screens/profile_detail_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart'; // Kayıt ekranına yönlendirmek için
import './profile_screen.dart'
    as profile; // Başarılı giriş sonrası yönlendirme için
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback updateLoginStatus;

  LoginScreen({required this.updateLoginStatus});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    bool success = await AuthService().login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true); // Kullanıcı giriş yaptı
      // HomeScreen'e yönlendirmek yerine, sadece hesap sekmesini güncelle
      widget.updateLoginStatus();
    } else {
      setState(() {
        _errorMessage = "Giriş başarısız! Lütfen bilgilerinizi kontrol edin.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Giriş Yap")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 70.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text("Giriş Yap", style: TextStyle(fontSize: 30))),

            SizedBox(height: 30),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "E-posta"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Şifre"),
            ),
            SizedBox(height: 10),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 10),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 50.0,
                  ), // Sağdan ve soldan boşluk ekler
                  child: ElevatedButton(
                    onPressed: _login,
                    child: Text('Giriş Yap'),
                  ),
                ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              RegisterScreen(onLogin: widget.updateLoginStatus),
                    ),
                  );
                },
                child: Text("Hesabın yok mu? Kayıt ol"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
