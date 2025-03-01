import 'package:flutter/material.dart';
import 'article_card.dart';

class ArticleListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> articles = [
    {
      "title": "Flutter Nedir?",
      "content": "Flutter, Google tarafından oluşturulan UI kitidir...",
      "author": "Mehmet Yılmaz",
      "jobTitle": "Flutter Developer",
      "imageUrl": "https://via.placeholder.com/150",
      "likeCount": 29,
    },
    {
      "title": "Bir yıl neden 365 gündür?",
      "content":
          "Bir yılın 365 gün 6 saat sürmesinin sebebi, Dünya’nın Güneş etrafında tam bir tur dönmesi için geçen sürenin 365 gün 6 saat olmasıdır. Ancak günlük hayatta kolaylık olması için 1 yıl 365 gün olarak kabul edilir. Bu durumda, her dört yılda bir fazladan gelen 6 saatler toplanarak Şubat ayına bir gün eklenir ve artık yıl oluşur. Artık yılın olmadığı yıllarda Şubat ayı 28 gün sürerken, artık yılın olduğu yıllarda Şubat ayı 29 gün sürer. Bu şekilde takvimimiz Güneş’in hareketine uyum sağlar.",
      "author": "Mehmet Yılmaz",
      "jobTitle": "Flutter Developer",
      "imageUrl": "https://via.placeholder.com/150",
      "likeCount": 29,
    },
    {
      "title": "Gökyüzü neden mavi?",
      "content":
          "Atmosferden geçerken ışık, havadaki gazlar ve partiküller tarafından emilir ve sonra dalga boyu uzunluğuna göre farklı yönlere saçılır. En kısa dalga boyuna sahip mavi ışınlar daha geniş bir alana saçılırlar. İşte, gökyüzünün mavi görünmesine neden budur.",
      "author": "Ayşe Demir",
      "jobTitle": "Flutter Developer",
      "imageUrl": "https://via.placeholder.com/150",
      "likeCount": 29,
    },
    {
      "title": "State Management",
      "content": "State yönetimi, Flutter uygulamalarında önemlidir...",
      "author": "Mehmet Yılmaz",
      "jobTitle": "Flutter Developer",
      "imageUrl": "https://via.placeholder.com/150",
      "likeCount": 20,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return ArticleCard(
            title: articles[index]["title"]!,
            content: articles[index]["content"]!,
            author: articles[index]["author"]!,
            jobTitle: articles[index]["jobTitle"]!,
            imageUrl: articles[index]["imageUrl"]!,
            likeCount: articles[index]["likeCount"]!,
          );
        },
      ),
    );
  }
}
