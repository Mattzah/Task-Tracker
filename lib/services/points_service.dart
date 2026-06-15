import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppStats {
  final int currentStreak;
  final int longestStreak;
  final int biggestDayPoints;
  final String? biggestDayDate;
  final bool isCurrentStreakLongest;
  final int shields;
  final bool highOutputWeek;
  final String currentLevel;
  final double streakMultiplier;

  const AppStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.biggestDayPoints,
    this.biggestDayDate,
    required this.isCurrentStreakLongest,
    required this.shields,
    required this.highOutputWeek,
    required this.currentLevel,
    required this.streakMultiplier,
  });
}

class PointsService {
  static const String _pointsKey = 'points';
  static const String _lastResetDateKey = 'lastResetDate';
  static const String _dailyHistoryKey = 'dailyPointsHistory';
  static const String _levelKey = 'user_level';
  static const String _shieldsKey = 'streak_shields';

  String _todayKey() => DateTime.now().toIso8601String().split('T')[0];

  /// Points were historically stored as int; tolerate legacy values on read.
  double _readPoints(SharedPreferences prefs) {
    final raw = prefs.get(_pointsKey);
    if (raw is double) return raw;
    if (raw is int) return raw.toDouble();
    return 0.0;
  }

  /// Call this once on app initialization to check/reset daily points.
  /// Returns [true] if this is the first open of a new day, [false] otherwise.
  Future<bool> checkAndResetDaily() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastResetDate = prefs.getString(_lastResetDateKey);
      final today = _todayKey();

