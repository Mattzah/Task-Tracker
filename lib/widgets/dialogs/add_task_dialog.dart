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
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskController,
            decoration: const InputDecoration(
              labelText: 'Enter a new task',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Select Category',
            ),
            items: [
              ...widget.categories.map((category) => DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: widget.categoryColors[category] ?? Colors.grey,
                      margin: const EdgeInsets.only(right: 8),
                    ),
                    Text(category),
                  ],
                ),
              )),
              const DropdownMenuItem(
                value: 'New Category',
                child: Text('+ Add New Category'),
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
                  // Reopen this dialog
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
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_taskController.text.isNotEmpty && _selectedCategory != null) {
              Navigator.pop(context, {
                'description': _taskController.text,
                'category': _selectedCategory,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
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
  Color _selectedColor = Colors.blue;

  static final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
            ),
          ),
          const SizedBox(height: 16),
          const Text('Choose a Color'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: color,
                      border: _selectedColor == color
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final categoryName = _categoryController.text.trim();
            if (categoryName.isNotEmpty) {
              Navigator.pop(context, {
                'name': categoryName,
                'color': _selectedColor,
              });
            }
          },
          child: const Text('Add Category'),
        ),
      ],
    );
  }
}