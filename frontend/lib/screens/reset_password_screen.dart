import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  ResetPasswordScreen({required this.token});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    bool success = await AuthService().resetPassword(
      widget.token,
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _message =
          success
              ? "Şifreniz başarıyla güncellendi!"
              : "Şifre sıfırlama başarısız.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yeni Şifre Belirle")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Yeni Şifre"),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _resetPassword,
                  child: Text("Şifreyi Güncelle"),
                ),
            if (_message != null)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(_message!, style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
