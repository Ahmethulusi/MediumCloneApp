import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'article_detail_screen.dart'; // 🔁 Makale detayına yönlendirme için

class AuthorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  AuthorProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${user['name']} • Yazar Profili")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage:
                  user['profileImage'] != null
                      ? NetworkImage(user['profileImage'])
                      : AssetImage('assets/default_avatar.png')
                          as ImageProvider,
            ),
            title: Text(user['name']),
            subtitle: Text(user['email']),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "📚 Yayınlanan Makaleler",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchArticles(user['_id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                final articles = snapshot.data as List<dynamic>? ?? [];

                if (articles.isEmpty) {
                  return Center(child: Text("Bu yazarın henüz makalesi yok."));
                }

                return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        title: Text(article['title']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ArticleDetailScreen(article: article),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: Text("Makale Silinsin mi?"),
                                    content: Text(
                                      "Bu makaleyi silmek istediğine emin misin?",
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text("İptal"),
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                      ),
                                      ElevatedButton(
                                        child: Text("Sil"),
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirm == true) {
                              await deleteArticle(article['_id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Makale silindi ✅")),
                              );
                              // Sayfayı yeniden yükle
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AuthorProfileScreen(user: user),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> fetchArticles(String userId) async {
    final res = await http.get(
      Uri.parse("http://localhost:8000/api/articles/$userId"),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['stories'] ?? [];
    }
    return [];
  }

  Future<void> deleteArticle(String articleId) async {
    final res = await http.delete(
      Uri.parse("http://localhost:8000/api/admin/delete/$articleId"),
    );
    if (res.statusCode != 200) {
      print("❌ Makale silinemedi: ${res.body}");
    }
  }
}
