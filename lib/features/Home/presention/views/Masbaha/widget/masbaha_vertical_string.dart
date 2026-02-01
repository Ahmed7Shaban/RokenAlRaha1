import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class MasbahaVerticalString extends StatelessWidget {
  final int count;
  final Color baseColor;

  const MasbahaVerticalString({
    super.key,
    required this.count,
    this.baseColor = AppColors.primaryColor, // Premium wood color (Brown 700)
  });

  @override
  Widget build(BuildContext context) {
    // We use a key derived from count only if we wanted to reset,
    // but for smooth accumulation, just changing end value is correct.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: count.toDouble(), end: count.toDouble()),
      // Duration matches the user's tap rhythm - fast enough to feel responsive
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return _BeadsStringRenderer(
          scrollProgress: value,
          beadColor: baseColor,
        );
      },
    );
  }
}

class _BeadsStringRenderer extends StatelessWidget {
  final double scrollProgress;
  final Color beadColor;

  const _BeadsStringRenderer({
    required this.scrollProgress,
    required this.beadColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        const beadSize = 40.0;
        const spacing = 50.0; // Standard spacing between beads

        final centerY = height / 2;
        // String visual width
        const stringWidth = 2.0;
        final stringColor = Colors.brown.withOpacity(0.4);

        // Calculate Visible Range
        // We render generic beads based on scrollProgress
        // Visible Y range: [-beadSize, height + beadSize]
        // y = centerY + (i - scrollProgress)*spacing
        final int minIndex = (scrollProgress - (height / spacing) - 2).floor();
        final int maxIndex = (scrollProgress + (height / spacing) + 2).ceil();

        List<Widget> children = [];

        // 1. Draw the continuous string
        children.add(
          Positioned(
            top: -50,
            bottom: -50,
            left: (constraints.maxWidth - stringWidth) / 2,
            child: Container(width: stringWidth, color: stringColor),
          ),
        );

        // 2. Draw Beads
        for (int i = minIndex; i <= maxIndex; i++) {
          final dist = i - scrollProgress;

          final top = centerY + (dist * spacing) - (beadSize / 2);

          // Boundaries check
          if (top < -beadSize || top > height) continue;

          children.add(
            Positioned(
              top: top,
              left: (constraints.maxWidth - beadSize) / 2,
              child: _RealisticBead(size: beadSize, color: beadColor, index: i),
            ),
          );
        }

        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }
}

class _RealisticBead extends StatelessWidget {
  final double size;
  final Color color;
  final int index;

  const _RealisticBead({
    required this.size,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Wood texture simulation using gradients
    // Base color varying slightly by index for natural look
    final Color effectiveColor = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness + (index % 3) * 0.02).clamp(
            0.0,
            1.0,
          ),
        )
        .toColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Main 3D Volume
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.4),
          focal: const Alignment(-0.4, -0.4),
          radius: 1.0,
          colors: [
            effectiveColor.withOpacity(0.9), // Highlight
            effectiveColor, // Base
            Colors.black.withOpacity(0.6), // Shadow
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          // Drop shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(2, 4),
            blurRadius: 6,
          ),
          // Inner glow/rim light for polished wood effect
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            offset: const Offset(-1, -1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      // Subtle wood grain detail could be added with a CustomPainter here
      // but gradient is usually sufficient for small moving objects.
      child: CustomPaint(painter: _WoodGrainPainter(color: effectiveColor)),
    );
  }
}

class _WoodGrainPainter extends CustomPainter {
  final Color color;
  _WoodGrainPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Very subtle lines to simulate wood grain
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw a couple of curved lines
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.4,
      size.width * 0.8,
      size.height * 0.3,
    );

    path.moveTo(size.width * 0.2, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.7,
      size.width * 0.8,
      size.height * 0.6,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
