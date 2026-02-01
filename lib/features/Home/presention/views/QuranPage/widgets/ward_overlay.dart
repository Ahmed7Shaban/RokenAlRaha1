import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';

class WardOverlay extends StatelessWidget {
  final int currentPage;
  final int startPage;
  final int endPage;

  const WardOverlay({
    Key? key,
    required this.currentPage,
    required this.startPage,
    required this.endPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Basic calculation
    int totalWardPages = endPage - startPage + 1;
    if (totalWardPages < 1) totalWardPages = 1;

    // Pages read in this specific ward session context
    // Ideally this is (currentPage - startPage + 1).
    // If currentPage < startPage, it's 0 or negative (shouldn't happen if logical).
    int pagesRead = currentPage - startPage + 1;
    if (pagesRead < 0) pagesRead = 0;
    if (pagesRead > totalWardPages) pagesRead = totalWardPages;

    // Remaining pages calculation
    int remaining = totalWardPages - pagesRead;
    if (remaining < 0) remaining = 0;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C).withOpacity(0.95), // Deep Dark opaque
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.goldenYellow, // Primary Golden
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "بقي لك $remaining صفحات لتتم وردك اليوم",
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pagesRead / totalWardPages,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.goldenYellow,
                ),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
