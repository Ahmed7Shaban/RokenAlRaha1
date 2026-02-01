import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AzkarStatsService {
  static const String _lastActiveDateKey = 'last_active_date';
  static const String _currentStreakKey = 'current_streak';
  static const String _highestStreakKey = 'highest_streak';
  static const String _totalTasbeehKey = 'total_tasbeeh_count';
  static const String _zikrPrefix = 'zikr_count_';

  static final ValueNotifier<int> totalTasbeehNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> currentStreakNotifier = ValueNotifier<int>(0);

  // Initialize notifier
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    totalTasbeehNotifier.value = prefs.getInt(_totalTasbeehKey) ?? 0;
    currentStreakNotifier.value = prefs.getInt(_currentStreakKey) ?? 0;
  }

  // Increment specific zikr count
  static Future<void> incrementZikr(String title) async {
    final prefs = await SharedPreferences.getInstance();
    // Normalize key
    final key = _zikrPrefix + title.hashCode.toString();
    int current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);

    // Also increment total & track activity
    await incrementTotal();
    await _trackDailyActivity(prefs);
  }

  // Increment global total
  static Future<void> incrementTotal() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_totalTasbeehKey) ?? 0;
    int newValue = current + 1;
    await prefs.setInt(_totalTasbeehKey, newValue);
    totalTasbeehNotifier.value = newValue;
  }

  // Track daily activity & streaks
  static Future<void> _trackDailyActivity(SharedPreferences prefs) async {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final dailyKey = "daily_count_$todayStr";

    // 1. Increment today's count
    int todayCount = prefs.getInt(dailyKey) ?? 0;
    await prefs.setInt(dailyKey, todayCount + 1);

    // 2. Check Streak
    String? lastActiveDateStr = prefs.getString(_lastActiveDateKey);

    if (lastActiveDateStr != todayStr) {
      // First activity of today
      if (lastActiveDateStr != null) {
        final lastDate = _parseDate(lastActiveDateStr);
        final difference = now.difference(lastDate).inDays;

        if (difference == 1) {
          // Consecutive day
          int streak = prefs.getInt(_currentStreakKey) ?? 0;
          streak++;
          await prefs.setInt(_currentStreakKey, streak);
          currentStreakNotifier.value = streak;

          // Update highest streak if needed
          int highest = prefs.getInt(_highestStreakKey) ?? 0;
          if (streak > highest) {
            await prefs.setInt(_highestStreakKey, streak);
          }
        } else if (difference > 1) {
          // Streak broken
          await prefs.setInt(_currentStreakKey, 1); // Reset to 1 (today)
          currentStreakNotifier.value = 1;
        }
      } else {
        // First ever
        await prefs.setInt(_currentStreakKey, 1);
        currentStreakNotifier.value = 1;
      }

      // Update last active date
      await prefs.setString(_lastActiveDateKey, todayStr);
    }
  }

  static DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  // Get weekly activity (last 7 days including today)
  // Returns Map<String, int> where key is day name (e.g., 'Mon') or index, and value is count.
  // Actually, returns a List of counts for the last 7 days ending today.
  static Future<List<int>> getWeeklyActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    List<int> counts = [];

    // Order: [Today-6, Today-5, ..., Today]
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = "${date.year}-${date.month}-${date.day}";
      final count = prefs.getInt("daily_count_$dateStr") ?? 0;
      counts.add(count);
    }
    return counts;
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  // Get global total
  static Future<int> getTotal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalTasbeehKey) ?? 0;
  }

  // Get specific zikr count
  static Future<int> getZikrCount(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _zikrPrefix + title.hashCode.toString();
    return prefs.getInt(key) ?? 0;
  }
}
