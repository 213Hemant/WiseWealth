// lib/models/asset.dart
class Asset {
  int? id;
  final String name;
  final double value;
  final String type;
  final DateTime createdAt;

  Asset({
    this.id,
    required this.name,
    required this.value,
    required this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
