import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppStats {
  final int currentStreak;
  final int longestStreak;
  final int biggestDayPoints;
  final String? biggestDayDate;
  final bool isCurrentStreakLongest;

  const AppStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.biggestDayPoints,
    this.biggestDayDate,
    required this.isCurrentStreakLongest,
  });
}

class PointsService {
  static const String _pointsKey = 'points';
  static const String _lastResetDateKey = 'lastResetDate';
  static const String _dailyHistoryKey = 'dailyPointsHistory';
  static const String _levelKey = 'user_level';

  String _todayKey() => DateTime.now().toIso8601String().split('T')[0];

  /// Call this once on app initialization to check/reset daily points.
  /// Before resetting, saves the previous day's earned points to history.
  Future<void> checkAndResetDaily() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastResetDate = prefs.getString(_lastResetDateKey);
      final today = _todayKey();

      if (lastResetDate == null) {
        // First run — record today's date and set initial level
        await prefs.setString(_lastResetDateKey, today);
        await prefs.setString(_levelKey, 'Beginner');
      } else if (lastResetDate != today) {
        // New day: persist previous day's points into history before resetting
        final currentPoints = prefs.getInt(_pointsKey) ?? 0;
        if (currentPoints > 0) {
          await _saveDayToHistory(prefs, lastResetDate, currentPoints);
        }
        await prefs.setInt(_pointsKey, 0);
        await prefs.setString(_lastResetDateKey, today);

        // Compute and store the level for this new day based on yesterday's data
        final level = _computeLevel(prefs);
        await prefs.setString(_levelKey, level);
      }
    } catch (e) {
      throw Exception('Failed to reset daily points: $e');
    }
  }

  Future<void> _saveDayToHistory(
      SharedPreferences prefs, String date, int points) async {
    final historyJson = prefs.getString(_dailyHistoryKey) ?? '{}';
    final history = Map<String, int>.from(jsonDecode(historyJson));
    history[date] = points;
    await prefs.setString(_dailyHistoryKey, jsonEncode(history));
  }

  /// Computes the user's level from the current history snapshot.
  /// Called synchronously inside [checkAndResetDaily] after history is updated.
  String _computeLevel(SharedPreferences prefs) {
    final historyJson = prefs.getString(_dailyHistoryKey) ?? '{}';
    final history = Map<String, int>.from(jsonDecode(historyJson));

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    final yesterdayPoints = history[yesterdayKey] ?? 0;

    // Streak is computed from history only (today just started, so 0 pts today
    // means _calculateCurrentStreak naturally counts backwards from yesterday).
    final streak = _calculateCurrentStreak(history);

    if (yesterdayPoints > 50 && streak > 3) return 'Expert';
    if (yesterdayPoints > 1 && streak >= 2 && streak <= 3) return 'Intermediate';
    return 'Beginner';
  }

  /// Returns the level that was stored on the most recent daily reset.
  Future<String> getUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_levelKey) ?? 'Beginner';
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

  Future<int> addPoints(int currentPoints, bool isCompleting, int pointValue) async {
    final newPoints = isCompleting
        ? currentPoints + pointValue
        : currentPoints - pointValue;
    await savePoints(newPoints);
    return newPoints;
  }

  /// Returns computed stats, incorporating today's live points alongside history.
  Future<AppStats> getStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_dailyHistoryKey) ?? '{}';
      final history = Map<String, int>.from(jsonDecode(historyJson));

      // Merge today's live points so stats reflect the current session
      final today = _todayKey();
      final todayPoints = prefs.getInt(_pointsKey) ?? 0;
      if (todayPoints > 0) {
        history[today] = todayPoints;
      }

      final currentStreak = _calculateCurrentStreak(history);
      final longestStreak = _calculateLongestStreak(history);
      final biggestDay = _findBiggestDay(history);

      return AppStats(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        biggestDayPoints: biggestDay?.$1 ?? 0,
        biggestDayDate: biggestDay?.$2,
        isCurrentStreakLongest:
            currentStreak > 0 && currentStreak >= longestStreak,
      );
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }

  int _calculateCurrentStreak(Map<String, int> history) {
    if (history.isEmpty) return 0;

    final now = DateTime.now();
    final todayKey = _todayKey();

    // If today has points, start counting from today; otherwise start from yesterday
    DateTime checkDate = (history[todayKey] ?? 0) > 0
        ? DateTime(now.year, now.month, now.day)
        : DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 1));

    int streak = 0;
    while (true) {
      final key =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      if ((history[key] ?? 0) > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int _calculateLongestStreak(Map<String, int> history) {
    if (history.isEmpty) return 0;

    final activeDates = history.entries
        .where((e) => e.value > 0)
        .map((e) => DateTime.parse(e.key))
        .toList()
      ..sort();

    if (activeDates.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < activeDates.length; i++) {
      final diff = activeDates[i].difference(activeDates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  /// Returns (points, dateString) for the day with the highest points earned.
  (int, String)? _findBiggestDay(Map<String, int> history) {
    if (history.isEmpty) return null;

    String? bestDate;
    int bestPoints = 0;

    for (final entry in history.entries) {
      if (entry.value > bestPoints) {
        bestPoints = entry.value;
        bestDate = entry.key;
      }
    }

    return bestDate != null ? (bestPoints, bestDate) : null;
  }
}
