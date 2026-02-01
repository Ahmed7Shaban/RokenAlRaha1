import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../../core/theme/app_colors.dart';
import 'shared_branding_widget.dart';

class CustomShareCard extends StatelessWidget {
  final Widget child;
  final String title;

  const CustomShareCard({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // Fixed width for consistent image generation
      decoration: BoxDecoration(
        color: const Color(0xFF0A3D36), // Deep Emerald Base
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 1. Background Image with Opacity
            Positioned.fill(
              child: Opacity(
                opacity: 0.15, // Subtle pattern
                child: Image.asset(
                  'assets/Images/ramadan.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.primaryColor.withOpacity(0.1)),
                ),
              ),
            ),

            // 2. Gradient Overlay for Depth
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.1),
                      const Color(0xFF0A3D36).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Main Content Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Area
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.9),
                        AppColors.primaryColor.withOpacity(0.7),
                      ],
                    ),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFFD4AF37), width: 2),
                    ),
                  ),
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ),

                // Dynamic Body Content
                Padding(padding: const EdgeInsets.all(24.0), child: child),

                // Footer Branding
                const SharedBrandingWidget(),
              ],
            ),

            // 4. Decorative Corners (Optional Islamic Touch)
            // Top Left
            Positioned(
              top: 10,
              left: 10,
              child: Icon(
                Icons.star,
                color: const Color(0xFFD4AF37).withOpacity(0.4),
                size: 16,
              ),
            ),
            // Top Right
            Positioned(
              top: 10,
              right: 10,
              child: Icon(
                Icons.star,
                color: const Color(0xFFD4AF37).withOpacity(0.4),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
