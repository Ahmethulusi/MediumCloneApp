import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'article_detail_screen.dart';
import 'other_profil_screen.dart';
import '../components/customc_complaint.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> categories = [];
  Map<String, String> categoryMap = {};
  TabController? _tabController;
  String? currentUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId');
    await _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/categories'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final mainCategories =
            data
                .where((c) => c['parent'] == null)
                .map((e) => e as Map<String, dynamic>)
                .toList();

        setState(() {
          categories = mainCategories;
          categoryMap = {for (var cat in data) cat['_id']: cat['name']};
          _tabController = TabController(
            length: 2 + categories.length,
            vsync: this,
          );
          isLoading = false;
        });
      }
    } catch (e) {
      print("Kategori çekme hatası: $e");
    }
  }

  String _getPreferredArticlesUrl() =>
      'http://localhost:8000/api/articles/byPreferredCategories/$currentUserId';

  String _getFollowingArticlesUrl() =>
      'http://localhost:8000/api/articles/byFollowing/$currentUserId';

  String _getArticlesByCategoryUrl(String categoryId) =>
      'http://localhost:8000/api/articles/byCategory/$categoryId';

  Widget _buildArticleListView(String url) {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse(url)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.statusCode != 200) {
          return Center(child: Text("Veri alınamadı"));
        }

        final List articles =
            json.decode(snapshot.data!.body)['articles'] ?? [];

        if (articles.isEmpty) {
          return Center(child: Text("Gösterilecek makale yok."));
        }

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            final author = article['author'] ?? {};
            final authorName = author['name'] ?? 'Anonim';
            final authorId = author['_id'];

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
                                (_) => ArticleDetailScreen(article: article),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (authorId != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => AuthorProfileScreen(
                                                authorId: authorId,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 8),
                                      Text(
                                        authorName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'like') {
                                      await _likeArticle(article['_id']);
                                    } else if (value == 'save') {
                                      await _saveArticle(article['_id']);
                                    } else if (value == 'follow') {
                                      await _followAuthor(authorId);
                                    } else if (value == 'report') {
                                      _showReportDrawer(
                                        context,
                                        article['_id'],
                                      );
                                    }
                                  },
                                  itemBuilder:
                                      (context) => [
                                        PopupMenuItem(
                                          value: 'like',
                                          child: Text('Beğen'),
                                        ),
                                        PopupMenuItem(
                                          value: 'save',
                                          child: Text('Kaydet'),
                                        ),
                                        if (currentUserId != null &&
                                            currentUserId != authorId)
                                          PopupMenuItem(
                                            value: 'follow',
                                            child: Text('Yazarı Takip Et'),
                                          ),
                                        PopupMenuItem(
                                          value: 'report',
                                          child: Text('Şikayet Et'),
                                        ),
                                      ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
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
                                (article['categories'] ?? []).map<Widget>((id) {
                                  final name = categoryMap[id] ?? 'Kategori';
                                  return Chip(
                                    label: Text(name),
                                    backgroundColor: Colors.grey[200],
                                  );
                                }),
                              ),
                            ),
                            SizedBox(height: 10),
                            if (article['coverImage'] != null &&
                                article['coverImage'].isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
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
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _likeArticle(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/articles/$articleId/like'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId}),
    );
    _handleResponse(
      response,
      success: "Beğenildi ✅",
      failure: "❌ Beğenilemedi",
    );
  }

  Future<void> _saveArticle(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/users/$userId/save-article'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"articleId": articleId}),
    );
    _handleResponse(
      response,
      success: "Kaydedildi ✅",
      failure: "❌ Kaydedilemedi",
    );
  }

  Future<void> _followAuthor(String authorId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('userId');
    if (currentUserId == null || currentUserId == authorId) return;

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/users/$authorId/follow'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": currentUserId}),
    );
    _handleResponse(
      response,
      success: "Takip edildi",
      failure: "❌ Takip işlemi başarısız",
    );
  }

  void _handleResponse(
    http.Response response, {
    required String success,
    required String failure,
  }) {
    final msg =
        response.statusCode == 200
            ? jsonDecode(response.body)['message'] ?? success
            : failure;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      print("Şikayet gönderme hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2 + categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Anasayfa"),
          bottom:
              isLoading
                  ? null
                  : TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: [
                      Tab(text: "İlgi Alanları"),
                      Tab(text: "Takip Ettiklerin"),
                      ...categories.map((c) => Tab(text: c['name'])).toList(),
                    ],
                  ),
        ),
        body:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildArticleListView(_getPreferredArticlesUrl()),
                    _buildArticleListView(_getFollowingArticlesUrl()),
                    ...categories.map(
                      (c) => _buildArticleListView(
                        _getArticlesByCategoryUrl(c['_id']),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
