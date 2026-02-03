import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../sub_title.dart';
import '../support_home_card.dart';

class HomeSupportSection extends StatelessWidget {
  const HomeSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SubTitle(subTitle: 'الدعم والتواصل'),
        const SizedBox(height: 10),
        const SupportHomeCard()
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 20),
      ],
    );
  }
}
