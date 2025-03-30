// lib/models/transaction_model.dart
class TransactionModel {
  final int? id;
  final String name;
  final double amount;
  final String type; // "Income" or "Expense"
  final String category;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  // Convert a TransactionModel into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  // Create a TransactionModel from a Map.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      date: DateTime.parse(map['date']),
    );
  }
}
