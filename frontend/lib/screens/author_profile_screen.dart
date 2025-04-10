import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  AuthorProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    // Bu ekran içinde user['_id'] ile makaleleri çekebiliriz
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
                return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return ListTile(
                      title: Text(article['title']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // TODO: Makale sil
                        },
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
}
