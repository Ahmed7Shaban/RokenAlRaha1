import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../services/azkar_notification_helper.dart';

import '../date/morning_list.dart';
import '../date/evening_list.dart';
import '../date/wakeUp_list.dart';
import '../date/sleep_list.dart';

class AzkarNotificationSettingsSheet extends StatefulWidget {
  // ... (No change to class definition)
  final String title;
  final String notificationKey;
  final String notificationBody;

  const AzkarNotificationSettingsSheet({
    super.key,
    required this.title,
    required this.notificationKey,
    required this.notificationBody,
  });

  @override
  State<AzkarNotificationSettingsSheet> createState() =>
      _AzkarNotificationSettingsSheetState();
}

class _AzkarNotificationSettingsSheetState
    extends State<AzkarNotificationSettingsSheet> {
  // ... (No change to state vars)
  bool _isEnabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await AzkarNotificationHelper.getSettings(
      widget.notificationKey,
    );
    if (mounted) {
      setState(() {
        _isEnabled = settings['enabled'];
        _time = settings['time'];
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);

    // Select dynamic content based on key
    List<String>? dynamicContent;
    if (widget.notificationKey == 'morning_azkar')
      dynamicContent = morningAzkar;
    else if (widget.notificationKey == 'evening_azkar')
      dynamicContent = eveningAzkar;
    else if (widget.notificationKey == 'wakeup_azkar')
      dynamicContent = wakeUpAzkar;
    else if (widget.notificationKey == 'sleep_azkar')
      dynamicContent = sleepAzkar;

    if (_isEnabled) {
      await AzkarNotificationHelper.scheduleAzkarNotification(
        key: widget.notificationKey,
        title: widget.title,
        body: widget.notificationBody,
        time: _time,
        dynamicContent: dynamicContent,
      );
    } else {
      await AzkarNotificationHelper.cancelAzkarNotification(
        widget.notificationKey,
      );
    }
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ الإعدادات')));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
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
      setState(() => _time = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "تنبيه ${widget.title}",
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            SwitchListTile(
              title: Text(
                "تفعيل التنبيه",
                style: GoogleFonts.tajawal(fontSize: 16),
              ),
              value: _isEnabled,
              activeColor: AppColors.primaryColor,
              onChanged: (val) => setState(() => _isEnabled = val),
            ),
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: Column(
                children: [
                  const Divider(),
                  ListTile(
                    title: Text(
                      "وقت التنبيه",
                      style: GoogleFonts.tajawal(fontSize: 16),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _time.format(context),
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    onTap: _pickTime,
                  ),
                ],
              ),
              crossFadeState: _isEnabled
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "حفظ",
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