      if (lastResetDate == null) {
        // Very first run — set up defaults, no celebration needed yet
        await prefs.setString(_lastResetDateKey, today);
        await prefs.setString(_levelKey, 'Cadet');
        return false;
      } else if (lastResetDate != today) {
        // New day: persist previous day's points into history before resetting.
        // The live value already includes the streak multiplier, so it is
        // saved as-is (rounded) with no further adjustment.
        final currentPoints = _readPoints(prefs);
        final previousDayPoints = currentPoints.round();
        if (previousDayPoints > 0) {
          await _saveDayToHistory(prefs, lastResetDate, previousDayPoints);
        }

        // Shield: if the previous day was missed (0 points), spend a banked
        // shield to keep the streak alive by marking that day as active.
        final history = _loadHistory(prefs);
        if ((history[lastResetDate] ?? 0) == 0) {
          final shields = prefs.getInt(_shieldsKey) ?? 0;
          if (shields > 0) {
            await prefs.setInt(_shieldsKey, shields - 1);
            history[lastResetDate] = 1;
            await prefs.setString(_dailyHistoryKey, jsonEncode(history));
          }
        }

        // Daily volume bonus: high-output days seed the next day's points.
        int bonus = 0;
        if (previousDayPoints >= 100) {
          bonus = 20;
        } else if (previousDayPoints >= 75) {
          bonus = 10;
        } else if (previousDayPoints >= 50) {
          bonus = 5;
        }
        await prefs.setDouble(_pointsKey, bonus.toDouble());
        await prefs.setString(_lastResetDateKey, today);

        // Shield milestone: bank a shield every 7 streak days, max 3.
        final streak = _calculateCurrentStreak(_loadHistory(prefs));
        if (streak > 0 && streak % 7 == 0) {
          final shields = prefs.getInt(_shieldsKey) ?? 0;
          if (shields < 3) {
            await prefs.setInt(_shieldsKey, shields + 1);
          }
        }

        // Store the level for this new day based on the current streak
        await prefs.setString(_levelKey, _levelForStreak(streak));
        return true; // ← first open of the day
      }
      return false; // already ran today
    } catch (e) {
      throw Exception('Failed to reset daily points: $e');
    }
  }

  Map<String, int> _loadHistory(SharedPreferences prefs) {
    final historyJson = prefs.getString(_dailyHistoryKey) ?? '{}';
    return Map<String, int>.from(jsonDecode(historyJson));
  }

  Future<void> _saveDayToHistory(
      SharedPreferences prefs, String date, int points) async {
    final history = _loadHistory(prefs);
    history[date] = points;
    await prefs.setString(_dailyHistoryKey, jsonEncode(history));
  }

  /// Space Exploration tiers, determined solely by streak length.
  String _levelForStreak(int streak) {
    if (streak >= 90) return 'Voyager';
    if (streak >= 30) return 'Commander';
    if (streak >= 7) return 'Astronaut';
    return 'Cadet';
  }

  /// Live point multiplier earned by maintaining a streak.
  double getStreakMultiplier(int streak) {
    if (streak >= 90) return 1.3;
    if (streak >= 30) return 1.2;
    if (streak >= 7) return 1.1;
    return 1.0;
  }

  static const Set<String> _validLevels = {
    'Cadet', 'Astronaut', 'Commander', 'Voyager'
  };

  /// Returns the level that was stored on the most recent daily reset.
  /// A missing or legacy value (Beginner/Intermediate/Expert) is recomputed
  /// from the current streak and migrated in place.
  Future<String> getUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_levelKey);
    if (stored != null && _validLevels.contains(stored)) return stored;

    final history = _loadHistory(prefs);
    final todayPoints = _readPoints(prefs).round();
    if (todayPoints > 0) {
      history[_todayKey()] = todayPoints;
    }
    final level = _levelForStreak(_calculateCurrentStreak(history));
    await prefs.setString(_levelKey, level);
    return level;
  }

  Future<int> getShields() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_shieldsKey) ?? 0;
  }

  Future<double> loadPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return _readPoints(prefs);
    } catch (e) {
      throw Exception('Failed to load points: $e');
    }
  }

  Future<void> savePoints(double points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_pointsKey, points);
    } catch (e) {
      throw Exception('Failed to save points: $e');
    }
  }

  Future<double> addPoints(double currentPoints, bool isCompleting, int pointValue) async {
    double newPoints;
    if (isCompleting) {
      final prefs = await SharedPreferences.getInstance();
      final history = _loadHistory(prefs);
      final streak = _calculateCurrentStreak(history);
      final multiplier = getStreakMultiplier(streak);
      newPoints = currentPoints + (pointValue * multiplier);
    } else {
      // Uncompleting deducts the base value only — no multiplier on deduction.
      newPoints = currentPoints - pointValue;
    }
    await savePoints(newPoints);
    return newPoints;
  }

  /// Returns computed stats, incorporating today's live points alongside history.
  Future<AppStats> getStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = _loadHistory(prefs);

      // Merge today's live points so stats reflect the current session
      final today = _todayKey();
      final todayPoints = _readPoints(prefs).round();
      if (todayPoints > 0) {
        history[today] = todayPoints;
      }

      final currentStreak = _calculateCurrentStreak(history);
      final longestStreak = _calculateLongestStreak(history);
      final biggestDay = _findBiggestDay(history);
      final shields = prefs.getInt(_shieldsKey) ?? 0;
      final currentLevel = await getUserLevel();

      return AppStats(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        biggestDayPoints: biggestDay?.$1 ?? 0,
        biggestDayDate: biggestDay?.$2,
        isCurrentStreakLongest:
            currentStreak > 0 && currentStreak >= longestStreak,
        shields: shields,
        highOutputWeek: _checkHighOutputWeek(history),
        currentLevel: currentLevel,
        streakMultiplier: getStreakMultiplier(currentStreak),
      );
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }

  /// True if 5+ of the 7 calendar days prior to today earned ≥ 50 points.
  bool _checkHighOutputWeek(Map<String, int> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int highOutputDays = 0;
    for (int i = 1; i <= 7; i++) {
      final day = today.subtract(Duration(days: i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      if ((history[key] ?? 0) >= 50) {
        highOutputDays++;
      }
    }
    return highOutputDays >= 5;
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
