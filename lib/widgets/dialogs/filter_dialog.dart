import 'package:flutter/material.dart';

class FilterDialog extends StatelessWidget {
  final String currentFilter;
  final List<String> categories;
  final Map<String, Color> categoryColors;

  const FilterDialog({
    super.key,
    required this.currentFilter,
    required this.categories,
    required this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Tasks'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All Categories'),
              value: 'All Categories',
              groupValue: currentFilter,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            ...categories.map((category) {
              return RadioListTile<String>(
                title: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: categoryColors[category] ?? Colors.grey,
                      margin: const EdgeInsets.only(right: 8),
                    ),
                    Expanded(
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                value: category,
                groupValue: currentFilter,
                onChanged: (value) => Navigator.pop(context, value),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}