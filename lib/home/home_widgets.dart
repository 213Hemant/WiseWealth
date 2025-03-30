import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisewealth/providers/profile_provider.dart';
import 'package:wisewealth/providers/asset_provider.dart';
import 'package:wisewealth/providers/transaction_provider.dart';
import './add_expense.dart';
import './view_bills.dart';
import '../animations/animations.dart'; // Import reusable animations
import '../animations/transitions.dart';

/// Header section displays a greeting and the user's net worth.
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user's name from ProfileProvider and net worth from AssetProvider.
    final profile = Provider.of<ProfileProvider>(context).profile;
    final netWorth = Provider.of<AssetProvider>(context).totalAssets;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning, ${profile.name}!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Net Worth: ₹${netWorth.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}

/// Spending summary section calculates the expense for the current month and shows progress.
class SpendingSummarySection extends StatelessWidget {
  const SpendingSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final txnProvider = Provider.of<TransactionProvider>(context);
    // Filter expenses for current month and year.
    final now = DateTime.now();
    final monthExpenses = txnProvider.transactions
        .where((txn) =>
            txn.type == "Expense" &&
            txn.date.month == now.month &&
            txn.date.year == now.year)
        .fold(0.0, (prev, txn) => prev + txn.amount);
    // Use the provider's budget if available; otherwise, default to 1000.
    final budget = txnProvider.budget;
    final double spentPercent = (budget > 0) ? (monthExpenses / budget).clamp(0, 1) : 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "Spent this Month: ₹${monthExpenses.toStringAsFixed(2)} / ₹${budget.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Text(
                  "${(spentPercent * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: spentPercent,
              color: Colors.blueAccent,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            // For demo, bills due are statically calculated.
            const Text(
              "2 Bills Due This Week",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Buttons section with navigation to add expense and view bills.
class ButtonsSection extends StatelessWidget {
  const ButtonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              slideUpTransition(const AddExpenseScreen()),
            );
          },
          child: const Text("Add Expense"),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              slideUpTransition(const ViewBillsScreen()),
            );
          },
          child: const Text("View Bills"),
        ),
      ],
    );
  }
}
