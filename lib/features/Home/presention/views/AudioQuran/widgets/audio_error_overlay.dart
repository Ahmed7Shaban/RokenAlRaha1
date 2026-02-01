import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';

class AudioErrorOverlay extends StatefulWidget {
  final String message;
  final VoidCallback? onRetry;

  const AudioErrorOverlay({super.key, required this.message, this.onRetry});

  @override
  State<AudioErrorOverlay> createState() => _AudioErrorOverlayState();
}

class _AudioErrorOverlayState extends State<AudioErrorOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIconForMessage(String msg) {
    if (msg.contains("الإنترنت")) {
      return Icons.wifi_off_rounded;
    } else if (msg.contains("الملف") || msg.contains("404")) {
      return Icons.error_outline_rounded;
    } else {
      return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 200.h,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getIconForMessage(widget.message),
                    size: 48.sp,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Content Fade In
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      widget.message,
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),

                    if (widget.onRetry != null)
                      SizedBox(
                        width: 160.w,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_controller.isCompleted) {
                              _controller.reverse().then((_) {
                                widget.onRetry!();
                              });
                            } else {
                              widget.onRetry!();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: AppColors.primaryColor.withOpacity(
                              0.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                "إعادة المحاولة",
                                style: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
