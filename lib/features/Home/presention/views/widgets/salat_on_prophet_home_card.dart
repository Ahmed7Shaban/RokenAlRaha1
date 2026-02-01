import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Seerah/salat_on_prophet_view.dart';

class SalatOnProphetHomeCard extends StatefulWidget {
  const SalatOnProphetHomeCard({Key? key}) : super(key: key);

  @override
  State<SalatOnProphetHomeCard> createState() => _SalatOnProphetHomeCardState();
}

class _SalatOnProphetHomeCardState extends State<SalatOnProphetHomeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.2), // Gold shadow
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8E6E1D), // Dark Gold
            Color(0xFFD4AF37), // Primary Gold
            Color(0xFFF9D873), // Light Gold
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SalatOnProphetView(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Pattern
              Positioned(
                left: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 150,
                    color: Colors.white,
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text Column
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "وردك اليومي",
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "الصلاة على النبي",
                            style: GoogleFonts.amiri(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            "اللهم صل وسلم على نبينا محمد",
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Animated Icon
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: const Color(0xFFD4AF37),
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
