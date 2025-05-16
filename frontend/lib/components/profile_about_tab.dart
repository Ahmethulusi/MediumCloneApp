import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class UserProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      children: [
        // 👤 Profil Fotoğrafı
        // CircleAvatar(
        //   radius: 50,
        //   backgroundImage:
        //       userProvider.profileImage.isNotEmpty
        //           ? NetworkImage(userProvider.profileImage)
        //           : AssetImage('assets/default_avatar.png') as ImageProvider,
        // ),
        // SizedBox(height: 10),

        // // 📛 İsim
        // Text(
        //   userProvider.name,
        //   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        // ),

        // 💼 Ünvan
        SizedBox(height: 50),

        // if (userProvider.jobTitle != null &&
        //     userProvider.jobTitle.trim().isNotEmpty)
        //   Text(
        //     userProvider.jobTitle,
        //     style: TextStyle(color: Colors.grey[900], fontSize: 14),
        //   ),

        // SizedBox(height: 8),

        // 📄 Biyografi
        if (userProvider.bio != null && userProvider.bio.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              userProvider.bio,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          )
        else
          Text(
            "Henüz biyografi eklenmemiş.",
            style: TextStyle(color: Colors.grey),
          ),

        SizedBox(height: 20),
      ],
    );
  }
}
