import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_card.dart';

class SalatCounterWidget extends StatelessWidget {
  final int counter;
  final VoidCallback onIncrement;
  final VoidCallback onReset;

  const SalatCounterWidget({
    super.key,
    required this.counter,
    required this.onIncrement,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: IconButton(
              onPressed: onReset,
              icon: const Icon(
                Icons.restart_alt_rounded,
                color: Colors.white70,
              ),
              tooltip: "تصفير العداد",
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                "اللهم صل وسلم على نبينا محمد",
                style: GoogleFonts.amiri(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Interactive Button
              GestureDetector(
                onTap: onIncrement,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD4AF37).withOpacity(0.2),
                        const Color(0xFFD4AF37).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFFD4AF37),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, color: Colors.white30, size: 30),
                      SizedBox(height: 10),
                      Text(
                        "$counter",
                        style: GoogleFonts.notoSans(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "اضغط للعد",
                style: GoogleFonts.tajawal(fontSize: 14, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
