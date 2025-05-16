import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthorProfileScreen extends StatefulWidget {
  final String authorId;

  const AuthorProfileScreen({required this.authorId});

  @override
  _AuthorProfileScreenState createState() => _AuthorProfileScreenState();
}

class _AuthorProfileScreenState extends State<AuthorProfileScreen> {
  Map<String, dynamic>? authorData;
  bool isFollowing = false;
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchAuthorData();
  }

  Future<void> _fetchAuthorData() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId');

    final response = await http.get(
      Uri.parse('http://localhost:8000/api/users/${widget.authorId}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final followers = List<String>.from(data['followers'] ?? []);
      setState(() {
        authorData = data;
        isFollowing = followers.contains(currentUserId);
        isLoading = false;
      });
    } else {
      print("❌ Yazar bilgisi alınamadı: ${response.body}");
    }
  }

  Future<void> _toggleFollow() async {
    if (currentUserId == null) return;

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/users/${widget.authorId}/follow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': currentUserId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        isFollowing = !isFollowing;
      });
    } else {
      print("Takip işlemi başarısız: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || authorData == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(authorData!['name'] ?? 'Kullanıcı')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(authorData!['profileImage'] ?? ''),
            ),
            SizedBox(height: 10),
            Text(
              authorData!['name'] ?? '',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(authorData!['jobTitle'] ?? ''),
            SizedBox(height: 10),
            Text(authorData!['bio'] ?? ''),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleFollow,
              child: Text(isFollowing ? "Takibi Bırak" : "Takip Et"),
            ),
            SizedBox(height: 20),
            Text(
              "Takipçi: ${authorData!['followers']?.length ?? 0} • Takip Edilen: ${authorData!['following']?.length ?? 0}",
            ),
            // Buraya yazarın makaleleri eklenebilir
          ],
        ),
      ),
    );
  }
}
