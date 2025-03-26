// lib/assets_tab/assets_screen.dart
import 'package:flutter/material.dart';
import 'assets_widgets.dart';
import '../home/bottom_navbar.dart';
import 'add_asset.dart';
import '../animations/animations.dart'; // Import animations
import '../animations/transitions.dart'; // Import transitions

class AssetsScreen extends StatelessWidget {
  static const String routeName = '/assets';

  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Assets"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fadeIn(child: const TotalAssetsSection()),
              const SizedBox(height: 16),
              slideInFromBottom(child: const PieChartSection()),
              const SizedBox(height: 16),
              scaleIn(child: const AssetGrowthGraphSection()),
              const SizedBox(height: 16),
              slideInFromLeft(child: const RecentAssetsSection()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            slideUpTransition(const AddAssetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
