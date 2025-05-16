import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'author_profile_screen.dart';

class UsersList extends StatefulWidget {
  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList>
    with SingleTickerProviderStateMixin {
  List<dynamic> authors = [];
  List<dynamic> filteredAuthors = [];
  String searchQuery = '';
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    fetchAuthors();
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(_applyFilters);
  }

  void _applyFilters() {
    final selectedTab = _tabController!.index;
    final filtered =
        authors.where((user) {
          final nameMatch = user['name'].toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
          final isBanned = user['isBanned'] == true;
          final isFrozen = user['isFrozen'] == true;

          if (selectedTab == 1) return isBanned && nameMatch;
          if (selectedTab == 2) return isFrozen && nameMatch;
          return !isBanned && !isFrozen && nameMatch;
        }).toList();

    setState(() => filteredAuthors = filtered);
  }

  void _onSearchChanged(String value) {
    setState(() => searchQuery = value);
    _applyFilters();
  }

  Future<void> fetchAuthors() async {
    final response = await http.get(
      Uri.parse("http://localhost:8000/api/users"),
    );

    if (response.statusCode == 200) {
      List<dynamic> allUsers = json.decode(response.body);
      final authorsList = allUsers.where((u) => u['role'] == 'author').toList();

      setState(() {
        authors = authorsList;
      });

      _applyFilters(); // İlk filtreleme
    }
  }

  Future<void> _sendMessageToUser(String userId, String message) async {
    final response = await http.post(
      Uri.parse("http://localhost:8000/api/admin/message"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "message": message}),
    );

    final messageText =
        response.statusCode == 200
            ? "Mesaj gönderildi ✅"
            : "Mesaj gönderilemedi ❌";

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(messageText)));
  }

  void _showMessageDialog(String userId) {
    TextEditingController _messageController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Kullanıcıya Mesaj Gönder"),
            content: TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Mesajınızı yazın...",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("İptal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _sendMessageToUser(userId, _messageController.text);
                },
                child: Text("Gönder"),
              ),
            ],
          ),
    );
  }

  void _showActionsDrawer(BuildContext context, Map<String, dynamic> user) {
    final bool isBanned = user['isBanned'] == true;

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
                  leading: Icon(Icons.message),
                  title: Text("Mesaj Gönder"),
                  onTap: () {
                    Navigator.pop(context);
                    _showMessageDialog(user['_id']);
                  },
                ),
                ListTile(
                  leading: Icon(isBanned ? Icons.undo : Icons.block),
                  title: Text(
                    isBanned
                        ? "Kullanıcının Banını Kaldır"
                        : "Kullanıcıyı Banla",
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _performUserAction(user['_id'], isBanned ? "unban" : "ban");
                  },
                ),
                ListTile(
                  leading: Icon(Icons.pause_circle),
                  title: Text("Hesabı Dondur"),
                  onTap: () {
                    Navigator.pop(context);
                    _performUserAction(user['_id'], "freeze");
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("Hesabı Sil"),
                  onTap: () {
                    Navigator.pop(context);
                    _performUserAction(user['_id'], "delete");
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _performUserAction(String userId, String action) async {
    Uri url;
    Map<String, dynamic> body = {"userId": userId};

    if (action == "delete") {
      url = Uri.parse("http://localhost:8000/api/admin/action/delete/$userId");
    } else {
      url = Uri.parse("http://localhost:8000/api/admin/action/$action");
    }

    final response =
        action == "delete"
            ? await http.delete(url)
            : await http.post(
              url,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(body),
            );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.statusCode == 200
              ? "✅ İşlem başarılı: $action"
              : "❌ İşlem başarısız: $action",
        ),
      ),
    );

    fetchAuthors();
  }

  void _navigateToAuthorProfile(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AuthorProfileScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Yazarlar"),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Aktif"),
              Tab(text: "Banlı"),
              Tab(text: "Dondurulmuş"),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Kullanıcı ara...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredAuthors.length,
                itemBuilder: (context, index) {
                  final user = filteredAuthors[index];

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
                            onPressed: () => _showActionsDrawer(context, user),
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
            ),
          ],
        ),
      ),
    );
  }
}
