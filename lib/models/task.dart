import 'package:uuid/uuid.dart';

class Task {
  final String id;
  String description;
  bool isCompleted;
  String category;
  DateTime? dueDate;
  bool isRecurring;
  final DateTime createdAt;

  Task({
    String? id,
    required this.description,
    required this.isCompleted,
    this.category = 'Uncategorized',
    this.dueDate,
    this.isRecurring = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'isCompleted': isCompleted,
    'category': category,
    'dueDate': dueDate?.toIso8601String(),
    'isRecurring': isRecurring,
    'createdAt': createdAt.toIso8601String(),
  };

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      category: json['category'] ?? 'Uncategorized',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isRecurring: json['isRecurring'] ?? false,
      // Existing tasks saved before this field existed default to now,
      // so they're treated as created today on first load.
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  /// Points this task is worth when completed:
  ///
  /// • No due date                          → 1 pt
  /// • Due date is in the past              → 1 pt  (would have been 5, demoted)
  /// • Due date == creation date (same day) → 1 pt
  /// • Due date > creation date (planned ahead) AND not yet past → 5 pts
  int get pointValue {
    if (dueDate == null) return 1;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);

    // Past-due: demote to 1 pt
    if (due.isBefore(today)) return 1;

    // Was the task planned at least a day ahead when it was created?
    final created = DateTime(createdAt.year, createdAt.month, createdAt.day);
    return due.isAfter(created) ? 5 : 1;
  }
}
