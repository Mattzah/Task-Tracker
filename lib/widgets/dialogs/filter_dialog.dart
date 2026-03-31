import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final String currentFilter;
  final String currentDateFilter;
  final List<String> categories;
  final Map<String, Color> categoryColors;

  const FilterDialog({
    super.key,
    required this.currentFilter,
    required this.currentDateFilter,
    required this.categories,
    required this.categoryColors,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String _selectedCategory;
  late String _selectedDateFilter;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentFilter;
    _selectedDateFilter = widget.currentDateFilter;
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
            const SizedBox(height: 14),
            const Text(
              'DATE',
              style: TextStyle(
                color: Color(0xFF607B96),
                fontFamily: 'RobotoMono',
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            _buildDateOption('Today', 'Today'),
            _buildDateOption('All Dates', 'All Dates'),
            const SizedBox(height: 14),
            Container(height: 0.5, color: const Color(0xFF1E3A5F)),
            const SizedBox(height: 10),
            const Text(
              'CATEGORY',
              style: TextStyle(
                color: Color(0xFF607B96),
                fontFamily: 'RobotoMono',
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            _buildCategoryOption(
              label: 'ALL MODULES',
              value: 'All Categories',
              color: const Color(0xFF607B96),
            ),
            ...widget.categories.map((category) => _buildCategoryOption(
              label: category.toUpperCase(),
              value: category,
              color: widget.categoryColors[category] ?? const Color(0xFF1E3A5F),
            )),
            const SizedBox(height: 10),
            Container(height: 0.5, color: const Color(0xFF1E3A5F)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1E3A5F), width: 0.5),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Color(0xFF607B96), fontFamily: 'RobotoMono', fontSize: 11, letterSpacing: 1),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context, {
                    'category': _selectedCategory,
                    'dateFilter': _selectedDateFilter,
                  }),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4FF).withOpacity(0.1),
                    side: const BorderSide(color: Color(0xFF00D4FF), width: 0.5),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'APPLY',
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

  Widget _buildDateOption(String label, String value) {
    final isSelected = _selectedDateFilter == value;
    const color = Color(0xFF00FF88);
    return GestureDetector(
      onTap: () => setState(() => _selectedDateFilter = value),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.transparent,
          border: isSelected
              ? const Border(left: BorderSide(color: color, width: 2))
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
              label.toUpperCase(),
              style: TextStyle(
                color: isSelected ? color : const Color(0xFF607B96),
                fontFamily: 'RobotoMono',
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              const Icon(Icons.check, size: 12, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOption({
    required String label,
    required String value,
    required Color color,
  }) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
