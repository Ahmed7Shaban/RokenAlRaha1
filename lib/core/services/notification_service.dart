import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:adhan/adhan.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math'; // For random selection
import '../constants/notification_ids.dart';
import '../../features/Home/presention/views/Masbaha/date/tasbeeh_list.dart';
import '../../features/Home/presention/views/Masbaha/date/istighfar_list.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  fln.FlutterLocalNotificationsPlugin get plugin =>
      _flutterLocalNotificationsPlugin;

  bool _isInitialized = false;

  /// 1. Initialize the notification plugin with error handling
  Future<void> init({
    void Function(fln.NotificationResponse)? onNotificationClick,
  }) async {
    if (_isInitialized) return;

    try {
      // Initialize Timezones for accurate scheduling
      tz.initializeTimeZones();
      try {
        final String timeZoneName = tz.local.name;
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        debugPrint(
          "Timezone invalid or not found, using UTC/Local default: $e",
        );
      }
    } catch (e) {
      debugPrint("Timezone init fatal error: $e");
    }

    try {
      // Android Initialization
      const fln.AndroidInitializationSettings initializationSettingsAndroid =
          fln.AndroidInitializationSettings('@mipmap/launcher_icon');

      // iOS Initialization
      final fln.DarwinInitializationSettings initializationSettingsDarwin =
          fln.DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          );

      final fln.InitializationSettings initializationSettings =
          fln.InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            onNotificationClick ??
            (fln.NotificationResponse details) {
              debugPrint("Notification Clicked: ${details.payload}");
            },
      );

      // Create Channels
      await _createAzanChannel();
      await _createKhatmaChannels();

      _isInitialized = true;
      debugPrint("✅ NotificationService Initialized Successfully");
    } catch (e) {
      debugPrint("❌ NotificationService Init Error: $e");
    }
  }

  /// Create High Importance Channels for Azan (One per sound to support Android 8+ dynamic sounds)
  Future<void> _createAzanChannel() async {
    final sounds = [
      'azan_yaser',
      'azan_ahmed_1',
      'azan_ahmed_2',
      'mohamd_gazy',
      'alarm', // Added alarm just in case
    ];

    for (var sound in sounds) {
      try {
        final fln.AndroidNotificationChannel channel =
            fln.AndroidNotificationChannel(
              'azan_channel_${sound}_v3', // Updated to v3 to force recreation
              'الأذان (${_getSoundDisplayName(sound)})', // Descriptive Title
              description: 'تنبيهات الأذان بصوت ${_getSoundDisplayName(sound)}',
              importance: fln.Importance.max,
              playSound: true,
              sound: fln.RawResourceAndroidNotificationSound(sound),
              audioAttributesUsage:
                  fln.AudioAttributesUsage.alarm, // Ensure alarm usage
            );

        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              fln.AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);
      } catch (e) {
        debugPrint("Error creating channel for $sound: $e");
      }
    }
  }

  String _getSoundDisplayName(String file) {
    if (file.contains('yaser')) return 'ياسر الدوسري';
    if (file.contains('ahmed_1')) return 'أحمد جلال 1';
    if (file.contains('ahmed_2')) return 'أحمد جلال 2';
    if (file.contains('gazy')) return 'محمد جازي';
    return 'افتراضي';
  }

  /// Create Channels for Khatma & Reminders
  Future<void> _createKhatmaChannels() async {
    // 1. Daily Reminders Channel
    const fln.AndroidNotificationChannel reminderChannel =
        fln.AndroidNotificationChannel(
          'khatma_channel',
          'الختمة والورد اليومي',
          description: 'تذكيرات الورد اليومي',
          importance: fln.Importance.max,
        );

    // 2. Instant Alerts Channel (Congratulation messages)
    const fln.AndroidNotificationChannel alertsChannel =
        fln.AndroidNotificationChannel(
          'khatma_alerts',
          'تنبيهات الختمة',
          description: 'إشعارات إتمام الورد والختمات',
          importance: fln.Importance.max,
        );

    // 3. Hadith Channel
    const fln.AndroidNotificationChannel hadithChannel =
        fln.AndroidNotificationChannel(
          'hadith_channel',
          'حديث اليوم',
          description: 'تنبيهات الحديث اليومي',
          importance: fln.Importance.high,
        );

    // 4. Sunrise Channel
    const fln.AndroidNotificationChannel sunriseChannel =
        fln.AndroidNotificationChannel(
          'sunrise_channel',
          'موعد الشروق',
          description: 'تنبيهات وقت الشروق',
          importance: fln.Importance.high,
          playSound: true,
        );

    // 5. Masbaha Custom Channel
    const fln.AndroidNotificationChannel customMasbahaChannel =
        fln.AndroidNotificationChannel(
          'masbaha_custom_channel',
          'تذكيرات الأذكار المخصصة',
          description: 'تنبيهات للأذكار التي أضفتها بنفسك',
          importance: fln.Importance.max,
        );

    // 6. Hamed (Praise) Channel
    const fln.AndroidNotificationChannel hamedChannel =
        fln.AndroidNotificationChannel(
          'hamed_channel',
          'مفكرة النعم والحمد',
          description: 'تذكير يومي بتسجيل النعم وحمد الله',
          importance: fln.Importance.high,
        );

    final platform = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          fln.AndroidFlutterLocalNotificationsPlugin
        >();

    await platform?.createNotificationChannel(reminderChannel);
    await platform?.createNotificationChannel(alertsChannel);
    await platform?.createNotificationChannel(hadithChannel);
    await platform?.createNotificationChannel(sunriseChannel);
    await platform?.createNotificationChannel(customMasbahaChannel);
    await platform?.createNotificationChannel(hamedChannel);
    await platform?.createNotificationChannel(
      const fln.AndroidNotificationChannel(
        'salat_on_prophet_channel',
        'الصلاة على النبي',
        description: 'تذكير يومي بالصلاة على النبي',
        importance: fln.Importance.max,
      ),
    );
    await platform?.createNotificationChannel(
      const fln.AndroidNotificationChannel(
        'tasbeeh_channel',
        'إشعارات التسبيح',
        description: 'تذكيرات التسبيح اليومي',
        importance: fln.Importance.high,
      ),
    );
    await platform?.createNotificationChannel(
      const fln.AndroidNotificationChannel(
        'istighfar_channel',
        'إشعارات الاستغفار',
        description: 'تذكيرات الاستغفار اليومي',
        importance: fln.Importance.high,
      ),
    );

    // Create Fajr Alarm Channel explicitly
    await _createFajrAlarmChannel(platform);
  }

  Future<void> _createFajrAlarmChannel(
    fln.AndroidFlutterLocalNotificationsPlugin? platform,
  ) async {
    const fln.AndroidNotificationChannel channel =
        fln.AndroidNotificationChannel(
          'fajr_alarm_channel_v2',
          'منبه الفجر الذكي',
          description: 'تنبيه ذكي لصلاة الفجر',
          importance: fln.Importance.max,
          sound: fln.RawResourceAndroidNotificationSound('alarm'),
          playSound: true,
          audioAttributesUsage: fln.AudioAttributesUsage.alarm,
        );
    await platform?.createNotificationChannel(channel);
  }

  /// Schedule Hamed (Gratitude) Daily Reminder
  Future<void> scheduleHamedReminder({
    required TimeOfDay time,
    bool isEnabled = true,
  }) async {
    // 1. Cancel previous Hamed notification
    await cancelNotification(NotificationIds.hamedReminder);

    if (!isEnabled) return;

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    fln.AndroidScheduleMode scheduleMode =
        fln.AndroidScheduleMode.exactAllowWhileIdle;
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        scheduleMode = fln.AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      NotificationIds.hamedReminder,
      "كيف حال قلبك مع الله؟",
      "لا تنسَ تسجيل نعم الله عليك اليوم في مفكرة النعم 📝",
      tz.TZDateTime.from(scheduledDate, tz.local),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'hamed_channel',
          'مفكرة النعم والحمد',
          channelDescription: 'تذكير يومي بتسجيل النعم',
          importance: fln.Importance.high,
          priority: fln.Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: fln.DateTimeComponents.time,
      payload: 'hamed_reminder',
    );

    debugPrint("🔔 Hamed Reminder Scheduled at $time");
  }

  /// Schedule Custom Dhikr Daily Reminder
  Future<void> scheduleCustomDhikrReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    fln.AndroidScheduleMode scheduleMode =
        fln.AndroidScheduleMode.exactAllowWhileIdle;
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        scheduleMode = fln.AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'masbaha_custom_channel', // Distinct Channel
          'تذكيرات الأذكار المخصصة',
          channelDescription: 'تنبيهات للأذكار التي أضفتها بنفسك',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
          icon: '@mipmap/launcher_icon',
          styleInformation: fln.BigTextStyleInformation(''),
        ),
        iOS: fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: fln.DateTimeComponents.time, // Daily repeat
      payload: 'masbaha_custom',
    );

    debugPrint("🔔 Custom Dhikr Scheduled: ID=$id Time=$time");
  }

  // --- Prayer Check Reminders (New) ---

  Future<void> schedulePrayerCheckReminders(
    PrayerTimes prayerTimes,
    int delayMinutes,
  ) async {
    await cancelPrayerCheckReminders();

    final prayers = [
      {
        'name': 'Fajr',
        'time': prayerTimes.fajr,
        'id': NotificationIds.prayerCheckBase,
      },
      {
        'name': 'Dhuhr',
        'time': prayerTimes.dhuhr,
        'id': NotificationIds.prayerCheckBase + 1,
      },
      {
        'name': 'Asr',
        'time': prayerTimes.asr,
        'id': NotificationIds.prayerCheckBase + 2,
      },
      {
        'name': 'Maghrib',
        'time': prayerTimes.maghrib,
        'id': NotificationIds.prayerCheckBase + 3,
      },
      {
        'name': 'Isha',
        'time': prayerTimes.isha,
        'id': NotificationIds.prayerCheckBase + 4,
      },
    ];

    for (var prayer in prayers) {
      DateTime scheduledTime = (prayer['time'] as DateTime).add(
        Duration(minutes: delayMinutes),
      );
      final String name = prayer['name'] as String;
      final int id = prayer['id'] as int;

      if (scheduledTime.isBefore(DateTime.now())) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _scheduleSingleAzan(
        id: id,
        title: "هل صليت ${_getPrayerDisplayName(name)}؟",
        body: "قم بتسجيل صلاتك الآن للمتابعة ✅",
        time: scheduledTime,
        soundFileName: "", // Standard notification sound
        channelId: 'khatma_channel', // Use reminder channel
        payload: 'prayer_check_$name',
      );
    }
    debugPrint(
      "✅ Prayer Check Reminders scheduled with delay $delayMinutes mins",
    );
  }

  Future<void> cancelPrayerCheckReminders() async {
    for (int i = 0; i < 5; i++) {
      await _flutterLocalNotificationsPlugin.cancel(
        NotificationIds.prayerCheckBase + i,
      );
    }
  }

  String _getPrayerDisplayName(String name) {
    switch (name) {
      case 'Fajr':
        return 'الفجر';
      case 'Dhuhr':
        return 'الظهر';
      case 'Asr':
        return 'العصر';
      case 'Maghrib':
        return 'المغرب';
      case 'Isha':
        return 'العشاء';
      default:
        return 'الصلاة';
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin
          >();

      await androidImplementation?.requestNotificationsPermission();

      // Request exact alarm permission if required
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } else if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            fln.IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// 3. Schedule Daily Azan Logic
  /// Modified to support batch scheduling (fixing the daily repeat flaw)
  Future<void> scheduleAzanForPrayerTimes(
    PrayerTimes prayerTimes,
    String moazzenKey, {
    int dayOffset = 0,
  }) async {
    // Only cancel if this is the first day (Day 0), to start fresh.
    // However, the Cubit should handle clearing before starting the batch.
    if (dayOffset == 0) {
      await cancelAzanNotifications();
    }

    final prayers = [
      {'name': 'Fajr', 'time': prayerTimes.fajr, 'id': NotificationIds.fajr},
      {
        'name': 'Sunrise',
        'time': prayerTimes.sunrise,
        'id': NotificationIds.sunrise,
      },
      {'name': 'Dhuhr', 'time': prayerTimes.dhuhr, 'id': NotificationIds.dhuhr},
      {'name': 'Asr', 'time': prayerTimes.asr, 'id': NotificationIds.asr},
      {
        'name': 'Maghrib',
        'time': prayerTimes.maghrib,
        'id': NotificationIds.maghrib,
      },
      {'name': 'Isha', 'time': prayerTimes.isha, 'id': NotificationIds.isha},
    ];

    // Identify the correct sound file
    final String soundFileName = _mapMoazzenToFileName(moazzenKey);
    // Construct the channel ID that corresponds to this sound
    final String channelId = 'azan_channel_${soundFileName}_v3';

    for (var prayer in prayers) {
      DateTime scheduledTime = prayer['time'] as DateTime;
      final String name = prayer['name'] as String;
      int baseId = prayer['id'] as int;

      // Calculate dynamic ID based on day offset (Shift by 10 per day)
      // e.g. Day 0: 1, Day 1: 11, Day 2: 21...
      final int id = baseId + (dayOffset * 10);

      // Skip if time has passed
      if (scheduledTime.isBefore(DateTime.now())) {
        continue;
      }

      if (name == 'Sunrise') {
        // Sunrise: Simple Reminder (No Azan Sound)
        await _scheduleSingleAzan(
          id: id,
          title: "موعد الشروق",
          body: "تذكير بوقت الشروق",
          time: scheduledTime,
          soundFileName: "", // No custom sound
          channelId: 'sunrise_channel',
          payload: name,
        );
      } else {
        // Other Prayers: Full Azan
        await _scheduleSingleAzan(
          id: id,
          title: _getArabicTitle(name),
          body: "حي على الصلاة، حي على الفلاح",
          time: scheduledTime,
          soundFileName: soundFileName,
          channelId: channelId,
          payload: name,
        );
      }
    }

    debugPrint(
      "📅 Azan Scheduled for Day $dayOffset with sound: $soundFileName",
    );
  }

  /// Internal: Schedule a single Azan
  Future<void> _scheduleSingleAzan({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required String soundFileName,
    required String channelId,
    required String payload,
  }) async {
    // Check for Exact Alarm Permission specifically before scheduling
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        debugPrint("⚠️ Schedule Exact Alarm permission denied. Requesting...");
        await Permission.scheduleExactAlarm.request();
      }
    }

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(time, tz.local);

    fln.AndroidScheduleMode scheduleMode =
        fln.AndroidScheduleMode.exactAllowWhileIdle;

    if (Platform.isAndroid) {
      // Re-check after request
      if (await Permission.scheduleExactAlarm.isDenied) {
        debugPrint("⚠️ Exact Alarm still denied. Scheduling might be inexact.");
        scheduleMode = fln.AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        fln.NotificationDetails(
          android: fln.AndroidNotificationDetails(
            channelId, // Use the specific channel ID for this sound
            payload == 'Sunrise' ? 'موعد الشروق' : 'الأذان',
            channelDescription: 'تنبيهات أوقات الصلاة',
            importance: fln.Importance.max,
            priority: fln.Priority.high,
            playSound: true,
            sound: soundFileName.isNotEmpty
                ? fln.RawResourceAndroidNotificationSound(soundFileName)
                : null,
            fullScreenIntent:
                soundFileName.isNotEmpty, // Only full screen for Azan
            visibility: fln.NotificationVisibility.public,
            audioAttributesUsage: fln.AudioAttributesUsage.alarm,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: fln.DarwinNotificationDetails(
            sound: soundFileName.isNotEmpty ? '$soundFileName.mp3' : null,
            presentSound: true,
            interruptionLevel: fln.InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: scheduleMode,
        // CRITICAL FIX: Removed matchDateTimeComponents: fln.DateTimeComponents.time
        // This ensures we schedule EXACT dates, not recurring daily times which are incorrect for prayers.
        payload: payload,
      );
    } catch (e) {
      debugPrint("❌ Error scheduling Azan/Reminder (ID: $id): $e");
    }
  }

  Future<void> cancelAzanNotifications() async {
    final baseIds = [
      NotificationIds.fajr,
      NotificationIds.dhuhr,
      NotificationIds.asr,
      NotificationIds.maghrib,
      NotificationIds.isha,
      NotificationIds.sunrise,
    ];

    // Cancel for up to 30 days ahead to be safe
    for (int day = 0; day < 30; day++) {
      for (var baseId in baseIds) {
        await _flutterLocalNotificationsPlugin.cancel(baseId + (day * 10));
      }
    }
  }

  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // --- Helpers ---

  String _mapMoazzenToFileName(String moazzenKey) {
    final key = moazzenKey.toLowerCase();

    if (key == 'azan_ahmed_1') return 'azan_ahmed_1';
    if (key == 'azan_ahmed_2') return 'azan_ahmed_2';
    if (key == 'azan_yaser') return 'azan_yaser';
    if (key == 'mohamd_gazy') return 'mohamd_gazy';

    if (key.contains('azan_ahmed_1')) return 'azan_ahmed_1';
    if (key.contains('azan_ahmed_2')) return 'azan_ahmed_2';
    if (key.contains('azan_yaser')) return 'azan_yaser';
    if (key.contains('mohamd_gazy')) return 'mohamd_gazy';

    return 'azan_yaser';
  }

  String _getArabicTitle(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return 'حان الآن موعد أذان الفجر';
      case 'Sunrise':
        return 'موعد الشروق';
      case 'Dhuhr':
        return 'حان الآن موعد أذان الظهر';
      case 'Asr':
        return 'حان الآن موعد أذان العصر';
      case 'Maghrib':
        return 'حان الآن موعد أذان المغرب';
      case 'Isha':
        return 'حان الآن موعد أذان العشاء';
      default:
        return 'حان موعد الصلاة';
    }
  }

  // --- Legacy Support & Khatma Scheduling ---

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required String payload,
    bool forceTomorrow = false,
    bool isDaily = false,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (forceTomorrow || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    fln.AndroidScheduleMode scheduleMode =
        fln.AndroidScheduleMode.exactAllowWhileIdle;
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        scheduleMode = fln.AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'khatma_channel',
          'الختمة والورد اليومي',
          channelDescription: 'تذكيرات الورد اليومي',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: isDaily ? fln.DateTimeComponents.time : null,
      payload: payload,
    );
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'khatma_alerts',
          'تنبيهات الختمة',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: fln.DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> scheduleHadithReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    fln.AndroidScheduleMode scheduleMode =
        fln.AndroidScheduleMode.exactAllowWhileIdle;
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        scheduleMode = fln.AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'hadith_channel',
          'حديث اليوم',
          channelDescription: 'تنبيهات الحديث اليومي',
          importance: fln.Importance.high,
          priority: fln.Priority.high,
          icon: '@mipmap/launcher_icon',
          styleInformation: fln.BigTextStyleInformation(''),
        ),
        iOS: fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: fln.DateTimeComponents.time,
      payload: 'hadith_daily',
    );
  }

  /// Schedule a specific non-recurring Hadtih notification for a set date
  Future<void> scheduleOneOffHadithReminder({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    fln.AndroidScheduleMode scheduleMode =
        fln.AndroidScheduleMode.exactAllowWhileIdle;
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        scheduleMode = fln.AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'hadith_channel',
          'حديث اليوم',
          channelDescription: 'تنبيهات الحديث اليومي',
          importance: fln.Importance.high,
          priority: fln.Priority.high,
          icon: '@mipmap/launcher_icon',
          styleInformation: fln.BigTextStyleInformation(
            body,
          ), // Handle long text
        ),
        iOS: const fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      payload: 'hadith_daily_oneoff',
    );
  }

  // --- TASBEEH SCHEDULING (IDs 800-806) ---
  Future<void> scheduleTasbeehRotations({required TimeOfDay time}) async {
    await cancelTasbeehNotifications();
    final now = DateTime.now();
    final random = Random();
    int lastIndex = -1;

    for (int i = 0; i < 7; i++) {
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      ).add(Duration(days: i));

      if (i == 0 && scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      int index = random.nextInt(tasbeehList.length);
      if (index == lastIndex && tasbeehList.length > 1) {
        index = (index + 1) % tasbeehList.length;
      }
      lastIndex = index;

      await _scheduleSingleMasbaha(
        id: NotificationIds.tasbeehBase + i,
        title: 'تسبيح اليوم',
        body: tasbeehList[index],
        date: scheduledDate,
        channelId: 'tasbeeh_channel',
      );
    }
  }

  Future<void> cancelTasbeehNotifications() async {
    for (int i = 0; i < 7; i++) {
      await _flutterLocalNotificationsPlugin.cancel(
        NotificationIds.tasbeehBase + i,
      );
    }
    // Also cancel mixed legacy IDs if they exist to be clean
    await _flutterLocalNotificationsPlugin.cancel(888);
  }

  // --- ISTIGHFAR SCHEDULING (IDs 810-816) ---
  Future<void> scheduleIstighfarRotations({required TimeOfDay time}) async {
    await cancelIstighfarNotifications();
    final now = DateTime.now();
    final random = Random();
    int lastIndex = -1;

    for (int i = 0; i < 7; i++) {
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      ).add(Duration(days: i));

      if (i == 0 && scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      int index = random.nextInt(istighfarList.length);
      if (index == lastIndex && istighfarList.length > 1) {
        index = (index + 1) % istighfarList.length;
      }
      lastIndex = index;

      await _scheduleSingleMasbaha(
        id: NotificationIds.istighfarBase + i,
        title: 'استغفار اليوم',
        body: istighfarList[index],
        date: scheduledDate,
        channelId: 'istighfar_channel',
      );
    }
  }

  Future<void> cancelIstighfarNotifications() async {
    for (int i = 0; i < 7; i++) {
      await _flutterLocalNotificationsPlugin.cancel(
        NotificationIds.istighfarBase + i,
      );
    }
  }

  // -----------------------------------------------------

  // --- DUAA SCHEDULING (IDs 555-561) ---
  Future<void> scheduleDuaaRotations({
    required List<String> duaas,
    required TimeOfDay time,
  }) async {
    await cancelDuaaRotations();
    if (duaas.isEmpty) return;

    final now = DateTime.now();
    final random = Random();
    int lastIndex = -1;

    for (int i = 0; i < 7; i++) {
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      ).add(Duration(days: i));

      if (i == 0 && scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      int index = random.nextInt(duaas.length);
      // Try to avoid repeating the same duaa consecutive days
      if (index == lastIndex && duaas.length > 1) {
        index = (index + 1) % duaas.length;
      }
      lastIndex = index;

      await _scheduleSingleMasbaha(
        id: 555 + i,
        title: 'دعاء اليوم',
        body: duaas[index],
        date: scheduledDate,
        channelId: 'khatma_channel', // Reusing general religious channel
      );
    }
  }

  Future<void> cancelDuaaRotations() async {
    for (int i = 555; i <= 561; i++) {
      await _flutterLocalNotificationsPlugin.cancel(i);
    }
  }

  // -----------------------------------------------------

  Future<void> _scheduleSingleMasbaha({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required String channelId,
  }) async {
    fln.AndroidScheduleMode scheduleMode =
        fln.AndroidScheduleMode.exactAllowWhileIdle;
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        scheduleMode = fln.AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          channelId,
          title,
          channelDescription: 'تذكيرات يومية',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
          icon: '@mipmap/launcher_icon',
          styleInformation: fln.BigTextStyleInformation(body),
        ),
        iOS: const fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      payload: 'duaa_daily_random',
    );
  }

  /// Cancel all Masbaha related
  Future<void> cancelMasbahaNotifications() async {
    await cancelTasbeehNotifications();
    await cancelIstighfarNotifications();
    await cancelDuaaRotations();
  }

  // --- GENERIC AZKAR ROTATION SCHEDULING ---
  Future<void> scheduleRotatedReminders({
    required int baseId,
    required String title,
    required List<String> contentList,
    required TimeOfDay time,
    required String channelId,
    required String payloadTag,
  }) async {
    // 1. Cancel previous 7 days to avoid duplicates
    for (int i = 0; i < 7; i++) {
      await cancelNotification(baseId + i);
    }

    final now = DateTime.now();
    final random = Random();

    // Determine start date
    var startDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (startDate.isBefore(now)) {
      startDate = startDate.add(const Duration(days: 1));
    }

    // Schedule for next 7 days
    for (int i = 0; i < 7; i++) {
      final scheduledDate = startDate.add(Duration(days: i));

      // Pick random content
      final content = contentList[random.nextInt(contentList.length)];

      await _scheduleSingleOneOffNotification(
        id: baseId + i,
        title: title,
        body: content,
        date: scheduledDate,
        channelId: channelId,
        payload: '${payloadTag}_day_$i',
      );
    }

    debugPrint(
      "✅ Rotated Reminders Scheduled for $payloadTag (Base ID: $baseId)",
    );
  }

  Future<void> _scheduleSingleOneOffNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required String channelId,
    required String payload,
  }) async {
    fln.AndroidScheduleMode scheduleMode =
        fln.AndroidScheduleMode.exactAllowWhileIdle;
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        scheduleMode = fln.AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          channelId,
          title,
          importance: fln.Importance.max,
          priority: fln.Priority.high,
          icon: '@mipmap/launcher_icon',
          styleInformation: fln.BigTextStyleInformation(body),
        ),
        iOS: const fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      payload: payload,
    );
  }

  // --- SALAT ON PROPHET SCHEDULING ---
  // --- SALAT ON PROPHET SCHEDULING ---
  Future<void> scheduleSalatOnProphetReminder({
    required TimeOfDay time,
    required int id,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    fln.AndroidScheduleMode scheduleMode =
        fln.AndroidScheduleMode.exactAllowWhileIdle;
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        scheduleMode = fln.AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      "صل على الحبيب قلبك يطيب ❤️",
      "اللهم صل وسلم على نبينا محمد وعلى آله وصحبه أجمعين.",
      tz.TZDateTime.from(scheduledDate, tz.local),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'salat_on_prophet_channel',
          'الصلاة على النبي',
          channelDescription: 'تذكير يومي بالصلاة على النبي',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: fln.DateTimeComponents.time, // Daily repeat
      payload: 'salat_on_prophet',
    );

    debugPrint("🔔 Salat on Prophet Scheduled at $time with ID: $id");
  }

  Future<void> cancelSalatOnProphetReminder(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllSalatOnProphetReminders() async {
    for (int i = 0; i < 50; i++) {
      await _flutterLocalNotificationsPlugin.cancel(
        NotificationIds.salatOnProphetBase + i,
      );
    }
  }

  // --- FAJR ALARM SCHEDULING ---
  Future<void> scheduleFajrAlarm({
    required DateTime alarmTime,
    required String title,
    required String body,
    required String payload,
  }) async {
    fln.AndroidScheduleMode scheduleMode =
        fln.AndroidScheduleMode.exactAllowWhileIdle;
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        scheduleMode = fln.AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    const fln.AndroidNotificationDetails androidPlatformChannelSpecifics =
        fln.AndroidNotificationDetails(
          'fajr_alarm_channel_v2',
          'منبه الفجر الذكي',
          channelDescription: 'تنبيه ذكي لصلاة الفجر',
          importance: fln.Importance.max,
          priority: fln.Priority.max,
          fullScreenIntent: true,
          sound: fln.RawResourceAndroidNotificationSound('alarm'),
          playSound: true,
          audioAttributesUsage: fln.AudioAttributesUsage.alarm,
        );

    const fln.NotificationDetails platformChannelSpecifics =
        fln.NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      10001,
      title,
      body,
      tz.TZDateTime.from(alarmTime, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: scheduleMode,
      payload: payload,
    );

    debugPrint("✅ Fajr Alarm Scheduled via NotificationService for $alarmTime");
  }

  Future<void> cancelFajrAlarm() async {
    await _flutterLocalNotificationsPlugin.cancel(10001);
  }
}
