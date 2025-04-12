import 'package:flutter/material.dart';
import '../widgets/gyro_drawer_wrapper.dart';
import 'home_widgets.dart';
import 'bottom_navbar.dart';
import 'side_menu.dart';
import '../animations/animations.dart'; // Adjust path as needed

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GyroDrawerWrapper(
      child: Scaffold(
      appBar: AppBar(
        title: const Text("Finance Manager"),
        centerTitle: true,
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section with fade-in animation.
              fadeIn(child: const HeaderSection()),
              const SizedBox(height: 16),
              // Spending Summary Section with slide-in from bottom animation.
              slideInFromBottom(child: const SpendingSummarySection()),
              const SizedBox(height: 16),
              // Buttons Section with scale-in animation.
              scaleIn(child: const ButtonsSection()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    ),
    );
  }
}
