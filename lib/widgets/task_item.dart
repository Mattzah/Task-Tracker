import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Color categoryColor;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.categoryColor,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        color: const Color(0xFF0D1526),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            Container(
              width: 3,
              height: double.infinity,
              color: const Color(0xFF00D4FF),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.edit, color: Color(0xFF00D4FF), size: 16),
            const SizedBox(width: 8),
            const Text(
              'MODIFY',
              style: TextStyle(
                color: Color(0xFF00D4FF),
                fontFamily: 'RobotoMono',
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        color: const Color(0xFF0D1526),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'DELETE',
              style: TextStyle(
                color: Color(0xFFFF4466),
                fontFamily: 'RobotoMono',
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.delete_outline, color: Color(0xFFFF4466), size: 16),
            const SizedBox(width: 12),
            Container(
              width: 3,
              height: double.infinity,
              color: const Color(0xFFFF4466),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final confirmed = await _showDeleteConfirmation(context);
          if (confirmed) onDelete();
        } else if (direction == DismissDirection.startToEnd) {
          onEdit();
        }
        return false;
      },
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? const Color(0xFF080C18)
                : const Color(0xFF0A101E),
            border: Border(
              left: BorderSide(
                color: task.isCompleted
                    ? const Color(0xFF1E3A5F)
                    : categoryColor,
                width: 2,
              ),
              bottom: BorderSide(
                color: const Color(0xFF0F1A2E),
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    task.description,
                    style: TextStyle(
                      color: task.isCompleted
                          ? const Color(0xFF2A4A6A)
                          : const Color(0xFFB0C4DE),
                      fontSize: 13,
                      fontFamily: 'RobotoMono',
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: const Color(0xFF2A4A6A),
                    ),
                  ),
                ),
                if (!task.isCompleted)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: categoryColor.withOpacity(0.6),
                      boxShadow: [
                        BoxShadow(
                          color: categoryColor.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF0D1526),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFFF4466), width: 1),
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirm Delete',
                style: TextStyle(
                  color: Color(0xFFFF4466),
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '> "${task.description}"',
                style: const TextStyle(
                  color: Color(0xFF607B96),
                  fontFamily: 'RobotoMono',
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF607B96),
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4466).withOpacity(0.1),
                      side: const BorderSide(color: Color(0xFFFF4466), width: 0.5),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Color(0xFFFF4466),
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;
  }
}