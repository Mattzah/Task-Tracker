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
                  'FILTER MODULE',
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
            const SizedBox(height: 16),
            Container(
              height: 0.5,
              color: const Color(0xFF1E3A5F),
            ),
            const SizedBox(height: 8),
            _buildFilterOption(
              context,
              label: 'ALL MODULES',
              value: 'All Categories',
              color: const Color(0xFF607B96),
            ),
            ...categories.map((category) => _buildFilterOption(
              context,
              label: category.toUpperCase(),
              value: category,
              color: categoryColors[category] ?? const Color(0xFF1E3A5F),
            )),
            const SizedBox(height: 8),
            Container(height: 0.5, color: const Color(0xFF1E3A5F)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1E3A5F), width: 0.5),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(color: Color(0xFF607B96), fontFamily: 'RobotoMono', fontSize: 11, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final isSelected = currentFilter == value;
    return GestureDetector(
      onTap: () => Navigator.pop(context, value),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.transparent,
          border: isSelected
              ? Border(left: BorderSide(color: color, width: 2))
              : const Border(left: BorderSide(color: Color(0xFF1E3A5F), width: 2)),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : const Color(0xFF1E3A5F),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)]
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : const Color(0xFF607B96),
                fontFamily: 'RobotoMono',
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Icon(Icons.check, size: 12, color: color),
            ],
          ],
        ),
      ),
    );
  }
}