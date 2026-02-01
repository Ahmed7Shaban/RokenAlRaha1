import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/Home/presention/views/AllAzkar/models/azkar_stats_service.dart';
import '../../source/app_images.dart';
import '../theme/app_colors.dart';
import 'shared_branding_widget.dart';

class ZikrItem extends StatefulWidget {
  final String title;
  final int initialCount;
  final VoidCallback? onTap;

  const ZikrItem({
    super.key,
    required this.title,
    this.initialCount = 1,
    this.onTap,
  });

  @override
  State<ZikrItem> createState() => _ZikrItemState();
}

class _ZikrItemState extends State<ZikrItem>
    with SingleTickerProviderStateMixin {
  late int _count;
  late int _totalTarget;
  late AnimationController _controller;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isPressed =
      false; // Kept but ignoring warning or remove if truly unused. Actually, let's remove it.

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
    _totalTarget = widget.initialCount;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.1,
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _shareAsImage() async {
    try {
      final widgetToCapture = _buildShareableWidget();
      final Uint8List imageBytes = await _screenshotController
          .captureFromWidget(
            widgetToCapture,
            delay: const Duration(milliseconds: 150),
            pixelRatio: 3.0,
          );

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/zikr_share.png').create();
      await imagePath.writeAsBytes(imageBytes);

      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'من تطبيق ركن الراحة');
    } catch (e) {
      debugPrint("Error sharing image: $e");
    }
  }

  Widget _buildShareableWidget() {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        image: const DecorationImage(
          image: AssetImage(
            Assets.ramadan,
          ), // Using app background if available, else plain
          fit: BoxFit.cover,
          opacity: 0.05,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Decorative Top
          Icon(
            Icons.format_quote,
            color: AppColors.primaryColor.withOpacity(0.5),
            size: 40,
          ),
          const SizedBox(height: 20),

          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 26,
              height: 1.8,
              color: const Color(0xFF2D2D2D),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 40),
          Divider(
            color: AppColors.primaryColor.withOpacity(0.3),
            thickness: 1,
            indent: 50,
            endIndent: 50,
          ),
          const SizedBox(height: 20),
          const SharedBrandingWidget(),
        ],
      ),
    );
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: widget.title));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الذكر'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _handleTap() async {
    if (_count > 0) {
      await _controller.forward();
      setState(() {
        _count--;
      });
      await _controller.reverse();

      // Track Stats
      AzkarStatsService.incrementZikr(widget.title);

      if (_count == 0) {
        // HapticFeedback.mediumImpact(); // Optional if user wants vibration
      }
    } else {
      // Reset on long press equivalent or just ignore?
      // User might want to restart. Let's make it easy to restart if 0.
    }
  }

  void _reset() {
    setState(() {
      _count = _totalTarget;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = _totalTarget > 0 ? (1 - (_count / _totalTarget)) : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Card Container
          Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    // Header (Share/Copy)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _actionButton(Icons.copy_rounded, _copyText),
                          const SizedBox(width: 8),
                          _actionButton(Icons.share_rounded, _shareAsImage),
                        ],
                      ),
                    ),

                    // Text Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: 22,
                          height: 1.8,
                          color:
                              Theme.of(context).textTheme.bodyLarge?.color ??
                              Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Interactive Counter Area
                    GestureDetector(
                      onTap: _handleTap,
                      onLongPress: _reset,
                      child: Transform.scale(
                        scale: 1.0 - _controller.value,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: _count == 0
                                ? const Color(0xFF4CAF50)
                                : AppColors.primaryColor,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                            gradient: LinearGradient(
                              colors: _count == 0
                                  ? [
                                      Colors.green.shade400,
                                      Colors.green.shade700,
                                    ]
                                  : [
                                      AppColors.primaryColor.withOpacity(0.85),
                                      AppColors.primaryColor,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_count > 0)
                                Positioned(
                                  left: 0,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        progress,
                                    height: 60,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_count == 0)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 28,
                                    ).animate().scale(
                                      duration: 300.ms,
                                      curve: Curves.elasticOut,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _count == 0
                                        ? "أتممت الذكر"
                                        : "$_count / $_totalTarget",
                                    style: GoogleFonts.tajawal(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              if (_count == 0)
                                Positioned(
                                  right: 16,
                                  child: GestureDetector(
                                    onTap: _reset,
                                    child: const Icon(
                                      Icons.refresh,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.primaryColor.withOpacity(0.6),
        ),
      ),
    );
  }
}
