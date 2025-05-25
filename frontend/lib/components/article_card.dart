import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/article_detail_screen.dart';
import '../screens/other_profil_screen.dart';
import 'customc_complaint.dart';
import '../utils/image_helper.dart';

class ArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;
  final Map<String, String> categoryMap;

  const ArticleCard({
    required this.article,
    required this.categoryMap,
    super.key,
  });

  void _navigateToAuthorProfile(BuildContext context, String authorId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthorProfileScreen(authorId: authorId),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
    );
  }

  void _showReportDrawer(BuildContext context, String articleId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Şikayet Nedeni Seçin",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                _buildReportOption(context, articleId, "Telif Hakkı İhlali"),
                _buildReportOption(context, articleId, "Spam"),
                _buildReportOption(context, articleId, "Uygunsuz İçerik"),
                ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: const Text("Diğer"),
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
      leading: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.pop(context);
        _sendReport(context, articleId, reason);
      },
    );
  }

  Future<void> _sendReport(
    BuildContext context,
    String articleId,
    String reason,
  ) async {
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

  Future<void> _handleMenuAction(
    BuildContext context,
    String value,
    String authorId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) return;

    http.Response response;

    switch (value) {
      case 'like':
        response = await http.post(
          Uri.parse(
            'http://localhost:8000/api/articles/like/${article['_id']}',
          ),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"userId": userId}),
        );
        _showResponseMessage(
          context,
          response,
          "Beğenildi ✅",
          "❌ Beğenilemedi",
        );
        break;
      case 'save':
        response = await http.post(
          Uri.parse('http://localhost:8000/api/users/$userId/save-article'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"articleId": article['_id']}),
        );
        _showResponseMessage(
          context,
          response,
          "Kaydedildi ✅",
          "❌ Kaydedilemedi",
        );
        break;
      case 'follow':
        if (userId == authorId) return;
        response = await http.post(
          Uri.parse('http://localhost:8000/api/users/$authorId/follow'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"userId": userId}),
        );
        _showResponseMessage(
          context,
          response,
          "Takip edildi",
          "❌ Takip işlemi başarısız",
        );
        break;
      case 'report':
        _showReportDrawer(context, article['_id']);
        break;
    }
  }

  void _showResponseMessage(
    BuildContext context,
    http.Response response,
    String success,
    String failure,
  ) {
    final msg =
        response.statusCode == 200
            ? jsonDecode(response.body)['message'] ?? success
            : failure;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final author = article['author'] ?? {};
    final authorName = author['name'] ?? 'Anonim';
    final authorId = author['_id'];

    print(author);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ÜST KISIM: Yazar adı + menü
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      if (authorId != null) {
                        _navigateToAuthorProfile(context, authorId);
                      }
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: getProfileImage(
                            author['profileImage'],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          authorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: Colors.white,
                    onSelected:
                        (value) => _handleMenuAction(context, value, authorId),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'like',
                            child: Text('Beğen'),
                          ),
                          const PopupMenuItem(
                            value: 'save',
                            child: Text('Kaydet'),
                          ),
                          if (authorId != null)
                            const PopupMenuItem(
                              value: 'follow',
                              child: Text('Yazarı Takip Et'),
                            ),
                          const PopupMenuItem(
                            value: 'report',
                            child: Text('Şikayet Et'),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              /// Başlık
              Text(
                article['title'] ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// Kategoriler
              Wrap(
                spacing: 8,
                runSpacing: -8,
                children: List<Widget>.from(
                  (article['categories'] ?? []).map<Widget>((id) {
                    final name = categoryMap[id] ?? 'Kategori';
                    return Chip(
                      label: Text("# " + name),
                      backgroundColor: const Color.fromARGB(255, 234, 231, 231),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 10),

              /// Kapak fotoğrafı
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
    );
  }
}
