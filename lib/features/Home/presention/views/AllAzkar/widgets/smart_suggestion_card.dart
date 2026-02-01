import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../source/app_images.dart';

class SmartSuggestionCard extends StatelessWidget {
  const SmartSuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine time of day
    final now = DateTime.now();
    final hour = now.hour;

    String title = "";
    String subtitle = "";
    String route = "";
    String imageAsset = "";
    List<Color> gradientColors = [];

    // Simple time logic (can be improved with PrayerTimes if available globally)
    if (hour >= 4 && hour < 11) {
      // Morning (Fajr - Dhuhr approx)
      title = "أذكار الصباح";
      subtitle = "ابدأ يومك بذكر الله وحمده";
      route = Routes.MorningAzkar;
      imageAsset = Assets.imagesSunrise; // Assuming exists or use generic
      gradientColors = [const Color(0xFFFFF176), const Color(0xFFFFB74D)];
    } else if (hour >= 15 && hour < 19) {
      // Evening (Asr - Maghrib approx)
      title = "أذكار المساء";
      subtitle = "حصن نفسك في المساء";
      route = Routes.EveningAzkar;
      imageAsset = Assets.imagesNight; // or sunset
      gradientColors = [const Color(0xFF90CAF9), const Color(0xFF1565C0)];
    } else if (hour >= 20 || hour < 4) {
      // Night/Sleep
      title = "أذكار النوم";
      subtitle = "باسمك ربي وضعت جنبي";
      route = Routes.SleepAzkar;
      imageAsset = Assets.imagesSleep;
      gradientColors = [const Color(0xFF311B92), const Color(0xFF4527A0)];
    } else {
      // Default (e.g. general suggestion)
      title = "وردك اليومي";
      subtitle = "لا تنسَ ذكر الله في كل وقت";
      route = Routes.Azkary; // Or random
      imageAsset = Assets.azkar;
      gradientColors = [
        AppColors.primaryColor.withOpacity(0.7),
        AppColors.primaryColor,
      ];
    }

    return GestureDetector(
      onTap: () {
        if (route.isNotEmpty) {
          Navigator.pushNamed(context, route);
        }
      },
      child:
          Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.last.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "اقتراح لك",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Image
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        imageAsset.isNotEmpty ? imageAsset : Assets.azkar,
                        width: 50,
                        height: 50,
                        color: Colors.white,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.2, end: 0, curve: Curves.easeOutBack),
    );
  }
}
