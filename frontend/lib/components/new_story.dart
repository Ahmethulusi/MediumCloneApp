import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NewStoryScreen extends StatefulWidget {
  @override
  _NewStoryScreenState createState() => _NewStoryScreenState();
}

class _NewStoryScreenState extends State<NewStoryScreen> {
  final QuillEditorController _controller = QuillEditorController();
  final TextEditingController _titleController = TextEditingController();

  /// 🛠 Makale Gönderme Fonksiyonu
  Future<void> _submitStory({required String status}) async {
    String htmlContent = await _controller.getText();
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      print("🚨 Kullanıcı ID bulunamadı.");
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/articles/newArticle'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": _titleController.text.trim(),
        "content": htmlContent,
        "authorId": userId,
        "status": status, // "published" veya "draft"
      }),
    );

    if (response.statusCode == 201) {
      print("✅ Makale başarıyla $status olarak kaydedildi.");
      Navigator.pop(context, 'refresh');
    } else {
      print("❌ Makale kaydedilemedi: ${response.body}");
    }
  }

  Future<void> _publishStory() async {
    await _submitStory(status: "public");
  }

  Future<void> _saveAsDraft() async {
    await _submitStory(status: "draft");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yeni Makale Oluştur"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == "public") {
                _publishStory();
              } else if (value == "draft") {
                _saveAsDraft();
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(
                    value: "public",
                    child: ListTile(
                      leading: Icon(Icons.send, color: Colors.blue),
                      title: Text("Yayınla"),
                    ),
                  ),
                  PopupMenuItem(
                    value: "draft",
                    child: ListTile(
                      leading: Icon(Icons.save, color: Colors.green),
                      title: Text("Taslağa Kaydet"),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Makale Başlığı",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ToolBar(
            controller: _controller,
            toolBarColor: Colors.grey[200]!,
            activeIconColor: Colors.blue,
            padding: EdgeInsets.all(8),
            iconSize: 20,
          ),
          Expanded(
            child: QuillHtmlEditor(
              controller: _controller,
              hintText: "Buraya yaz...",
              minHeight: 400,
              autoFocus: true,
              isEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
