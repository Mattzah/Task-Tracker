import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
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
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // List of tasks, now using the Task model
  final List<Task> _todoItems = [];
  // Custom categories will be stored in SharedPreferences
  List<String> _customCategories = [];
  Map<String, Color> _categoryColors = {};

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load the tasks when the app starts
    _loadCustomCategories(); // Load the tasks when the app starts
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
      _customCategories.forEach((category) {
        final colorValue = prefs.getInt('category_color_$category');
        if (colorValue != null) {
          _categoryColors[category] = Color(colorValue);
        }
      });
    });
  }

  // Save custom categories and their colors to SharedPreferences
  Future<void> _saveCustomCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('customCategories', _customCategories);

    // Save color for each category
    _customCategories.forEach((category) {
      if (_categoryColors.containsKey(category)) {
        prefs.setInt('category_color_$category', _categoryColors[category]!.value);
      }
    });
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
    final TextEditingController _taskController = TextEditingController();
    String? _selectedCategory;
    Color? _selectedColor;
    final TextEditingController _newCategoryController = TextEditingController();

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
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: 'Enter a new task',
                      ),
                    ),
                    SizedBox(height: 16),
                    // Category Dropdown with Add New option
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
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
                                    margin: EdgeInsets.only(right: 8),
                                  ),
                                  Text(category),
                                ],
                              ),
                            )
                        ),
                        DropdownMenuItem(
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
                            _selectedCategory = value;
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
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_taskController.text.isNotEmpty && _selectedCategory != null) {
                        _addTodoItem(_taskController.text, _selectedCategory!);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Add'),
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
    final TextEditingController _categoryController = TextEditingController();
    Color _selectedColor = Colors.blue;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Add New Category'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Choose a Color'),
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
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: EdgeInsets.symmetric(horizontal: 4),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      final categoryName = _categoryController.text.trim();
                      if (categoryName.isNotEmpty) {
                        _addCustomCategory(categoryName, _selectedColor);
                        Navigator.of(context).pop();
                        // Reopen the task add dialog with the new category
                        _showAddTodoDialog();
                      }
                    },
                    child: Text('Add Category'),
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

  // Show a confirmation dialog before deleting
  Future<void> _confirmDeleteTask(int index) async {
    final Task task = _todoItems[index];

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${task.description}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm delete
              },
              child: Text('Delete'),
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
      _saveTasks(); // Save the updated completion status
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
      key: ValueKey(task.description),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        await _confirmDeleteTask(index);
        return false;
      },
      child: ListTile(
        leading: Container(
          width: 10,
          color: _getCategoryColor(task.category),
        ),
        title: Text(
          task.description,
          style: TextStyle(
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
        title: Text(
          'Tasks',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          // Add filter button to the app bar
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
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
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  // Add a clear filter button
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.blue),
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
              padding: EdgeInsets.symmetric(vertical: 8.0),
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
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Add a filter variable
  String _currentFilter = 'All Categories';

  // Method to get filtered tasks
  List<Task> get _filteredTasks {
    if (_currentFilter == 'All Categories') {
      return _todoItems;
    }
    return _todoItems.where((task) => task.category == _currentFilter).toList();
  }

  // Method to show filter dialog
  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Tasks'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add 'All Categories' option
                RadioListTile<String>(
                  title: Text('All Categories'),
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
                          margin: EdgeInsets.only(right: 8),
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
                }).toList(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
