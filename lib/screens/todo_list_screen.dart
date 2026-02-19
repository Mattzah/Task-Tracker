import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/points_service.dart';
import '../widgets/task_item.dart';
import '../widgets/dialogs/add_task_dialog.dart';
import '../widgets/dialogs/edit_task_dialog.dart';
import '../widgets/dialogs/filter_dialog.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> with SingleTickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  final PointsService _pointsService = PointsService();

  final List<Task> _tasks = [];
  List<String> _categories = [];
  final Map<String, Color> _categoryColors = {};
  int _points = 0;
  String _currentFilter = 'All Categories';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController);
    _loadData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await _pointsService.checkAndResetDaily();
      final tasks = await _storageService.loadTasks();
      final categoryData = await _storageService.loadCategories();
      final points = await _pointsService.loadPoints();

      setState(() {
        _tasks.addAll(tasks);
        _categories = List<String>.from(categoryData['categories']);
        _categoryColors.addAll(
          (categoryData['colors'] as Map<String, int>).map(
                (key, value) => MapEntry(key, Color(value)),
          ),
        );
        _points = points;
      });
    } catch (e) {
      _showError('LOAD ERROR: $e');
    }
  }

  Future<void> _saveTasks() async {
    try {
      await _storageService.saveTasks(_tasks);
    } catch (e) {
      _showError('SAVE ERROR: $e');
    }
  }

  Future<void> _saveCategories() async {
    try {
      final colorValues = _categoryColors.map(
            (key, value) => MapEntry(key, value.value),
      );
      await _storageService.saveCategories(_categories, colorValues);
    } catch (e) {
      _showError('SAVE ERROR: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'RobotoMono', color: Color(0xFFFF4466))),
          backgroundColor: const Color(0xFF0D1526),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFFF4466)),
            borderRadius: BorderRadius.zero,
          ),
        ),
      );
    }
  }

  Future<void> _showAddTaskDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddTaskDialog(
        categories: _categories,
        categoryColors: _categoryColors,
        onNewCategory: _addCategory,
      ),
    );

    if (result != null) {
      setState(() {
        _tasks.add(Task(
          description: result['description'],
          isCompleted: false,
          category: result['category'],
        ));
      });
      await _saveTasks();
    }
  }

  Future<void> _addCategory(String name, Color color) async {
    if (name.isNotEmpty && !_categories.contains(name)) {
      setState(() {
        _categories.add(name);
        _categoryColors[name] = color;
      });
      await _saveCategories();
    }
  }

  Future<void> _editTask(Task task) async {
    final newDescription = await showDialog<String>(
      context: context,
      builder: (context) => EditTaskDialog(
        initialDescription: task.description,
      ),
    );

    if (newDescription != null && newDescription.isNotEmpty) {
      setState(() {
        task.description = newDescription;
      });
      await _saveTasks();
    }
  }

  Future<void> _deleteTask(Task task) async {
    setState(() {
      _tasks.remove(task);
    });
    await _saveTasks();
  }

  Future<void> _toggleTask(Task task) async {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    try {
      _points = await _pointsService.addPoints(_points, task.isCompleted);
      await _saveTasks();
    } catch (e) {
      _showError('POINTS ERROR: $e');
    }
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    final filteredTasks = _getFilteredTasks();
    final task = filteredTasks[oldIndex];
    final actualOldIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (actualOldIndex == -1) return;
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      _tasks.removeAt(actualOldIndex);
      _tasks.insert(newIndex.clamp(0, _tasks.length), task);
    });
    _saveTasks();
  }

  void _clearCompletedTasks() {
    final completedCount = _tasks.where((t) => t.isCompleted).length;
    if (completedCount == 0) return;

    showDialog(
      context: context,
      builder: (context) => _ConfirmDialog(
        title: 'Clear Completed Tasks',
        content: 'Delete $completedCount completed task${completedCount == 1 ? '' : 's'}?',
        onConfirm: () {
          setState(() {
            _tasks.removeWhere((t) => t.isCompleted);
          });
          _saveTasks();
        },
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    final filter = await showDialog<String>(
      context: context,
      builder: (context) => FilterDialog(
        currentFilter: _currentFilter,
        categories: _categories,
        categoryColors: _categoryColors,
      ),
    );
    if (filter != null) {
      setState(() {
        _currentFilter = filter;
      });
    }
  }

  List<Task> _getFilteredTasks() {
    List<Task> filtered = _currentFilter == 'All Categories'
        ? List.from(_tasks)
        : _tasks.where((t) => t.category == _currentFilter).toList();

    filtered.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });
    return filtered;
  }

  Color _getCategoryColor(String category) {
    return _categoryColors[category] ?? const Color(0xFF1E3A5F);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      backgroundColor: const Color(0xFF080C18),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildScanLine(),
          if (_currentFilter != 'All Categories') _buildFilterBadge(),
          Expanded(
            child: filteredTasks.isEmpty
                ? _buildEmptyState()
                : ReorderableListView(
              onReorder: _reorderTasks,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              proxyDecorator: (child, index, animation) => Material(
                color: Colors.transparent,
                child: child,
              ),
              children: [
                for (final task in filteredTasks)
                  TaskItem(
                    key: ValueKey(task.id),
                    task: task,
                    categoryColor: _getCategoryColor(task.category),
                    onToggle: () => _toggleTask(task),
                    onEdit: () => _editTask(task),
                    onDelete: () => _deleteTask(task),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF080C18),
      elevation: 0,
      leadingWidth: 100,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt,
                color: const Color(0xFFFFD700).withOpacity(_pulseAnimation.value),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '$_points',
                style: TextStyle(
                  color: const Color(0xFFFFD700).withOpacity(_pulseAnimation.value),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ],
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00FF88),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0xFF00FF88), blurRadius: 6, spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'TASK TRACKER',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
              fontFamily: 'RobotoMono',
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF607B96), size: 20),
          color: const Color(0xFF0D1526),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFF1E3A5F)),
            borderRadius: BorderRadius.zero,
          ),
          onSelected: (value) {
            if (value == 'filter') _showFilterDialog();
            else if (value == 'clear') _clearCompletedTasks();
          },
          itemBuilder: (context) => [
            _buildMenuItem('filter', 'Filter', Icons.filter_list),
            _buildMenuItem('clear', 'Clear Completed', Icons.delete_sweep),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String label, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00D4FF), size: 14),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB0C4DE),
              fontFamily: 'RobotoMono',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanLine() {
    return Container(
      height: 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Color(0x2200D4FF), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildFilterBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1526),
              border: Border.all(color: const Color(0xFF00D4FF), width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_list, color: Color(0xFF00D4FF), size: 11),
                const SizedBox(width: 6),
                Text(
                  _currentFilter.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 10,
                    fontFamily: 'RobotoMono',
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _currentFilter = 'All Categories'),
                  child: const Icon(Icons.close, color: Color(0xFF607B96), size: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: const Color(0xFF1E3A5F),
          ),
          const SizedBox(height: 12),
          const Text(
            'NO TASKS FOUND',
            style: TextStyle(
              color: Color(0xFF1E3A5F),
              fontFamily: 'RobotoMono',
              fontSize: 12,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '> PRESS + TO INSERT NEW TASK',
            style: TextStyle(
              color: Color(0xFF1E3A5F),
              fontFamily: 'RobotoMono',
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF00D4FF),
        foregroundColor: const Color(0xFF080C18),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFF4466),
                fontFamily: 'RobotoMono',
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                color: Color(0xFFB0C4DE),
                fontFamily: 'RobotoMono',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: () {
                    onConfirm();
                    Navigator.pop(context);
                  },
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
    );
  }
}