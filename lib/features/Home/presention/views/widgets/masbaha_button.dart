import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/features/Home/presention/views/AsmaaAllah/presentation/views/asmaa_allah_view.dart';
import 'package:roken_al_raha/features/Home/presention/views/Masbaha/IstighfarView/istighfar_view.dart';

import '../../../../../core/theme/app_colors.dart';

class MasbahaButton extends StatelessWidget {
  final String title;
  final String imagePath;
  final double scale;

  const MasbahaButton({
    super.key,
    this.title = "تسابيح واستغفار",
    this.imagePath = "assets/Images/backimg2.jpg",
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const IstighfarView()),
          );
        },
        child: Container(
          // Card Margin: Add horizontal margins (e.g., 8.0)
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          width: 200,
          height: 100, // Implicitly controlled by parent but good to match
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
