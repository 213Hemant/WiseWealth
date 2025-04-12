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
  bool _isDrawerOpen = false;
  final double _openThreshold = 3.0;
  final double _closeThreshold = -3.0;
  DateTime _lastTriggerTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    bool isLoggedIn = AuthService().currentUser != null;

    if (isLoggedIn) {
      _gyroSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
        final now = DateTime.now();

        // Debounce gesture every 500ms
        if (now.difference(_lastTriggerTime).inMilliseconds < 500) return;

        if (event.y > _openThreshold && !_isDrawerOpen) {
          _scaffoldKey.currentState?.openDrawer();
          _isDrawerOpen = true;
          _lastTriggerTime = now;
        } else if (event.y < _closeThreshold && _isDrawerOpen) {
          Navigator.of(context).pop(); // closes the drawer
          _isDrawerOpen = false;
          _lastTriggerTime = now;
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
      onDrawerChanged: (isOpened) {
        // Keeps track of drawer state
        _isDrawerOpen = isOpened;
      },
      body: widget.child,
    );
  }
}
