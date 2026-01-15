import 'package:shared_preferences/shared_preferences.dart';

class PointsService {
  static const String _pointsKey = 'points';
  static const String _lastResetDateKey = 'lastResetDate';
  static const int _pointsPerTask = 5;

  /// Call this once on app initialization to check/reset daily points
  Future<void> checkAndResetDaily() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastResetDate = prefs.getString(_lastResetDateKey);
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (lastResetDate != today) {
        await prefs.setInt(_pointsKey, 0);
        await prefs.setString(_lastResetDateKey, today);
      }
    } catch (e) {
      throw Exception('Failed to reset daily points: $e');
    }
  }

  Future<int> loadPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_pointsKey) ?? 0;
    } catch (e) {
      throw Exception('Failed to load points: $e');
    }
  }

  Future<void> savePoints(int points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_pointsKey, points);
    } catch (e) {
      throw Exception('Failed to save points: $e');
    }
  }

  Future<int> addPoints(int currentPoints, bool isCompleting) async {
    final newPoints = isCompleting
        ? currentPoints + _pointsPerTask
        : currentPoints - _pointsPerTask;
    await savePoints(newPoints);
    return newPoints;
  }
}