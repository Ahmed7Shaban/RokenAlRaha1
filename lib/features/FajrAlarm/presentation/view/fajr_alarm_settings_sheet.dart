import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../services/fajr_alarm_service.dart';
import 'fajr_alarm_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Home/presention/views/SmartContainer/cubit/smart_container_cubit.dart';

class FajrAlarmSettingsSheet extends StatefulWidget {
  const FajrAlarmSettingsSheet({super.key});

  @override
  State<FajrAlarmSettingsSheet> createState() => _FajrAlarmSettingsSheetState();
}

class _FajrAlarmSettingsSheetState extends State<FajrAlarmSettingsSheet> {
  final FajrAlarmService _service = FajrAlarmService();
  bool _enabled = false;
  int _offset = 20;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final settings = await _service.getSettings();
    if (mounted) {
      setState(() {
        _enabled = settings['enabled'];
        _offset = settings['offset'];
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAlarm(bool value) async {
    setState(() {
      _enabled = value;
    });
    await _service.saveSettings(enabled: value, offset: _offset);
    if (mounted) {
      context.read<SmartContainerCubit>().refreshFajrAlarm();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "إعدادات منبه الفجر الذكي",
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // Toggle
          SwitchListTile(
            title: Text(
              "تفعيل المنبه",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            ),
            value: _enabled,
            activeColor: AppColors.primaryColor,
            onChanged: (val) {
              _toggleAlarm(val);
            },
          ),

          const SizedBox(height: 10),

          // Offset Control
          if (_enabled)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "وقت التنبيه",
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "قبل الفجر بـ $_offset دقيقة",
                      style: GoogleFonts.tajawal(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _offset.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  activeColor: AppColors.primaryColor,
                  label: "$_offset دقيقة",
                  onChanged: (val) {
                    setState(() => _offset = val.toInt());
                  },
                  onChangeEnd: (val) async {
                    await _service.saveSettings(
                      enabled: _enabled,
                      offset: val.toInt(),
                    );
                    if (mounted) {
                      context.read<SmartContainerCubit>().refreshFajrAlarm();
                    }
                  },
                ),
              ],
            ),

          const SizedBox(height: 20),

          // Test Button
          // Test Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _service.scheduleTestAlarm();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "سيتم تشغيل المنبه بعد 10 ثوانٍ للتجربة ⏳",
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              icon: const Icon(Icons.timer_outlined),
              label: const Text("تجربة المنبه (بعد 10 ثوانٍ)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldenYellow,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
