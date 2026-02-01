import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../cubit/smart_container_cubit.dart';

class PrayerTrackingSheet extends StatelessWidget {
  const PrayerTrackingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocBuilder<SmartContainerCubit, SmartContainerState>(
        builder: (context, state) {
          final cubit = context.read<SmartContainerCubit>();

          return SingleChildScrollView(
            // For smaller screens
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'متابعة العبادات',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Settings moved to PrayerListSheet
                // const SizedBox(height: 24),

                // Motivation Message (Dynamic based on progress)
                _buildMotivationMessage(state),
                const SizedBox(height: 16),

                // Daily Checklist
                Text(
                  'صلوات  اليوم',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDailyChecklist(context, cubit, state),

                const SizedBox(height: 24),

                // Weekly Dashboard
                Text(
                  'سجل الأسبوع',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildWeeklyDashboard(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMotivationMessage(SmartContainerState state) {
    final now = DateTime.now();
    final dateKey = "${now.year}-${now.month}-${now.day}";
    final todayCount = state.completedPrayers[dateKey]?.length ?? 0;

    String message = "ابدأ يومك بذكر الله والصلاة";
    IconData icon = Icons.wb_sunny_outlined;

    if (todayCount >= 5) {
      message = "ما شاء الله! أتممت صلواتك اليوم، تقبل الله عملك.";
      icon = Icons.verified;
    } else if (todayCount >= 3) {
      message = "أحسنت! اقتربت من إتمام وردك، واصل.";
      icon = Icons.trending_up;
    } else if (todayCount > 0) {
      message = "بداية موفقة، لا تفوت باقي الصلوات.";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.tajawal(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChecklist(
    BuildContext context,
    SmartContainerCubit cubit,
    SmartContainerState state,
  ) {
    if (state.prayerTimes == null) return const SizedBox();

    final prayers = [
      {'key': 'Fajr', 'label': 'الفجر', 'time': state.prayerTimes!.fajr},
      {'key': 'Dhuhr', 'label': 'الظهر', 'time': state.prayerTimes!.dhuhr},
      {'key': 'Asr', 'label': 'العصر', 'time': state.prayerTimes!.asr},
      {'key': 'Maghrib', 'label': 'المغرب', 'time': state.prayerTimes!.maghrib},
      {'key': 'Isha', 'label': 'العشاء', 'time': state.prayerTimes!.isha},
    ];

    final now = DateTime.now();
    final dateKey = "${now.year}-${now.month}-${now.day}";
    final completedList = state.completedPrayers[dateKey] ?? [];

    return Column(
      children: prayers.map((p) {
        final key = p['key'] as String;
        final label = p['label'] as String;
        final time = p['time'] as DateTime;
        final isCompleted = completedList.contains(key);
        final isTimePassed = now.isAfter(time);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: isTimePassed
              ? (isCompleted ? Colors.green.withOpacity(0.05) : Colors.white)
              : Colors.grey.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCompleted ? Colors.green : Colors.grey.shade200,
            ),
          ),
          child: CheckboxListTile(
            title: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              color: isTimePassed
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      if (!isTimePassed) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.lock_clock,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  DateFormat(
                    'h:mm a',
                    'en',
                  ).format(time).replaceAll('AM', 'ص').replaceAll('PM', 'م'),
                  style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            value: isCompleted,
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onChanged: isTimePassed
                ? (val) {
                    cubit.togglePrayerStatus(key, val ?? false);
                  }
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyDashboard(SmartContainerState state) {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final prayerIcons = {
      'Fajr': Icons.wb_twilight,
      'Dhuhr': Icons.wb_sunny,
      'Asr': Icons.wb_cloudy,
      'Maghrib': Icons.nights_stay_outlined,
      'Isha': Icons.nights_stay,
    };
    final now = DateTime.now();
    // Calculate start of the week (Sunday)
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final todayDate = DateTime(now.year, now.month, now.day);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "اليوم",
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              ...prayers.map(
                (p) => Expanded(
                  child: Center(
                    child: Icon(
                      prayerIcons[p],
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          // Rows
          ...List.generate(7, (index) {
            final date = startOfWeek.add(Duration(days: index));
            final dateKey = "${date.year}-${date.month}-${date.day}";
            final completed = state.completedPrayers[dateKey] ?? [];
            final dayName = DateFormat('EEEE', 'ar').format(date);

            final dateOnly = DateTime(date.year, date.month, date.day);
            final isToday = dateOnly.isAtSameMomentAs(todayDate);
            final isFuture = dateOnly.isAfter(todayDate);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        dayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday
                              ? AppColors.primaryColor
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  ...prayers.map((p) {
                    final isDone = completed.contains(p);

                    if (isFuture) {
                      return Expanded(
                        child: Center(
                          child: Icon(
                            Icons.remove,
                            size: 14,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDone ? Icons.check : Icons.close,
                            size: 14,
                            color: isDone
                                ? Colors.green
                                : Colors.red.withOpacity(0.5),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.tajawal(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
          color: isHeader ? AppColors.primaryColor : Colors.black87,
        ),
      ),
    );
  }
}
