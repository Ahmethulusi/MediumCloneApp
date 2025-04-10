import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'author_profile_screen.dart';

class UsersList extends StatefulWidget {
  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  List<dynamic> authors = [];

  @override
  void initState() {
    super.initState();
    fetchAuthors();
  }

  Future<void> fetchAuthors() async {
    final response = await http.get(
      Uri.parse("http://localhost:8000/api/users"),
    );

    if (response.statusCode == 200) {
      List<dynamic> allUsers = json.decode(response.body);
      setState(() {
        authors = allUsers.where((u) => u['role'] == 'author').toList();
      });
    }
  }

  void _showActionsDrawer(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Container(
            padding: EdgeInsets.all(16),
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.block),
                  title: Text("Kullanıcıyı Banla"),
                  onTap: () {
                    Navigator.pop(context);
                    _performUserAction(userId, "ban");
                  },
                ),
                ListTile(
                  leading: Icon(Icons.pause_circle),
                  title: Text("Hesabı Dondur"),
                  onTap: () {
                    Navigator.pop(context);
                    _performUserAction(userId, "freeze");
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("Hesabı Sil"),
                  onTap: () {
                    Navigator.pop(context);
                    _performUserAction(userId, "delete");
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _performUserAction(String userId, String action) async {
    print("🔧 $action işlemi uygulanıyor: $userId");
    // TODO: API'ye bağlı işlemleri buraya yaz
    // await http.post(...);
    fetchAuthors(); // Listeyi yenile
  }

  void _navigateToAuthorProfile(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AuthorProfileScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yazarlar")),
      body: ListView.builder(
        itemCount: authors.length,
        itemBuilder: (context, index) {
          final user = authors[index];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    user['profileImage'] != null
                        ? NetworkImage(user['profileImage'])
                        : AssetImage('assets/default_avatar.png')
                            as ImageProvider,
              ),
              title: Text(user['name']),
              subtitle: Text(user['email']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () => _showActionsDrawer(context, user['_id']),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () => _navigateToAuthorProfile(user),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
