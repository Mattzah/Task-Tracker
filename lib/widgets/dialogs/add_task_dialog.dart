import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final List<String> categories;
  final Map<String, Color> categoryColors;
  final Function(String, Color) onNewCategory;

  const AddTaskDialog({
    super.key,
    required this.categories,
    required this.categoryColors,
    required this.onNewCategory,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _taskController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _taskController.dispose();
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
                Container(
                  width: 3,
                  height: 16,
                  color: const Color(0xFF00D4FF),
                ),
                const SizedBox(width: 10),
                const Text(
                  'New Task',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontFamily: 'RobotoMono',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLabel('Description'),
            const SizedBox(height: 6),
            TextField(
              controller: _taskController,
              style: const TextStyle(
                color: Color(0xFFB0C4DE),
                fontFamily: 'RobotoMono',
                fontSize: 13,
              ),
              cursorColor: const Color(0xFF00D4FF),
              decoration: const InputDecoration(
                hintText: 'Enter task description...',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Category'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111D35),
                border: Border.all(color: const Color(0xFF1E3A5F)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Select category...',
                      style: TextStyle(
                        color: Color(0xFF3A5472),
                        fontFamily: 'RobotoMono',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  isExpanded: true,
                  dropdownColor: const Color(0xFF0D1526),
                  iconEnabledColor: const Color(0xFF607B96),
                  items: [
                    ...widget.categories.map((category) => DropdownMenuItem(
                      value: category,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              color: widget.categoryColors[category] ?? Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              category,
                              style: const TextStyle(
                                color: Color(0xFFB0C4DE),
                                fontFamily: 'RobotoMono',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                    const DropdownMenuItem(
                      value: 'New Category',
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '+ New Category',
                          style: TextStyle(
                            color: Color(0xFF00D4FF),
                            fontFamily: 'RobotoMono',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == 'New Category') {
                      Navigator.pop(context);
                      final result = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (context) => const NewCategoryDialog(),
                      );
                      if (result != null) {
                        widget.onNewCategory(result['name'], result['color']);
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AddTaskDialog(
                              categories: widget.categories,
                              categoryColors: widget.categoryColors,
                              onNewCategory: widget.onNewCategory,
                            ),
                          );
                        }
                      }
                    } else {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton('Cancel', const Color(0xFF607B96), false, () => Navigator.pop(context)),
                const SizedBox(width: 10),
                _buildActionButton('Add', const Color(0xFF00D4FF), true, () {
                  if (_taskController.text.isNotEmpty && _selectedCategory != null) {
                    Navigator.pop(context, {
                      'description': _taskController.text,
                      'category': _selectedCategory,
                    });
                  }
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF607B96),
        fontFamily: 'RobotoMono',
        fontSize: 10,
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, bool filled, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: filled ? color.withOpacity(0.1) : Colors.transparent,
        side: BorderSide(color: color.withOpacity(filled ? 1 : 0.4), width: 0.5),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontFamily: 'RobotoMono',
          fontSize: 11,
        ),
      ),
    );
  }
}

class NewCategoryDialog extends StatefulWidget {
  const NewCategoryDialog({super.key});

  @override
  State<NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewCategoryDialog> {
  final TextEditingController _categoryController = TextEditingController();
  Color _selectedColor = const Color(0xFF00D4FF);

  static final List<Color> _availableColors = [
    const Color(0xFF00D4FF),
    const Color(0xFF00FF88),
    const Color(0xFFFF4466),
    const Color(0xFFFFD700),
    const Color(0xFFBF5AF2),
    const Color(0xFFFF9F0A),
    const Color(0xFF30D158),
    const Color(0xFF0A84FF),
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1526),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF00FF88), width: 1),
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
                Container(width: 3, height: 16, color: const Color(0xFF00FF88)),
                const SizedBox(width: 10),
                const Text(
                  'New Category',
                  style: TextStyle(
                    color: Color(0xFF00FF88),
                    fontFamily: 'RobotoMono',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Name',
              style: TextStyle(
                color: Color(0xFF607B96),
                fontFamily: 'RobotoMono',
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _categoryController,
              style: const TextStyle(
                color: Color(0xFFB0C4DE),
                fontFamily: 'RobotoMono',
                fontSize: 13,
              ),
              cursorColor: const Color(0xFF00FF88),
              decoration: const InputDecoration(
                hintText: 'Category name...',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00FF88), width: 1.5),
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Color',
              style: TextStyle(
                color: Color(0xFF607B96),
                fontFamily: 'RobotoMono',
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _availableColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        border: Border.all(
                          color: isSelected ? color : color.withOpacity(0.3),
                          width: isSelected ? 2 : 0.5,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.check, size: 14, color: color)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF607B96), fontFamily: 'RobotoMono', fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    final name = _categoryController.text.trim();
                    if (name.isNotEmpty) {
                      Navigator.pop(context, {'name': name, 'color': _selectedColor});
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF88).withOpacity(0.1),
                    side: const BorderSide(color: Color(0xFF00FF88), width: 0.5),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Color(0xFF00FF88), fontFamily: 'RobotoMono', fontSize: 11),
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