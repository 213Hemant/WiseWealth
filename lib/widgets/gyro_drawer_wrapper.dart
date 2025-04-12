// lib/widgets/gyro_drawer_wrapper.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/auth_service.dart';
import '../home/side_menu.dart';

class GyroDrawerWrapper extends StatefulWidget {
  final Widget child;

  /// [child] is the content of the main tab screen.
  const GyroDrawerWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _GyroDrawerWrapperState createState() => _GyroDrawerWrapperState();
}

class _GyroDrawerWrapperState extends State<GyroDrawerWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription? _gyroSubscription;

  @override
  void initState() {
    super.initState();
    // Check if a user is logged in using your AuthService
    bool isLoggedIn = AuthService().currentUser != null;
    if (isLoggedIn) {
      _gyroSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
        // event.y > threshold implies a left-to-right tilt.
        // Adjust the threshold as necessary.
        if (event.y > 3.0 && !(_scaffoldKey.currentState?.isDrawerOpen ?? false)) {
          _scaffoldKey.currentState?.openDrawer();
        }
      });
    }
  }

  @override
  void dispose() {
    _gyroSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideMenu(),
      body: widget.child,
    );
  }
}
