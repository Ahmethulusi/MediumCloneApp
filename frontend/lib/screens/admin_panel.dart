import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(
      Uri.parse("http://localhost:8000/api/users"),
    );

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    final response = await http.put(
      Uri.parse("http://localhost:8000/api/users/$userId/role"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"role": newRole}),
    );

    if (response.statusCode == 200) {
      fetchUsers(); // Listeyi güncelle
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Paneli")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user["name"]),
            subtitle: Text("Rol: ${user["role"]}"),
            trailing: DropdownButton<String>(
              value: user["role"],
              onChanged: (newRole) {
                if (newRole != null) {
                  updateUserRole(user["_id"], newRole);
                }
              },
              items:
                  ["author", "admin"].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
            ),
          );
        },
      ),
    );
  }
}
