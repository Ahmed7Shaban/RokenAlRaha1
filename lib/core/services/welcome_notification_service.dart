import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeNotificationService {
  static final WelcomeNotificationService _instance =
      WelcomeNotificationService._internal();

  factory WelcomeNotificationService() => _instance;

  WelcomeNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Shows a welcome notification immediately when called.
  /// No 'is_first_launch' check is performed here, per requirement to show on "Main Screen entry".
  /// To ensure it doesn't spam, usage should be controlled by the caller (e.g., initState of HomeView).
  ///
  /// Note: On Android 13+, POST_NOTIFICATIONS permission must be granted.
  Future<void> showWelcomeNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'welcome_channel',
          'Welcome Notifications',
          channelDescription: 'General welcome messages',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/launcher_icon',
          enableVibration: true,
          playSound: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // ID 0 - will overwrite previous welcome notification
      'أهلاً بك في ركن الراحة 🌿',
      'نتمنى لك وقتاً مليئاً بالسكينة والذكر.',
      platformChannelSpecifics,
    );
  }

  // Legacy method for first launch only (kept if needed)
  Future<void> showWelcomeNotificationIfFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

    if (isFirstLaunch) {
      await showWelcomeNotification();
      await prefs.setBool('is_first_launch', false);
    }
  }
}
