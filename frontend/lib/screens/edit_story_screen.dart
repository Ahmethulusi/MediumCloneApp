import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show QuillEditor, QuillSimpleToolbar, QuillController, Document;
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditStoryScreen extends StatefulWidget {
  final Map<String, dynamic> articleData;

  EditStoryScreen({required this.articleData});

  @override
  _EditStoryScreenState createState() => _EditStoryScreenState();
}

class _EditStoryScreenState extends State<EditStoryScreen> {
  final TextEditingController _titleController = TextEditingController();
  File? _newCoverImage;
  QuillController? _quillController;
  List<Map<String, dynamic>> categories = [];
  List<String> selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.articleData['title'] ?? '';
    selectedCategoryIds = List<String>.from(
      widget.articleData['categories'] ?? [],
    );
    _loadContent();
    _fetchCategories();
  }

  Future<void> _loadContent() async {
    final articleId = widget.articleData['_id'];
    try {
      final res = await http.get(
        Uri.parse(
          'http://localhost:8000/api/articles/$articleId/content-delta',
        ),
      );
      if (res.statusCode == 200) {
        final deltaOps = jsonDecode(res.body)['delta']['ops'];
        final delta = Delta.fromJson(deltaOps);
        setState(() {
          _quillController = QuillController(
            document: Document.fromDelta(delta),
            selection: const TextSelection.collapsed(offset: 0),
          );
        });
      } else {
        print("❌ İçerik getirilemedi: ${res.body}");
      }
    } catch (e) {
      print("🚨 İçerik yüklenirken hata: $e");
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final res = await http.get(
        Uri.parse('http://localhost:8000/api/categories'),
      );
      if (res.statusCode == 200) {
        setState(() {
          categories = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        });
      } else {
        print("❌ Kategori alınamadı: ${res.body}");
      }
    } catch (e) {
      print("❌ Kategoriler alınamadı: $e");
    }
  }

  Future<void> _pickNewImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newCoverImage = File(picked.path));
    }
  }

  Future<void> _deleteArticle() async {
    final id = widget.articleData["_id"];
    final res = await http.delete(
      Uri.parse("http://localhost:8000/api/articles/$id/delete"),
    );
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Makale başarıyla silindi.")));
      Navigator.pop(context, "deleted");
    } else {
      print("❌ Silme başarısız: ${res.body}");
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Makaleyi Sil'),
            content: Text('Bu makaleyi silmek istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Evet, Sil'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _deleteArticle();
    }
  }

  Future<void> _saveChanges() async {
    final body = {
      "title": _titleController.text.trim(),
      "categories": selectedCategoryIds,
      "content": jsonEncode(_quillController?.document.toDelta().toJson()),
    };

    if (_newCoverImage != null) {
      final imageReq = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8000/api/uploads'),
      );
      imageReq.files.add(
        await http.MultipartFile.fromPath('image', _newCoverImage!.path),
      );
      final imageRes = await imageReq.send();

      if (imageRes.statusCode == 200) {
        final imageJson = jsonDecode(await imageRes.stream.bytesToString());
        body['coverImage'] = imageJson['imageUrl'];
      } else {
        print("❌ Görsel yüklenemedi.");
        return;
      }
    }

    final articleId = widget.articleData['_id'];
    final res = await http.put(
      Uri.parse('http://localhost:8000/api/articles/$articleId/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Makale başarıyla güncellendi.")),
      );
      Navigator.pop(context, 'updated');
    } else {
      print("❌ Güncelleme başarısız: ${res.body}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Güncelleme başarısız.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingImage = widget.articleData['coverImage'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Makale Düzenle"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
            color: Colors.green,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _confirmDelete,
            color: Colors.redAccent,
          ),
        ],
      ),
      body:
          _quillController == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: "Makale Başlığı"),
                    ),
                    SizedBox(height: 16),

                    // Kapak Görseli
                    Text(
                      "Kapak Fotoğrafı",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    _newCoverImage != null
                        ? Image.file(_newCoverImage!, height: 200)
                        : existingImage != null && existingImage.isNotEmpty
                        ? Image.network(
                          "http://localhost:8000$existingImage",
                          height: 200,
                        )
                        : Text("Kapak görseli yok."),
                    OutlinedButton.icon(
                      onPressed: _pickNewImage,
                      icon: Icon(Icons.photo),
                      label: Text("Yeni Fotoğraf Seç"),
                    ),
                    SizedBox(height: 16),

                    // Kategoriler
                    Text(
                      "Kategoriler",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          categories.map((cat) {
                            final isSelected = selectedCategoryIds.contains(
                              cat['_id'],
                            );
                            return FilterChip(
                              label: Text(cat['name']),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selected
                                      ? selectedCategoryIds.add(cat['_id'])
                                      : selectedCategoryIds.remove(cat['_id']);
                                });
                              },
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 20),

                    // Editör
                    QuillSimpleToolbar(controller: _quillController!),
                    SizedBox(height: 8),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: QuillEditor.basic(controller: _quillController!),
                    ),
                  ],
                ),
              ),
    );
  }
}
