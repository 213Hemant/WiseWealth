// lib/transactions/manual_adjust_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class ManualAdjustScreen extends StatefulWidget {
  const ManualAdjustScreen({Key? key}) : super(key: key);

  @override
  State<ManualAdjustScreen> createState() => _ManualAdjustScreenState();
}

class _ManualAdjustScreenState extends State<ManualAdjustScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _expensesController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    _incomeController.text =
        provider.manualIncome?.toString() ?? provider.computedIncome.toString();
    _expensesController.text =
        provider.manualExpenses?.toString() ?? provider.computedExpenses.toString();
    _budgetController.text =
        provider.manualBudget?.toString() ?? TransactionProvider.defaultBudget.toString();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manual Adjustments"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Set Your Finances Manually: ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // TextFormField(
              //   controller: _incomeController,
              //   decoration: const InputDecoration(
              //     labelText: "Income",
              //     border: OutlineInputBorder(),
              //   ),
              //   keyboardType: TextInputType.number,
              //   validator: (value) =>
              //       (value == null || double.tryParse(value) == null)
              //           ? "Enter a valid income"
              //           : null,
              // ),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: "Budget",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value == null || double.tryParse(value) == null)
                        ? "Enter a valid budget"
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expensesController,
                decoration: const InputDecoration(
                  labelText: "Expenses",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value == null || double.tryParse(value) == null)
                        ? "Enter a valid expense"
                        : null,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final double income = double.parse(_incomeController.text);
                    final double expenses = double.parse(_expensesController.text);
                    final double budget = double.parse(_budgetController.text);
                    provider.setManualValues(income, expenses, budget);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Save"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  provider.clearManualValues();
                  Navigator.of(context).pop();
                },
                child: const Text("Clear Overrides"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
