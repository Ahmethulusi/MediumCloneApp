import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  final String userId;

  EditProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: "Name")),
            SizedBox(height: 10),
            TextField(decoration: InputDecoration(labelText: "Email")),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Güncelleme işlemi
              },
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
