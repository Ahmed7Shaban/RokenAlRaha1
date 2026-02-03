import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final bool isLastPage;
  final VoidCallback? onStartPressed;

  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.isLastPage = false,
    this.onStartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image Section - Fills upper space elegantly
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover, // Fills completely
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
          ),
        ),

        const SizedBox(height: 40),

        // Text Section
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    height: 1.2,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                if (isLastPage) ...[
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: onStartPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        shadowColor: AppColors.primaryColor.withOpacity(0.4),
                      ),
                      child: Text(
                        "ابدأ الآن",
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).scale(),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
