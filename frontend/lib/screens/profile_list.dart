import 'package:flutter/material.dart';
import '../screens/profile_detail_screen.dart';

class ContactsScreen extends StatelessWidget {
  final List<Map<String, String>> contacts = [
    {
      "name": "Mehmet Yılmaz",
      "jobTitle": "Flutter Developer",
      "imageUrl": "https://via.placeholder.com/150",
    },
    {
      "name": "Ayşe Demir",
      "jobTitle": "Software Engineer",
      "imageUrl": "https://via.placeholder.com/150",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kişiler')),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(contacts[index]["imageUrl"]!),
            ),
            title: Text(contacts[index]["name"]!),
            subtitle: Text(contacts[index]["jobTitle"]!),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ProfileScreen(
                        name: contacts[index]["name"]!,
                        jobTitle: contacts[index]["jobTitle"]!,
                        imageUrl: contacts[index]["imageUrl"]!,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
