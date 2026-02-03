import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../../../core/theme/app_colors.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../FajrAlarm/presentation/view/fajr_alarm_settings_sheet.dart';
import '../cubit/smart_container_cubit.dart';

class PrayerListSheet extends StatelessWidget {
  final PrayerTimes prayerTimes;

  const PrayerListSheet({super.key, required this.prayerTimes});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmartContainerCubit, SmartContainerState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'مواقيت الصلاة',
                    style: GoogleFonts.tajawal(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // --- Reminder Settings Section ---
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'تذكير "هل صليت؟"',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'إشعار للمتابعة بعد الصلاة',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: state.isPrayerReminderEnabled,
                                activeColor: AppColors.primaryColor,
                                onChanged: (value) {
                                  context
                                      .read<SmartContainerCubit>()
                                      .togglePrayerReminder(value);
                                },
                              ),
                            ],
                          ),
                          if (state.isPrayerReminderEnabled) ...[
                            const Divider(),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'وقت التذكير بعد (بالدقائق):',
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [5, 10, 15, 20, 30].map((mins) {
                                final isSelected =
                                    state.prayerReminderDelay == mins;
                                return GestureDetector(
                                  onTap: () {
                                    context
                                        .read<SmartContainerCubit>()
                                        .setPrayerReminderDelay(mins);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryColor
                                            : Colors.grey.withOpacity(0.3),
                                        width: isSelected ? 0 : 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryColor
                                                    .withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$mins',
                                        style: GoogleFonts.tajawal(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                'تذكير بعد ${state.prayerReminderDelay} دقائق',
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // ---------------------------------
                  const SizedBox(height: 20),
                  _buildPrayerRow(
                    context,
                    'الفجر',
                    prayerTimes.fajr,
                    prayerTimes.nextPrayer() == Prayer.fajr,
                  ),
                  _buildPrayerRow(
                    context,
                    'الشروق',
                    prayerTimes.sunrise,
                    false,
                  ),
                  _buildPrayerRow(
                    context,
                    'الظهر',
                    prayerTimes.dhuhr,
                    prayerTimes.nextPrayer() == Prayer.dhuhr,
                  ),
                  _buildPrayerRow(
                    context,
                    'العصر',
                    prayerTimes.asr,
                    prayerTimes.nextPrayer() == Prayer.asr,
                  ),
                  _buildPrayerRow(
                    context,
                    'المغرب',
                    prayerTimes.maghrib,
                    prayerTimes.nextPrayer() == Prayer.maghrib,
                  ),
                  _buildPrayerRow(
                    context,
                    'العشاء',
                    prayerTimes.isha,
                    prayerTimes.nextPrayer() == Prayer.isha,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrayerRow(
    BuildContext context,
    String name,
    DateTime time,
    bool isNext,
  ) {
    bool isFajr = name == 'الفجر';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.primaryColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: isNext ? Border.all(color: AppColors.primaryColor) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                name,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                  color: isNext ? AppColors.primaryColor : Colors.black87,
                ),
              ),
              if (isFajr) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (context) => const FajrAlarmSettingsSheet(),
                    );
                  },
                  icon: const Icon(
                    Icons.alarm_add,
                    color: AppColors.goldenYellow,
                  ),
                  tooltip: "إعدادات منبه الفجر",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          Text(
            intl.DateFormat('h:mm a', 'ar').format(time),
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
              color: isNext ? AppColors.primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
