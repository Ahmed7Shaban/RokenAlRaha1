import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';

import '../Khatma/presentation/views/khatma_dashboard_view.dart';

class KhatmaImageButton extends StatefulWidget {
  const KhatmaImageButton({Key? key}) : super(key: key);

  @override
  State<KhatmaImageButton> createState() => _KhatmaImageButtonState();
}

class _KhatmaImageButtonState extends State<KhatmaImageButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 3. Animation & Interactivity: Subtle Pulse/Scale
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        height: 190, // 1. Dimensions: 180-200
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // 4. Image Optimization: Fallback color
        decoration: BoxDecoration(
          color: AppColors.primaryColor, // Deep Dark fallback
          borderRadius: BorderRadius.circular(20),
          // 1. Border: Golden
          border: Border.all(color: AppColors.primaryColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
          image: const DecorationImage(
            image: AssetImage('assets/Images/ktma.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KhatmaPage()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            splashColor: AppColors.goldenYellow.withOpacity(0.3),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // 1. Decoration: Dark Overlay
                color: Colors.black.withOpacity(0.5),
              ),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 2. Typography: "ختمة"
                  Text(
                    "ختمة",
                    style: GoogleFonts.amiri(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        const BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                        BoxShadow(
                          color: AppColors.goldenYellow.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Optional: Subtitle or decorative element could go here
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
