import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/services/notification_service.dart';

class MasbahaNotificationHelper {
  static Future<void> refreshAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    // --- Tasbeeh ---
    // Default Time: 10:00 AM
    final int defaultTasbeehHour = 10;
    final int defaultTasbeehMinute = 0;

    final bool isTasbeehEnabled =
        prefs.getBool('tasbeeh_notif_enabled') ?? true;

    if (prefs.getBool('tasbeeh_notif_enabled') == null) {
      await prefs.setBool('tasbeeh_notif_enabled', true);
    }

    if (isTasbeehEnabled) {
      final int tHour =
          prefs.getInt('tasbeeh_notif_hour') ?? defaultTasbeehHour;
      final int tMinute =
          prefs.getInt('tasbeeh_notif_minute') ?? defaultTasbeehMinute;

      // Ensure time is saved if it was default
      if (prefs.getInt('tasbeeh_notif_hour') == null) {
        await prefs.setInt('tasbeeh_notif_hour', tHour);
        await prefs.setInt('tasbeeh_notif_minute', tMinute);
      }

      await NotificationService().scheduleTasbeehRotations(
        time: TimeOfDay(hour: tHour, minute: tMinute),
      );
    }

    // --- Istighfar ---
    // Default Time: 4:00 PM (16:00)
    final int defaultIstighfarHour = 16;
    final int defaultIstighfarMinute = 0;

    final bool isIstighfarEnabled =
        prefs.getBool('istighfar_notif_enabled') ?? true;

    if (prefs.getBool('istighfar_notif_enabled') == null) {
      await prefs.setBool('istighfar_notif_enabled', true);
    }

    if (isIstighfarEnabled) {
      final int iHour =
          prefs.getInt('istighfar_notif_hour') ?? defaultIstighfarHour;
      final int iMinute =
          prefs.getInt('istighfar_notif_minute') ?? defaultIstighfarMinute;

      // Ensure time is saved if it was default
      if (prefs.getInt('istighfar_notif_hour') == null) {
        await prefs.setInt('istighfar_notif_hour', iHour);
        await prefs.setInt('istighfar_notif_minute', iMinute);
      }

      await NotificationService().scheduleIstighfarRotations(
        time: TimeOfDay(hour: iHour, minute: iMinute),
      );
    }
  }
}
