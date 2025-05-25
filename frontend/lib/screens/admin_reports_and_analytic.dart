import 'package:flutter/material.dart';

import 'reports/statistics.dart';

import 'reports/top_article_stats.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Raporlar & İstatistikler")),
      body: ListView(
        children: [
          _buildTile(
            icon: Icons.people,
            title: "Sayısal İstatistikler",
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminStatisticsScreen()),
                ),
          ),
          // _buildTile(
          //   icon: Icons.people,
          //   title: "Grafikler İstatistikler",
          //   onTap:
          //       () => Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (_) => TopReadArticlesScreen()),
          //       ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
