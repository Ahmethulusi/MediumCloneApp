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
  List<Map<String, dynamic>> categories = [];
  Map<String, String> categoryMap = {};
  bool isLoading = true;
  String selectedCategoryId = 'all';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/categories'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        setState(() {
          categories = [
            {'_id': 'all', 'name': 'Tümü'},
            ...data.where((c) => c['parent'] == null).toList(),
          ];

          categoryMap = {for (var cat in data) cat['_id']: cat['name']};

          fetchArticles();
        });
      }
    } catch (e) {
      print("❌ Kategori çekilemedi: $e");
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 200
                ? "Şikayet gönderildi ✅"
                : "Şikayet gönderilemedi ❌",
          ),
        ),
      );
    } catch (e) {
      print("🚨 Şikayet gönderme hatası: $e");
    }
  }

  Future<void> fetchArticles() async {
    setState(() => isLoading = true);

    String url =
        selectedCategoryId == 'all'
            ? 'http://localhost:8000/api/articles/explore/random'
            : 'http://localhost:8000/api/articles/byCategory/$selectedCategoryId';

    try {
      final response = await http.get(Uri.parse(url));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Anasayfa")),
      body: Column(
        children: [
          // 🟦 Kategori Tabları
          SizedBox(
            height: 50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children:
                    categories.map((cat) {
                      final isSelected = cat['_id'] == selectedCategoryId;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(cat['name']),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedCategoryId = cat['_id'];
                              fetchArticles();
                            });
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          // 📃 Makale Listesi
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : articles.isEmpty
                    ? Center(child: Text("Gösterilecek makale yok."))
                    : ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];

                        return Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Card(
                                color: Color(0xFFF9F9F9),
                                margin: EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ArticleDetailScreen(
                                              article: article,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article['author']?['name'] ??
                                              'Anonim',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          article['title'] ?? '',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: -8,
                                          children: List<Widget>.from(
                                            (article['categories'] ?? [])
                                                .map<Widget>((id) {
                                                  final name =
                                                      categoryMap[id] ??
                                                      'Kategori';
                                                  return Chip(
                                                    label: Text(name),
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                  );
                                                }),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        if (article['coverImage'] != null &&
                                            article['coverImage'].isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              "http://localhost:8000${article['coverImage']}",
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // 🚩 Şikayet Butonu
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: Icon(Icons.report_gmailerrorred),
                                onPressed:
                                    () => _showReportDrawer(
                                      context,
                                      article['_id'],
                                    ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
