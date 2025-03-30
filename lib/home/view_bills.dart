import 'package:flutter/material.dart';

class ViewBillsScreen extends StatelessWidget {
  static const String routeName = '/view-bills';

  const ViewBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Bills"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            ListTile(
              leading: Icon(Icons.payment),
              title: Text("Electricity Bill"),
              subtitle: Text("Due: Feb 25"),
              trailing: Text("₹50"),
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text("Water Bill"),
              subtitle: Text("Due: Feb 28"),
              trailing: Text("₹30"),
            ),
          ],
        ),
      ),
    );
  }
}
