import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../source/app_images.dart';

class BodySplash extends StatelessWidget {
  const BodySplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Gradient Background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                Color(0xFF3E3768), // Darker shade of 5d5491
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // 2. Islamic Pattern Overlay (Low Opacity)
        Opacity(
          opacity: 0.05,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  Assets.imagesBackgroundSplash,
                ), // Using this as texture
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ),

        // 3. Central Elements (Logo + Title)
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Image.asset(
                    Assets.imagesMosque, // Mosques are a safe symbol
                    width: 120,
                    color: Colors.white,
                  )
                  .animate()
                  .fade(duration: 800.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                    curve: Curves.easeOutBack,
                  )
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 800.ms,
                    curve: Curves.easeOut,
                  ), // Slide up approx 30px relative

              const SizedBox(height: 20),

              // App Name
              Text(
                    'ركن الراحة',
                    style: GoogleFonts.tajawal(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  )
                  .animate()
                  .fade(duration: 800.ms, delay: 300.ms) // Staggered
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 800.ms,
                    curve: Curves.easeOut,
                  ),
            ],
          ),
        ),

        // 4. Bottom Loading Indicator
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: const CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              strokeWidth: 2,
            ).animate().fade(duration: 600.ms, delay: 1000.ms), // Appears last
          ),
        ),
      ],
    );
  }
}
