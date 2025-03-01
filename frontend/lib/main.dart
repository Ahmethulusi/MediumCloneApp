import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // HomeScreen dosyanızı içe aktarın

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Article App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:
          HomeScreen(), // Uygulamanın ana ekranı olarak HomeScreen'i ayarlayın
    );
  }
}
