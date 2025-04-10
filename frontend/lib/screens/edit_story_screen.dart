import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class EditStoryScreen extends StatelessWidget {
  final Map<String, dynamic> articleData;

  EditStoryScreen({required this.articleData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Makale Düzenle")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Html(data: articleData['content'] ?? '<p>İçerik bulunamadı</p>'),
      ),
    );
  }
}
