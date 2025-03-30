// lib/transactions/transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'transactions_widgets.dart';
import '../home/bottom_navbar.dart';
import 'add_transaction.dart';
import '../animations/animations.dart'; // Import animations
import '../animations/transitions.dart'; // Import transitions
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

enum TransactionFilter { none, category, date, type }

class TransactionsScreen extends StatefulWidget {
  static const String routeName = '/transactions';

  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionFilter _selectedFilter = TransactionFilter.none;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    // Get all transactions
    List<TransactionModel> allTxns = transactionProvider.transactions;

    // Apply sorting based on _selectedFilter
    final List<TransactionModel> displayedTxns = List.from(allTxns);
    switch (_selectedFilter) {
      case TransactionFilter.category:
        displayedTxns.sort((a, b) => a.category.compareTo(b.category));
        break;
      case TransactionFilter.date:
        // Sort descending by date
        displayedTxns.sort((a, b) => b.date.compareTo(a.date));
        break;
      case TransactionFilter.type:
        displayedTxns.sort((a, b) => a.type.compareTo(b.type));
        break;
      case TransactionFilter.none:
        // Already in descending date order from the DB
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fadeInUp(child: const TransactionSummarySection()),
              const SizedBox(height: 16),
              slideInFromLeft(
                child: FilterSection(
                  onCategoryTap: () => setState(() {
                    _selectedFilter = TransactionFilter.category;
                  }),
                  onDateTap: () => setState(() {
                    _selectedFilter = TransactionFilter.date;
                  }),
                  onTypeTap: () => setState(() {
                    _selectedFilter = TransactionFilter.type;
                  }),
                ),
              ),
              const SizedBox(height: 16),
              slideInFromBottom(
                child: TransactionsListSection(transactions: displayedTxns),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            slideUpTransition(const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
