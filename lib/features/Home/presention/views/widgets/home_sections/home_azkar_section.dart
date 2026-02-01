import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../azkar_home_card.dart';

class HomeAzkarSection extends StatelessWidget {
  const HomeAzkarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AzkarHomeCard()
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
