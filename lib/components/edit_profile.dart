import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/components/profile_image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  final String userId;

  EditProfileScreen({required this.userId});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _profileImageUrl; // Profil resmi URL'si

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      _nameController.text = userProvider.name;
      _jobTitleController.text = userProvider.jobTitle ?? "";
      _bioController.text = userProvider.bio ?? "";
      _profileImageUrl = userProvider.profileImage;
    });
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.put(
      Uri.parse(
        'http://localhost:8000/api/users/update-profile/${widget.userId}',
      ), // ✅ userId URL'ye eklendi
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": _nameController.text.trim(),
        "jobTitle": _jobTitleController.text.trim(),
        "bio": _bioController.text.trim(),
        "profileImage": _profileImageUrl, // Güncellenmiş profil resmi URL'si
      }),
    );

    if (response.statusCode == 200) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserData(
        widget.userId,
      ); // Kullanıcı verilerini güncelle

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profil başarıyla güncellendi!")));

      Navigator.pop(context); // Sayfadan çık
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil güncellenemedi, tekrar deneyin.")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onProfileImageChanged(String newImageUrl) {
    setState(() {
      _profileImageUrl = newImageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profili Düzenle")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileImagePicker(
                userId: widget.userId,
                onImageChanged: _onProfileImageChanged,
                initialImageUrl: _profileImageUrl ?? "",
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Adınız"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _jobTitleController,
                decoration: InputDecoration(labelText: "Meslek / İş Ünvanı"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: "Hakkınızda",
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _updateProfile,
                    child: Text("Güncelle"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
