import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../routes/routes.dart';
import '../../../../../source/app_images.dart';
import '../../../models/service_item.dart';
import '../AllAzkar/date/zekr_item_list.dart';
import 'card/services_grid.dart';

class AzkarHomeCard extends StatelessWidget {
  const AzkarHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.2),
          ), // Gold hint
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          image: const DecorationImage(
            image: AssetImage(
              "assets/Images/backimg.jpg",
            ), // Subtle texture if available or generic pattern
            fit: BoxFit.cover,
            opacity: 0.03,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wb_twilight_rounded,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "أذكارك اليومية",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ServicesGrid(
              list: [
                ...zekrItemList.take(4),
                ServiceItem(
                  iconPath: Assets.note,
                  label: 'أذكارى',
                  route: Routes.Azkary,
                ),
                ServiceItem(
                  iconPath: Assets.azkar,
                  label: "المزيد",
                  route: Routes.AllAzkar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
