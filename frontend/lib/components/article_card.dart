import '../screens/article_screen.dart';
import 'package:flutter/material.dart';
import 'like_button.dart';

class ArticleCard extends StatelessWidget {
  final String title;
  final String content;
  final String author;
  final String jobTitle;
  final String imageUrl;
  final int likeCount;

  const ArticleCard({
    required this.title,
    required this.content,
    required this.author,
    required this.jobTitle,
    required this.imageUrl,
    required this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(author, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      jobTitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(width: 10),
                LikeButton(),
                Text(likeCount.toString()),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ArticleScreen(
                              name: author,
                              jobTitle: jobTitle,
                              imageUrl: imageUrl,
                              content: content,
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
