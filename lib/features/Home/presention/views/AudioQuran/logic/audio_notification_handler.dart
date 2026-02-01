// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class AudioNotificationHandler {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static const int _notificationId = 888; // Unique ID for Audio Player
//   static const String _channelId = 'audio_playback_channel';
//   static const String _channelName = 'Audio Playback';
//   static const String _channelDesc =
//       'Shows current playing Quran reciter and surah';

//   static Future<void> init() async {
//     // Assuming global init is done in main.dart, but we ensure channel exists
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       _channelId,
//       _channelName,
//       description: _channelDesc,
//       importance: Importance.low, // Low importance to avoid sound/vibration
//       playSound: false,
//       enableVibration: false,
//       showBadge: false,
//     );

//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(channel);
//   }

//   static Future<void> showNotification({
//     required String surahName,
//     required String reciterName,
//     required bool isPlaying,
//   }) async {
//     final AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//           _channelId,
//           _channelName,
//           channelDescription: _channelDesc,
//           importance: Importance.low,
//           priority: Priority.low,
//           playSound: false,
//           enableVibration: false,
//           ongoing: true, // Persistent while playing
//           autoCancel: false,
//           showWhen: false,
//           styleInformation: const MediaStyleInformation(),
//           // Adding basic actions (Simulation - callbacks need extra setup)
//           actions: [
//             const AndroidNotificationAction(
//               'prev',
//               'السابق',
//               icon: DrawableResourceAndroidBitmap(
//                 'ic_media_previous',
//               ), // Standard android icons may need adjustment
//             ),
//             AndroidNotificationAction(
//               isPlaying ? 'pause' : 'play',
//               isPlaying ? 'إيقاف' : 'تشغيل',
//               icon: DrawableResourceAndroidBitmap(
//                 isPlaying ? 'ic_media_pause' : 'ic_media_play',
//               ),
//             ),
//             const AndroidNotificationAction(
//               'next',
//               'التالي',
//               icon: DrawableResourceAndroidBitmap('ic_media_next'),
//             ),
//           ],
//         );

//     final NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//     );

//     await _notificationsPlugin.show(
//       _notificationId,
//       surahName, // Title
//       reciterName, // Body
//       details,
//     );
//   }

//   static Future<void> cancel() async {
//     await _notificationsPlugin.cancel(_notificationId);
//   }
// }
