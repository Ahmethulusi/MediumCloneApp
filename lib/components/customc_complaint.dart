import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomComplaintScreen extends StatefulWidget {
  final String articleId;

  CustomComplaintScreen({required this.articleId});

  @override
  _CustomComplaintScreenState createState() => _CustomComplaintScreenState();
}

class _CustomComplaintScreenState extends State<CustomComplaintScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSending = false;
  Future<void> _submitComplaint() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final response = await http.post(
        Uri.parse(
          'http://localhost:8000/api/reports/',
        ), // localhost yerine 10.0.2.2 (emülatör için)
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "articleId": widget.articleId,
          "reason": _titleController.text.trim(),
          "description": _descController.text.trim(),
        }),
      );

      print("⚠️ Backend cevabı: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Şikayet gönderildi ✅")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gönderilemedi ❌")));
      }
    } catch (e) {
      print("🚨 Hata oluştu: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Bir hata oluştu ❌")));
    }

    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Özel Şikayet")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Başlık"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Açıklama",
                alignLabelWithHint: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSending ? null : _submitComplaint,
              child: _isSending ? CircularProgressIndicator() : Text("Gönder"),
            ),
          ],
        ),
      ),
    );
  }
}
