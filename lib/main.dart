import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Task model with description and completion status
class Task {
  String description;
  bool isCompleted;
  String category;

  Task(this.description, this.isCompleted, {this.category = 'Uncategorized'});

  // Convert Task object to JSON
  Map<String, dynamic> toJson() => {
    'description': description,
    'isCompleted': isCompleted,
    'category': category,
  };

  // Create a Task object from JSON
  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      json['description'],
      json['isCompleted'],
      category: json['category'] ?? 'Uncategorized',
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // List of tasks, now using the Task model
  final List<Task> _todoItems = [];
  // Custom categories will be stored in SharedPreferences
  List<String> _customCategories = [];
  final Map<String, Color> _categoryColors = {};
  int _points = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load the tasks when the app starts
    _loadCustomCategories(); // Load the tasks when the app starts
    _loadPoints(); // Load the points
  }

  void _clearCompletedTasks() {
    final completedCount = _todoItems.where((task) => task.isCompleted).length;

    if (completedCount == 0) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed'),
        content: Text('Delete $completedCount completed task${completedCount == 1 ? '' : 's'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _todoItems.removeWhere((task) => task.isCompleted);
                _saveTasks();
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Point tracking methods
  Future<void> _loadPoints() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastResetDate = prefs.getString('lastResetDate');
    final String today = DateTime.now().toIso8601String().split('T')[0];

    // Reset if it's a new day
    if (lastResetDate != today) {
      setState(() {
        _points = 0;
      });
      prefs.setInt('points', 0);
      prefs.setString('lastResetDate', today);
    } else {
      setState(() {
        _points = prefs.getInt('points') ?? 0;
      });
    }
  }

  Future<void> _savePoints() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('points', _points);
  }


  // Save the task list to shared preferences
  Future<void> _saveTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String tasksJson = jsonEncode(_todoItems.map((task) => task.toJson()).toList());
    prefs.setString('tasks', tasksJson);
  }

  // Load the task list from shared preferences
  Future<void> _loadTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> taskList = jsonDecode(tasksJson);
      setState(() {
        _todoItems.clear();
        _todoItems.addAll(taskList.map((json) => Task.fromJson(json)).toList());
      });
    }
  }

  // Load custom categories and their colors from SharedPreferences
  Future<void> _loadCustomCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load categories
      _customCategories = prefs.getStringList('customCategories') ?? [];

      // Load colors for each category
      for (var category in _customCategories) {
        final colorValue = prefs.getInt('category_color_$category');
        if (colorValue != null) {
          _categoryColors[category] = Color(colorValue);
        }
      }
    });
  }

  // Save custom categories and their colors to SharedPreferences
  Future<void> _saveCustomCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('customCategories', _customCategories);

    // Save color for each category
    for (var category in _customCategories) {
      if (_categoryColors.containsKey(category)) {
        prefs.setInt('category_color_$category', _categoryColors[category]!.value);
      }
    }
  }

  // Method to add a new custom category with color
  Future<void> _addCustomCategory(String category, Color color) async {
    if (category.isNotEmpty && !_customCategories.contains(category)) {
      setState(() {
        _customCategories.add(category);
        _categoryColors[category] = color;
      });
      await _saveCustomCategories();
    }
  }

  // Method to get color for a category
  Color _getCategoryColor(String category) {
    return _categoryColors[category] ?? Colors.grey[300]!;
  }

  // Function to show the dialog box for adding a new task
  Future<void> _showAddTodoDialog() async {
    final TextEditingController taskController = TextEditingController();
    String? selectedCategory;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                // title: Text('Add a New Task'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: taskController,
                      decoration: const InputDecoration(
                        labelText: 'Enter a new task',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category Dropdown with Add New option
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Select Category',
                      ),
                      items: [
                        ..._customCategories.map((category) =>
                            DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: _getCategoryColor(category),
                                    margin: const EdgeInsets.only(right: 8),
                                  ),
                                  Text(category),
                                ],
                              ),
                            )
                        ),
                        const DropdownMenuItem(
                          value: 'New Category',
                          child: Text('+ Add New Category'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == 'New Category') {
                          // Show dialog to add new category with color picker
                          _showNewCategoryDialog(context);
                        } else {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (taskController.text.isNotEmpty && selectedCategory != null) {
                        _addTodoItem(taskController.text, selectedCategory!);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            }
        );
      },
    );
  }
  // New method to show color picker and create new category
  Future<void> _showNewCategoryDialog(BuildContext context) async {
    final TextEditingController categoryController = TextEditingController();
    Color selectedColor = Colors.blue;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Add New Category'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Choose a Color'),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Colors.blue, Colors.green, Colors.red,
                          Colors.purple, Colors.orange, Colors.teal,
                          Colors.pink, Colors.indigo
                        ].map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: color,
                                border: selectedColor == color
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      final categoryName = categoryController.text.trim();
                      if (categoryName.isNotEmpty) {
                        _addCustomCategory(categoryName, selectedColor);
                        Navigator.of(context).pop();
                        // Reopen the task add dialog with the new category
                        _showAddTodoDialog();
                      }
                    },
                    child: const Text('Add Category'),
                  ),
                ],
              );
            }
        );
      },
    );
  }


