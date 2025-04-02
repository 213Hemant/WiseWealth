import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';

/// Summary section showing overall goals data.
class GoalsSummarySection extends StatelessWidget {
  const GoalsSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Using Table to automatically allocate space without truncation.
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Total Goals: ${goalProvider.totalGoals}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "${goalProvider.completedGoals} Completed",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Overall Progress: ${(goalProvider.overallProgress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Remaining: ₹${goalProvider.remainingAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: goalProvider.overallProgress,
              minHeight: 8,
              color: Colors.green,
              backgroundColor: const Color.fromARGB(89, 129, 245, 133),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section displaying active goals.
class ActiveGoalsSection extends StatelessWidget {
  const ActiveGoalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, _) {
        final activeGoals =
            goalProvider.goals.where((goal) => !goal.isCompleted).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Active Goals",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (activeGoals.isNotEmpty)
              ...activeGoals
                  .map((goal) => ActiveGoalItem(goal: goal))
                  .toList()
            else
              const Text("No active goals."),
          ],
        );
      },
    );
  }
}

/// Widget for an individual active goal with action buttons and two progress bars.
class ActiveGoalItem extends StatelessWidget {
  final Goal goal;
  const ActiveGoalItem({super.key, required this.goal});

  // Calculate time consumed progress.
  // Here we assume a default plan period of 30 days ending at targetDate.
  double _calculateTimeProgress() {
    final now = DateTime.now();
    final target = goal.targetDate;
    // Assume the goal started 30 days before target date.
    final start = target.subtract(const Duration(days: 30));
    if (now.isBefore(start)) return 0;
    if (now.isAfter(target)) return 1;
    return now.difference(start).inDays / 30;
  }

  @override
  Widget build(BuildContext context) {
    final timeProgress = _calculateTimeProgress();
    final double progressTaken = (goal.savedAmount / goal.targetAmount).clamp(0, 1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with goal title and target amount
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "Target: ₹${goal.targetAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Display saved amount and target date
            Text(
              "Saved: ₹${goal.savedAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              "Target Date: ${goal.targetDate.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            // Two progress bars: Time consumed and progress taken
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Time Consumed",
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: timeProgress,
                  minHeight: 6,
                  color: Colors.orange,
                  backgroundColor: Colors.orange.shade100,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Progress",
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progressTaken,
                  minHeight: 6,
                  color: Colors.blue,
                  backgroundColor: Colors.blue.shade100,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Action buttons: Update Progress, Mark Complete, Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Update"),
                  onPressed: () {
                    _showUpdateProgressDialog(context, goal);
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text("Complete"),
                  onPressed: () async {
                    // Check if goal progress is less than 100%
                    if (progressTaken < 1) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Confirm Completion"),
                          content: const Text(
                              "Your goal progress is not 100%. Do you want to mark this goal as complete anyway? This will update the saved amount to the target amount."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text("Confirm",
                                  style: TextStyle(color: Colors.green)),
                            ),
                          ],
                        ),
                      );
                      if (confirm != true) return;
                      final updatedGoal = Goal(
                        id: goal.id,
                        name: goal.name,
                        targetAmount: goal.targetAmount,
                        savedAmount: goal.targetAmount,
                        targetDate: goal.targetDate,
                        isCompleted: true,
                      );
                      await Provider.of<GoalProvider>(context, listen: false)
                          .updateGoal(updatedGoal);
                    } else {
                      final updatedGoal = Goal(
                        id: goal.id,
                        name: goal.name,
                        targetAmount: goal.targetAmount,
                        savedAmount: goal.savedAmount,
                        targetDate: goal.targetDate,
                        isCompleted: true,
                      );
                      await Provider.of<GoalProvider>(context, listen: false)
                          .updateGoal(updatedGoal);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmDelete(context, goal);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dialog to update saved amount (goal progress)
  void _showUpdateProgressDialog(BuildContext context, Goal goal) {
    final _progressController =
        TextEditingController(text: goal.savedAmount.toString());
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Update Progress"),
          content: TextField(
            controller: _progressController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "New saved amount"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final newValue = double.tryParse(_progressController.text);
                if (newValue != null) {
                  final updatedGoal = Goal(
                    id: goal.id,
                    name: goal.name,
                    targetAmount: goal.targetAmount,
                    savedAmount: newValue,
                    targetDate: goal.targetDate,
                    isCompleted: goal.isCompleted,
                  );
                  await Provider.of<GoalProvider>(context, listen: false)
                      .updateGoal(updatedGoal);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // Confirm deletion dialog.
  void _confirmDelete(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this goal?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<GoalProvider>(context, listen: false)
                  .deleteGoal(goal.id!);
              Navigator.of(ctx).pop();
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Section displaying completed goals.
class CompletedGoalsSection extends StatelessWidget {
  const CompletedGoalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, _) {
        final completedGoals =
            goalProvider.goals.where((goal) => goal.isCompleted).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Completed Goals",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (completedGoals.isNotEmpty)
              ...completedGoals
                  .map((goal) => CompletedGoalItem(goal: goal))
                  .toList()
            else
              const Text("No completed goals."),
          ],
        );
      },
    );
  }
}

/// Widget for an individual completed goal.
class CompletedGoalItem extends StatelessWidget {
  final Goal goal;
  const CompletedGoalItem({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          "${goal.name}: Completed",
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text("Target: ₹${goal.targetAmount.toStringAsFixed(2)}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Confirm Delete"),
                content: const Text("Are you sure you want to delete this goal?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Provider.of<GoalProvider>(context, listen: false)
                          .deleteGoal(goal.id!);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
