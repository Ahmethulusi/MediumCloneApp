import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class NewStoryScreen extends StatefulWidget {
  @override
  _NewStoryScreenState createState() => _NewStoryScreenState();
}

class _NewStoryScreenState extends State<NewStoryScreen> {
  final QuillEditorController _controller = QuillEditorController();

  /// **📝 Makale Yayınlama Fonksiyonu**
  Future<void> _publishStory() async {
    String htmlContent = await _controller.getText();
    print("🚀 Makale Yayınlandı: $htmlContent");
    // TODO: Burada makaleyi backend'e "yayınlandı" olarak gönder
  }

  /// **📌 Taslağa Kaydetme Fonksiyonu**
  Future<void> _saveAsDraft() async {
    String htmlContent = await _controller.getText();
    print("💾 Makale Taslağa Kaydedildi: $htmlContent");
    // TODO: Burada makaleyi backend'e "taslak" olarak kaydet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yeni Makale Oluştur"),
        actions: [
          /// **Üç Nokta Menüsü (PopupMenuButton)**
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == "publish") {
                _publishStory(); // Yayınla
              } else if (value == "draft") {
                _saveAsDraft(); // Taslağa Kaydet
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(
                    value: "publish",
                    child: ListTile(
                      leading: Icon(Icons.send, color: Colors.blue),
                      title: Text("Yayınla"),
                    ),
                  ),
                  PopupMenuItem(
                    value: "draft",
                    child: ListTile(
                      leading: Icon(Icons.save, color: Colors.green),
                      title: Text("Taslağa Kaydet"),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          /// 🛠 **quill_html_editor** içindeki araç çubuğu
          ToolBar(
            controller: _controller,
            toolBarColor: Colors.grey[200]!,
            activeIconColor: Colors.blue,
            padding: EdgeInsets.all(8),
            iconSize: 20,
          ),

          /// **Editör**
          Expanded(
            child: QuillHtmlEditor(
              controller: _controller,
              hintText: "Buraya yaz...",
              minHeight: 400,
              autoFocus: true,
              isEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
