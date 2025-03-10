import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../components/edit_profile.dart';
import 'login_screen.dart';
import '../components/new_story.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchUserData(widget.userId);
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
                      // 📌 Profil Resmi Gösterme
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
                      TabBarViewSection(),
                    ],
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewStoryScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.edit),
      ),
    );
  }
}

class TabBarViewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            height: 200,
            child: TabBarView(
              children: [
                Center(child: Text("No stories available")),
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
