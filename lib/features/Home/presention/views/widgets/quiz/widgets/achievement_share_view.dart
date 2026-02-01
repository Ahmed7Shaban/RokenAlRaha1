import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom_share_card.dart';

class AchievementShareView extends StatelessWidget {
  final int correctCount;
  final int wrongCount;
  final int totalAnswered;

  const AchievementShareView({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.totalAnswered,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentage
    final double percentage = totalAnswered > 0
        ? (correctCount / totalAnswered)
        : 0.0;
    final int percentageInt = (percentage * 100).toInt();

    return CustomShareCard(
      title: "إنجازي في مسابقة ركن الراحة",
      child: Column(
        children: [
          // Circular Badge
          Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 4,
              ),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.2), Colors.transparent],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.white10,
                  color: const Color(0xFFD4AF37),
                  strokeWidth: 8,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$percentageInt%",
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "نسبة الدقة",
                        style: GoogleFonts.tajawal(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Stats Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("مجاب", "$totalAnswered", Colors.blueAccent),
                Container(width: 1, height: 40, color: Colors.white10),
                _buildStatItem("صحيح", "$correctCount", Colors.greenAccent),
                Container(width: 1, height: 40, color: Colors.white10),
                _buildStatItem("خطأ", "$wrongCount", Colors.redAccent),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // Motivational Text
          Text(
            "هل يمكنك التغلب على نتيجتي؟",
            style: GoogleFonts.tajawal(
              color: const Color(0xFFD4AF37),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.tajawal(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
