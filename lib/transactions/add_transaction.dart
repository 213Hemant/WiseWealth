// lib/transactions/add_transaction.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'transactions_screen.dart';
import '../animations/transitions.dart';

class AddTransactionScreen extends StatefulWidget {
  static const String routeName = '/add-transaction';

  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedType;
  String? _selectedCategory;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Transaction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Transaction Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Enter transaction name" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if(value == null || value.isEmpty) return "Enter amount";
                    if(double.tryParse(value) == null) return "Enter valid number";
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Type",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Income", child: Text("Income")),
                    DropdownMenuItem(value: "Expense", child: Text("Expense")),
                  ],
                  onChanged: (value) => setState(() => _selectedType = value),
                  validator: (value) => value == null ? "Select type" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Food", child: Text("Food")),
                    DropdownMenuItem(value: "Shopping", child: Text("Shopping")),
                    DropdownMenuItem(value: "Salary", child: Text("Salary")),
                  ],
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  validator: (value) => value == null ? "Select category" : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() => _selectedDate = pickedDate);
                  },
                  child: Text(_selectedDate == null
                      ? "Select Date"
                      : "Selected: ${_selectedDate!.toLocal().toString().split(' ')[0]}"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if(_formKey.currentState!.validate() && _selectedDate != null) {
                      final transaction = TransactionModel(
                        name: _nameController.text,
                        amount: double.parse(_amountController.text),
                        type: _selectedType!,
                        category: _selectedCategory!,
                        date: _selectedDate!,
                      );
                      await transactionProvider.addTransaction(transaction);
                      Navigator.pushReplacement(
                        context,
                        slideDownTransition(const TransactionsScreen()),
                      );
                    }
                  },
                  child: const Text("Add Transaction"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
