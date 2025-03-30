// lib/goals/new_goal_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'goals_screen.dart';
import 'package:wisewealth/animations/transitions.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';

class NewGoalScreen extends StatefulWidget {
  const NewGoalScreen({super.key});

  @override
  State<NewGoalScreen> createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Goal"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Goal Name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _goalNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter goal name",
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter goal name" : null,
              ),
              const SizedBox(height: 16),
              const Text(
                "Target Amount",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter target amount",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter target amount";
                  if (double.tryParse(value) == null) return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                },
                child: Text(_selectedDate == null
                    ? "Select Target Date"
                    : "Target Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _selectedDate != null) {
                    final newGoal = Goal(
                      name: _goalNameController.text,
                      targetAmount: double.parse(_targetAmountController.text),
                      savedAmount: 0, // Initially, no savings.
                      targetDate: _selectedDate!,
                    );
                    await goalProvider.addGoal(newGoal);
                    Navigator.pushReplacement(
                      context,
                      slideDownTransition(const GoalsScreen()),
                    );
                  }
                },
                child: const Text("Add Goal"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
