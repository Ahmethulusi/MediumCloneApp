import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategorySelectorDialog extends StatefulWidget {
  const CategorySelectorDialog({super.key});

  @override
  State<CategorySelectorDialog> createState() => _CategorySelectorDialogState();
}

class _CategorySelectorDialogState extends State<CategorySelectorDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> followed = [];
  List<dynamic> suggestions = [];
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserIdAndCategories();
  }

  Future<void> _loadUserIdAndCategories() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId != null) {
      await _loadCategories();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
    });

    final followRes = await http.get(
      Uri.parse('http://localhost:8000/api/users/$userId/followed-categories'),
    );

    // final suggestRes = await http.post(
    //   Uri.parse('http://localhost:8000/api/categories/suggestions'),
    //   headers: {"Content-Type": "application/json"},
    //   body: jsonEncode({"userId": userId}),
    // );

    final suggestRes = await http.get(
      Uri.parse('http://localhost:8000/api/categories/suggestions/$userId'),
    );

    if (followRes.statusCode != 200 || suggestRes.statusCode != 200) {
      print("followRes: ${followRes.statusCode} - ${followRes.body}");
      print("suggestRes: ${suggestRes.statusCode} - ${suggestRes.body}");
    }

    if (followRes.statusCode == 200 && suggestRes.statusCode == 200) {
      if (mounted) {
        setState(() {
          followed = json.decode(followRes.body);
          suggestions = json.decode(suggestRes.body);
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _followCategory(String id) async {
    final res = await http.post(
      Uri.parse('http://localhost:8000/api/users/$userId/follow-category'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"categoryId": id}),
    );

    if (res.statusCode == 200) {
      final followedCat = suggestions.firstWhere((c) => c['_id'] == id);

      setState(() {
        suggestions.removeWhere((c) => c['_id'] == id);

        followed.add(followedCat);
      });
    }
  }

  Future<void> _unfollowCategory(String id) async {
    final res = await http.post(
      Uri.parse('http://localhost:8000/api/users/$userId/unfollow-category'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"categoryId": id}),
    );

    if (res.statusCode == 200) {
      final cat = followed.firstWhere((c) => c['_id'] == id);

      setState(() {
        followed.removeWhere((c) => c['_id'] == id);
        suggestions.add(cat);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        )
        : SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                "İlgi Alanlarını Düzenle",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: const Color.fromARGB(206, 48, 48, 48),
                controller: _tabController,
                tabs: const [
                  Tab(text: "Takip Edilenler"),
                  Tab(text: "Önerilenler"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildFollowedList(), _buildSuggestionList()],
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildFollowedList() {
    if (followed.isEmpty) {
      return const Center(child: Text("Takip edilen kategori bulunamadı."));
    }

    return ListView.builder(
      itemCount: followed.length,
      itemBuilder: (context, index) {
        final cat = followed[index];
        return ListTile(
          leading: const Icon(Icons.topic),
          title: Text(cat['name']),
          trailing: ElevatedButton(
            onPressed: () => _unfollowCategory(cat['_id']),
            child: const Text("Takibi Bırak"),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionList() {
    if (suggestions.isEmpty) {
      return const Center(child: Text("Önerilecek başka kategori yok."));
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final cat = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.topic),
          title: Text(cat['name']),
          subtitle: Text(
            "${cat['articleCount']} içerik · ${cat['followerCount']} takipçi",
          ),
          trailing: ElevatedButton(
            onPressed: () => _followCategory(cat['_id']),
            child: const Text("Takip Et"),
          ),
        );
      },
    );
  }
}
