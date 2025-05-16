import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'article_detail_screen.dart';

class ComplaintManagementScreen extends StatefulWidget {
  @override
  _ComplaintManagementScreenState createState() =>
      _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState extends State<ComplaintManagementScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> complaints = [];
  List<dynamic> reviewedComplaints = []; // İncelenmiş şikayetler için liste
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // 5 sekme
    fetchComplaints(); // tümünü getir
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging == false) {
        fetchComplaints();
      }
    });
  }

  Future<void> fetchComplaints() async {
    final response = await http.get(
      Uri.parse("http://localhost:8000/api/reports/all"), // Tüm raporları getir
    );
    if (response.statusCode == 200) {
      final List<dynamic> allReports = json.decode(response.body);
      setState(() {
        complaints =
            allReports.where((report) {
              String selectedTab = getSelectedTab();
              final reason = report['reason']?.toLowerCase() ?? "";
              if (selectedTab == 'Tümü') return true;
              if (selectedTab == 'Diğer') {
                return ![
                  'Spam',
                  'Telif Hakkı İhlali',
                  'Uygunsuz İçerik',
                ].contains(reason);
              }
              return reason == selectedTab.toLowerCase();
            }).toList();

        // İncelenmiş şikayetleri filtrele
        reviewedComplaints =
            allReports.where((report) => report['resolved'] == true).toList();
      });
    }
  }

  String getSelectedTab() {
    switch (_tabController!.index) {
      case 0:
        return 'Tümü';
      case 1:
        return 'Spam';
      case 2:
        return 'Telif Hakkı İhlali';
      case 3:
        return 'Uygunsuz İçerik';
      case 4:
        return 'İncelenmiş'; // Yeni sekme
      default:
        return 'Tümü';
    }
  }

  Future<void> markAsResolved(String reportId) async {
    final response = await http.patch(
      Uri.parse(
        "http://localhost:8000/api/reports/$reportId/resolve",
      ), // Raporu çözülmüş olarak işaretle
    );
    if (response.statusCode == 200) {
      fetchComplaints(); // Yeniden yükle
    }
  }

  void goToArticleDetail(Map<String, dynamic> article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Şikayet Yönetimi"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Tümü'),
            Tab(text: 'Spam'),
            Tab(text: 'Telif Hakkı İhlali'),
            Tab(text: 'Uygunsuz İçerik'),
            Tab(text: 'İncelenmiş'), // Yeni sekme
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tüm şikayetler
          buildComplaintList(complaints),
          // Spam şikayetler
          buildComplaintList(
            complaints
                .where((report) => report['reason']?.toLowerCase() == 'spam')
                .toList(),
          ),
          // Telif Hakkı İhlali şikayetler
          buildComplaintList(
            complaints
                .where(
                  (report) =>
                      (report['reason']?.toLowerCase() ?? '').contains('telif'),
                )
                .toList(),
          ),
          // Uygunsuz İçerik şikayetler
          buildComplaintList(
            complaints
                .where(
                  (report) => (report['reason']?.toLowerCase() ?? '').contains(
                    'uygunsuz',
                  ),
                )
                .toList(),
          ),
          // İncelenmiş şikayetler
          buildComplaintList(reviewedComplaints),
        ],
      ),
    );
  }

  Widget buildComplaintList(List<dynamic> complaintList) {
    return ListView.builder(
      itemCount: complaintList.length,
      itemBuilder: (context, index) {
        final complaint = complaintList[index];
        final article = complaint['article'];

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Icon(Icons.report, color: Colors.redAccent),
            title: Text(article?['title'] ?? "Makale Başlığı Yok"),
            subtitle: Text("Sebep: ${complaint['reason']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dinamik ikon
                complaint['resolved'] == true
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () => markAsResolved(complaint['_id']),
                    ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () => goToArticleDetail(article),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
