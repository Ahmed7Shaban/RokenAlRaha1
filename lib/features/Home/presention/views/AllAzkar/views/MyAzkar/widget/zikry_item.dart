import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../../core/widgets/shared_branding_widget.dart';
import '../../../../../../../../source/app_images.dart';
import '../../../models/azkar_stats_service.dart';
import '../model/zikr_model.dart';
import '../../../widgets/azkar_notification_settings_sheet.dart';

class ZikryItem extends StatefulWidget {
  final ZikrModel zikr;
  final VoidCallback? onDeleted;
  final VoidCallback? onEdit;

  const ZikryItem({super.key, required this.zikr, this.onDeleted, this.onEdit});

  @override
  State<ZikryItem> createState() => _ZikryItemState();
}

class _ZikryItemState extends State<ZikryItem>
    with SingleTickerProviderStateMixin {
  late int _count;
  late int _totalTarget;
  late AnimationController _controller;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    // Daily Reset Logic could be here, but ideally in Cubit
    // For now, we trust the model's count, but let's assume users want to count towards daily goal
    _count = widget.zikr.dailyGoal; // Countdown style
    // If you want "Count Up" vs "Count Down", standardizing on Count Down visually
    // Or we can track progress. Let's do Count Down as it's more satisfying for goals.
    _totalTarget = widget.zikr.dailyGoal;

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
  void didUpdateWidget(ZikryItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.zikr.dailyGoal != oldWidget.zikr.dailyGoal) {
      setState(() {
        _totalTarget = widget.zikr.dailyGoal;
        _count = widget.zikr.dailyGoal; // Reset on edit? Maybe
      });
    }
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
      final imagePath = await File(
        '${directory.path}/zikr_share_${Random().nextInt(10000)}.png',
      ).create();
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
          image: AssetImage("assets/Images/ramdanback.jpg"),
          fit: BoxFit.cover,
          opacity: 0.05,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.format_quote,
            color: AppColors.primaryColor.withOpacity(0.5),
            size: 40,
          ),
          const SizedBox(height: 20),
          Text(
            widget.zikr.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 26,
              height: 1.8,
              color: const Color(0xFF2D2D2D),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.zikr.content.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              widget.zikr.content,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
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
    Clipboard.setData(
      ClipboardData(text: "${widget.zikr.title}\n${widget.zikr.content}"),
    );
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

      // We should ideally update the model in the cubit too, but for UI responsiveness local state is faster
      AzkarStatsService.incrementZikr(widget.zikr.title); // Track Global Stats

      if (_count == 0) {
        // Goal Reached
      }
    }
  }

  void _reset() {
    setState(() {
      _count = _totalTarget;
    });
  }

  void _showNotificationSettings() {
    // We use the key as the identifier
    final notificationKey = "my_zikr_${widget.zikr.key}";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AzkarNotificationSettingsSheet(
        title: widget.zikr.title,
        notificationKey: notificationKey,
        notificationBody: widget.zikr.content.isNotEmpty
            ? widget.zikr.content
            : "وقت ذكرك الخاص",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = _totalTarget > 0 ? (1 - (_count / _totalTarget)) : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Dismissible(
        key: ValueKey(widget.zikr.key),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.red, size: 30),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "تأكيد الحذف",
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  "هل أنت متأكد من حذف هذا الذكر؟",
                  style: GoogleFonts.tajawal(),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      "إلغاء",
                      style: GoogleFonts.tajawal(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      "حذف",
                      style: GoogleFonts.tajawal(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          if (widget.onDeleted != null) widget.onDeleted!();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              // Header Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Notification Icon
                    GestureDetector(
                      onTap: _showNotificationSettings,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 18,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _actionButton(Icons.edit_outlined, () {
                          if (widget.onEdit != null) widget.onEdit!();
                        }),
                        _actionButton(Icons.copy_rounded, _copyText),
                        _actionButton(Icons.share_rounded, _shareAsImage),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    Text(
                      widget.zikr.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (widget.zikr.content.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.zikr.content,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Interactive Counter
              GestureDetector(
                onTap: _handleTap,
                onLongPress: _reset,
                child: Transform.scale(
                  scale: 1.0 - _controller.value,
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: _count == 0
                          ? Colors.green
                          : AppColors.primaryColor,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                      gradient: LinearGradient(
                        colors: _count == 0
                            ? [Colors.green.shade400, Colors.green.shade700]
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
                                  progress, // Simple width based progress
                              height: 55,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_count == 0)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 24,
                              ).animate().scale(
                                duration: 300.ms,
                                curve: Curves.elasticOut,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              _count == 0
                                  ? "أتممت الهدف"
                                  : "$_count / $_totalTarget",
                              style: GoogleFonts.tajawal(
                                fontSize: 18,
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
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _actionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 20, color: Colors.grey[400]),
      ),
    );
  }
}
