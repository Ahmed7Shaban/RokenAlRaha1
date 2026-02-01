import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SharedBrandingWidget extends StatelessWidget {
  const SharedBrandingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF062823), // Dark Emerald
        border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/app_icon/icon.png',
            height: 30,
            width: 30,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.star, color: Color(0xFFD4AF37)),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ركن الراحة",
                style: GoogleFonts.tajawal(
                  color: const Color(0xFFD4AF37),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "رفيقك في رحلة الإيمان",
                style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
