import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';

class KhatmaShareCard extends StatelessWidget {
  final String userName; // Optional
  final String khatmaName;
  final int progressPercent;
  final int totalCompleted;
  final String currentWard;
  final bool isCompleted;

  const KhatmaShareCard({
    Key? key,
    this.userName = "قارئ القرآن",
    required this.khatmaName,
    required this.progressPercent,
    required this.totalCompleted,
    required this.currentWard,
    this.isCompleted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E), // Premium Dark
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldenYellow, width: 2),
        image: const DecorationImage(
          image: AssetImage('assets/Images/888-02.png'),
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Header / Logo ---
          const Icon(
            Icons.menu_book_rounded,
            size: 40,
            color: AppColors.goldenYellow,
          ),
          const SizedBox(height: 8),
          Text(
            "ركن الراحة",
            style: GoogleFonts.amiri(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          const Divider(color: Colors.white24, height: 32),

          // --- Motivational Quote ---
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isCompleted
                  ? "الحمد لله الذي بنعمته تتم الصالحات"
                  : "اللهم اجعله ربيع قلبي",
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                color: Colors.white70,
                fontSize: 16, // Slightly larger base
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Main Achievement Title ---
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isCompleted ? "أتممت ختمة القرآن الكريم!" : "إنجاز وردي اليومي",
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                color: isCompleted ? AppColors.goldenYellow : Colors.white,
                fontSize: 24, // Responsive base
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // --- Khatma Name ---
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              khatmaName,
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- Stats Row ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildResponsiveStat("الإنجاز", "$progressPercent%"),
                  const VerticalDivider(color: Colors.white24, width: 1),
                  _buildResponsiveStat("الختمات", "$totalCompleted"),
                  const VerticalDivider(color: Colors.white24, width: 1),
                  _buildResponsiveStat(
                    "الورد الحالي",
                    currentWard,
                    isWide: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- Footer ---
          Text(
            "شاركني الأجر",
            style: GoogleFonts.tajawal(color: Colors.white30, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveStat(
    String label,
    String value, {
    bool isWide = false,
  }) {
    return Flexible(
      flex: isWide ? 2 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.tajawal(
                color: AppColors.goldenYellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.tajawal(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
