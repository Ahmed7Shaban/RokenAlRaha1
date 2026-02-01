import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';

class AnimatedPieIcon extends StatelessWidget {
  final int currentQuarter; // 1 to 4
  final bool isCompleted;
  final bool isCurrent;

  const AnimatedPieIcon({
    super.key,
    required this.currentQuarter,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    // If completed, show checkmark
    if (isCompleted) {
      return Icon(Icons.check_circle, color: Colors.green, size: 20.sp);
    }

    // Determine target fill: 0.25, 0.5, 0.75, 1.0 (though 1.0 usually means completed)
    // Actually, visually:
    // Q1 -> 1 piece (1/4)
    // Q2 -> 2 pieces (2/4)
    // Q3 -> 3 pieces (3/4)
    // Q4 -> 4 pieces (4/4 -> full pie)
    // BUT usually the icon represents "Which quarter is this?".
    // If this is Q1, it represents the first piece.
    // If this is Q2, it represents the second piece.
    // However, user requirement says:
    // "1/4 -> quarter-filled, 2/4 -> half-filled..."
    // This implies Cumulative Progress of the Hizb?
    // "HizbSubCard" is a ROW for a quarter.
    // If I am at "Quarter 3 row", does the icon show 3/4 filled?
    // Usually, yes, visually indicating "This is the 3rd quarter".

    double targetFill = currentQuarter / 4.0;

    // Color logic
    Color activeColor = isCurrent ? AppColors.primaryColor : Colors.grey[400]!;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: targetFill),
      builder: (context, value, child) {
        return CustomPaint(
          size: Size(20.sp, 20.sp),
          painter: _PiePainter(progress: value, color: activeColor),
        );
      },
    );
  }
}

class _PiePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;

  _PiePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Paint for border (outline)
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Paint for Fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. Draw Outline Circle
    canvas.drawCircle(center, radius, borderPaint);

    // 2. Draw Pie Slice
    // Start from -90 degrees (top)
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, // Start at top
        2 * pi * progress, // Sweep angle
        true, // Use center
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
