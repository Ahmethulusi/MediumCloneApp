import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/user_provider.dart';

class ProfileImagePicker extends StatefulWidget {
  final String userId;

  ProfileImagePicker({required this.userId});

  @override
  _ProfileImagePickerState createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _selectedImage;
  Uint8List? _webImageBytes;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    String profileImageUrl =
        userProvider.profileImage; // Backend'den gelen güncellenmiş URL

    return Column(
      children: [
        _isUploading
            ? CircularProgressIndicator()
            : profileImageUrl
                .isNotEmpty // Eğer güncellenmiş resim varsa göster
            ? CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profileImageUrl),
              onBackgroundImageError: (_, __) {
                // 🛠️ Hata yakalama
                print("❌ Profil resmi yüklenemedi: $profileImageUrl");
              },
            )
            : _webImageBytes != null
            ? CircleAvatar(
              radius: 50,
              backgroundImage: MemoryImage(_webImageBytes!),
            )
            : _selectedImage != null
            ? CircleAvatar(
              radius: 50,
              backgroundImage: FileImage(_selectedImage!),
            )
            : CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/default_avatar.png'),
            ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () {
            print("🟢 Butona basıldı, resim yükleme işlemi başlatılıyor...");
            _pickAndUploadImage();
          },
          child: Text("Profil Resmini Değiştir"),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage() async {
    print("🟢 Resim seçme işlemi başladı...");
    File? imageFile;

    if (kIsWeb) {
      print("🌍 Web platformunda çalışıyor...");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        print("✅ Web için seçilen resim: ${result.files.single.name}");
        setState(() {
          _webImageBytes = result.files.single.bytes!;
          _selectedImage = null;
        });

        String? uploadedImageUrl = await uploadProfileImageWeb(
          _webImageBytes!,
          result.files.single.name,
        );
        if (uploadedImageUrl != null) {
          Provider.of<UserProvider>(
            context,
            listen: false,
          ).updateProfileImage(uploadedImageUrl);
        }
      }
    } else {
      print("📱 Mobil platformda çalışıyor...");
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        print("✅ Mobil için seçilen resim: ${pickedFile.path}");
        setState(() {
          _selectedImage = File(pickedFile.path);
          _webImageBytes = null;
        });

        String? uploadedImageUrl = await uploadProfileImage(_selectedImage!);
        if (uploadedImageUrl != null) {
          Provider.of<UserProvider>(
            context,
            listen: false,
          ).updateProfileImage(uploadedImageUrl);
        }
      }
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      setState(() {
        _isUploading = true;
      });

      print("🚀 Mobil için resim yükleme başlatıldı...");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8000/api/users/upload-profile-image'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('profileImage', imageFile.path),
      );
      request.fields['userId'] = widget.userId;

      print("🚀 HTTP isteği gönderiliyor...");
      var response = await request.send();
      print("📩 Sunucu yanıtı: ${response.statusCode}");

      setState(() {
        _isUploading = false;
      });

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        print("✅ Resim başarıyla yüklendi: ${jsonData['imageUrl']}");
        return jsonData['imageUrl'];
      } else {
        print("❌ Resim yükleme başarısız!");
        return null;
      }
    } catch (e) {
      print("🚨 HATA: $e");
      setState(() {
        _isUploading = false;
      });
      return null;
    }
  }

  Future<String?> uploadProfileImageWeb(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      setState(() {
        _isUploading = true;
      });

      print("🚀 Web için resim yükleme başlatılıyor...");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8000/api/users/upload-profile-image'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'profileImage',
          fileBytes,
          filename: fileName,
        ),
      );

      request.fields['userId'] = widget.userId;

      print("🚀 HTTP isteği gönderiliyor...");
      var response = await request.send();
      print("📩 Sunucu yanıtı: ${response.statusCode}");

      setState(() {
        _isUploading = false;
      });

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        print("✅ Resim başarıyla yüklendi: ${jsonData['imageUrl']}");
        return jsonData['imageUrl'];
      } else {
        print("❌ Resim yükleme başarısız!");
        return null;
      }
    } catch (e) {
      print("🚨 HATA: $e");
      setState(() {
        _isUploading = false;
      });
      return null;
    }
  }
}
