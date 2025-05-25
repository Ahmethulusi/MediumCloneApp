import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'suggested_users_screen.dart';

class InterestSelectionScreen extends StatefulWidget {
  @override
  _InterestSelectionScreenState createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  List<Map<String, dynamic>> categories = [];
  List<String> selectedCategoryIds = [];
  bool isLoading = true;

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
        final data = json.decode(response.body) as List;
        setState(() {
          categories = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        print("❌ Kategoriler alınamadı: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("🚨 Hata: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen en az bir kategori seçin.")),
      );
      return;
    }

    final response = await http.patch(
      Uri.parse('http://localhost:8000/api/users/$userId/interests'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'interests': selectedCategoryIds}),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuggestedFollowsScreen(userId: userId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Kaydedilemedi. Lütfen tekrar deneyin.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("İlgi Alanlarını Seç")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "İlgi duyduğun konuları seç",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
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
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitSelection,
                      child: Text("Kaydet ve Devam Et"),
                    ),
                  ],
                ),
              ),
    );
  }
}
