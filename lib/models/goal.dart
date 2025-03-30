// lib/models/goal.dart
class Goal {
  final int? id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;
  final bool isCompleted;

  Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      targetAmount: map['targetAmount'],
      savedAmount: map['savedAmount'],
      targetDate: DateTime.parse(map['targetDate']),
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
