import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/repositories/hadith_repository.dart';
import 'dart:math';
import '../core/services/notification_service.dart';

class HadithNotificationService {
  static const String _prefEnabledKey = 'hadith_notification_enabled';
  static const String _prefHourKey = 'hadith_notification_hour';
  static const String _prefMinuteKey = 'hadith_notification_minute';
  static const int _notificationId = 777; // Unique ID for Hadith Notification

  /// Initialize: Load settings and re-schedule if needed (e.g. on app start)
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_prefEnabledKey) ?? false;

    if (isEnabled) {
      final hour = prefs.getInt(_prefHourKey) ?? 8; // Default 8 AM
      final minute = prefs.getInt(_prefMinuteKey) ?? 0;
      await scheduleNotification(TimeOfDay(hour: hour, minute: minute));
    }
  }

  /// Get current settings
  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_prefEnabledKey) ?? false,
      'time': TimeOfDay(
        hour: prefs.getInt(_prefHourKey) ?? 8,
        minute: prefs.getInt(_prefMinuteKey) ?? 0,
      ),
    };
  }

  /// Save settings and update schedule
  static Future<void> saveSettings({
    required bool enabled,
    required TimeOfDay time,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabledKey, enabled);
    await prefs.setInt(_prefHourKey, time.hour);
    await prefs.setInt(_prefMinuteKey, time.minute);

    if (enabled) {
      await scheduleNotification(time);
    } else {
      await cancelNotification();
    }
  }

  /// Cancel the notification
  static Future<void> cancelNotification() async {
    // Cancel legacy static notification
    await NotificationService().cancelNotification(_notificationId);

    // Cancel batch notifications (ids 777000 to 777030)
    for (int i = 0; i < 30; i++) {
      await NotificationService().cancelNotification(
        _notificationId * 1000 + i,
      );
    }
  }

  /// Schedule the daily notification
  static Future<void> scheduleNotification(TimeOfDay time) async {
    // 1. Cancel existing to prevent duplicates
    await cancelNotification();

    try {
      // 2. Initialize Repository & Fetch Books
      final repo = HadithRepository();
      // Ensure Hive is initialized if needed, though repo.getBooks() calls init()
      final books = await repo.getBooks();

      // Filter for available (downloaded or local) books
      final availableBooks = books
          .where((b) => b.isDownloaded || b.isLocal)
          .toList();

      if (availableBooks.isEmpty) {
        _scheduleGenericFallback(time);
        return;
      }

      // 3. Pick a random book and load its Hadiths
      final random = Random();
      final book = availableBooks[random.nextInt(availableBooks.length)];
      final hadiths = await repo.getHadiths(book);

      if (hadiths.isEmpty) {
        _scheduleGenericFallback(time);
        return;
      }

      // 4. Schedule 30 days of unique Hadiths
      // Shuffle to ensure variety
      hadiths.shuffle();

      final now = DateTime.now();
      // Determine start date: Today @ Time, or Tomorrow if passed
      DateTime startDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (startDate.isBefore(now)) {
        startDate = startDate.add(const Duration(days: 1));
      }

      for (int i = 0; i < 30; i++) {
        // Retrieve hadith (wrap around if not enough)
        final hadith = hadiths[i % hadiths.length];
        final scheduledDate = startDate.add(Duration(days: i));

        // Truncate very long hadiths for notification body if needed,
        // though BigTextStyle handles plenty. keeping it clean.
        String content = hadith.hadith;
        if (content.length > 500) {
          content = "${content.substring(0, 500)}...";
        }

        await NotificationService().scheduleOneOffHadithReminder(
          id: _notificationId * 1000 + i,
          title: "حديث من ${book.name}",
          body: content,
          date: scheduledDate,
        );
      }

      debugPrint("✅ Scheduled 30 Hadith notifications starting $startDate");
    } catch (e) {
      debugPrint("❌ Error scheduling Hadith notifications: $e");
      _scheduleGenericFallback(time);
    }
  }

  static Future<void> _scheduleGenericFallback(TimeOfDay time) async {
    await NotificationService().scheduleHadithReminder(
      id: _notificationId,
      title: 'حديث اليوم',
      body: 'طالع حديث اليوم واقرأ من السنة النبوية الشريفة',
      time: time,
    );
  }
}
