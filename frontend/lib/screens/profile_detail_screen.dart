import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String jobTitle;
  final String imageUrl;

  const ProfileScreen({
    required this.name,
    required this.jobTitle,
    required this.imageUrl,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.imageUrl),
                radius: 50,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                widget.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                widget.jobTitle,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
