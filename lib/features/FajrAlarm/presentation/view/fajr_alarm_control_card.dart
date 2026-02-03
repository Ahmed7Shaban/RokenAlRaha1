import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../services/fajr_alarm_service.dart';
import 'fajr_alarm_screen.dart';

class FajrAlarmControlCard extends StatefulWidget {
  const FajrAlarmControlCard({super.key});

  @override
  State<FajrAlarmControlCard> createState() => _FajrAlarmControlCardState();
}

class _FajrAlarmControlCardState extends State<FajrAlarmControlCard> {
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
    // Save
    await _service.saveSettings(enabled: value, offset: _offset);
    // Note: Re-scheduling usually requires Fajr Time.
    // Ideally this widget should have access to SmartContainerCubit to get prayer times.
    // For now we just save preferences. The SmartContainerCubit refresh loop or init should handle scheduling.
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
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
                    setSheetState(() => _enabled = val);
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
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                            ),
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
                          setSheetState(() => _offset = val.toInt());
                          setState(
                            () => _offset = val.toInt(),
                          ); // Update parent too
                        },
                        onChangeEnd: (val) {
                          _service.saveSettings(
                            enabled: _enabled,
                            offset: val.toInt(),
                          );
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Test Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FajrAlarmScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.alarm_on),
                    label: const Text("تجربة المنبه الآن"),
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Light greyish
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showSettingsSheet,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _enabled
                        ? AppColors.primaryColor
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.wb_twilight_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "منبه الفجر الذكي 🕌",
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _enabled
                            ? "نشط - قبل الفجر بـ $_offset دقيقة"
                            : "المنبه غير مفعل",
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow or Setting Icon
                Icon(Icons.settings, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
