import 'package:flutter/material.dart';

class EditTaskDialog extends StatefulWidget {
  final String initialDescription;
  final DateTime? initialDueDate;

  const EditTaskDialog({
    super.key,
    required this.initialDescription,
    this.initialDueDate,
  });

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late final TextEditingController _controller;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDescription);
    _dueDate = widget.initialDueDate;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00D4FF),
            onPrimary: Color(0xFF080C18),
            surface: Color(0xFF0D1526),
            onSurface: Color(0xFFB0C4DE),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1526),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF00D4FF), width: 1),
        borderRadius: BorderRadius.zero,
      ),
      child: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 3, height: 16, color: const Color(0xFF00D4FF)),
                const SizedBox(width: 10),
                const Text(
                  'MODIFY TASK',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontFamily: 'RobotoMono',
                    fontSize: 12,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'TASK DESCRIPTION',
              style: TextStyle(
                color: Color(0xFF607B96),
                fontFamily: 'RobotoMono',
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _controller,
              style: const TextStyle(
                color: Color(0xFFB0C4DE),
                fontFamily: 'RobotoMono',
                fontSize: 13,
              ),
              cursorColor: const Color(0xFF00D4FF),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'DUE DATE',
              style: TextStyle(
                color: Color(0xFF607B96),
                fontFamily: 'RobotoMono',
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF111D35),
                  border: Border.all(color: const Color(0xFF1E3A5F)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dueDate != null ? _formatDate(_dueDate!) : 'No due date',
                      style: TextStyle(
                        color: _dueDate != null ? const Color(0xFF00D4FF) : const Color(0xFF3A5472),
                        fontFamily: 'RobotoMono',
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF607B96), size: 12),
                        if (_dueDate != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _dueDate = null),
                            child: const Icon(Icons.close, color: Color(0xFF607B96), size: 12),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Color(0xFF607B96), fontFamily: 'RobotoMono', fontSize: 11, letterSpacing: 1),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      Navigator.pop(context, {
                        'description': _controller.text,
                        'dueDate': _dueDate,
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4FF).withOpacity(0.1),
                    side: const BorderSide(color: Color(0xFF00D4FF), width: 0.5),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'SAVE',
                    style: TextStyle(color: Color(0xFF00D4FF), fontFamily: 'RobotoMono', fontSize: 11, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}
