import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show QuillEditor, QuillSimpleToolbar, QuillController, Document;
import 'package:dart_quill_delta/dart_quill_delta.dart'; // DİKKAT: flutter_quill uyumlu delta
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
    _fetchCategories();
    _loadContentFromBackend();
  }

  Future<void> _loadContentFromBackend() async {
    final articleId = widget.articleData['_id'];
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:8000/api/articles/$articleId/content-delta',
        ),
      );

      if (response.statusCode == 200) {
        final deltaJson = jsonDecode(response.body)['delta'];
        final delta = Delta.fromJson(deltaJson);
        setState(() {
          _quillController = QuillController(
            document: Document.fromDelta(delta),
            selection: const TextSelection.collapsed(offset: 0),
          );
        });
      } else {
        print("❌ İçerik getirilemedi: ${response.body}");
      }
    } catch (e) {
      print("🚨 Delta içeriği yüklenirken hata: $e");
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final id = widget.articleData['_id'];
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/articles/$id/content-delta'),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final deltaOps =
            jsonBody['delta']['ops']; // 🔥 ÖNEMLİ: 'ops' alanına eriş
        final delta = Delta.fromJson(deltaOps);
        setState(() {
          _quillController = QuillController(
            document: Document.fromDelta(delta),
            selection: const TextSelection.collapsed(offset: 0),
          );
        });
      }
    } catch (e) {
      print("❌ Kategoriler alınamadı: $e");
    }
  }

  Future<void> _pickNewImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _newCoverImage = File(pickedFile.path));
    }
  }

  Future<void> _saveChanges() async {
    final updatedTitle = _titleController.text.trim();
    final updatedCategories = selectedCategoryIds;
    final updatedContent = jsonEncode(
      _quillController?.document.toDelta().toJson(),
    );

    final Map<String, dynamic> body = {
      "title": updatedTitle,
      "categories": updatedCategories,
      "content": updatedContent,
    };

    // Eğer yeni fotoğraf seçildiyse önce onu yükle
    if (_newCoverImage != null) {
      final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8000/api/uploads'),
      );
      imageUploadRequest.files.add(
        await http.MultipartFile.fromPath('image', _newCoverImage!.path),
      );
      final imageResponse = await imageUploadRequest.send();

      if (imageResponse.statusCode == 200) {
        final imageJson = jsonDecode(
          await imageResponse.stream.bytesToString(),
        );
        body['coverImage'] = imageJson['imageUrl'];
      } else {
        print("❌ Görsel yüklenemedi.");
        return;
      }
    }

    final articleId = widget.articleData['_id'];
    final response = await http.put(
      Uri.parse('http://localhost:8000/api/articles/$articleId/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Makale başarıyla güncellendi.")),
      );
      Navigator.pop(context, 'updated');
    } else {
      print("❌ Güncelleme başarısız: ${response.body}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Güncelleme başarısız.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingImageUrl = widget.articleData['coverImage'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Makale Düzenle"),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveChanges)],
      ),
      body:
          _quillController == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: "Makale Başlığı"),
                    ),
                    SizedBox(height: 16),

                    // Görsel
                    Text(
                      "Kapak Fotoğrafı",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    _newCoverImage != null
                        ? Image.file(_newCoverImage!, height: 200)
                        : existingImageUrl != null &&
                            existingImageUrl.isNotEmpty
                        ? Image.network(
                          "http://localhost:8000$existingImageUrl",
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
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    selectedCategoryIds.add(cat['_id']);
                                  } else {
                                    selectedCategoryIds.remove(cat['_id']);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 20),

                    // Editor
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
