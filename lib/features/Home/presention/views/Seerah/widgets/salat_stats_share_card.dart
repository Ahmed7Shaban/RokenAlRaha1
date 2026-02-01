import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/widgets/branding_widget.dart';
import '../../../../../../core/theme/app_colors.dart';

class SalatStatsShareCard extends StatelessWidget {
  final int counter;

  const SalatStatsShareCard({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mosque, color: Color(0xFFD4AF37), size: 50),
          const SizedBox(height: 16),
          Text(
            "إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ",
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            "يا أيها الذين آمنوا صلوا عليه وسلموا تسليما",
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white30),
            ),
            child: Column(
              children: [
                Text(
                  "عدد الصلوات",
                  style: GoogleFonts.tajawal(color: Colors.white70),
                ),
                Text(
                  "$counter",
                  style: GoogleFonts.tajawal(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          BrandingWidget(),
        ],
      ),
    );
  }
}
