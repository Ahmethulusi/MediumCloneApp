// theme_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'admin_edit_theme.dart';
import 'admin_new_theme.dart';

class Theme {
  final String id;
  final String name;
  final String description;
  final bool isDefault;
  final String createdBy;
  final ThemeComponents components;

  Theme({
    required this.id,
    required this.name,
    required this.description,
    required this.isDefault,
    required this.createdBy,
    required this.components,
  });

  factory Theme.fromJson(Map<String, dynamic> json) {
    return Theme(
      id: json['_id'],
      name: json['name'],
      description: json['description'] ?? '',
      isDefault: json['isDefault'] ?? false,
      createdBy: json['createdBy'] ?? 'admin',
      components: ThemeComponents.fromJson(json['components']),
    );
  }
}

class ThemeComponents {
  final String primaryColor;
  final String scaffoldBackgroundColor;
  final String appBarColor;
  final String bottomNavSelected;
  final String bottomNavUnselected;
  final String cardColor;
  final String buttonBackground;
  final String tabSelected;
  final String tabUnselected;
  final String inputFill;
  final String textColor;

  ThemeComponents({
    required this.primaryColor,
    required this.scaffoldBackgroundColor,
    required this.appBarColor,
    required this.bottomNavSelected,
    required this.bottomNavUnselected,
    required this.cardColor,
    required this.buttonBackground,
    required this.tabSelected,
    required this.tabUnselected,
    required this.inputFill,
    required this.textColor,
  });

  factory ThemeComponents.fromJson(Map<String, dynamic> json) {
    return ThemeComponents(
      primaryColor: json['primaryColor'],
      scaffoldBackgroundColor: json['scaffoldBackgroundColor'],
      appBarColor: json['appBarColor'],
      bottomNavSelected: json['bottomNavSelected'],
      bottomNavUnselected: json['bottomNavUnselected'],
      cardColor: json['cardColor'],
      buttonBackground: json['buttonBackground'],
      tabSelected: json['tabSelected'],
      tabUnselected: json['tabUnselected'],
      inputFill: json['inputFill'],
      textColor: json['textColor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor,
      'scaffoldBackgroundColor': scaffoldBackgroundColor,
      'appBarColor': appBarColor,
      'bottomNavSelected': bottomNavSelected,
      'bottomNavUnselected': bottomNavUnselected,
      'cardColor': cardColor,
      'buttonBackground': buttonBackground,
      'tabSelected': tabSelected,
      'tabUnselected': tabUnselected,
      'inputFill': inputFill,
      'textColor': textColor,
    };
  }
}

// API Service for themes
class ThemeService {
  final String baseUrl = 'http://localhost:8000/api/themes';

  Future<List<Theme>> getThemes() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> themesJson = jsonDecode(response.body);
      return themesJson.map((json) => Theme.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load themes');
    }
  }
}

class ThemeListScreen extends StatefulWidget {
  @override
  _ThemeListScreenState createState() => _ThemeListScreenState();
}

class _ThemeListScreenState extends State<ThemeListScreen> {
  late Future<List<Theme>> futureThemes;
  final ThemeService _themeService = ThemeService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    futureThemes = _themeService.getThemes();
  }

  void _refreshThemes() {
    setState(() {
      futureThemes = _themeService.getThemes();
    });
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Theme Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThemeCreateScreen()),
              );
              if (result == true) {
                _refreshThemes();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Theme>>(
        future: futureThemes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No themes available'));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final theme = snapshot.data![index];
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ThemeEditScreen(themeId: theme.id),
                      ),
                    );
                    if (result == true) {
                      _refreshThemes();
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: hexToColor(theme.components.primaryColor),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  theme.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  theme.description,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          if (theme.isDefault)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Default',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          SizedBox(width: 8),
                          Icon(Icons.palette, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.palette), label: 'Themes'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
