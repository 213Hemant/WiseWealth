import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../assets_tab/assets_screen.dart';
import '../transactions/transactions_screen.dart';
import '../goals/goals_screen.dart';
import '../animations/transitions.dart'; // Import transitions
import '../auth/biometric_helper.dart'; // Import the corrected BiometricHelper

class BottomNavBar extends StatefulWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final BiometricHelper _biometricHelper = BiometricHelper();

  // This function is triggered when a tab is tapped
  void _onTabTapped(BuildContext context, int index) async {
    if (index == widget.currentIndex) return; // If the same tab is tapped, do nothing

    // Handle the authentication when tapping the Goals tab (index 3)
    if (index == 3) {
      bool authenticated = await _biometricHelper.authenticateWithBiometrics();
      if (authenticated) {
        _navigateToTab(context, index);
      } else {
        // If authentication fails, show a more descriptive message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Authentication failed. Please try again.")),
        );
      }
    } else {
      _navigateToTab(context, index);
    }
  }

  // This function handles the navigation to the selected tab
  void _navigateToTab(BuildContext context, int index) {
    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeScreen();
        break;
      case 1:
        nextScreen = const AssetsScreen();
        break;
      case 2:
        nextScreen = const TransactionsScreen();
        break;
      case 3:
        nextScreen = const GoalsScreen();
        break;
      default:
        return;
    }

    // Determine the transition direction
    bool slideFromRight = index > widget.currentIndex;

    Navigator.pushReplacement(
      context,
      slideTabTransition(nextScreen, fromRight: slideFromRight),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) => _onTabTapped(context, index), // Use the new onTap handler
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance),
          label: "Assets",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: "Transactions",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flag),
          label: "Goals",
        ),
      ],
    );
  }
}
