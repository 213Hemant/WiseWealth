import 'package:flutter/material.dart';
import 'dart:io';  // Add this import
import 'package:provider/provider.dart';
import '../animations/animations.dart';
import '../animations/transitions.dart';
import '../side_menu/profile.dart';
import '../side_menu/about.dart';
import '../side_menu/news.dart'; // Import NewsPage
import '../providers/profile_provider.dart'; // Import the ProfileProvider

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // DrawerHeader with dynamic profile photo
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Use Consumer to listen to ProfileProvider and update the UI when the profile changes
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    final profile = profileProvider.profile;
                    return scaleIn(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: profile.imagePath != null
                            ? FileImage(File(profile.imagePath!))
                            : const AssetImage('assets/profile.png') as ImageProvider,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                fadeIn(
                  child: const Text(
                    "Welcome, User!",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          slideInFromLeft(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(fadeTransition(ProfilePage()));
              },
            ),
          ),
          slideInFromLeft(
            child: ListTile(
              leading: const Icon(Icons.article),
              title: const Text("Finance News"),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(fadeTransition(NewsPage()));
              },
            ),
          ),
          slideInFromLeft(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(fadeTransition(AboutPage()));
              },
            ),
          ),
          slideInFromLeft(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/splash');
              },
            ),
          ),
        ],
      ),
    );
  }
}
