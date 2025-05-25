import 'package:flutter/material.dart';

ImageProvider getProfileImage(String? profileImage) {
  const baseUrl = 'http://192.168.1.10:8000'; // cihaz IP adresin
  const defaultImage = AssetImage('assets/default_avatar.png');

  if (profileImage == null || profileImage.isEmpty) {
    return defaultImage;
  }
  print("Gelenk kullanıcı veriri: " + profileImage);
  final isFullUrl = profileImage.startsWith("http");
  return NetworkImage(isFullUrl ? profileImage : "$baseUrl$profileImage");
}
