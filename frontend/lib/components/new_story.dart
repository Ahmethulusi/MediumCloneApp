import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:convert';
import 'html_editor.dart';

class NewArticleFormScreen extends StatefulWidget {
  @override
  _NewArticleFormScreenState createState() => _NewArticleFormScreenState();
}

class _NewArticleFormScreenState extends State<NewArticleFormScreen> {
  final TextEditingController _titleController = TextEditingController();
  File? _coverImage;
  List<Map<String, dynamic>> categories = [];
  List<String> selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/categories'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data.cast<Map<String, dynamic>>();
        });
      } else {
        print("Kategori alınamadı: ${response.body}");
      }
    } catch (e) {
      print("Kategori hatası: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  void _goToEditorScreen() async {
    if (_titleController.text.trim().isEmpty ||
        _coverImage == null ||
        selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lütfen tüm alanları doldurun.")));
      return;
    }
    if (!(_coverImage is File)) {
      print("⚠️ Kapak fotoğrafı doğru değil: $_coverImage");
      return;
    }

    print("⏩ Navigating to editor...");
    print("📄 Başlık: ${_titleController.text}");
    print("📷 Görsel: ${_coverImage!.path}");
    print("🏷️ Kategoriler: $selectedCategoryIds");

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ArticleEditorScreen(
              arguments: {
                "title": _titleController.text.trim(),
                "coverImage": _coverImage,
                "categories": selectedCategoryIds,
              },
            ),
      ),
    );

    if (result == 'refresh') {
      Navigator.pop(context, 'refresh'); // B ➡️ A
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yeni Makale")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Makale Başlığı",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Kapak Fotoğrafı",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _coverImage != null
                ? Image.file(_coverImage!, height: 150)
                : OutlinedButton(
                  onPressed: _pickImage,
                  child: Text("Fotoğraf Seç"),
                ),
            SizedBox(height: 16),
            Text("Kategoriler", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownSearch<String>.multiSelection(
              items: categories.map((e) => e['name'] as String).toList(),
              onChanged: (List<String> selectedNames) {
                setState(() {
                  selectedCategoryIds =
                      categories
                          .where((cat) => selectedNames.contains(cat['name']))
                          .map((cat) => cat['_id'] as String)
                          .toList();
                });
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  hintText: "Kategori Seç",
                  border: OutlineInputBorder(),
                ),
              ),
              popupProps: PopupPropsMultiSelection.dialog(showSearchBox: false),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _goToEditorScreen,
                child: Text("İlerle"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
