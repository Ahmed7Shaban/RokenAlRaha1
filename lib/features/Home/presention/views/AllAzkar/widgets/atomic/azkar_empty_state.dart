import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AzkarEmptyState extends StatelessWidget {
  const AzkarEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("لا توجد نتائج", style: GoogleFonts.tajawal(color: Colors.grey)),
        ],
      ).animate().fadeIn(),
    );
  }
}
