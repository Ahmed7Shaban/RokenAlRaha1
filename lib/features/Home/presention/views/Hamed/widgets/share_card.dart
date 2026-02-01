import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/widgets/branding_widget.dart';

import '../../../../../../core/theme/app_colors.dart';

class ShareCard extends StatelessWidget {
  final String text;
  final int count;

  const ShareCard({super.key, required this.text, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6), // Off-white
        image: const DecorationImage(
          image: AssetImage('assets/Images/backimg1.jpg'), // Islamic Pattern
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
        border: Border.all(
          color: AppColors.primaryColor,
          width: 3,
        ), // Gold border
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.format_quote,
            color: AppColors.primaryColor,
            size: 40,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'عدد المرات: $count',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B6B18),
              ),
            ),
          ),
          const SizedBox(height: 20),
          BrandingWidget(),
        ],
      ),
    );
  }
}
