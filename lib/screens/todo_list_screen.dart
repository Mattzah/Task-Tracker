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

class _TodoListScreenState extends State<TodoListScreen> {
  final StorageService _storageService = StorageService();
  final PointsService _pointsService = PointsService();

  final List<Task> _tasks = [];
  List<String> _categories = [];
  final Map<String, Color> _categoryColors = {};
  int _points = 0;
  String _currentFilter = 'All Categories';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Check and reset points ONCE on app initialization
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
      _showError('Failed to load data: $e');
    }
  }

  Future<void> _saveTasks() async {
    try {
      await _storageService.saveTasks(_tasks);
    } catch (e) {
      _showError('Failed to save tasks: $e');
    }
  }

  Future<void> _saveCategories() async {
    try {
      final colorValues = _categoryColors.map(
            (key, value) => MapEntry(key, value.value),
      );
      await _storageService.saveCategories(_categories, colorValues);
    } catch (e) {
      _showError('Failed to save categories: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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
      _showError('Failed to update points: $e');
    }
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    final filteredTasks = _getFilteredTasks();
    final task = filteredTasks[oldIndex];

    // FIXED: Use task ID instead of indexOf for reliable matching
    final actualOldIndex = _tasks.indexWhere((t) => t.id == task.id);

    if (actualOldIndex == -1) return; // Safety check

    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      _tasks.removeAt(actualOldIndex);
      final insertIndex = newIndex.clamp(0, _tasks.length);
      _tasks.insert(insertIndex, task);
    });

    _saveTasks();
  }

  void _clearCompletedTasks() {
    final completedCount = _tasks.where((t) => t.isCompleted).length;
    if (completedCount == 0) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed'),
        content: Text(
            'Delete $completedCount completed task${completedCount == 1 ? '' : 's'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tasks.removeWhere((t) => t.isCompleted);
              });
              _saveTasks();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
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
    return _categoryColors[category] ?? Colors.grey[300]!;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 20),
              const SizedBox(width: 4),
              Text(
                '$_points pts',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        title: const Text(
          'Tasks',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'filter') {
                _showFilterDialog();
              } else if (value == 'clear') {
                _clearCompletedTasks();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'filter', child: Text('Filter Tasks')),
              PopupMenuItem(value: 'clear', child: Text('Clear Completed')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_currentFilter != 'All Categories')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Filtered by: $_currentFilter',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        _currentFilter = 'All Categories';
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: ReorderableListView(
              onReorder: _reorderTasks,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}