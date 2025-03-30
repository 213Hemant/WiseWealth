// lib/transactions/transactions_widgets.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'manual_adjust_screen.dart';

/// Displays a summary of transactions (income, expenses, etc.).
/// Tapping on it opens a screen to manually adjust these values.
class TransactionSummarySection extends StatelessWidget {
  const TransactionSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return GestureDetector(
      onTap: () {
        // Navigate to ManualAdjustScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManualAdjustScreen()),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Transaction Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Use a Wrap or Row with Flexible to avoid overflow
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _summaryText(
                    "Income: ₹${transactionProvider.totalIncome.toStringAsFixed(2)}",
                    color: Colors.green,
                  ),
                  _summaryText(
                    "Expenses: ₹${transactionProvider.totalExpenses.toStringAsFixed(2)}",
                    color: Colors.red,
                  ),
                  _summaryText(
                    "Remaining: ₹${transactionProvider.remaining.toStringAsFixed(2)}",
                  ),
                  _summaryText(
                    "Budget: ₹${transactionProvider.budget.toStringAsFixed(2)}",
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: transactionProvider.budget == 0
                    ? 0
                    : (transactionProvider.totalExpenses / transactionProvider.budget)
                        .clamp(0, 1),
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                color: (transactionProvider.totalExpenses <= transactionProvider.budget)
                    ? Colors.blue
                    : Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryText(String text, {Color? color}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color ?? Colors.black,
      ),
    );
  }
}

/// FilterSection handles user taps to sort transactions by Category, Date, or Type.
class FilterSection extends StatelessWidget {
  final Function onCategoryTap;
  final Function onDateTap;
  final Function onTypeTap;

  const FilterSection({
    super.key,
    required this.onCategoryTap,
    required this.onDateTap,
    required this.onTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => onCategoryTap(),
              child: const Text("Category"),
            ),
            OutlinedButton(
              onPressed: () => onDateTap(),
              child: const Text("Date"),
            ),
            OutlinedButton(
              onPressed: () => onTypeTap(),
              child: const Text("Type"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays a list of transactions, either recent or sorted by category/date/type.
class TransactionsListSection extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionsListSection({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            if (transactions.isNotEmpty)
              ...transactions.map((transaction) {
                IconData icon;
                Color iconColor;
                if (transaction.type == "Income") {
                  icon = Icons.attach_money;
                  iconColor = Colors.green;
                } else {
                  icon = Icons.shopping_cart;
                  iconColor = Colors.red;
                }
                return ListTile(
                  leading: Icon(icon, color: iconColor),
                  title: Text(transaction.name),
                  subtitle: Text("${transaction.type} - ₹${transaction.amount.toStringAsFixed(2)}"),
                  trailing: _DeleteTransactionButton(transaction: transaction),
                );
              }).toList()
            else
              const Text("No transactions found."),
          ],
        ),
      ),
    );
  }
}

/// Delete button extracted for clarity.
class _DeleteTransactionButton extends StatelessWidget {
  final TransactionModel transaction;
  const _DeleteTransactionButton({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text("Are you sure you want to delete this transaction?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  transactionProvider.deleteTransaction(transaction.id!);
                  Navigator.of(ctx).pop();
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }
}
