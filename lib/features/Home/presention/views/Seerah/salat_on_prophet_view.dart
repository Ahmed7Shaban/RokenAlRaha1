import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/services/notification_service.dart';
import '../../../../../core/theme/app_colors.dart';
import 'widgets/salat_counter_widget.dart';
import 'widgets/salat_stats_share_card.dart';
import 'widgets/notification_settings_card.dart';
import 'widgets/benefits_section.dart';

class SalatOnProphetView extends StatefulWidget {
  static const String routeName = '/SalatOnProphet';

  const SalatOnProphetView({super.key});

  @override
  State<SalatOnProphetView> createState() => _SalatOnProphetViewState();
}

class _SalatOnProphetViewState extends State<SalatOnProphetView> {
  // State Variables
  int _counter = 0;
  bool _isNotificationEnabled = true;
  List<TimeOfDay> _reminderTimes = []; // List of reminder times
  final ScreenshotController _screenshotController = ScreenshotController();

  static const String _counterKey = 'salat_counter_total';
  static const String _notifEnabledKey = 'salat_notif_enabled';
  // Legacy key for single time
  static const String _legacyNotifTimeKey = 'salat_notif_time';
  // New key for list of times
  static const String _notifTimesListKey = 'salat_notif_times_list';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt(_counterKey) ?? 0;
      _isNotificationEnabled = prefs.getBool(_notifEnabledKey) ?? true;

      // 1. Try load new list
      final List<String>? timeStrings = prefs.getStringList(_notifTimesListKey);
      if (timeStrings != null) {
        _reminderTimes = timeStrings.map((str) {
          final parts = str.split(':');
          return TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }).toList();
      } else {
        // 2. Fallback: Try load legacy single time and migrate
        final legacyTimeStr = prefs.getString(_legacyNotifTimeKey);
        if (legacyTimeStr != null) {
          final parts = legacyTimeStr.split(':');
          final time = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
          _reminderTimes = [time];
          // Migrate immediately
          _saveTimes();
          prefs.remove(_legacyNotifTimeKey); // Clean up legacy
        } else {
          // Default: 8 PM if nothing set
          _reminderTimes = [const TimeOfDay(hour: 20, minute: 0)];
        }
      }
    });
  }

  Future<void> _saveTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> timeStrings = _reminderTimes.map((t) {
      return '${t.hour}:${t.minute}';
    }).toList();
    await prefs.setStringList(_notifTimesListKey, timeStrings);
  }

  Future<void> _incrementCounter() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _counter++;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, _counter);
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() {
      _isNotificationEnabled = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifEnabledKey, value);

    await _rescheduleAllReminders();
  }

  Future<void> _addReminder() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Check for duplicates
      final isDuplicate = _reminderTimes.any(
        (t) => t.hour == picked.hour && t.minute == picked.minute,
      );

      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('هذا الوقت مضاف بالفعل')),
          );
        }
        return;
      }

      setState(() {
        _reminderTimes.add(picked);
        // Sort times
        _reminderTimes.sort((a, b) {
          double aVal = a.hour + a.minute / 60.0;
          double bVal = b.hour + b.minute / 60.0;
          return aVal.compareTo(bVal);
        });
      });

      await _saveTimes();
      if (_isNotificationEnabled) {
        await _rescheduleAllReminders();
      }
    }
  }

  Future<void> _editReminder(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTimes[index],
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTimes[index]) {
      // Check for duplicates (excluding current index)
      final isDuplicate = _reminderTimes.asMap().entries.any(
        (entry) =>
            entry.key != index &&
            entry.value.hour == picked.hour &&
            entry.value.minute == picked.minute,
      );

      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('هذا الوقت مضاف بالفعل')),
          );
        }
        return;
      }

      setState(() {
        _reminderTimes[index] = picked;
        // Sort times
        _reminderTimes.sort((a, b) {
          double aVal = a.hour + a.minute / 60.0;
          double bVal = b.hour + b.minute / 60.0;
          return aVal.compareTo(bVal);
        });
      });

      await _saveTimes();
      if (_isNotificationEnabled) {
        await _rescheduleAllReminders();
      }
    }
  }

  Future<void> _removeTime(int index) async {
    setState(() {
      _reminderTimes.removeAt(index);
    });
    await _saveTimes();
    if (_isNotificationEnabled) {
      await _rescheduleAllReminders();
    }
  }

  Future<void> _rescheduleAllReminders() async {
    final notifService = NotificationService();
    // 1. Cancel all existing
    await notifService.cancelAllSalatOnProphetReminders();

    // 2. If enabled, schedule all in list
    if (_isNotificationEnabled) {
      // Limit to 50 to avoid ID collision if list is huge (unlikely)
      for (int i = 0; i < _reminderTimes.length && i < 50; i++) {
        await notifService.scheduleSalatOnProphetReminder(
          time: _reminderTimes[i],
          id: 900 + i, // Base ID 900
        );
      }
    }
  }

  Future<void> _resetCounter() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          "تصفير العداد",
          style: GoogleFonts.tajawal(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
        ),
        content: Text(
          "هل أنت متأكد من تصفير عداد الصلاة على النبي؟",
          style: GoogleFonts.tajawal(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "إلغاء",
              style: GoogleFonts.tajawal(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "تصفير",
              style: GoogleFonts.tajawal(
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _counter = 0;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_counterKey, _counter);
    }
  }

  Future<void> _shareStats() async {
    try {
      final double pixelRatio = MediaQuery.of(context).devicePixelRatio;

      // Capture the stats card
      final Uint8List imageBytes = await _screenshotController
          .captureFromWidget(
            SalatStatsShareCard(counter: _counter),
            delay: const Duration(milliseconds: 100),
            pixelRatio: pixelRatio > 2 ? pixelRatio : 3.0,
          );

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/salat_share.png',
      ).create();
      await imagePath.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text:
            'اللهم صل وسلم على نبينا محمد 🌸\nعدد صلواتي في التطبيق: $_counter',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء المشاركة: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "الصلاة على النبي",
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        toolbarHeight: 120,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () => _shareStats(),
            tooltip: 'مشاركة إنجازي',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. Decorative Patterns
          Positioned(
            top: -50,
            right: -50,
            child: Opacity(
              opacity: 0.1,
              child: const Icon(Icons.star, size: 300, color: Colors.white),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- Tasbeeh Counter Section ---
                  SalatCounterWidget(
                    counter: _counter,
                    onIncrement: _incrementCounter,
                    onReset: _resetCounter,
                  ),

                  const SizedBox(height: 20),

                  // --- Benefits Section ---
                  const BenefitsSection(),

                  const SizedBox(height: 20),

                  // --- Notification Settings ---
                  NotificationSettingsCard(
                    isNotificationEnabled: _isNotificationEnabled,
                    reminderTimes: _reminderTimes,
                    onToggle: _toggleNotification,
                    onAddTime: _addReminder,
                    onRemoveTime: _removeTime,
                    onEditTime: _editReminder,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
