import 'package:flutter/material.dart';

import '../../../../../../core/widgets/appbar_widget.dart';
import '../../../../../../core/services/welcome_notification_service.dart';

import 'home_sections/home_daily_section.dart';
import 'home_sections/home_premium_section.dart';
import 'home_sections/home_quiz_section.dart';
import 'home_sections/home_services_section.dart';
import 'home_sections/home_azkar_section.dart';
import 'home_sections/home_khatma_section.dart';

class BodyHomeView extends StatefulWidget {
  const BodyHomeView({super.key});

  @override
  State<BodyHomeView> createState() => _BodyHomeViewState();
}

class _BodyHomeViewState extends State<BodyHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WelcomeNotificationService().showWelcomeNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          AppbarWidget(title: 'ركن الراحة'),
          const SizedBox(height: 12),

          // Daily Essentials (Prayer, Dynamic Inspiration, Hadith, Qiblah)
          const HomeDailySection(),
          const SizedBox(height: 16),

          // Premium Features
          const HomePremiumSection(),
          const SizedBox(height: 16),

          // Interactive (Quiz)
          const HomeQuizSection(),
          const SizedBox(height: 16),

          // Tools & Services
          const HomeServicesSection(),

          // Azkar Card
          const HomeAzkarSection(),
          const SizedBox(height: 24),

          // Footer (Khatma CTA)
          const HomeKhatmaSection(),
          const SizedBox(height: 40), // Bottom padding
        ],
      ),
    );
  }
}
