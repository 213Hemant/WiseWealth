// lib/providers/transaction_provider.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  Database? _db;
  List<TransactionModel> _transactions = [];

  // Manual overrides (if the user manually adjusts them in the summary widget).
  double? _manualIncome;
  double? _manualExpenses;
  double? _manualBudget;

  double? get manualIncome => _manualIncome;
  double? get manualExpenses => _manualExpenses;
  double? get manualBudget => _manualBudget;

  // For demonstration, we still have a default budget if none is set manually.
  static const double defaultBudget = 10000.0;

  List<TransactionModel> get transactions => _transactions;

  double get computedIncome =>
      _transactions.where((t) => t.type == "Income").fold(0, (prev, t) => prev + t.amount);

  double get computedExpenses =>
      _transactions.where((t) => t.type == "Expense").fold(0, (prev, t) => prev + t.amount);

  double get totalIncome => _manualIncome ?? computedIncome;
  double get totalExpenses => _manualExpenses ?? computedExpenses;
  double get budget => _manualBudget ?? defaultBudget;

  double get remaining => budget - totalExpenses;

  Future<void> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'transactions.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            amount REAL,
            type TEXT,
            category TEXT,
            date TEXT
          )
        ''');
      },
    );
    await fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    if (_db == null) return;
    final List<Map<String, dynamic>> maps =
        await _db!.query('transactions', orderBy: 'date DESC');
    _transactions = maps.map((map) => TransactionModel.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    if (_db == null) return;
    await _db!.insert('transactions', transaction.toMap());
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    if (_db == null) return;
    await _db!.delete('transactions', where: 'id = ?', whereArgs: [id]);
    await fetchTransactions();
  }

  /// Allows user to manually override income, expenses, and budget.
  void setManualValues(double income, double expenses, double budget) {
    _manualIncome = income;
    _manualExpenses = expenses;
    _manualBudget = budget;
    notifyListeners();
  }

  /// Clears manual overrides.
  void clearManualValues() {
    _manualIncome = null;
    _manualExpenses = null;
    _manualBudget = null;
    notifyListeners();
  }
}
