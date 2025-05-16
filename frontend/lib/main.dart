import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/user_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_home_screen.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  String? role = prefs.getString('role');
  int? sessionStartTime = prefs.getInt('sessionStartTime');

  bool isSessionValid = false;
  if (sessionStartTime != null) {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    isSessionValid = currentTime - sessionStartTime < 3600000;
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MyApp(
        userId: (userId != null && isSessionValid) ? userId : null,
        userRole: role,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? userId;
  final String? userRole;

  MyApp({this.userId, this.userRole});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        ...GlobalMaterialLocalizations.delegates,
        quill.FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'), // veya Locale('en')
      ],
      home:
          userId != null
              ? (userRole == "admin"
                  ? AdminHomeScreen(userId: userId!)
                  : HomeScreen(userId: userId!))
              : LoginScreen(),
    );
  }
}
