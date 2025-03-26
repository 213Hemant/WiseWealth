// lib/assets_tab/add_asset.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asset_provider.dart';
import '../models/asset.dart';
import 'assets_screen.dart';
import 'package:wisewealth/animations/transitions.dart';

class AddAssetScreen extends StatefulWidget {
  static const String routeName = '/add-asset';

  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  String _selectedType = "Real Estate";

  // Mapping asset type to icon.
  final Map<String, IconData> _assetTypeIcons = {
    "Real Estate": Icons.home,
    "Investment": Icons.trending_up,
    "Cash": Icons.money,
    "Other": Icons.account_balance_wallet,
  };

  @override
  Widget build(BuildContext context) {
    final assetProvider = Provider.of<AssetProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Asset"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form to add asset.
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Asset Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter asset name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _valueController,
                    decoration: const InputDecoration(
                      labelText: "Asset Value (INR)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter asset value";
                      }
                      if (double.tryParse(value) == null) {
                        return "Enter a valid number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: "Asset Type",
                      border: OutlineInputBorder(),
                    ),
                    items: _assetTypeIcons.keys.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_assetTypeIcons[type]),
                            const SizedBox(width: 8),
                            Text(type),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final asset = Asset(
                          name: _nameController.text,
                          value: double.parse(_valueController.text),
                          type: _selectedType,
                        );
                        assetProvider.addAsset(asset);
                        // Clear fields for next entry.
                        _nameController.clear();
                        _valueController.clear();
                        setState(() {
                          _selectedType = "Real Estate";
                        });
                        // Navigate back to AssetsScreen to see the updated list.
                        Navigator.pushReplacement(
                          context,
                          slideDownTransition(const AssetsScreen()),
                        );
                      }
                    },
                    child: const Text("Add Asset"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // List of added assets with removal functionality.
            Expanded(
              child: ListView.builder(
                itemCount: assetProvider.assets.length,
                itemBuilder: (context, index) {
                  final asset = assetProvider.assets[index];
                  return ListTile(
                    leading: Icon(_assetTypeIcons[asset.type] ?? Icons.wallet),
                    title: Text(asset.name),
                    subtitle: Text("₹${asset.value.toStringAsFixed(2)}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Ask for confirmation before deletion.
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: const Text(
                                  "Are you sure you want to delete this asset?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          assetProvider.removeAsset(asset);
                          // After deletion, redirect back to AssetsScreen.
                          Navigator.pushReplacement(
                            context,
                            slideDownTransition(const AssetsScreen()),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
