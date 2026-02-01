import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../../../../../../routes/routes.dart';

class SeerahHomeCard extends StatefulWidget {
  const SeerahHomeCard({Key? key}) : super(key: key);

  @override
  State<SeerahHomeCard> createState() => _SeerahHomeCardState();
}

class _SeerahHomeCardState extends State<SeerahHomeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    // Shimmering light effect animation
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
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
      height: 140, // Prominent height
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF1E5F46,
            ).withOpacity(0.3), // Islamic Green shadow
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          colors: [
            Color(0xFF144D38), // Islamic Deep Green
            Color(0xFF2C7D5D), // Lighter Green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, Routes.Seerah);
          },
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Pattern (Islamic Geometry Style)
              Positioned(
                right: -30,
                top: -30,
                child: Icon(
                  Icons.mosque_rounded,
                  size: 180,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),

              // Animated Light Shine
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Positioned.fill(
                    child: FractionallySizedBox(
                      widthFactor: 0.3,
                      alignment: Alignment(_shimmerAnimation.value, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.0),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    // Icon / Symbol
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                          width: 1,
                        ), // Gold border hint
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Text
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "السيرة النبوية",
                            style: GoogleFonts.amiri(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.goldenYellow,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "رحلة في حياة خير البشر",
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 16,
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
