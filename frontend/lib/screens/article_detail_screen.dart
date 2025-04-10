import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  ArticleDetailScreen({required this.article});

  void _openCommentsDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            builder:
                (_, scrollController) =>
                    CommentSheet(scrollController: scrollController),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentHtml = article['content'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(article['title'] ?? 'Makale')),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📌 Başlık
            Text(
              article['title'] ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            /// 🧑‍💻 Yazar
            Text(
              "Yazar: ${article['author']?['name'] ?? 'Anonim'}",
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 16),

            /// 📝 HTML İçerik
            Html(data: contentHtml),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
            IconButton(icon: Icon(Icons.bookmark_border), onPressed: () {}),
            IconButton(
              icon: Icon(Icons.comment),
              onPressed: () => _openCommentsDrawer(context),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentSheet extends StatelessWidget {
  final ScrollController scrollController;

  CommentSheet({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "Yorumlar",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),

          /// 📝 Yorum Yazma Alanı
          TextField(
            decoration: InputDecoration(
              hintText: "Yorumunuzu yazın...",
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          SizedBox(height: 10),
          ElevatedButton(onPressed: () {}, child: Text("Gönder")),
          SizedBox(height: 16),

          /// 💬 Yorum Listesi
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text("Kullanıcı $index"),
                  subtitle: Text("Bu makale çok faydalıydı!"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
