import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show QuillEditor, QuillSimpleToolbar, QuillController;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ArticleEditorScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const ArticleEditorScreen({Key? key, required this.arguments})
    : super(key: key);

  @override
  State<ArticleEditorScreen> createState() => _ArticleEditorScreenState();
}

class _ArticleEditorScreenState extends State<ArticleEditorScreen> {
  late QuillController _quillController;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
  }

  Future<void> _submitArticle(String status) async {
    setState(() => isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final delta = _quillController.document.toDelta();
    final htmlContent = jsonEncode(delta.toJson());

    if (userId == null) {
      print("🚫 Kullanıcı ID bulunamadı");
      setState(() => isSubmitting = false);
      return;
    }

    final title = widget.arguments['title'] ?? '';
    final coverImage = widget.arguments['coverImage'];
    final categories = widget.arguments['categories'] ?? [];

    if (coverImage is! File) {
      print("🚫 Geçersiz kapak fotoğrafı: $coverImage");
      setState(() => isSubmitting = false);
      return;
    }

    // 1. Kapak fotoğrafını yükle
    String? uploadedImagePath;
    try {
      final uploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8000/api/uploads'),
      );
      uploadRequest.files.add(
        await http.MultipartFile.fromPath('image', coverImage.path),
      );

      final uploadResponse = await uploadRequest.send();

      if (uploadResponse.statusCode == 200) {
        final resBody = await uploadResponse.stream.bytesToString();
        uploadedImagePath = json.decode(resBody)['imageUrl'];
      } else {
        print("❌ Kapak fotoğrafı yüklenemedi: ${uploadResponse.statusCode}");
        setState(() => isSubmitting = false);
        return;
      }
    } catch (e) {
      print("❌ Yükleme hatası: $e");
      setState(() => isSubmitting = false);
      return;
    }

    // 2. Makaleyi kaydet
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/articles/newArticle'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "title": title,
        "content": htmlContent,
        "authorId": userId,
        "status": status,
        "coverImage": uploadedImagePath,
        "categories": categories,
      }),
    );

    setState(() => isSubmitting = false);

    if (response.statusCode == 201) {
      print("✅ Makale kaydedildi");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Makale başarıyla kaydedildi!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      print("❌ Makale gönderilemedi: ${response.body}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Makale gönderilemedi."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.arguments['title'] ?? 'Yeni Makale';

    return Scaffold(
      appBar: AppBar(title: Text("İçerik Düzenle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            QuillSimpleToolbar(controller: _quillController),
            SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QuillEditor.basic(controller: _quillController),
              ),
            ),
            SizedBox(height: 12),
            if (isSubmitting)
              CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => _submitArticle("public"),
                    child: Text("Yayınla"),
                  ),
                  OutlinedButton(
                    onPressed: () => _submitArticle("draft"),
                    child: Text("Taslağa Kaydet"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
