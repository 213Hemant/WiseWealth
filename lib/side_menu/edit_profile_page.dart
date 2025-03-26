// screens/edit_profile_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _selectedRole = "User";
  bool _subscribed = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _selectedRole = profile.role;
    _subscribed = profile.subscribed;
    _imagePath = profile.imagePath;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      Provider.of<ProfileProvider>(context, listen: false).updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole,
        subscribed: _subscribed,
        imagePath: _imagePath,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imagePath != null
                        ? FileImage(File(_imagePath!))
                        : const AssetImage('assets/profile.png')
                            as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Please enter a name" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Please enter an email" : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: "User", child: Text("User")),
                  DropdownMenuItem(value: "Employee", child: Text("Employee")),
                  DropdownMenuItem(value: "Entrepreneur", child: Text("Entrepreneur")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value ?? "User";
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Role",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text("Receive additional updates"),
                value: _subscribed,
                onChanged: (value) {
                  setState(() {
                    _subscribed = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
