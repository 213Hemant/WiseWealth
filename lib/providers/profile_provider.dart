// lib/providers/profile_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  /// Updates local profile state and syncs the changes to Firestore.
  Future<void> updateProfile({
    String? name,
    String? email,
    String? imagePath,
    String? role,
    bool? subscribed,
  }) async {
    _profile = Profile(
      name: name ?? _profile.name,
      email: email ?? _profile.email,
      imagePath: imagePath ?? _profile.imagePath,
      role: role ?? _profile.role,
      subscribed: subscribed ?? _profile.subscribed,
    );
    notifyListeners();

    await _syncProfileToFirestore();
  }

  /// PRIVATE: Syncs the profile to Firestore.
  Future<void> _syncProfileToFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create or update the user document in Firestore.
        final docRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        await docRef.set({
          'name': _profile.name,
          'email': _profile.email,
          'imagePath': _profile.imagePath,
          'role': _profile.role,
          'subscribed': _profile.subscribed,
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error syncing profile: $e");
    }
  }
}