// Update _addTodoItem method to accept category
  void _addTodoItem(String taskDescription, String category) {
    if (taskDescription.isNotEmpty) {
      setState(() {
        _todoItems.add(Task(taskDescription, false, category: category));
        _saveTasks();
      });
    }
  }

  Future<void> _editTask(int index) async {
    final TextEditingController controller = TextEditingController(
      text: _todoItems[index].description,
    );

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Task description',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _todoItems[index].description = controller.text;
                    _saveTasks();
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Show a confirmation dialog before deleting
  Future<void> _confirmDeleteTask(int index) async {
    final Task task = _todoItems[index];

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${task.description}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm delete
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _todoItems.removeAt(index); // Delete the task if confirmed
        _saveTasks(); // Save the updated list after deleting
      });
    }
  }

  // Toggle task completion when short pressed
  void _toggleTaskCompletion(int index) {
    setState(() {
      _todoItems[index].isCompleted = !_todoItems[index].isCompleted;

      // Add/remove points
      if (_todoItems[index].isCompleted) {
        _points += 5;
      } else {
        _points -= 5;
      }

      _saveTasks();
      _savePoints();
    });
  }

  // Reorder task list items
  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      // Find the actual task in the full list
      final Task oldTask = _filteredTasks[oldIndex];
      final int actualOldIndex = _todoItems.indexOf(oldTask);

      // Find the actual new index
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Remove from original list and reinsert
      final Task item = _todoItems.removeAt(actualOldIndex);
      _todoItems.insert(
          newIndex < _todoItems.length ? newIndex : _todoItems.length,
          item
      );

      _saveTasks();
    });
  }

  // Build a task item with swipe-to-delete functionality and conditional styling
  Widget _buildTodoItem(Task task, int index) {
    return Dismissible(
      key: ValueKey(task.description + index.toString()),
      direction: DismissDirection.horizontal,  // Changed to horizontal
      background: Container(  // Swipe right - Edit
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(  // Swipe left - Delete
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await _confirmDeleteTask(index);
        } else if (direction == DismissDirection.startToEnd) {
          await _editTask(index);
        }
        return false;
      },
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        visualDensity: const VisualDensity(vertical: -2),
        leading: Container(
          width: 10,
          color: _getCategoryColor(task.category),
        ),
        title: Text(
          task.description,
          style: TextStyle(
            fontSize: 14,
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        onTap: () => _toggleTaskCompletion(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(color: Colors.white, fontSize: 14),
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
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'filter',
                child: Text('Filter Tasks'),
              ),
              const PopupMenuItem<String>(
                value: 'clear',
                child: Text('Clear Completed'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Display current filter if not 'All Categories'
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
                  // Add a clear filter button
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

          // Use the filtered tasks instead of _todoItems
          Expanded(
            child: ReorderableListView(
              onReorder: _reorderTasks,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: <Widget>[
                for (int index = 0; index < _filteredTasks.length; index++)
                  _buildTodoItem(_filteredTasks[index],
                      // Use the original index from the full list to maintain correct reordering
                      _todoItems.indexOf(_filteredTasks[index])),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Add a filter variable
  String _currentFilter = 'All Categories';

  // Method to get filtered tasks
  List<Task> get _filteredTasks {
    List<Task> filtered;
    if (_currentFilter == 'All Categories') {
      filtered = List.from(_todoItems);
    } else {
      filtered = _todoItems.where((task) => task.category == _currentFilter).toList();
    }

    // Sort: uncompleted tasks first, then completed tasks
    filtered.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });

    return filtered;
  }

  // Method to show filter dialog
  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Tasks'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add 'All Categories' option
                RadioListTile<String>(
                  title: const Text('All Categories'),
                  value: 'All Categories',
                  groupValue: _currentFilter,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _currentFilter = value;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                ),
                // Add custom categories
                ..._customCategories.map((category) {
                  return RadioListTile<String>(
                    title: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: _getCategoryColor(category),
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        Expanded(  // Wrap the Text with Expanded
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,  // Add ellipsis for long text
                            maxLines: 1,  // Limit to one line
                          ),
                        ),
                      ],
                    ),
                    value: category,
                    groupValue: _currentFilter,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _currentFilter = value;
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  );
                }),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
