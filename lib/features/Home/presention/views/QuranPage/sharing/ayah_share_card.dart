import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/core/widgets/shared_branding_widget.dart';

class AyahShareCard extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;
  final String verseText;
  final String surahName;
  final Color backgroundColor;
  final Color textColor;

  const AyahShareCard({
    Key? key,
    required this.surahNumber,
    required this.verseNumber,
    required this.verseText,
    required this.surahName,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      color: Colors.white, // Fixed Background
      child: Column(
        mainAxisSize: MainAxisSize.min, // Hug content
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              border: const Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 255, 196, 0),
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "آية $verseNumber",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
                Text(
                  "سورة $surahName",
                  style: GoogleFonts.amiri(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),

          // 2. Body (Ayah Text)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 50.0,
            ),
            child: Text(
              verseText,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: "QCF_P002",
                fontSize: 25,
                color: Colors.black, // Fixed Text Color
              ),
            ),
          ),

          // 3. Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            color: AppColors.primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SharedBrandingWidget(color: Colors.white, fontSize: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
