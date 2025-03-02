import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback updateLoginStatus;
  final String name;
  final String email;
  final String profileImage;

  ProfileScreen({
    required this.updateLoginStatus,
    required this.name,
    required this.email,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Ayarlar sayfasına yönlendirme
            },
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: updateLoginStatus),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildTabSection(),
            _buildPostsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni makale ekleme
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.edit),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(radius: 50, backgroundImage: NetworkImage(profileImage)),
          SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(email, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: Text(
                  "View stats",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {},
                child: Text("Edit your profile"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
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

  Widget _buildPostsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          DropdownButton<String>(
            isExpanded: true,
            value: "Public",
            onChanged: (value) {},
            items:
                ["Public", "Private"].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              "You don’t have any public posts.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
