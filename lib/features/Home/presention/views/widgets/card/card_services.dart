import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../models/service_item.dart';
import '../../AllAzkar/widgets/azkar_notification_settings_sheet.dart';

class CardServices extends StatefulWidget {
  final ServiceItem item;
  final int index;
  final VoidCallback onTap;

  const CardServices({
    super.key,
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  State<CardServices> createState() => _CardServicesState();
}

class _CardServicesState extends State<CardServices> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizes
    final imageSize = screenWidth * 0.12;
    final fontSize = screenWidth * 0.032;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child:
          AnimatedScale(
                scale: _isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.08),
                        offset: const Offset(0, 8),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        offset: const Offset(-5, -5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFFF8F5FF), // Very subtle purple tint
                      ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor.withOpacity(0.05),
                            ),
                            child:
                                Image.asset(
                                      widget.item.iconPath,
                                      width: imageSize,
                                      height: imageSize,
                                      fit: BoxFit.contain,
                                    )
                                    .animate(target: _isPressed ? 1 : 0)
                                    .scale(
                                      begin: const Offset(1, 1),
                                      end: const Offset(0.9, 0.9),
                                      duration: 200.ms,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              widget.item.label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.tajawal(
                                // Changed to Tajawal for better Arabic look
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2D2D2D),
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.item.notificationKey != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: GestureDetector(
                            // Needs to handle tap separately
                            onTap: () {
                              // Show settings
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    AzkarNotificationSettingsSheet(
                                      title: widget.item.label,
                                      notificationKey:
                                          widget.item.notificationKey!,
                                      notificationBody:
                                          "حان وقت ${widget.item.label}",
                                    ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                size: 16,
                                color: AppColors.goldenYellow,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: (50 * widget.index).ms)
              .slideY(begin: 0.2, end: 0),
    );
  }
}
