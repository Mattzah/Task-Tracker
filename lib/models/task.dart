import 'package:uuid/uuid.dart';

class Task {
  final String id;
  String description;
  bool isCompleted;
  String category;

  Task({
    String? id,
    required this.description,
    required this.isCompleted,
    this.category = 'Uncategorized',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'isCompleted': isCompleted,
    'category': category,
  };

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      category: json['category'] ?? 'Uncategorized',
    );
  }
}