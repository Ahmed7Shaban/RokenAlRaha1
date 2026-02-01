import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/services/notification_service.dart';
import '../../../../../../core/theme/app_colors.dart';

class MasbahaNotificationSettingsBottomSheet extends StatefulWidget {
  const MasbahaNotificationSettingsBottomSheet({super.key});

  @override
  State<MasbahaNotificationSettingsBottomSheet> createState() =>
      _MasbahaNotificationSettingsBottomSheetState();
}

class _MasbahaNotificationSettingsBottomSheetState
    extends State<MasbahaNotificationSettingsBottomSheet> {
  // Tasbeeh Settings
  bool _isTasbeehEnabled = false;
  TimeOfDay _tasbeehTime = const TimeOfDay(hour: 10, minute: 0);

  // Istighfar Settings
  bool _isIstighfarEnabled = false;
  TimeOfDay _istighfarTime = const TimeOfDay(hour: 10, minute: 0);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Tasbeeh Load
      _isTasbeehEnabled = prefs.getBool('tasbeeh_notif_enabled') ?? false;
      final tHour = prefs.getInt('tasbeeh_notif_hour') ?? 10;
      final tMinute = prefs.getInt('tasbeeh_notif_minute') ?? 0;
      _tasbeehTime = TimeOfDay(hour: tHour, minute: tMinute);

      // Istighfar Load
      _isIstighfarEnabled = prefs.getBool('istighfar_notif_enabled') ?? false;
      final iHour = prefs.getInt('istighfar_notif_hour') ?? 10;
      final iMinute = prefs.getInt('istighfar_notif_minute') ?? 0;
      _istighfarTime = TimeOfDay(hour: iHour, minute: iMinute);

      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationService = NotificationService();

    // Request permissions once
    if (_isTasbeehEnabled || _isIstighfarEnabled) {
      await notificationService.requestPermissions();
    }

    // --- Save & Schedule Tasbeeh ---
    await prefs.setBool('tasbeeh_notif_enabled', _isTasbeehEnabled);
    await prefs.setInt('tasbeeh_notif_hour', _tasbeehTime.hour);
    await prefs.setInt('tasbeeh_notif_minute', _tasbeehTime.minute);

    if (_isTasbeehEnabled) {
      await notificationService.scheduleTasbeehRotations(time: _tasbeehTime);
    } else {
      await notificationService.cancelTasbeehNotifications();
    }

    // --- Save & Schedule Istighfar ---
    await prefs.setBool('istighfar_notif_enabled', _isIstighfarEnabled);
    await prefs.setInt('istighfar_notif_hour', _istighfarTime.hour);
    await prefs.setInt('istighfar_notif_minute', _istighfarTime.minute);

    if (_isIstighfarEnabled) {
      await notificationService.scheduleIstighfarRotations(
        time: _istighfarTime,
      );
    } else {
      await notificationService.cancelIstighfarNotifications();
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ الإعدادات بنجاح')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إشعارات المسبحة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Tasbeeh Section ---
            _buildSectionHeader('تنبيهات التسبيح'),
            _buildToggleTile(
              title: 'تفعيل إشعارات التسبيح',
              value: _isTasbeehEnabled,
              onChanged: (val) => setState(() => _isTasbeehEnabled = val),
            ),
            if (_isTasbeehEnabled)
              _buildTimePicker(
                time: _tasbeehTime,
                onTimeChanged: (newTime) =>
                    setState(() => _tasbeehTime = newTime),
              ),

            const Divider(height: 32),

            // --- Istighfar Section ---
            _buildSectionHeader('تنبيهات الاستغفار'),
            _buildToggleTile(
              title: 'تفعيل إشعارات الاستغفار',
              value: _isIstighfarEnabled,
              onChanged: (val) => setState(() => _isIstighfarEnabled = val),
            ),
            if (_isIstighfarEnabled)
              _buildTimePicker(
                time: _istighfarTime,
                onTimeChanged: (newTime) =>
                    setState(() => _istighfarTime = newTime),
              ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'حفظ الكل',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        value: value,
        activeColor: AppColors.primaryColor,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTimePicker({
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onTimeChanged,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'وقت التذكير',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            time.format(context),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primaryColor,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onTimeChanged(picked);
          }
        },
      ),
    );
  }
}
