import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore import
import 'package:firebase_auth/firebase_auth.dart';         // FirebaseAuth import
import '../models/goal.dart';

class GoalProvider extends ChangeNotifier {
  Database? _db;
  List<Goal> _goals = [];

  List<Goal> get goals => _goals;

  // Summary getters
  int get totalGoals => _goals.length;
  int get completedGoals => _goals.where((goal) => goal.isCompleted).length;
  
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
    double totalTarget = _goals.fold(0, (prev, goal) => prev + goal.targetAmount);
    double totalSaved = _goals.fold(0, (prev, goal) => prev + goal.savedAmount);
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
    await _syncGoalToFirestore(goal, isNew: true);
  }

  Future<void> updateGoal(Goal goal) async {
    if (_db == null || goal.id == null) return;
    await _db!.update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
    await fetchGoals();
    await _syncGoalToFirestore(goal, isNew: false);
  }

  Future<void> deleteGoal(int id) async {
    if (_db == null) return;
    await _db!.delete('goals', where: 'id = ?', whereArgs: [id]);
    await fetchGoals();
    await _deleteGoalFromFirestore(id);
  }
  
  /// PRIVATE: Sync a goal to Firestore.
  Future<void> _syncGoalToFirestore(Goal goal, {required bool isNew}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestoreRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('goals');

        // If you want to map SQLite id with Firestore document, you might store id field in the Firestore doc.
        if (isNew) {
          await firestoreRef.add({
            'name': goal.name,
            'targetAmount': goal.targetAmount,
            'savedAmount': goal.savedAmount,
            'targetDate': goal.targetDate.toIso8601String(),
            'isCompleted': goal.isCompleted,
            'syncedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // For updating, you should have a way to get the Firestore document id.
          // This example simply finds goals with the same name and target date.
          final snapshot = await firestoreRef
              .where('name', isEqualTo: goal.name)
              .where('targetDate', isEqualTo: goal.targetDate.toIso8601String())
              .get();
          if (snapshot.docs.isNotEmpty) {
            for (var doc in snapshot.docs) {
              await doc.reference.update({
                'savedAmount': goal.savedAmount,
                'isCompleted': goal.isCompleted,
                'syncedAt': FieldValue.serverTimestamp(),
              });
            }
          }
        }
      }
    } catch (e) {
      print("Error syncing goal: $e");
    }
  }

  /// PRIVATE: Delete a goal from Firestore.
  Future<void> _deleteGoalFromFirestore(int goalId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestoreRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('goals');

        // Similar to above, delete based on criteria. Adjust as needed.
        final snapshot = await firestoreRef.where('id', isEqualTo: goalId).get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print("Error deleting goal from Firestore: $e");
    }
  }
}
