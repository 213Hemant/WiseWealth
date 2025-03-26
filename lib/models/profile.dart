// models/profile.dart
class Profile {
  String name;
  String email;
  String? imagePath; // local path to image picked from gallery
  String role; // example dropdown: could be 'Admin', 'User', etc.
  bool subscribed; // example checkbox for subscription

  Profile({
    required this.name,
    required this.email,
    this.imagePath,
    required this.role,
    required this.subscribed,
  });
}
