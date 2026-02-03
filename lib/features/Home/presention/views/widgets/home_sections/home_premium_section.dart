import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../sub_title.dart';
import '../salat_on_prophet_home_card.dart';
import '../duaa_home_banner.dart';
import '../../../../../FajrAlarm/presentation/view/fajr_alarm_control_card.dart';

class HomePremiumSection extends StatelessWidget {
  const HomePremiumSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubTitle(subTitle: 'الأقسام المميزة'),
        const SizedBox(height: 8),

        const FajrAlarmControlCard()
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.2, end: 0),

        const SizedBox(height: 12),

        const SalatOnProphetHomeCard()
            .animate()
            .fadeIn(duration: 350.ms)
            .slideX(begin: 0.3, end: 0, curve: Curves.easeInCirc),

        const DuaaHomeBanner()
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.3, end: 0, curve: Curves.easeInCirc),
      ],
    );
  }
}
