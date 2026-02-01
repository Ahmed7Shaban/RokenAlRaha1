import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../routes/routes.dart';

class SmartAzkarCard extends StatelessWidget {
  const SmartAzkarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isMorning = hour >= 4 && hour < 12; // Morning: 4 AM - 12 PM
    final isEvening =
        hour >= 12 && hour < 19; // Evening: 12 PM - 7 PM (Sort of relative)
    // Adjust logic as preferred. Commonly: Morning (Fajr-Zohr), Evening (Asr-Maghrib).
    // Let's simplify: Morning < 12, Evening >= 12 (Afternoon/Evening).

    // Better Logic:
    // Morning Azkar logic: Between Fajr and Sunrise (approx 4am - 9am best time, can extend to Dhuhr)
    // Evening Azkar logic: Between Asr and Maghrib (approx 3pm - 7pm best time, can extend to Midnight)
    // Sleep Azkar: Night time.

    String title;
    String subtitle;
    String route;
    IconData icon;
    List<Color> gradientColors;

    if (hour >= 4 && hour < 12) {
      title = "أذكار الصباح";
      subtitle = "بداية يوم مباركة بذكر الله";
      route = Routes.MorningAzkar;
      icon = Icons.wb_sunny_rounded;
      gradientColors = [const Color(0xFFFF9800), const Color(0xFFFFE0B2)];
    } else if (hour >= 12 && hour < 20) {
      title = "أذكار المساء";
      subtitle = "حصن نفسك في نهاية اليوم";
      route = Routes.EveningAzkar;
      icon = Icons.nightlight_round;
      gradientColors = [const Color(0xFF3F51B5), const Color(0xFF9FA8DA)];
    } else {
      title = "أذكار النوم";
      subtitle = "نوم هادئ ومطمئن بذكر الله";
      route = Routes.SleepAzkar;
      icon = Icons.bedtime_rounded;
      gradientColors = [const Color(0xFF1A237E), const Color(0xFF534BAE)];
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0),
    );
  }
}
