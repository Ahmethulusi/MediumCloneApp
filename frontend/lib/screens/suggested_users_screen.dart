import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class SuggestedFollowsScreen extends StatefulWidget {
  final String userId;

  const SuggestedFollowsScreen({required this.userId});

  @override
  State<SuggestedFollowsScreen> createState() => _SuggestedFollowsScreenState();
}

class _SuggestedFollowsScreenState extends State<SuggestedFollowsScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  Set<String> followedIds = {};

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final res = await http.get(
        Uri.parse(
          'http://localhost:8000/api/users/suggestions/${widget.userId}',
        ),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        setState(() {
          users = data;
          isLoading = false;
        });
      } else {
        print("❌ Önerilen kullanıcılar alınamadı: ${res.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("🚨 Hata: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _followUser(String id) async {
    final res = await http.post(
      Uri.parse('http://localhost:8000/api/users/$id/follow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': widget.userId}),
    );

    if (res.statusCode == 200) {
      setState(() {
        followedIds.add(id);
      });
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(userId: widget.userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Takip Etmek İster Misin?")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Aşağıdaki yazarlardan ilgini çekenleri takip edebilirsin.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        print("Profil resmi URL: ${user['profileImage']}");

                        final alreadyFollowed = followedIds.contains(
                          user['_id'],
                        );
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                user['profileImage'] != null &&
                                        user['profileImage'].isNotEmpty
                                    ? NetworkImage(
                                      user['profileImage'].startsWith("http")
                                          ? user['profileImage']
                                          : "http://192.168.1.10:8000${user['profileImage']}",
                                    )
                                    : AssetImage('assets/default_avatar.png')
                                        as ImageProvider,
                          ),

                          title: Text(user['name'] ?? "Anonim"),
                          subtitle: Text(user['jobTitle'] ?? ""),
                          trailing:
                              alreadyFollowed
                                  ? Text("Takip ediliyor")
                                  : TextButton(
                                    onPressed: () => _followUser(user['_id']),
                                    child: Text("Takip Et"),
                                  ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _finishOnboarding,
                      child: Text("Devam Et"),
                    ),
                  ),
                ],
              ),
    );
  }
}
