import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  final String userId;

  LibraryScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Kütüphane içeriği (Kullanıcı ID: $userId)")),
    );
  }
}
