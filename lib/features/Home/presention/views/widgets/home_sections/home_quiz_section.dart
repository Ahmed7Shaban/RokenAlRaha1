import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../sub_title.dart';
import '../quiz/islamic_quiz_widget.dart';

class HomeQuizSection extends StatelessWidget {
  const HomeQuizSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubTitle(subTitle: 'اختبر معلوماتك'),
        const SizedBox(height: 8),
        const IslamicQuizWidget()
            .animate()
            .fadeIn(duration: 500.ms)
            .slideX(begin: 0.3, end: 0, curve: Curves.easeInCirc),
      ],
    );
  }
}
