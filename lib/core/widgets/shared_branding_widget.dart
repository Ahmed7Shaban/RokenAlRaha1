import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable custom widget for the shared watermark text "ركن الراحة".
/// Designed to be visually attractive, elegant, and spiritually fitting.
class SharedBrandingWidget extends StatelessWidget {
  final Color? color;
  final double fontSize;
  final bool withShadow;

  const SharedBrandingWidget({
    Key? key,
    this.color,
    this.fontSize = 22,
    this.withShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Default color logic
    final textColor =
        color ?? const Color(0xFFD4AF37); // Gold-ish default or Theme primary

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // "From App" phrase - reduced opacity and smaller size
        Text(
          "من تطبيق",
          style: GoogleFonts.amiri(
            fontSize: fontSize * 0.65, // Smaller relative to main text
            fontWeight: FontWeight.normal,
            color: textColor.withOpacity(0.8), // Reduced opacity
            height: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        // App Name - Main focus, bold, and visually dominant
        Text(
          "ركن الراحة",
          style: GoogleFonts.amiri(
            fontSize: fontSize * 1.25, // Increased size
            fontWeight: FontWeight.bold,
            color: textColor,
            height: 1.0,
            shadows: withShadow
                ? [
                    BoxShadow(
                      color: textColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        ),
        // Decorative underline - refined
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: fontSize * 3, // Slightly wider
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                textColor.withOpacity(0.0),
                textColor.withOpacity(0.6),
                textColor.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
