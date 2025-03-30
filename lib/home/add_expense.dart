import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisewealth/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'home_screen.dart';
import 'package:wisewealth/animations/transitions.dart';

class AddExpenseScreen extends StatefulWidget {
  static const String routeName = '/add-expense';

  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final txnProvider = Provider.of<TransactionProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: "Expense Amount",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter amount";
                  if (double.tryParse(value) == null) return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Expense Description",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate!,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  "Select Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}",
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Create a new expense transaction.
                    // Assuming your TransactionModel has fields: name, amount, type, category, and date.
                    // For expense, we'll use type "Expense" and a default category "General".
                    final expenseTxn = TransactionModel(
                      name: _descriptionController.text,
                      amount: double.parse(_amountController.text),
                      type: "Expense",
                      category: "General",
                      date: _selectedDate!,
                    );
                    await txnProvider.addTransaction(expenseTxn);
                    Navigator.pushReplacement(
                      context,
                      slideDownTransition(const HomeScreen()),
                    );
                  }
                },
                child: const Text("Add Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
