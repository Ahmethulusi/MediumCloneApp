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
                        height: 180,
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
                              padding: EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🧾 İçerik kısmı
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article['title'] ?? 'Başlık yok',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          "Yazar: ${article['author']?['name'] ?? 'Anonim'}",
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          formatContent(
                                            article['content'] ?? "",
                                          ),
                                          style: TextStyle(fontSize: 15),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                        ),
                                      ],
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
