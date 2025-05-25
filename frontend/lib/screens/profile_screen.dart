import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../components/edit_profile.dart';
import 'login_screen.dart';
import 'edit_story_screen.dart';
import '../components/new_story.dart';
import '../components/profile_about_tab.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme_settings.dart';
import 'reports/top_read_article.dart';
import 'reports/top_article_stats.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int followerCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchUserStories(widget.userId);
      _fetchFollowerStats();
    });
  }

  Future<void> _fetchFollowerStats() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/users/${widget.userId}/stats'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        followerCount = data['followers'] ?? 0;
        followingCount = data['following'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.color_lens_sharp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');
              final themeProvider = Provider.of<AppThemeProvider>(
                context,
                listen: false,
              );

              themeProvider
                  .setThemeForAuth(); // çıkış sonrası login ekranına dönerken

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body:
          userProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        userProvider.profileImage.isNotEmpty
                            ? NetworkImage(userProvider.profileImage)
                            : AssetImage('assets/default_avatar.png')
                                as ImageProvider,
                  ),
                  SizedBox(height: 10),
                  Text(
                    userProvider.name,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$followerCount Takipçi • $followingCount Takip",
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => TopStatsScreen(userId: widget.userId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Text(
                          "İstatistikler",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      EditProfileScreen(userId: widget.userId),
                            ),
                          );
                        },
                        child: Text("Profilini Düzenle"),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(child: TabBarViewSection(userId: widget.userId)),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NewArticleFormScreen()),
          );

          if (result == 'refresh') {
            await Provider.of<UserProvider>(
              context,
              listen: false,
            ).fetchUserStories(widget.userId);
            setState(() {});
          }
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}

class TabBarViewSection extends StatefulWidget {
  final String userId;

  TabBarViewSection({required this.userId});

  @override
  _TabBarViewSectionState createState() => _TabBarViewSectionState();
}

class _TabBarViewSectionState extends State<TabBarViewSection> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserStories();
  }

  Future<void> _fetchUserStories() async {
    setState(() => isLoading = true);
    await Provider.of<UserProvider>(
      context,
      listen: false,
    ).fetchUserStories(widget.userId);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            unselectedLabelColor: Colors.black45,
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: "İçerikler"),
              Tab(text: "Listeler"),
              Tab(text: "Hakkımda"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : userProvider.publicStories.isEmpty
                    ? Center(child: Text("Henüz bir içerik mevcut değil !"))
                    : ListView.builder(
                      itemCount: userProvider.publicStories.length,
                      itemBuilder: (context, index) {
                        final story = userProvider.publicStories[index];
                        final rawContent = story['content']?.toString() ?? '';
                        final plainText = rawContent.replaceAll(
                          RegExp(r'<[^>]*>'),
                          '',
                        );
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => EditStoryScreen(articleData: story),
                              ),
                            );

                            if (result == 'updated' || result == 'deleted') {
                              // 🔁 Listeyi güncellemek için:
                              await userProvider.fetchUserStories(
                                widget.userId,
                              ); // Bu metot senin Provider'da olmalı
                              setState(() {}); // ekranı yeniden çiz
                            }
                          },

                          child: Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    story['title'] ?? 'Başlık yok',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    plainText.length > 100
                                        ? plainText.substring(0, 100) + "..."
                                        : plainText,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                Center(child: Text("Listeler")),
                SingleChildScrollView(child: UserProfileHeader()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
