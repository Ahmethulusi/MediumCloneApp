import 'package:flutter/material.dart';

class NewStoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController _storyController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("New Story")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _storyController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "Write your story...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Story ekleme işlemi
              },
              child: Text("Publish Story"),
            ),
          ],
        ),
      ),
    );
  }
}
