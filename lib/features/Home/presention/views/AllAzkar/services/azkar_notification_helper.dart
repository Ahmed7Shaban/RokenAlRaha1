import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/services/notification_service.dart';

import '../date/morning_list.dart';
import '../date/evening_list.dart';
import '../date/wakeUp_list.dart';
import '../date/sleep_list.dart';

class AzkarNotificationHelper {
  static const String _prefPrefix = 'azkar_notif_';

  /// Returns a consistent base ID for a given key.
  /// Used for both scheduling and cancelling (range: baseId to baseId + 7).
  static int _getBaseId(String key) {
    switch (key) {
      case 'morning_azkar':
        return 1000;
      case 'evening_azkar':
        return 1100;
      case 'wakeup_azkar':
        return 1200;
      case 'sleep_azkar':
        return 1300;
      default:
        // Fallback for unknown keys (should be stable for the same key)
        return (key.hashCode.abs() % 50000) + 20000;
    }
  }

  static Future<void> scheduleAzkarNotification({
    required String key,
    required String title,
    required String body,
    required TimeOfDay time,
    List<String>? dynamicContent, // NEW
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save settings
    await prefs.setBool('${_prefPrefix}${key}_enabled', true);
    await prefs.setInt('${_prefPrefix}${key}_hour', time.hour);
    await prefs.setInt('${_prefPrefix}${key}_minute', time.minute);

    // SCHEDULE NEW
    // ----------------------
    final int baseId = _getBaseId(key);

    // If dynamic content is provided, we use the rotation logic (7 days ahead)
    if (dynamicContent != null && dynamicContent.isNotEmpty) {
      await NotificationService().scheduleRotatedReminders(
        baseId: baseId,
        title: title,
        contentList: dynamicContent,
        time: time,
        channelId: 'khatma_channel',
        payloadTag: 'azkar_$key',
      );
    } else {
      // Fallback: Fixed Daily Content (Single ID)
      await NotificationService().scheduleDailyReminder(
        id: baseId,
        title: title,
        body: body,
        time: time,
        payload: 'azkar_$key',
        isDaily: true,
      );
    }
  }

  static Future<void> cancelAzkarNotification(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefPrefix}${key}_enabled', false);

    final int baseId = _getBaseId(key);

    // Cancel Main ID (if used for daily fixed)
    await NotificationService().cancelNotification(baseId);

    // Cancel Rotation IDs (baseId to baseId + 7)
    // We cancel a few extra just to be safe (e.g. up to +10)
    for (int i = 0; i < 10; i++) {
      await NotificationService().cancelNotification(baseId + i);
    }
  }

  static Future<Map<String, dynamic>> getSettings(String key) async {
    final prefs = await SharedPreferences.getInstance();
    bool enabled = prefs.getBool('${_prefPrefix}${key}_enabled') ?? false;
    int hour = prefs.getInt('${_prefPrefix}${key}_hour') ?? 8;
    int minute = prefs.getInt('${_prefPrefix}${key}_minute') ?? 0;

    return {'enabled': enabled, 'time': TimeOfDay(hour: hour, minute: minute)};
  }

  /// Refreshes all Azkar notifications.
  /// Should be called on app start to Ensure alarms are set for the next 7 days.
  static Future<void> refreshAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'morning_azkar',
      'evening_azkar',
      'wakeup_azkar',
      'sleep_azkar',
    ];
    final titles = {
      'morning_azkar': 'أذكار الصباح',
      'evening_azkar': 'أذكار المساء',
      'wakeup_azkar': 'أذكار الاستيقاظ',
      'sleep_azkar': 'أذكار النوم',
    };
    final contents = {
      'morning_azkar': morningAzkar,
      'evening_azkar': eveningAzkar,
      'wakeup_azkar': wakeUpAzkar,
      'sleep_azkar': sleepAzkar,
    };

    for (final key in keys) {
      final bool enabled =
          prefs.getBool('${_prefPrefix}${key}_enabled') ?? false;
      if (enabled) {
        final int hour = prefs.getInt('${_prefPrefix}${key}_hour') ?? 8;
        final int minute = prefs.getInt('${_prefPrefix}${key}_minute') ?? 0;
        final TimeOfDay time = TimeOfDay(hour: hour, minute: minute);

        // Re-schedule (this extends the rotation for another 7 days from now)
        await scheduleAzkarNotification(
          key: key,
          title: titles[key] ?? 'ذكر',
          body: 'حان وقت الذكر', // Fallback body
          time: time,
          dynamicContent: contents[key],
        );
      }
    }
  }
}
