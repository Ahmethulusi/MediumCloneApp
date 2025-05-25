import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ThemeCreateScreen extends StatefulWidget {
  @override
  _ThemeCreateScreenState createState() => _ThemeCreateScreenState();
}

class _ThemeCreateScreenState extends State<ThemeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Color controllers with default values
  final Map<String, TextEditingController> _colorControllers = {
    'primaryColor': TextEditingController(text: '#2196F3'),
    'scaffoldBackgroundColor': TextEditingController(text: '#FFFFFF'),
    'appBarColor': TextEditingController(text: '#2196F3'),
    'bottomNavSelected': TextEditingController(text: '#2196F3'),
    'bottomNavUnselected': TextEditingController(text: '#757575'),
    'cardColor': TextEditingController(text: '#F5F5F5'),
    'buttonBackground': TextEditingController(text: '#2196F3'),
    'tabSelected': TextEditingController(text: '#2196F3'),
    'tabUnselected': TextEditingController(text: '#BDBDBD'),
    'inputFill': TextEditingController(text: '#F5F5F5'),
    'textColor': TextEditingController(text: '#212121'),
  };

  Future<void> _createTheme() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final newTheme = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'isDefault': false,
        'createdBy': 'user123', // This would typically be the logged-in user ID
        'components': {
          for (var entry in _colorControllers.entries)
            entry.key: entry.value.text,
        },
      };

      final response = await http.post(
        Uri.parse('http://localhost:8000/api/themes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newTheme),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true); // Return true to indicate refresh needed
      } else {
        _showErrorSnackBar('Failed to create theme');
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
        title: Text('Create New Theme'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _isSaving ? null : _createTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Theme Name',
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Color Previews
              Container(
                height: 100,
                margin: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: _hexToColor(
                    _colorControllers['scaffoldBackgroundColor']!.text,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      color: _hexToColor(
                        _colorControllers['appBarColor']!.text,
                      ),
                      child: Center(
                        child: Text(
                          'App Bar Preview',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _hexToColor(
                              _colorControllers['buttonBackground']!.text,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Button',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Color selection tiles
              ..._buildColorTiles(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSaving ? null : _createTheme,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child:
                        _isSaving
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('CREATE THEME'),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
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
                      Text(name, style: TextStyle(fontWeight: FontWeight.w500)),
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

  // Template themes to quickly apply presets
  List<Map<String, String>> get _themeTemplates => [
    {
      'name': 'Light Theme',
      'primaryColor': '#2196F3',
      'scaffoldBackgroundColor': '#FFFFFF',
      'appBarColor': '#2196F3',
      'bottomNavSelected': '#2196F3',
      'bottomNavUnselected': '#757575',
      'cardColor': '#F5F5F5',
      'buttonBackground': '#2196F3',
      'tabSelected': '#2196F3',
      'tabUnselected': '#BDBDBD',
      'inputFill': '#F5F5F5',
      'textColor': '#212121',
    },
    {
      'name': 'Dark Theme',
      'primaryColor': '#BB86FC',
      'scaffoldBackgroundColor': '#121212',
      'appBarColor': '#1F1F1F',
      'bottomNavSelected': '#BB86FC',
      'bottomNavUnselected': '#757575',
      'cardColor': '#1F1F1F',
      'buttonBackground': '#BB86FC',
      'tabSelected': '#BB86FC',
      'tabUnselected': '#757575',
      'inputFill': '#2C2C2C',
      'textColor': '#E1E1E1',
    },
    {
      'name': 'Teal Theme',
      'primaryColor': '#009688',
      'scaffoldBackgroundColor': '#FFFFFF',
      'appBarColor': '#009688',
      'bottomNavSelected': '#009688',
      'bottomNavUnselected': '#757575',
      'cardColor': '#F5F5F5',
      'buttonBackground': '#009688',
      'tabSelected': '#009688',
      'tabUnselected': '#BDBDBD',
      'inputFill': '#F5F5F5',
      'textColor': '#212121',
    },
  ];

  // Function to apply a template theme (not shown in UI, but could be added)
  void _applyTemplate(Map<String, String> template) {
    _nameController.text = '${template['name']} Copy';

    template.forEach((key, value) {
      if (key != 'name' && _colorControllers.containsKey(key)) {
        _colorControllers[key]!.text = value;
      }
    });

    setState(() {});
  }
}
