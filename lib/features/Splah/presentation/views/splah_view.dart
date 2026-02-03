import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../routes/routes.dart';
import '../../../../features/Onboarding/presentation/view/onboarding_view.dart';
import '../widgets/body_splash.dart';

class SplahView extends StatefulWidget {
  const SplahView({super.key});
  static const String routeName = Routes.splash;

  @override
  State<SplahView> createState() => _SplahViewState();
}

class _SplahViewState extends State<SplahView> {
  @override
  void initState() {
    super.initState();

    // Auto navigation after animations check for onboarding
    Future.delayed(const Duration(milliseconds: 3500), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final bool hasSeenOnboarding =
            prefs.getBool('has_seen_onboarding') ?? false;

        if (mounted) {
          if (hasSeenOnboarding) {
            Navigator.pushReplacementNamed(context, Routes.home);
          } else {
            // Navigate to Onboarding
            Navigator.pushReplacementNamed(context, OnboardingView.routeName);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BodySplash());
  }
}
