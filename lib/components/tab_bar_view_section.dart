import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class TabBarViewSection extends StatefulWidget {
  final String userId; // 🔹 Kullanıcı ID parametresi eklendi

  TabBarViewSection({required this.userId});

  @override
  _TabBarViewSectionState createState() => _TabBarViewSectionState();
}

class _TabBarViewSectionState extends State<TabBarViewSection> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserStories();
  }

  Future<void> _fetchUserStories() async {
    setState(() {
      isLoading = true;
    });

    await Provider.of<UserProvider>(
      context,
      listen: false,
    ).fetchUserStories(widget.userId); // 🔹 userId ile çağrıldı

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [Tab(text: "Public Stories"), Tab(text: "Drafts")],
          ),
          Container(
            height: 300,
            child: TabBarView(
              children: [
                /// **📌 Yayınlanan Makaleler (Public Stories)**
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : userProvider.publicStories.isEmpty
                    ? Center(child: Text("No published stories"))
                    : ListView.builder(
                      itemCount: userProvider.publicStories.length,
                      itemBuilder: (context, index) {
                        final story = userProvider.publicStories[index];
                        return ListTile(
                          title: Text(story['title']),
                          subtitle: Text(
                            story['summary'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            // Makale detayına gitme işlemi
                          },
                        );
                      },
                    ),

                /// **📌 Taslak Makaleler (Drafts)**
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : userProvider.draftStories.isEmpty
                    ? Center(child: Text("No drafts available"))
                    : ListView.builder(
                      itemCount: userProvider.draftStories.length,
                      itemBuilder: (context, index) {
                        final story = userProvider.draftStories[index];
                        return ListTile(
                          title: Text(story['title']),
                          subtitle: Text(
                            story['summary'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(Icons.edit),
                          onTap: () {
                            // Düzenleme ekranına git
                          },
                        );
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
