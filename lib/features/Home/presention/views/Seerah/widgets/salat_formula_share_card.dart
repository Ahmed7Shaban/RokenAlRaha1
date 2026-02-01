import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/widgets/branding_widget.dart';
import '../../../../../../core/theme/app_colors.dart';

class SalatFormulaShareCard extends StatelessWidget {
  final String title;
  final String content;

  const SalatFormulaShareCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2027), // Dark background
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: Color(0xFFD4AF37),
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 20,
              color: Colors.white,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Center(child: BrandingWidget()),
        ],
      ),
    );
  }
}
