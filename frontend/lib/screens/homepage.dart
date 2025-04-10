import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'article_detail_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/articles/explore/random'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          articles = data['articles'] ?? [];
          isLoading = false;
        });
      } else {
        print("❌ Makaleler alınamadı: ${response.body}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("🚨 Hata oluştu: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatContent(String content) {
    final plainText = content.replaceAll(RegExp(r'<[^>]*>'), '');
    return plainText.length > 120
        ? plainText.substring(0, 120) + '...'
        : plainText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Anasayfa")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  final contentText = formatContent(article['content'] ?? "");

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ArticleDetailScreen(article: article),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 📌 Başlık
                            Text(
                              article['title'] ?? 'Başlık yok',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 6),

                            /// 🧑‍💻 Yazar adı
                            Text(
                              "Yazar: ${article['author']?['name'] ?? 'Anonim'}",
                              style: TextStyle(color: Colors.grey[700]),
                            ),

                            SizedBox(height: 10),

                            /// 📄 İçerik özeti
                            Text(contentText, style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
