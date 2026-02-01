// import 'dart:ui';

// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:permission_handler/permission_handler.dart';

// class UnifiedNotificationService {
//   /// 🔕 مفتاح تعطيل الإشعارات مؤقتاً
//   static const bool areNotificationsEnabled = false;

//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static bool _isInitialized = false;

//   static Future<void> init() async {
//     if (!areNotificationsEnabled) {
//       print('🔕 خدمة الإشعارات معطلة مؤقتاً');
//       return;
//     }
//     if (_isInitialized) {
//       print('⚠️ خدمة الإشعارات مهيأة مسبقاً');
//       return;
//     }

//     try {
//       tz.initializeTimeZones();

//       // طلب الأذونات
//       await _requestPermissions();

//       // إنشاء قنوات الإشعارات
//       await _createNotificationChannels();

//       const androidSettings = AndroidInitializationSettings('launcher_icon');
//       const initSettings = InitializationSettings(android: androidSettings);

//       final initialized = await _notificationsPlugin.initialize(
//         initSettings,
//         onDidReceiveNotificationResponse: _onNotificationTap,
//       );

//       if (initialized == true) {
//         _isInitialized = true;
//         print('✅ تم تهيئة خدمة الإشعارات الموحدة بنجاح');
//       } else {
//         print('❌ فشل في تهيئة خدمة الإشعارات');
//       }
//     } catch (e) {
//       print('❌ خطأ في تهيئة خدمة الإشعارات: $e');
//     }
//   }

//   // إنشاء قنوات الإشعارات
//   static Future<void> _createNotificationChannels() async {
//     try {
//       // قناة أذكار الصباح
//       const morningChannel = AndroidNotificationChannel(
//         'morning_azkar_channel',
//         'أذكار الصباح',
//         description: 'إشعارات أذكار الصباح اليومية',
//         importance: Importance.high,
//         playSound: true,
//         enableVibration: true,
//         enableLights: false, // تعطيل الأضواء لتجنب الخطأ
//         showBadge: true,
//       );

//       // قناة إشعارات الصلاة
//       const prayerChannel = AndroidNotificationChannel(
//         'prayer_notifications_channel',
//         'إشعارات الصلاة',
//         description: 'تنبيهات مواقيت الصلاة',
//         importance: Importance.max,
//         playSound: true,
//         enableVibration: true,
//         enableLights: false, // تعطيل الأضواء لتجنب الخطأ
//         showBadge: true,
//       );

//       // قناة الاختبار
//       const testChannel = AndroidNotificationChannel(
//         'test_notifications_channel',
//         'اختبار الإشعارات',
//         description: 'قناة لاختبار الإشعارات',
//         importance: Importance.max,
//         playSound: true,
//         enableVibration: true,
//         enableLights: false, // تعطيل الأضواء لتجنب الخطأ
//         showBadge: true,
//       );

//       // إنشاء القنوات
//       await _notificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin
//           >()
//           ?.createNotificationChannel(morningChannel);

//       await _notificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin
//           >()
//           ?.createNotificationChannel(prayerChannel);

//       await _notificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin
//           >()
//           ?.createNotificationChannel(testChannel);

//       print('✅ تم إنشاء قنوات الإشعارات بنجاح');
//     } catch (e) {
//       print('❌ خطأ في إنشاء قنوات الإشعارات: $e');
//     }
//   }

//   static Future<void> _requestPermissions() async {
//     try {
//       // طلب إذن الإشعارات
//       final notificationStatus = await Permission.notification.request();
//       print('📱 حالة إذن الإشعارات: $notificationStatus');

//       if (notificationStatus.isDenied) {
//         print('❌ تم رفض إذن الإشعارات - يجب تمكينها من إعدادات التطبيق');
//       } else if (notificationStatus.isPermanentlyDenied) {
//         print('❌ تم رفض إذن الإشعارات نهائياً - يجب الذهاب لإعدادات التطبيق');
//         await openAppSettings();
//       }

