import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../../../data/models/daily_ward_model.dart';

class DailyWardItem extends StatelessWidget {
  final DailyWard ward;
  final VoidCallback onTap;

  const DailyWardItem({Key? key, required this.ward, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Time & Status Logic
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final wardDate = DateTime(ward.date.year, ward.date.month, ward.date.day);
    final isPast = wardDate.isBefore(today);
    final isToday = wardDate.isAtSameMomentAs(today);

    // 2. Styling Variables
    Color containerColor = const Color(0xFF1E1E2C); // Deep Dark (Premium)
    Color borderColor = Colors.transparent;
    Color iconColor = Colors.grey;
    IconData icon = Icons.circle_outlined;
    Color progressBarColor = AppColors.goldenYellow;
    String statusMessage = "";

    // 3. Logic Implementation
    if (ward.isLocked) {
      // LOCKED
      statusMessage = "يرجى إتمام ورد اليوم أولاً";
      containerColor = const Color(
        0xFF1E1E2C,
      ).withOpacity(0.5); // Lower opacity
      borderColor = Colors.grey.withOpacity(0.1);
      iconColor = Colors.grey;
      icon = Icons.lock_outline;
      progressBarColor = Colors.grey;
    } else if (ward.isCompleted) {
      // COMPLETED
      containerColor = const Color(0xFF1A1A1A).withOpacity(0.9);
      borderColor = AppColors.goldenYellow;
      iconColor = AppColors.goldenYellow;
      icon = Icons.check_circle;
      progressBarColor = AppColors.goldenYellow;
      statusMessage = "تم ختم ورد اليوم بنجاح 🔥";
    } else {
      // NOT COMPLETED
      if (isPast) {
        // Delayed
        int totalPagesInWard = ward.endPage - ward.startPage + 1;
        int unread = totalPagesInWard - ward.pagesRead;
        statusMessage = "متأخر بمقدار $unread صفحة";

        containerColor = const Color(0xFF1A1A1A);
        borderColor = Colors.red.withOpacity(0.5);
        iconColor = Colors.red;
        icon = Icons.warning_amber_rounded;
        progressBarColor = Colors.red;
      } else if (isToday) {
        // Today
        statusMessage = "أنت على المسار الصحيح";
        containerColor = const Color(0xFF1E1E2C);
        borderColor = AppColors.goldenYellow.withOpacity(0.5);
        iconColor = AppColors.goldenYellow;
        icon = Icons.play_circle_fill;
        progressBarColor = AppColors.goldenYellow;
      } else {
        // Future (but not locked by strict logic yet, or unlockable)
        // If we are here, isLocked is false.
        statusMessage = "لم يحن الموعد بعد";
        containerColor = const Color(0xFF1E1E2C).withOpacity(0.8);
        borderColor = Colors.grey.withOpacity(0.2);
        iconColor = Colors.grey;
        // Even if unlocked future, use circle for consistency if not 'today'
        icon = Icons.circle_outlined;
        progressBarColor = Colors.grey;
      }
    }

    // Date formatting
    final dateFormat = DateFormat('d MMM', 'en');

    // Progress calc
    int totalPages = ward.endPage - ward.startPage + 1;
    double progress = totalPages > 0 ? ward.pagesRead / totalPages : 0;

    return GestureDetector(
      onTap: () {
        if (ward.isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "خطوة بخطوة.. أتمم ورد اليوم أولاً لتنتقل إلى الورد التالي بكل طمأنينة",
                style: GoogleFonts.tajawal(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        onTap();
      },
      child: Opacity(
        opacity: ward.isLocked ? 0.4 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Separation shadow
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Day & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: iconColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "ورد اليوم ${ward.dayNumber}",
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dateFormat.format(ward.date),
                      style: GoogleFonts.tajawal(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Dynamic Feedback Text
              Text(
                statusMessage,
                style: GoogleFonts.tajawal(
                  color: iconColor, // Match status color
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 12),

              // Footer: Surah Range & Pages Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${ward.startSurahName} - ${ward.endSurahName}",
                      style: GoogleFonts.tajawal(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "${ward.pagesRead} / $totalPages صفحة",
                    style: GoogleFonts.tajawal(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
