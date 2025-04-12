import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore import
import 'package:firebase_auth/firebase_auth.dart';         // FirebaseAuth import
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

  double get computedIncome => _transactions
      .where((t) => t.type == "Income")
      .fold(0, (prev, t) => prev + t.amount);

  double get computedExpenses => _transactions
      .where((t) => t.type == "Expense")
      .fold(0, (prev, t) => prev + t.amount);

  double get totalIncome => _manualIncome ?? computedIncome;
  double get totalExpenses => _manualExpenses ?? computedExpenses;
  double get budget => _manualBudget ?? defaultBudget;

  double get remaining => budget - totalExpenses;

  /// Computes the net value from transactions (income minus expenses).
  double get netWorth => totalIncome - totalExpenses;

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

    // After local insert, sync to Firestore.
    await _syncTransactionToFirestore(transaction);
  }

  Future<void> deleteTransaction(int id) async {
    if (_db == null) return;
    await _db!.delete('transactions', where: 'id = ?', whereArgs: [id]);
    await fetchTransactions();

    // After local deletion, you may want to remove the transaction from Firestore.
    await _deleteTransactionFromFirestore(id);
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

  /// PRIVATE: Sync a transaction to Firestore.
  Future<void> _syncTransactionToFirestore(TransactionModel transaction) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Under /users/{uid}/transactions collection
        final firestoreRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions');

        await firestoreRef.add({
          'name': transaction.name,
          'amount': transaction.amount,
          'type': transaction.type,
          'category': transaction.category,
          'date': transaction.date.toIso8601String(),
          // Optionally, add a timestamp for conflict resolution.
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Log error; you may also want to add retry logic or mark the local record as pending.
      print("Error syncing transaction: $e");
    }
  }

  /// PRIVATE: Delete a transaction from Firestore.
  Future<void> _deleteTransactionFromFirestore(int transactionId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestoreRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions');

        // In this simple example, we assume that the Firestore document has a field 'id' matching the SQLite id.
        // If you need to map these IDs, you might have to store the Firestore document id locally.
        final snapshot = await firestoreRef.where('id', isEqualTo: transactionId).get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print("Error deleting transaction from Firestore: $e");
    }
  }
}
