// providers/profile_provider.dart
import 'package:flutter/material.dart';
import '../models/profile.dart';

class ProfileProvider extends ChangeNotifier {
  Profile _profile = Profile(
    name: "User Name",
    email: "user@example.com",
    role: "User",
    subscribed: false,
    imagePath: null,
  );

  Profile get profile => _profile;

  void updateProfile({
    String? name,
    String? email,
    String? imagePath,
    String? role,
    bool? subscribed,
  }) {
    _profile = Profile(
      name: name ?? _profile.name,
      email: email ?? _profile.email,
      imagePath: imagePath ?? _profile.imagePath,
      role: role ?? _profile.role,
      subscribed: subscribed ?? _profile.subscribed,
    );
    notifyListeners();
  }
}
