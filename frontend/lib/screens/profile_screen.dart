import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchUserData(widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Profil")),
      body:
          userProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(userProvider.profileImage),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userProvider.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userProvider.email,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
    );
  }
}
