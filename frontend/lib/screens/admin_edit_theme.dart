import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ThemeEditScreen extends StatefulWidget {
  final String themeId;

  ThemeEditScreen({required this.themeId});

  @override
  _ThemeEditScreenState createState() => _ThemeEditScreenState();
}

class _ThemeEditScreenState extends State<ThemeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  late Map<String, dynamic> _themeData;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Color controllers
  final Map<String, TextEditingController> _colorControllers = {
    'primaryColor': TextEditingController(),
    'scaffoldBackgroundColor': TextEditingController(),
    'appBarColor': TextEditingController(),
    'bottomNavSelected': TextEditingController(),
    'bottomNavUnselected': TextEditingController(),
    'cardColor': TextEditingController(),
    'buttonBackground': TextEditingController(),
    'tabSelected': TextEditingController(),
    'tabUnselected': TextEditingController(),
    'inputFill': TextEditingController(),
    'textColor': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _fetchTheme();
  }

  Future<void> _fetchTheme() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/themes/${widget.themeId}'),
      );

      if (response.statusCode == 200) {
        final themeData = jsonDecode(response.body);
        setState(() {
          _themeData = themeData;
          _isLoading = false;

          // Set initial values
          _nameController.text = themeData['name'];
          _descriptionController.text = themeData['description'] ?? '';

          // Set color values
          final components = themeData['components'];
          if (components != null) {
            components.forEach((key, value) {
              if (_colorControllers.containsKey(key)) {
                _colorControllers[key]!.text = value;
              }
            });
          }
        });
      } else {
        _showErrorSnackBar('Failed to load theme');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _saveTheme() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedTheme = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'isDefault': _themeData['isDefault'],
        'components': {
          for (var entry in _colorControllers.entries)
            entry.key: entry.value.text,
        },
      };

      final response = await http.put(
        Uri.parse('http://localhost:8000/api/themes/${widget.themeId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedTheme),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Return true to indicate refresh needed
      } else {
        _showErrorSnackBar('Failed to update theme');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteTheme() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Theme'),
            content: Text('Are you sure you want to delete this theme?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('DELETE'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await http.delete(
        Uri.parse('http://your-api-url.com/api/themes/${widget.themeId}'),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Return true to indicate refresh needed
      } else {
        _showErrorSnackBar('Failed to delete theme');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showColorPicker(String colorKey, String colorName) async {
    final controller = _colorControllers[colorKey]!;
    Color pickerColor = _hexToColor(controller.text);
    Color currentColor = pickerColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick color for $colorName'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                // Convert the selected color to hex format
                final hexColor =
                    '#${pickerColor.value.toRadixString(16).substring(2)}';
                controller.text = hexColor.toUpperCase();
                Navigator.of(context).pop();
                // You might also want to trigger a state update here
                setState(() {});
              },
              child: const Text('SELECT'),
            ),
          ],
        );
      },
    );
  }

  Color _hexToColor(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('0xFF$hexColor'));
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Theme'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _isLoading ? null : _deleteTheme,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isLoading || _isSaving ? null : _saveTheme,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          // labelText: 'Theme Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a theme name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Theme Colors',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Color selection tiles
                      ..._buildColorTiles(),
                    ],
                  ),
                ),
              ),
    );
  }

  List<Widget> _buildColorTiles() {
    final colorNames = {
      'primaryColor': 'Primary Color',
      'scaffoldBackgroundColor': 'Background Color',
      'appBarColor': 'App Bar Color',
      'bottomNavSelected': 'Bottom Nav Selected',
      'bottomNavUnselected': 'Bottom Nav Unselected',
      'cardColor': 'Card Color',
      'buttonBackground': 'Button Color',
      'tabSelected': 'Tab Selected',
      'tabUnselected': 'Tab Unselected',
      'inputFill': 'Input Field Color',
      'textColor': 'Text Color',
    };

    return colorNames.entries.map((entry) {
      final key = entry.key;
      final name = entry.value;
      final controller = _colorControllers[key]!;

      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _showColorPicker(key, name),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hexToColor(controller.text),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        controller.text,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit, color: Colors.grey),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
