import 'package:flutter/material.dart';

class RamadanBackground extends StatelessWidget {
  final Widget child;
  const RamadanBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Base Gradient Layer
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFEF9E6), // Soft Cream/Gold
                Colors.white,
              ],
              stops: [0.0, 0.4],
            ),
          ),
        ),

        // 2. Hanging Decorative Image (Top Banner)
        // 2. Decorative Image (Bottom Layer)

        // 3. Content Area
        // Puts child on top. We assume child handles its own ScrollView/SafeArea if needed,
        // OR we can wrap it here. Given standard Scaffold bodies, they might expect full height.
        // We use Positioned.fill to ensure it takes available space.
        Positioned.fill(child: child),
      ],
    );
  }
}
