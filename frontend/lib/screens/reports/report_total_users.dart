import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportTotalUsers extends StatefulWidget {
  @override
  _ReportTotalUsersState createState() => _ReportTotalUsersState();
}

class _ReportTotalUsersState extends State<ReportTotalUsers> {
  int? totalUsers;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTotalUsers();
  }

  Future<void> fetchTotalUsers() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/admin/total-users'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        totalUsers = data['totalUsers'];
        isLoading = false;
      });
    } else {
      print("❌ Kullanıcı sayısı alınamadı: ${response.body}");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("👥 Toplam Kullanıcı Sayısı")),
      body: Center(
        child:
            isLoading
                ? CircularProgressIndicator()
                : Text(
                  "Toplam kullanıcı sayısı: $totalUsers",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }
}
