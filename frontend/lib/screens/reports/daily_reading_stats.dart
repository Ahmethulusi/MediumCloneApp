import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../article_detail_screen.dart'; // detay ekranına yönlendirme için

class TopReadArticlesScreen extends StatefulWidget {
  @override
  _TopReadArticlesScreenState createState() => _TopReadArticlesScreenState();
}

class _TopReadArticlesScreenState extends State<TopReadArticlesScreen> {
  List<dynamic> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTopArticles();
  }

  Future<void> fetchTopArticles() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/admin/stats/top-articles'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _articles = data['articles'] ?? [];
          _isLoading = false;
        });
      } else {
        print("❌ Veri alınamadı: ${response.body}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("🚨 Hata oluştu: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📈 En Çok Okunan Makaleler")),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _articles.isEmpty
              ? Center(child: Text("Hiç veri bulunamadı"))
              : ListView.separated(
                itemCount: _articles.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, index) {
                  final article = _articles[index];

                  return ListTile(
                    title: Text(article['title'] ?? 'Başlık Yok'),
                    subtitle: Text(
                      "Yazar: ${article['author']?['name'] ?? 'Bilinmiyor'} • Okunma: ${article['readCount'] ?? 0}",
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArticleDetailScreen(article: article),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
