import 'package:flutter/material.dart';

class ReportArticleScreen extends StatefulWidget {
  final String articleTitle;

  const ReportArticleScreen({super.key, required this.articleTitle});

  @override
  State<ReportArticleScreen> createState() => _ReportArticleScreenState();
}

class _ReportArticleScreenState extends State<ReportArticleScreen> {
  String? selectedReason;
  final TextEditingController _explanationController = TextEditingController();

  final List<String> reasons = [
    "Spam",
    "Uygunsuz İçerik",
    "Telif Hakkı İhlali",
    "Diğer",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Makaleyi Şikayet Et")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Şikayet Edilen Makale: ${widget.articleTitle}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Şikayet Nedeni",
                border: OutlineInputBorder(),
              ),
              items:
                  reasons
                      .map(
                        (reason) => DropdownMenuItem(
                          value: reason,
                          child: Text(reason),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedReason = value;
                });
              },
              value: selectedReason,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _explanationController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Açıklama (İsteğe bağlı)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Şu an sadece konsola yazdırıyoruz
                  print("Makale: ${widget.articleTitle}");
                  print("Neden: $selectedReason");
                  print("Açıklama: ${_explanationController.text}");

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Şikayet gönderildi")),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Şikayet Gönder"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
