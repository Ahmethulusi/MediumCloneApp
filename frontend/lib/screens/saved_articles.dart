import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'article_detail_screen.dart';

class SavedArticlesScreen extends StatefulWidget {
  final String userId;

  const SavedArticlesScreen({required this.userId});

  @override
  _SavedArticlesScreenState createState() => _SavedArticlesScreenState();
}

class _SavedArticlesScreenState extends State<SavedArticlesScreen> {
  List<dynamic> savedArticles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSavedArticles();
  }

  Future<void> fetchSavedArticles() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:8000/api/users/${widget.userId}/saved-articles',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          savedArticles = data['savedArticles'] ?? [];
          isLoading = false;
        });
      } else {
        print("❌ Kaydedilen makaleler alınamadı: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("🚨 Hata oluştu: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kaydedilen Makaleler")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : savedArticles.isEmpty
              ? Center(child: Text("Hiç makale kaydedilmemiş."))
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: savedArticles.length,
                itemBuilder: (context, index) {
                  final article = savedArticles[index];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      title: Text(article['title'] ?? 'Başlık'),
                      subtitle: Text(
                        "Yazar: ${article['author']?['name'] ?? 'Anonim'}",
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ArticleDetailScreen(article: article),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
