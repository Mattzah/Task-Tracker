import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _categoriesKey = 'customCategories';
  static const String _categoryColorPrefix = 'category_color_';

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
      await prefs.setString(_tasksKey, tasksJson);
    } catch (e) {
      throw Exception('Failed to save tasks: $e');
    }
  }

  Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);
      if (tasksJson == null) return [];

      final List<dynamic> taskList = jsonDecode(tasksJson);
      return taskList.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<void> saveCategories(List<String> categories, Map<String, int> colors) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_categoriesKey, categories);

      for (var category in categories) {
        if (colors.containsKey(category)) {
          await prefs.setInt('$_categoryColorPrefix$category', colors[category]!);
        }
      }
    } catch (e) {
      throw Exception('Failed to save categories: $e');
    }
  }

  Future<Map<String, dynamic>> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categories = prefs.getStringList(_categoriesKey) ?? [];
      final Map<String, int> colors = {};

      for (var category in categories) {
        final colorValue = prefs.getInt('$_categoryColorPrefix$category');
        if (colorValue != null) {
          colors[category] = colorValue;
        }
      }

      return {'categories': categories, 'colors': colors};
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}