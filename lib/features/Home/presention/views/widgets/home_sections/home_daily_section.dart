import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../SmartContainer/smart_islamic_container.dart';
import '../dynamic_content_box.dart';
import '../../Hadith/presentation/widgets/hadith_home_card.dart';
import '../qiblah_home_card.dart';

class HomeDailySection extends StatelessWidget {
  const HomeDailySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Priority Info: Prayer Times & Status
        const SmartIslamicContainer()
            .animate()
            .fadeIn(duration: 200.ms)
            .slideX(begin: 0.3, end: 0, curve: Curves.easeInCirc),

        // 2. Daily Inspiration
        const DynamicContentBox()
            .animate()
            .fadeIn(duration: 200.ms)
            .slideX(begin: 0.3, end: 0, curve: Curves.easeInCirc),

        // 3. Daily Content: Hadith
        const HadithHomeCard()
            .animate()
            .fadeIn(duration: 200.ms)
            .slideX(begin: 0.3, end: 0, curve: Curves.easeInCirc),

        const SizedBox(height: 16),

        // 3.5 Qiblah Card
        const QiblahHomeCard()
            .animate()
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.3, end: 0, curve: Curves.easeInCirc),
      ],
    );
  }
}