//       // طلب إذن المنبهات الدقيقة (مطلوب لـ Android 12+)
//       final alarmStatus = await Permission.scheduleExactAlarm.request();
//       print('⏰ حالة إذن المنبهات الدقيقة: $alarmStatus');

//       if (alarmStatus.isDenied) {
//         print('❌ تم رفض إذن المنبهات الدقيقة - قد لا تعمل الإشعارات المجدولة');
//       }

//       // فحص إضافي لحالة البطارية
//       final batteryOptimization =
//           await Permission.ignoreBatteryOptimizations.status;
//       print('🔋 حالة تحسين البطارية: $batteryOptimization');
//     } on PlatformException catch (e) {
//       if (e.code == 'PermissionHandler.PermissionManager' &&
//           e.message?.contains('Unable to detect current Android Activity') ==
//               true) {
//         print('⚠️ تعذر طلب الأذونات: لا يوجد نشاط نشط (قد يكون في الخلفية)');
//       } else {
//         print('❌ خطأ منصة في طلب الأذونات: $e');
//       }
//     } catch (e) {
//       print('❌ خطأ في طلب الأذونات: $e');
//     }
//   }

//   static void _onNotificationTap(NotificationResponse response) {
//     print('🔔 تم النقر على الإشعار: ${response.payload}');
//   }

//   // للحصول على instance الـ plugin
//   static FlutterLocalNotificationsPlugin get plugin => _notificationsPlugin;

//   // للتحقق من حالة التهيئة
//   static bool get isInitialized => _isInitialized;

//   // دالة اختبار
//   static Future<void> showTestNotification() async {
//     if (!areNotificationsEnabled) {
//       print('🔕 خدمة الإشعارات معطلة مؤقتاً');
//       return;
//     }
//     if (!_isInitialized) {
//       print('⚠️ يجب تهيئة الخدمة أولاً');
//       await init();
//     }

//     try {
//       await _notificationsPlugin.show(
//         999,
//         '🔔 اختبار فوري',
//         'إذا ظهر هذا الإشعار، فالنظام يعمل بشكل صحيح ✅',
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'test_notifications_channel',
//             'اختبار الإشعارات',
//             channelDescription: 'قناة لاختبار الإشعارات',
//             importance: Importance.max,
//             priority: Priority.high,
//             icon: 'launcher_icon',
//             playSound: true,
//             enableVibration: true,
//             enableLights: false, // تعطيل الأضواء لتجنب الخطأ
//             color: Color(0xFFFF9800),
//             colorized: true,
//             autoCancel: true,
//             ongoing: false,
//             showWhen: true,
//             usesChronometer: false,
//             fullScreenIntent: false,
//           ),
//         ),
//         payload: 'test_notification',
//       );
//       print('✅ تم إرسال إشعار تجريبي فوري');
//     } catch (e) {
//       print('❌ خطأ في إرسال الإشعار التجريبي: $e');
//     }
//   }

//   // عرض قائمة الإشعارات المجدولة
//   static Future<void> showPendingNotifications() async {
//     final pending = await _notificationsPlugin.pendingNotificationRequests();
//     print('📅 عدد الإشعارات المجدولة: ${pending.length}');

//     for (var notification in pending) {
//       print('🔔 ID: ${notification.id}, العنوان: ${notification.title}');
//     }
//   }

//   // إلغاء جميع الإشعارات
//   static Future<void> cancelAllNotifications() async {
//     await _notificationsPlugin.cancelAll();
//     print('🗑️ تم إلغاء جميع الإشعارات');
//   }

//   // فحص شامل لحالة النظام
//   static Future<Map<String, dynamic>> checkSystemStatus() async {
//     final status = <String, dynamic>{};

//     try {
//       // فحص التهيئة
//       status['initialized'] = _isInitialized;

