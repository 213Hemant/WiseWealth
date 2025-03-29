import 'package:flutter/material.dart';
import '../animations/animations.dart';
import '../animations/transitions.dart';
import '../side_menu/profile.dart';
import '../side_menu/about.dart';
import '../side_menu/news.dart'; // Import NewsPage

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                scaleIn(
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
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