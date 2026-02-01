import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class BrandingWidget extends StatelessWidget {
  final bool dark;

  const BrandingWidget({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: dark ? AppColors.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark
              ? Colors.white24
              : AppColors.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mosque,
            color: dark ? Colors.white : AppColors.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            "ركن الراحة",
            style: GoogleFonts.amiri(
              color: dark ? Colors.white : AppColors.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
