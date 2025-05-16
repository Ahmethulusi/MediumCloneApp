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
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _message = "⚠️ Lütfen e-posta adresinizi girin!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      bool success = await AuthService().forgotPassword(
        _emailController.text.trim(),
      );

      // Eğer widget kapanmışsa state değiştirme
      if (!mounted) return;

      print("📩 Şifre sıfırlama isteği gönderildi mi? $success");

      setState(() {
        _isLoading = false;
        _message =
            success
                ? "✅ Şifre sıfırlama bağlantısı e-posta adresinize gönderildi!"
                : "❌ Bu e-posta adresine ait bir hesap bulunamadı.";
      });
    } catch (e) {
      print("❌ Bir hata oluştu: $e");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _message = "❌ Bir hata oluştu, tekrar deneyin.";
      });
    }
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
            SizedBox(height: 10),
            if (_message != null)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains("✅") ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
