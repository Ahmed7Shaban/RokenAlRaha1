import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../models/azkar_stats_service.dart';

class AzkarStatsWidget extends StatefulWidget {
  const AzkarStatsWidget({super.key});

  @override
  State<AzkarStatsWidget> createState() => _AzkarStatsWidgetState();
}

class _AzkarStatsWidgetState extends State<AzkarStatsWidget> {
  List<int> _weeklyActivity = [];
  bool _isLoadingActivity = true;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    AzkarStatsService.init();
    _loadExtraStats();

    // Listen to changes in streak to update badges in real-time
    AzkarStatsService.currentStreakNotifier.addListener(_updateStreak);
  }

  @override
  void dispose() {
    AzkarStatsService.currentStreakNotifier.removeListener(_updateStreak);
    super.dispose();
  }

  void _updateStreak() {
    setState(() => _streak = AzkarStatsService.currentStreakNotifier.value);
  }

  Future<void> _loadExtraStats() async {
    final activity = await AzkarStatsService.getWeeklyActivity();
    final streak = await AzkarStatsService.getStreak();
    if (mounted) {
      setState(() {
        _weeklyActivity = activity;
        _streak = streak;
        _isLoadingActivity = false;
      });
    }
  }

  void _showBadgeInfo(
    BuildContext context,
    String title,
    String desc,
    bool unlocked,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                unlocked
                    ? Icons.emoji_events_rounded
                    : Icons.lock_outline_rounded,
                size: 60,
                color: unlocked ? AppColors.goldenYellow : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              if (!unlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "استمر في الأذكار لفتح هذا الوسام",
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'حسناً',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 5),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Total Count & Streak Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: AzkarStatsService.totalTasbeehNotifier,
                  builder: (context, count, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "إجمالي الأذكار",
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "$count",
                          style: GoogleFonts.tajawal(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Current Streak Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.goldenYellow.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$_streak يوم",
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 30),

          // 2. Weekly Activity Chart
          Text(
            "نشاطك الأسبوعي",
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingActivity)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  // counts are ordered [Today-6, ..., Today]
                  // Let's get day label
                  final date = DateTime.now().subtract(
                    Duration(days: 6 - index),
                  );
                  final dayLabel = DateFormat.E(
                    'ar',
                  ).format(date); // Need Ar locale setup, or custom
                  // Fallback simple labels if locale not ready
                  // final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S']; // simpler?

                  final count = _weeklyActivity.isNotEmpty
                      ? _weeklyActivity[index]
                      : 0;
                  final max = _weeklyActivity.reduce(
                    (a, b) => a > b ? a : b,
                  ); // simplistic max
                  final double percentage = max == 0 ? 0 : (count / max);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: "$count ذكر",
                        child:
                            Container(
                              width: 8, // Thin bars styling
                              height: 60 * percentage + 10, // Min height 10
                              decoration: BoxDecoration(
                                color: index == 6
                                    ? AppColors.primaryColor
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ).animate().scaleY(
                              begin: 0,
                              end: 1,
                              duration: 400.ms,
                              delay: (index * 50).ms,
                              alignment: Alignment.bottomCenter,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        // dayLabel, // Use simple index based if needed
                        DateFormat('E', 'ar').format(date),
                        style: GoogleFonts.tajawal(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

          const Divider(height: 30),

          // 3. Badges Section
          Text(
            "الأوسمة والإنجازات",
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBadge(
                context,
                "المواظب",
                _streak >= 7,
                "واظب على الأذكار لمدة 7 أيام متتالية",
              ),
              _buildBadge(
                context,
                "المتميز",
                AzkarStatsService.totalTasbeehNotifier.value >= 1000,
                "أكمل 1000 ذكر إجمالاً",
              ),
              _buildBadge(
                context,
                "الأسطورة",
                AzkarStatsService.totalTasbeehNotifier.value >= 5000,
                "أكمل 5000 ذكر إجمالاً",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String name,
    bool unlocked,
    String criteria,
  ) {
    return GestureDetector(
      onTap: () => _showBadgeInfo(context, name, criteria, unlocked),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? AppColors.goldenYellow.withOpacity(0.15)
                  : Colors.grey[100]!,
              border: Border.all(
                color: unlocked ? AppColors.goldenYellow : Colors.grey[300]!,
              ),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: unlocked ? AppColors.goldenYellow : Colors.grey[400]!,
              size: 28,
            ),
          ).animate(target: unlocked ? 1 : 0).shimmer(duration: 2000.ms),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: unlocked ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
