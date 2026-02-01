import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizHeader extends StatelessWidget {
  final int correct;
  final int wrong;
  final VoidCallback onStatsTap;
  final VoidCallback onSettingsTap; // New callback for settings
  final VoidCallback onShareTap; // New callback for main share

  const QuizHeader({
    super.key,
    required this.correct,
    required this.wrong,
    required this.onStatsTap,
    required this.onSettingsTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Share & Stats Group
        Row(
          children: [
            // Stats Button
            GestureDetector(
              onTap: onStatsTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bar_chart_rounded,
                      color: Color(0xFFD4AF37),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$correct",
                      style: GoogleFonts.tajawal(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      " / ",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      "$wrong",
                      style: GoogleFonts.tajawal(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Settings Button
            _buildIconButton(icon: Icons.settings, onTap: onSettingsTap),
          ],
        ),

        // Branding Title (Central)
        Expanded(
          child: Text(
            "مسابقات إيمانية",
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              color: const Color(0xFFD4AF37),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                const BoxShadow(
                  color: Colors.black45,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),

        // Main Share Button
        _buildIconButton(icon: Icons.share, onTap: onShareTap),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
      ),
    );
  }
}
