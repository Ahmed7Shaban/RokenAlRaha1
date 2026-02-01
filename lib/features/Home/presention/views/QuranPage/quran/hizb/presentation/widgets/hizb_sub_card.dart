import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../../logic/cubit/hizb_state.dart';
import 'animated_pie_icon.dart';

class HizbSubCard extends StatelessWidget {
  final HizbQuarterUiModel model;
  final VoidCallback onTap;

  const HizbSubCard({super.key, required this.model, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Determine title based on quarter number (1, 2, 3, 4)
    String title = "الربع ${model.data.number}";
    if (model.data.number == 1) title = "بداية الحزب";
    if (model.data.number == 2) title = "ربع الحزب";
    if (model.data.number == 3) title = "نصف الحزب";
    if (model.data.number == 4) title = "ثلاثة أرباع الحزب";

    // Status Color
    Color statusColor = Colors.grey[200]!;
    if (model.isCompleted) statusColor = Colors.green.withOpacity(0.1);
    if (model.isCurrent) statusColor = AppColors.primaryColor.withOpacity(0.1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(12),
          border: model.isCurrent
              ? Border.all(color: AppColors.primaryColor.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            // Icon - Animated Pie
            AnimatedPieIcon(
              currentQuarter: model.data.number,
              isCompleted: model.isCompleted,
              isCurrent: model.isCurrent,
            ),
            SizedBox(width: 12.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: model.isCurrent
                          ? AppColors.primaryColor
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    "بداية: ${model.data.startSurahName} (${model.data.startAyahNumber})",
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Progress Text
            if (model.isCurrent)
              Text(
                "${(model.progress * 100).toInt()}%",
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
