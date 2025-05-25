import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/article_card.dart'; // Kartı ayrıca yapabiliriz

class ArticleTabContent extends StatelessWidget {
  final TabController controller;
  final List<Map<String, dynamic>> categories;
  final String currentUserId;
  final Map<String, String> categoryMap;

  const ArticleTabContent({
    required this.controller,
    required this.categories,
    required this.currentUserId,
    required this.categoryMap,
    super.key,
  });

  String _getPreferredArticlesUrl() =>
      'http://localhost:8000/api/articles/byPreferredCategories/$currentUserId';

  String _getFollowingArticlesUrl() =>
      'http://localhost:8000/api/articles/byFollowing/$currentUserId';

  String _getArticlesByCategoryUrl(String categoryId) =>
      'http://localhost:8000/api/articles/byCategory/$categoryId';

  Widget _buildArticleListView(String url) {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse(url)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.statusCode != 200) {
          return const Center(child: Text("Veri alınamadı"));
        }

        final List articles =
            json.decode(snapshot.data!.body)['articles'] ?? [];

        if (articles.isEmpty) {
          return const Center(child: Text("Gösterilecek makale yok."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return ArticleCard(article: article, categoryMap: categoryMap);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      children: [
        _buildEmptyTab(), // bu eksikti
        _buildArticleListView(_getPreferredArticlesUrl()),
        _buildArticleListView(_getFollowingArticlesUrl()),
        ...categories.map(
          (c) => _buildArticleListView(_getArticlesByCategoryUrl(c['_id'])),
        ),
      ],
    );
  }

  Widget _buildEmptyTab() => const SizedBox.shrink();
}
