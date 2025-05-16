import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileImagePicker extends StatefulWidget {
  final String userId;
  final String initialImageUrl;
  final Function(String)
  onImageChanged; // Profil resmini değiştirmek için callback

  ProfileImagePicker({
    required this.userId,
    required this.initialImageUrl,
    required this.onImageChanged,
  });

  @override
  _ProfileImagePickerState createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _selectedImage;
  Uint8List? _webImageBytes;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _isUploading
            ? CircularProgressIndicator()
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
            : widget.initialImageUrl.isNotEmpty
            ? CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(widget.initialImageUrl),
            )
            : CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/default_avatar.png'),
            ),
        SizedBox(height: 10),
        TextButton(
          onPressed: _pickAndUploadImage,
          child: Text("Profil Resmini Değiştir"),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage() async {
    File? imageFile;

    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        _webImageBytes = result.files.single.bytes!;
        imageFile = File(result.files.single.name);
      }
    } else {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
      }
    }

    if (imageFile != null) {
      String? uploadedImageUrl = await _uploadProfileImage(imageFile);
      if (uploadedImageUrl != null) {
        widget.onImageChanged(uploadedImageUrl); // Yeni URL'yi geri döndür
      }
    }
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/api/users/upload-profile-image'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('profileImage', imageFile.path),
    );
    request.fields['userId'] = widget.userId;

    var response = await request.send();
    setState(() {
      _isUploading = false;
    });

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      return jsonData['imageUrl'];
    } else {
      return null;
    }
  }
}
