import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';

class QuranButtonCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final double scale;
  final double width;
  final double height;

  const QuranButtonCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.scale = 1.0,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          // Card Margin: Add horizontal margins (e.g., 8.0)
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          // Implicitly controlled by parent but good to match
          decoration: BoxDecoration(
            color: const Color(0xFF2E2E2E), // Fallback Dark Grey
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryColor, width: 1.5),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              18,
            ), // Slightly less than container to respect border
            child: Stack(
              children: [
                // Overlay
                Container(color: Colors.black.withOpacity(0.5)),
                // Text
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: GoogleFonts.tajawal(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
