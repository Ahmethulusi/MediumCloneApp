import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminStatisticsScreen extends StatefulWidget {
  @override
  _AdminStatisticsScreenState createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  int userCount = 0;
  int articleCount = 0;
  int totalReads = 0;
  int totalLikes = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/admin/statistics'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userCount = data['userCount'];
          articleCount = data['articleCount'];
          totalReads = data['totalReadCount'];
          totalLikes = data['totalLikeCount'];
          isLoading = false;
        });
      } else {
        print("❌ İstatistik alınamadı: ${response.body}");
      }
    } catch (e) {
      print("🚨 Hata oluştu: $e");
    }
  }

  Widget _buildStatCard(String title, int value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Genel İstatistikler")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                children: [
                  _buildStatCard(
                    "Toplam Kullanıcı",
                    userCount,
                    Colors.blue,
                    Icons.person,
                  ),
                  _buildStatCard(
                    "Toplam Makale",
                    articleCount,
                    Colors.green,
                    Icons.article,
                  ),
                  _buildStatCard(
                    "Toplam Okunma",
                    totalReads,
                    Colors.orange,
                    Icons.visibility,
                  ),
                  _buildStatCard(
                    "Toplam Beğeni",
                    totalLikes,
                    Colors.redAccent,
                    Icons.favorite,
                  ),
                ],
              ),
    );
  }
}
