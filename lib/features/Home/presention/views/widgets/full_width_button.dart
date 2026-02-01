import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FullWidthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData icon;

  const FullWidthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon = Icons.check, // افتراضي تيك
  });

  @override
  Widget build(BuildContext context) {
    // الحصول على عرض الشاشة
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth, // ياخد عرض الشاشة بالكامل
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16), // ارتفاع الزر
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // حواف مدورة
          ),
          backgroundColor: Colors.blueAccent,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.cairo( // خط عربي من Google Fonts
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

