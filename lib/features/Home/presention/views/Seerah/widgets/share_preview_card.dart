import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../models/seerah_model.dart';

class SharePreviewCard extends StatelessWidget {
  final SeerahModel seerahModel;

  const SharePreviewCard({super.key, required this.seerahModel});

  @override
  Widget build(BuildContext context) {
    // A fixed width container for sharing to ensure consistent look
    return Container(
      width: 400, // Fixed width for optimal social media viewing
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        image: DecorationImage(
          image: AssetImage("assets/Images/ramadan.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.withOpacity(0.95),
            BlendMode.hardLight,
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            seerahModel.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              seerahModel.period,
              style: GoogleFonts.tajawal(fontSize: 16, color: Colors.white),
            ),
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            seerahModel.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 18,
              height: 1.5,
              color: Colors.white.withOpacity(0.9),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white30, thickness: 1),
          const SizedBox(height: 16),

          // Lesson
          Text(
            "💎 الدرس المستفاد",
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amberAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            seerahModel.lesson,
            textAlign: TextAlign.center,
            style: GoogleFonts.scheherazadeNew(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 30),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.share, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                "تمت المشاركة من تطبيق ركن الراحة",
                style: GoogleFonts.tajawal(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
