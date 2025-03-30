// lib/goals/goals_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'goals_widgets.dart';
import 'new_goal_screen.dart';
import '../home/bottom_navbar.dart';
import '../animations/animations.dart'; // Import reusable animations
import '../animations/transitions.dart'; // Import reusable animations
import '../providers/goal_provider.dart';

class GoalsScreen extends StatelessWidget {
  static const String routeName = '/goals';

  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure that GoalProvider is accessible.
    final goalProvider = Provider.of<GoalProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Goals"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Goals Summary Section with a fade-in effect
            fadeIn(child: const GoalsSummarySection()),
            const SizedBox(height: 16),
            // Active Goals Section slides in from bottom
            slideInFromBottom(child: const ActiveGoalsSection()),
            const SizedBox(height: 16),
            // Completed Goals Section scales in
            scaleIn(child: const CompletedGoalsSection()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            slideUpTransition(const NewGoalScreen()),
          );
        },
        label: const Text("Add Goal"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}
