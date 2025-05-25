import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryManagementScreen extends StatefulWidget {
  @override
  _CategoryManagementScreenState createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final res = await http.get(
      Uri.parse("http://localhost:8000/api/categories"),
    );
    if (res.statusCode == 200) {
      setState(() {
        categories = json.decode(res.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainCategories =
        categories.where((c) => c['parent'] == null).toList();
    final subCategories = categories.where((c) => c['parent'] != null).toList();

    return Scaffold(
      appBar: AppBar(title: Text("📂 Kategori Yönetimi")),
      body: ListView.builder(
        itemCount: mainCategories.length,
        itemBuilder: (context, index) {
          final mainCat = mainCategories[index];
          final subCats =
              subCategories
                  .where((sc) => sc['parent']['_id'] == mainCat['_id'])
                  .toList();

          return ExpansionTile(
            title: Text(mainCat['name'], style: TextStyle(color: Colors.white)),
            children:
                subCats.map((subCat) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 32.0,
                    ), // 🔽 Alt kategori padding
                    child: ListTile(
                      title: Text(
                        subCat['name'],
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Icon(Icons.subdirectory_arrow_right, size: 18),
                    ),
                  );
                }).toList(),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (_) => AddCategoryDialog(
                  categories: categories,
                  onRefresh: fetchCategories,
                ),
          );
        },
        child: Icon(Icons.add),
        tooltip: "Yeni Kategori Ekle",
      ),
    );
  }
}

class AddCategoryDialog extends StatefulWidget {
  final List<dynamic> categories;
  final VoidCallback onRefresh;

  AddCategoryDialog({required this.categories, required this.onRefresh});

  @override
  _AddCategoryDialogState createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  String? selectedParentId;

  @override
  Widget build(BuildContext context) {
    final mainCategories =
        widget.categories.where((c) => c['parent'] == null).toList();

    return AlertDialog(
      title: Text("Yeni Kategori Ekle"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Kategori Adı"),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedParentId,
            hint: Text("Ana kategori seç (isteğe bağlı)"),
            items:
                mainCategories.map<DropdownMenuItem<String>>((cat) {
                  return DropdownMenuItem(
                    value: cat['_id'].toString(),
                    child: Text(cat['name']),
                  );
                }).toList(),
            onChanged: (val) {
              setState(() {
                selectedParentId = val;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("İptal"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text("Ekle"),
          onPressed: () async {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;

            final response = await http.post(
              Uri.parse("http://localhost:8000/api/categories"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "name": name,
                if (selectedParentId != null) "parentId": selectedParentId,
              }),
            );

            if (response.statusCode == 200) {
              Navigator.pop(context);
              widget.onRefresh();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("✅ Kategori oluşturuldu")));
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("❌ Kategori eklenemedi")));
            }
          },
        ),
      ],
    );
  }
}
