import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TopStatsScreen extends StatelessWidget {
  final String userId;

  TopStatsScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("📊 İçerik İstatistikleri"),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "📈 Okunanlar"),
              Tab(text: "❤️ Beğenilenler"),
              Tab(text: "🔖 Kaydedilenler"),
              Tab(text: "💬 Yorumlar"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TopArticlesTab(
              title: "📈 En Çok Okunan Makaleler",
              endpoint: "top-articles",
              userId: userId,
            ),
            _TopArticlesTab(
              title: "❤️ En Çok Beğenilen Makaleler",
              endpoint: "top-liked",
              userId: userId,
            ),
            _TopArticlesTab(
              title: "🔖 En Çok Kaydedilen Makaleler",
              endpoint: "top-saved",
              userId: userId,
            ),
            _TopArticlesTab(
              title: "💬 En Çok Yorum Alan Makaleler",
              endpoint: "top-commented",
              userId: userId,
            ),
          ],
        ),
      ),
    );
  }
}

// 🔁 Ortak sekme widget'ı
class _TopArticlesTab extends StatefulWidget {
  final String title;
  final String endpoint;
  final String userId;

  const _TopArticlesTab({
    required this.title,
    required this.endpoint,
    required this.userId,
  });

  @override
  State<_TopArticlesTab> createState() => _TopArticlesTabState();
}

class _TopArticlesTabState extends State<_TopArticlesTab> {
  List<dynamic> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final url =
        'http://localhost:8000/api/admin/${widget.endpoint}/${widget.userId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _articles = data['articles'] ?? [];
          _isLoading = false;
        });
      } else {
        print("❌ API Hatası: ${response.body}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("🚨 Bağlantı hatası: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator());
    if (_articles.isEmpty) return Center(child: Text("Hiç veri bulunamadı"));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _articles.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final article = _articles[index];
              return ListTile(
                title: Text(article['title'] ?? 'Başlık Yok'),
                subtitle: Text(
                  "Yazar: ${article['author']?['name'] ?? 'Bilinmiyor'}",
                ),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/articleDetail',
                    arguments: article,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
