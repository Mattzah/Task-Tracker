import 'package:uuid/uuid.dart';

class Task {
  final String id;
  String description;
  bool isCompleted;
  String category;
  DateTime? dueDate;
  bool isRecurring;

  Task({
    String? id,
    required this.description,
    required this.isCompleted,
    this.category = 'Uncategorized',
    this.dueDate,
    this.isRecurring = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'isCompleted': isCompleted,
    'category': category,
    'dueDate': dueDate?.toIso8601String(),
    'isRecurring': isRecurring,
  };

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      category: json['category'] ?? 'Uncategorized',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isRecurring: json['isRecurring'] ?? false,
    );
  }

  /// 5 pts if the task has a due date strictly after today (planned ahead),
  /// otherwise 1 pt (no due date, or due today / overdue).
  int get pointValue {
    if (dueDate == null) return 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isAfter(today) ? 5 : 1;
  }
}