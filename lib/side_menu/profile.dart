import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../animations/animations.dart';
import '../theme/theme.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  static const String routeName = '/profile';

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context).profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: scaleIn(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to EditProfilePage to allow photo update
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profile.imagePath != null
                        ? FileImage(File(profile.imagePath!))
                        : const AssetImage('assets/profile.png') as ImageProvider,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            fadeIn(
              child: Text(
                profile.name,
                style: AppTheme.textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 10),
            fadeIn(
              child: Text(
                profile.email,
                style: AppTheme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 10),
            fadeIn(
              child: Text(
                "Role: ${profile.role}",
                style: AppTheme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 10),
            fadeIn(
              child: Text(
                "Promotions: ${profile.subscribed ? 'Yes' : 'No'}",
                style: AppTheme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 20),
            slideInFromLeft(
              child: ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit Profile"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                },
              ),
            ),
            slideInFromLeft(
              child: ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Change Password"),
                onTap: () {
                  // Handle change password functionality
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
