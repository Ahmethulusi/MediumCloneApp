import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  ArticleDetailScreen({required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  String userRole = 'author';
  String? userId;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _incrementReadCount();
  }

  Future<void> _initializeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString("userId");
    final role = prefs.getString("role") ?? 'author';

    setState(() {
      userId = uid;
      userRole = role;
    });

    // isLiked kontrolünü burada çağır
    _checkIfLiked(uid);
  }

  Future<void> _incrementReadCount() async {
    try {
      final id = widget.article['_id'];
      await http.post(
        Uri.parse('http://localhost:8000/api/articles/increment-read/$id'),
      );
    } catch (e) {
      print("❌ Okunma sayısı artırılamadı: $e");
    }
  }

  void _checkIfLiked(String? uid) {
    if (uid == null) return;
    final likes = widget.article['likes'] as List<dynamic>? ?? [];
    setState(() {
      isLiked = likes.contains(uid);
    });
  }

  Future<void> _toggleLike() async {
    if (userId == null) return;

    final articleId = widget.article['_id'];
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/articles/like/$articleId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        isLiked = !isLiked;

        // backenddeki listeyi yerel olarak da güncelle
        final likes = widget.article['likes'] as List<dynamic>? ?? [];
        if (isLiked) {
          likes.add(userId);
        } else {
          likes.remove(userId);
        }
        widget.article['likes'] = likes;
      });
    }
  }

  void _openCommentsDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            builder:
                (_, scrollController) => CommentSheet(
                  scrollController: scrollController,
                  articleId: widget.article['id'],
                ),
          ),
    );
  }

  void _deleteArticle() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Makale silindi (dummy)")));
  }

  void _editArticle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Düzenleme ekranına yönlendirilecek")),
    );
  }

  void _viewAuthorProfile() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Yazar profiline gidiliyor...")));
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final contentHtml = article['content'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(article['title'] ?? 'Makale')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'] ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Yazar: ${article['author']?['name'] ?? 'Anonim'}",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Html(data: contentHtml),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child:
            userRole == 'admin'
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: _deleteArticle,
                    ),
                    IconButton(icon: Icon(Icons.edit), onPressed: _editArticle),
                    IconButton(
                      icon: Icon(Icons.person),
                      onPressed: _viewAuthorProfile,
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: _toggleLike,
                    ),
                    IconButton(
                      icon: Icon(Icons.bookmark_border),
                      onPressed: () {}, // TODO: Kaydetme işlemi
                    ),
                    IconButton(
                      icon: Icon(Icons.comment),
                      onPressed: _openCommentsDrawer,
                    ),
                  ],
                ),
      ),
    );
  }
}

class CommentSheet extends StatefulWidget {
  final ScrollController scrollController;
  final String articleId;

  CommentSheet({required this.scrollController, required this.articleId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  List<dynamic> comments = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndComments();
  }

  Future<void> _loadUserAndComments() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('userId');

    if (uid == null) {
      print("⚠️ userId null: Giriş yapılmamış olabilir.");
    }

    setState(() {
      userId = uid;
    });

    await _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          "http://localhost:8000/api/articles/comment/${widget.articleId}",
        ),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        // Eğer data null ise boş array'a çevir
        setState(() {
          comments = data ?? [];
          isLoading = false;
        });
      } else {
        print("❌ Yorumlar alınamadı: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Yorum çekilirken hata oluştu: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || userId == null) {
      print("⚠️ Yorum gönderilemedi: Kullanıcı yok veya metin boş.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://localhost:8000/api/articles/post-comment"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "articleId": widget.articleId,
          "userId": userId,
          "text": text,
        }),
      );

      if (response.statusCode == 201) {
        _controller.clear();
        await _fetchComments();
      } else {
        print("❌ Yorum gönderilemedi: ${response.body}");
      }
    } catch (e) {
      print("❌ Yorum gönderme hatası: $e");
    }
  }

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
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Yorumunuzu yazın...",
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          SizedBox(height: 10),
          ElevatedButton(onPressed: _submitComment, child: Text("Gönder")),
          SizedBox(height: 16),
          isLoading
              ? CircularProgressIndicator()
              : Expanded(
                child:
                    comments.isEmpty
                        ? Center(child: Text("Henüz yorum yapılmamış."))
                        : ListView.builder(
                          controller: widget.scrollController,
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final c = comments[index];
                            // Kullanıcı adı ve yorum metni için null kontrolü
                            final author = c['userId']?['name'] ?? 'Bilinmeyen';
                            final text = c['text'] ?? '';

                            return ListTile(
                              leading: CircleAvatar(child: Icon(Icons.person)),
                              title: Text(author),
                              subtitle: Text(text),
                            );
                          },
                        ),
              ),
        ],
      ),
    );
  }
}