//       // فحص الأذونات
//       status['notification_permission'] = await Permission.notification.status;
//       status['exact_alarm_permission'] =
//           await Permission.scheduleExactAlarm.status;
//       status['battery_optimization'] =
//           await Permission.ignoreBatteryOptimizations.status;

//       // فحص الإشعارات المجدولة
//       final pending = await _notificationsPlugin.pendingNotificationRequests();
//       status['pending_notifications_count'] = pending.length;
//       status['pending_notifications'] = pending
//           .map((n) => {'id': n.id, 'title': n.title, 'body': n.body})
//           .toList();

//       // طباعة التشخيص
//       print('🔍 تشخيص النظام:');
//       print('✅ مهيأ: ${status['initialized']}');
//       print('📱 إذن الإشعارات: ${status['notification_permission']}');
//       print('⏰ إذن المنبهات: ${status['exact_alarm_permission']}');
//       print('🔋 تحسين البطارية: ${status['battery_optimization']}');
//       print(
//         '📅 عدد الإشعارات المجدولة: ${status['pending_notifications_count']}',
//       );

//       for (var notif in status['pending_notifications']) {
//         print('🔔 إشعار مجدول: ${notif['id']} - ${notif['title']}');
//       }
//     } catch (e) {
//       print('❌ خطأ في فحص النظام: $e');
//       status['error'] = e.toString();
//     }

//     return status;
//   }

//   // دالة لإصلاح المشاكل الشائعة
//   static Future<void> fixCommonIssues() async {
//     print('🔧 محاولة إصلاح المشاكل الشائعة...');

//     try {
//       // إعادة تهيئة الخدمة
//       _isInitialized = false;
//       await init();

//       // إلغاء جميع الإشعارات وإعادة إنشائها
//       await cancelAllNotifications();

//       // طلب استثناء من تحسين البطارية
//       await requestBatteryOptimizationExemption();

//       print('✅ تم إصلاح المشاكل الشائعة');
//     } catch (e) {
//       print('❌ فشل في إصلاح المشاكل: $e');
//     }
//   }

//   // طلب استثناء من تحسين البطارية
//   static Future<void> requestBatteryOptimizationExemption() async {
//     try {
//       final batteryOptimizationStatus =
//           await Permission.ignoreBatteryOptimizations.status;

//       if (batteryOptimizationStatus.isDenied) {
//         print('⚠️ التطبيق خاضع لتحسين البطارية - سيتم طلب الاستثناء');
//         final result = await Permission.ignoreBatteryOptimizations.request();

//         if (result.isGranted) {
//           print('✅ تم استثناء التطبيق من تحسين البطارية');
//         } else {
//           print('❌ فشل في استثناء التطبيق من تحسين البطارية');
//           print('💡 يجب استثناء التطبيق يدوياً من إعدادات البطارية');
//         }
//       } else {
//         print('✅ التطبيق مستثنى من تحسين البطارية');
//       }
//     } catch (e) {
//       print('❌ خطأ في فحص تحسين البطارية: $e');
//     }
//   }

//   // إرشادات لحل مشاكل الإشعارات
//   static void printTroubleshootingGuide() {
//     print('''
// 🔧 دليل حل مشاكل الإشعارات:

// 1. تحقق من الأذونات:
//    - الإعدادات > التطبيقات > ركن الراحة > الأذونات
//    - فعّل "الإشعارات"

// 2. تحقق من قنوات الإشعارات:
//    - الإعدادات > التطبيقات > ركن الراحة > الإشعارات
//    - تأكد من تفعيل جميع القنوات

// 3. إعدادات البطارية:
//    - الإعدادات > البطارية > تحسين البطارية
//    - استثني "ركن الراحة" من التحسين

// 4. إعدادات عدم الإزعاج:
//    - تأكد من عدم تفعيل وضع "عدم الإزعاج"
//    - أو أضف التطبيق للاستثناءات

// 5. إعادة تشغيل الجهاز:
//    - أحياناً يساعد إعادة تشغيل الجهاز

// ''');
//   }
// }
