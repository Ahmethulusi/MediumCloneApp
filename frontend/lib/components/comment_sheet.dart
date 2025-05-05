import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('userId');
    print("📦 userId from prefs: $uid");

    setState(() {
      userId = uid;
    });

    await _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/api/comment/${widget.articleId}"),
      );

      print("📥 GET yorumlar response code: ${response.statusCode}");
      print("📥 GET yorumlar response body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("✅ Yorumlar çözümlendi: $decoded");

        if (decoded is List) {
          setState(() {
            comments = decoded;
            isLoading = false;
          });
        } else {
          print("⚠️ Beklenmeyen veri tipi: decoded is not List");
          setState(() {
            comments = [];
            isLoading = false;
          });
        }
      } else {
        print("❌ Yorumlar alınamadı: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Yorum çekme hatası: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    print("📝 Gönderilen yorum: $text");
    print("👤 userId: $userId");

    if (text.isEmpty || userId == null) {
      print("⚠️ Yorum gönderilemedi: boş metin veya userId null");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://localhost:8000/api/comment/"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "articleId": widget.articleId,
          "userId": userId,
          "text": text,
        }),
      );

      print("📤 POST yorum response: ${response.statusCode}");
      print("📤 Body: ${response.body}");

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
    print("🧱 Yorumlar Listesi: $comments");

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
                            final c = comments[index] ?? {};
                            final user = c['userId'];
                            final author =
                                (user is Map && user['name'] != null)
                                    ? user['name']
                                    : 'Bilinmeyen';
                            final text = c['text'] ?? '';

                            print(
                              "👤 $index. yorum | yazar: $author | text: $text",
                            );

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
