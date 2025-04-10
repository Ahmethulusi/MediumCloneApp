import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../components/edit_profile.dart';
import 'login_screen.dart';
import 'edit_story_screen.dart';
import '../components/new_story.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    Future.microtask(() {
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchUserStories(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Ayarlar ekranına yönlendirme
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body:
          userProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            userProvider.profileImage.isNotEmpty
                                ? NetworkImage(userProvider.profileImage)
                                : AssetImage('assets/default_avatar.png')
                                    as ImageProvider,
                        onBackgroundImageError: (_, __) {
                          print(
                            "❌ Profil resmi yüklenemedi: ${userProvider.profileImage}",
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        userProvider.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "0 Followers • 1 Following",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            child: Text(
                              "View stats",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EditProfileScreen(
                                        userId: widget.userId,
                                      ),
                                ),
                              );
                            },
                            child: Text("Edit your profile"),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      TabBarViewSection(userId: widget.userId),
                    ],
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewStoryScreen()),
          );

          if (result == 'refresh') {
            Provider.of<UserProvider>(
              context,
              listen: false,
            ).fetchUserStories(widget.userId);
          }
        },

        backgroundColor: Colors.green,
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
    setState(() {
      isLoading = true;
    });

    await Provider.of<UserProvider>(
      context,
      listen: false,
    ).fetchUserStories(widget.userId);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: "Stories"),
              Tab(text: "Lists"),
              Tab(text: "About"),
            ],
          ),
          Container(
            height: 300,
            child: TabBarView(
              children: [
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : userProvider.publicStories.isEmpty
                    ? Center(child: Text("No published stories"))
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        EditStoryScreen(articleData: story),
                              ),
                            );
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
                              padding: const EdgeInsets.all(16.0),
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

                Center(child: Text("No lists available")),
                Center(child: Text("About the user")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
