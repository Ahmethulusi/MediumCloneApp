import 'package:flutter/material.dart';
import 'profile_detail_screen.dart';

class ArticleScreen extends StatelessWidget {
  final String name;
  final String jobTitle;
  final String imageUrl;
  final String content;

  const ArticleScreen({
    required this.name,
    required this.jobTitle,
    required this.imageUrl,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(radius: 50, backgroundImage: NetworkImage(imageUrl)),
              SizedBox(height: 10),
              Row(
                children: [
                  Spacer(),
                  Text(
                    name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                ],
              ),

              Text(
                jobTitle,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProfileScreen(
                            name: name,
                            jobTitle: jobTitle,
                            imageUrl: imageUrl,
                          ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(content, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
