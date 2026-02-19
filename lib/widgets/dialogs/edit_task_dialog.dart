import 'package:flutter/material.dart';

class EditTaskDialog extends StatefulWidget {
  final String initialDescription;

  const EditTaskDialog({
    super.key,
    required this.initialDescription,
  });

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1526),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF00D4FF), width: 1),
        borderRadius: BorderRadius.zero,
      ),
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
                      Navigator.pop(context, _controller.text);
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
    );
  }
}