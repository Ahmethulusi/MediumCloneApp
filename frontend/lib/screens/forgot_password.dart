import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  Future<void> _sendResetEmail() async {
    setState(() {
      _isLoading = true;
    });

    bool success = await AuthService().forgotPassword(
      _emailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _message =
          success
              ? "Şifre sıfırlama bağlantısı gönderildi!"
              : "E-posta bulunamadı.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Şifremi Unuttum")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "E-posta"),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _sendResetEmail,
                  child: Text("Şifreyi Sıfırla"),
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
