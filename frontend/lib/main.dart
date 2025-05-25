import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'providers/user_provider.dart';
import 'theme/app_theme.dart'; // 🎯 Tema yönetim sınıfı
import 'screens/home_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  String? role = prefs.getString('role');
  int? sessionStartTime = prefs.getInt('sessionStartTime');
  int? savedThemeIndex = prefs.getInt('themeIndex');

  bool isSessionValid = false;
  if (sessionStartTime != null) {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    isSessionValid = currentTime - sessionStartTime < 3600000;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = AppThemeProvider();

            if (userId == null || !isSessionValid) {
              provider.setThemeForAuth();
            } else {
              if (savedThemeIndex != null) {
                provider.setTheme(AppThemeType.values[savedThemeIndex]);
              } else {
                provider.setTheme(AppThemeType.Light);
              }
            }

            return provider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.theme,
      localizationsDelegates: [
        ...GlobalMaterialLocalizations.delegates,
        quill.FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr')],
      home: Builder(
        builder: (context) {
          final prefs = SharedPreferences.getInstance();
          return FutureBuilder<SharedPreferences>(
            future: prefs,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final sp = snapshot.data!;
              final userId = sp.getString('userId');
              final role = sp.getString('role');
              final sessionStartTime = sp.getInt('sessionStartTime');
              final isSessionValid =
                  sessionStartTime != null &&
                  (DateTime.now().millisecondsSinceEpoch - sessionStartTime <
                      3600000);

              if (userId != null && isSessionValid) {
                if (role == "admin") {
                  return AdminHomeScreen(userId: userId);
                } else {
                  return HomeScreen(userId: userId);
                }
              } else {
                return LoginScreen();
              }
            },
          );
        },
      ),
    );
  }
}
