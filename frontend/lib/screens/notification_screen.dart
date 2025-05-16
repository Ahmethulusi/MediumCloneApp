import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  final String userId;

  NotificationsScreen({required this.userId});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/notification/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final List<dynamic> comments = data['comments'] ?? [];
      final List<dynamic> likes = data['likes'] ?? [];

      List<Map<String, dynamic>> combined = [];

      // Yorumları işle
      for (var c in comments) {
        combined.add({
          'type': 'comment',
          'article': c['articleId'],
          'byUser': c['userId'],
          'text': c['text'],
          'createdAt': c['createdAt'],
        });
      }

      // Beğenileri işle
      for (var l in likes) {
        combined.add({
          'type': 'like',
          'article': {'title': l['articleTitle'], '_id': l['articleId']},
          'byUser': {'name': l['userName'], '_id': l['userId']},
          'createdAt':
              DateTime.now()
                  .toIso8601String(), // backend'de yoksa şimdilik ekle
        });
      }

      // Tarihe göre sırala
      combined.sort(
        (a, b) => DateTime.parse(
          b['createdAt'],
        ).compareTo(DateTime.parse(a['createdAt'])),
      );

      setState(() {
        notifications = combined;
        isLoading = false;
      });
    } else {
      print("❌ Bildirimler alınamadı: ${response.body}");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bildirimler")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? Center(child: Text("Henüz bildirim yok."))
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final type = notif['type'];
                  final articleTitle = notif['article']?['title'] ?? 'Makale';
                  final actorName = notif['byUser']?['name'] ?? 'Bilinmeyen';

                  String message = "";
                  if (type == 'like') {
                    message = "$actorName makaleni beğendi";
                  } else if (type == 'comment') {
                    message = "$actorName makalene yorum yaptı";
                  }

                  return ListTile(
                    leading: Icon(
                      type == 'like' ? Icons.favorite : Icons.comment,
                      color: type == 'like' ? Colors.red : Colors.blue,
                    ),
                    title: Text(message),
                    subtitle: Text("📘 $articleTitle"),
                  );
                },
              ),
    );
  }
}
