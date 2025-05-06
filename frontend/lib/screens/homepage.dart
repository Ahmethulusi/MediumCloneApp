import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'article_detail_screen.dart';
import '../components/customc_complaint.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String> categoryMap = {}; // ID → İsim

  List<dynamic> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    fetchArticles();
  }

  Future<void> _fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/categories'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      setState(() {
        categoryMap = {for (var cat in data) cat['_id']: cat['name']};
      });
    }
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
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("🚨 Hata oluştu: $e");
      setState(() => isLoading = false);
    }
  }

  void _showReportDrawer(BuildContext context, String articleId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Şikayet Nedeni Seçin",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 12),
                _buildReportOption(context, articleId, "Telif Hakkı İhlali"),
                _buildReportOption(context, articleId, "Spam"),
                _buildReportOption(context, articleId, "Uygunsuz İçerik"),
                ListTile(
                  leading: Icon(Icons.edit_note),
                  title: Text("Diğer"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => CustomComplaintScreen(articleId: articleId),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildReportOption(
    BuildContext context,
    String articleId,
    String reason,
  ) {
    return ListTile(
      title: Text(reason),
      leading: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.pop(context);
        _sendReport(articleId, reason);
      },
    );
  }

  Future<void> _sendReport(String articleId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/reports/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"articleId": articleId, "reason": reason}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Şikayet gönderildi ✅")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Şikayet gönderilemedi ❌")));
      }
    } catch (e) {
      print("🚨 Şikayet gönderme hatası: $e");
    }
  }

  String formatContent(String content) {
    final plainText = content.replaceAll(RegExp(r'<[^>]*>'), '');
    return plainText.length > 100
        ? plainText.substring(0, 100) + '...'
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

                  return Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 250, // 🔼 Kart yüksekliği artırıldı
                        child: Card(
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
                                      (_) =>
                                          ArticleDetailScreen(article: article),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🧑 Yazar adı
                                  Text(
                                    article['author']?['name'] ?? 'Anonim',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 4),

                                  // 📝 Makale başlığı
                                  Text(
                                    article['title'] ?? 'Başlık yok',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),

                                  // 🏷️ Kategoriler
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: -8,
                                    children: List<Widget>.from(
                                      (article['categories'] ?? []).map<Widget>(
                                        (id) {
                                          final name =
                                              categoryMap[id] ?? 'Kategori';
                                          return Chip(
                                            label: Text(name),
                                            backgroundColor: Colors.grey[200],
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 10),

                                  // 🖼️ Görsel
                                  if (article['coverImage'] != null &&
                                      article['coverImage'].isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        "http://localhost:8000${article['coverImage']}",
                                        width: double.infinity,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(Icons.report_gmailerrorred),
                          onPressed:
                              () => _showReportDrawer(context, article['_id']),
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }
}
