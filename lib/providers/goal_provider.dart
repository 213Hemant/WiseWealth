// lib/providers/goal_provider.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal.dart';

class GoalProvider extends ChangeNotifier {
  Database? _db;
  List<Goal> _goals = [];

  List<Goal> get goals => _goals;

  // Summary getters
  int get totalGoals => _goals.length;
  int get completedGoals =>
      _goals.where((goal) => goal.isCompleted).length;
  double get overallProgress {
    if (_goals.isEmpty) return 0;
    double sumProgress = 0;
    for (var goal in _goals) {
      double progress = goal.savedAmount / goal.targetAmount;
      sumProgress += progress;
    }
    return (sumProgress / _goals.length).clamp(0, 1);
  }
  double get remainingAmount {
    double totalTarget =
        _goals.fold(0, (prev, goal) => prev + goal.targetAmount);
    double totalSaved =
        _goals.fold(0, (prev, goal) => prev + goal.savedAmount);
    return totalTarget - totalSaved;
  }

  Future<void> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'goals.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE goals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            targetAmount REAL,
            savedAmount REAL,
            targetDate TEXT,
            isCompleted INTEGER
          )
        ''');
      },
    );
    await fetchGoals();
  }

  Future<void> fetchGoals() async {
    if (_db == null) return;
    final List<Map<String, dynamic>> maps =
        await _db!.query('goals', orderBy: 'targetDate ASC');
    _goals = maps.map((map) => Goal.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addGoal(Goal goal) async {
    if (_db == null) return;
    await _db!.insert('goals', goal.toMap());
    await fetchGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    if (_db == null || goal.id == null) return;
    await _db!.update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
    await fetchGoals();
  }

  Future<void> deleteGoal(int id) async {
    if (_db == null) return;
    await _db!.delete('goals', where: 'id = ?', whereArgs: [id]);
    await fetchGoals();
  }
}
