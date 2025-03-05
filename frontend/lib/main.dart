import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/user_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  int? sessionStartTime = prefs.getInt('sessionStartTime');

  // Oturum süresini kontrol et (örneğin 1 saat = 3600000 ms)
  int sessionDuration = 3600000; // 1 saat

  bool isSessionValid = false;
  if (sessionStartTime != null) {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - sessionStartTime < sessionDuration) {
      isSessionValid = true;
    }
  }

  print("DEBUG: userId = $userId");
  print("DEBUG: sessionStartTime = $sessionStartTime");
  print("DEBUG: isSessionValid = $isSessionValid");

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MyApp(userId: (userId != null && isSessionValid) ? userId : null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? userId;

  MyApp({this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: userId != null ? HomeScreen(userId: userId!) : LoginScreen(),
    );
  }
}
