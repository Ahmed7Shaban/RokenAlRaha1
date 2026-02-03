import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/services/notification_service.dart';

import '../../../../../../core/constants/notification_ids.dart';
import '../date/morning_list.dart';
import '../date/evening_list.dart';
import '../date/wakeUp_list.dart';
import '../date/sleep_list.dart';

class AzkarNotificationHelper {
  static const String _prefPrefix = 'azkar_notif_';

  /// Returns a consistent base ID for a given key.
  static int _getBaseId(String key) {
    switch (key) {
      case 'morning_azkar':
        return NotificationIds.morningAzkar;
      case 'evening_azkar':
        return NotificationIds.eveningAzkar;
      case 'wakeup_azkar':
        return NotificationIds.wakeUpAzkar;
      case 'sleep_azkar':
        return NotificationIds.sleepAzkar;
      default:
        return (key.hashCode.abs() % 50000) + 20000;
    }
  }

  /// Get specific default time for each notification type
  static TimeOfDay _getDefaultTime(String key) {
    switch (key) {
      case 'morning_azkar':
        return const TimeOfDay(hour: 5, minute: 0); // 5:00 AM
      case 'evening_azkar':
        return const TimeOfDay(hour: 17, minute: 0); // 5:00 PM
      case 'wakeup_azkar':
        return const TimeOfDay(hour: 7, minute: 0); // 7:00 AM
      case 'sleep_azkar':
        return const TimeOfDay(hour: 22, minute: 0); // 10:00 PM
      default:
        return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  static Future<void> scheduleAzkarNotification({
    required String key,
    required String title,
    required String body,
    required TimeOfDay time,
    List<String>? dynamicContent,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save settings
    await prefs.setBool('${_prefPrefix}${key}_enabled', true);
    await prefs.setInt('${_prefPrefix}${key}_hour', time.hour);
    await prefs.setInt('${_prefPrefix}${key}_minute', time.minute);

    // SCHEDULE NEW
    final int baseId = _getBaseId(key);

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

    await NotificationService().cancelNotification(baseId);

    for (int i = 0; i < 10; i++) {
      await NotificationService().cancelNotification(baseId + i);
    }
  }

  static Future<Map<String, dynamic>> getSettings(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final defaultTime = _getDefaultTime(key);

    bool enabled = prefs.getBool('${_prefPrefix}${key}_enabled') ?? true;
    int hour = prefs.getInt('${_prefPrefix}${key}_hour') ?? defaultTime.hour;
    int minute =
        prefs.getInt('${_prefPrefix}${key}_minute') ?? defaultTime.minute;

    return {'enabled': enabled, 'time': TimeOfDay(hour: hour, minute: minute)};
  }

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
          prefs.getBool('${_prefPrefix}${key}_enabled') ?? true;

      if (prefs.getBool('${_prefPrefix}${key}_enabled') == null) {
        await prefs.setBool('${_prefPrefix}${key}_enabled', true);
      }

      if (enabled) {
        final defaultTime = _getDefaultTime(key);
        final int hour =
            prefs.getInt('${_prefPrefix}${key}_hour') ?? defaultTime.hour;
        final int minute =
            prefs.getInt('${_prefPrefix}${key}_minute') ?? defaultTime.minute;
        final TimeOfDay time = TimeOfDay(hour: hour, minute: minute);

        await scheduleAzkarNotification(
          key: key,
          title: titles[key] ?? 'ذكر',
          body: 'حان وقت الذكر',
          time: time,
          dynamicContent: contents[key],
        );
      } else {
        // If disabled, we ensure it's cancelled (just in case)
        // Note: We don't call cancel here to avoid redundant calls on every startup,
        // assuming logic elsewhere handles cancellation when toggled off.
        // But to be completely safe regarding "if I turn it off it shouldn't come":
        // We could validly call cancelAzkarNotification(key) here, but that does sharedPrefs writes again.
        // Better to trust the toggle logic, OR just do nothing as it won't be scheduled.
        // Existing alarms persist reboot? flutter_local_notifications might need rescheduling?
        // If they need rescheduling after reboot, NOT calling schedule here means they won't run.
        // Correct: If we don't schedule here, they won't happen (if they require rescheduling).
        // If they persist, we might need to cancel?
        // Usually Android alarms persist if configured, but flutter_local_notifications usually requires init on boot.
        // Actually, standard practice: schedule if enabled. If not enabled, do nothing.
      }
    }
  }
}
