import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/comment_sheet.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  ArticleDetailScreen({required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  String userRole = 'author';
  String? userId;
  bool isLiked = false;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _incrementReadCount();
  }

  Future<void> _initializeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString("userId");
    final role = prefs.getString("role") ?? 'author';

    setState(() {
      userId = uid;
      userRole = role;
    });

    // isLiked kontrolünü burada çağır
    _checkIfLiked(uid);
  }

  Future<void> _incrementReadCount() async {
    try {
      final id = widget.article['_id'];
      await http.post(
        Uri.parse('http://localhost:8000/api/articles/increment-read/$id'),
      );
    } catch (e) {
      print("❌ Okunma sayısı artırılamadı: $e");
    }
  }

  void _checkIfLiked(String? uid) {
    if (uid == null) return;
    final likes = widget.article['likes'] as List<dynamic>? ?? [];
    setState(() {
      isLiked = likes.contains(uid);
    });
  }

  Future<void> _toggleLike() async {
    if (userId == null) return;

    final articleId = widget.article['_id'];
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/articles/like/$articleId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        isLiked = !isLiked;

        // backenddeki listeyi yerel olarak da güncelle
        final likes = widget.article['likes'] as List<dynamic>? ?? [];
        if (isLiked) {
          likes.add(userId);
        } else {
          likes.remove(userId);
        }
        widget.article['likes'] = likes;
      });
    }
  }

  Future<void> _toggleSaveArticle() async {
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Giriş yapmanız gerekiyor.")));
      return;
    }

    final articleId = widget.article['_id'];

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/users/$userId/save-article'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"articleId": articleId}),
      );

      if (response.statusCode == 200) {
        final message = json.decode(response.body)['message'];
        setState(() {
          isSaved = !isSaved;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));

        // UI'de güncelleme yapmak istersen burada flag değiştirebilirsin.
        // Örnek: setState(() => isSaved = !isSaved);
      } else {
        print("❌ Kaydetme hatası: ${response.body}");
      }
    } catch (e) {
      print("🚨 Sunucuya bağlanırken hata oluştu: $e");
    }
  }

  void _openCommentsDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            builder:
                (_, scrollController) => CommentSheet(
                  scrollController: scrollController,
                  articleId: widget.article['_id'],
                ),
          ),
    );
  }

  void _deleteArticle() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Makale silindi (dummy)")));
  }

  void _editArticle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Düzenleme ekranına yönlendirilecek")),
    );
  }

  void _viewAuthorProfile() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Yazar profiline gidiliyor...")));
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final contentHtml = article['content'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(article['title'] ?? 'Makale')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'] ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Yazar: ${article['author']?['name'] ?? 'Anonim'}",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Html(data: contentHtml),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child:
            userRole == 'admin'
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: _deleteArticle,
                    ),
                    IconButton(icon: Icon(Icons.edit), onPressed: _editArticle),
                    IconButton(
                      icon: Icon(Icons.person),
                      onPressed: _viewAuthorProfile,
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: _toggleLike,
                    ),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark_border : Icons.bookmark,
                        color: isSaved ? Colors.black : null,
                      ),
                      onPressed: _toggleSaveArticle,
                    ),

                    IconButton(
                      icon: Icon(Icons.comment),
                      onPressed: _openCommentsDrawer,
                    ),
                  ],
                ),
      ),
    );
  }
}
