import 'package:flutter/material.dart';
import '../../../../routes/routes.dart';
import '../widgets/onboarding_page_widget.dart';
import '../widgets/permissions_page_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:roken_al_raha/core/services/storage_service.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';

class OnboardingView extends StatefulWidget {
  static const String routeName = '/onboarding';
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<Widget> _pages = [
    // Screen 1: Welcome
    const OnboardingPageWidget(
      title: "ركن الراحة.. واحتك الإيمانية",
      description:
          "مساحتك الخاصة للهدوء والسكينة.. رفيقك الذي يذكرك بالله في زحام الحياة، ويقربك من طاعته بكل يسر وسهولة .",
      imagePath: "assets/Images/onboarding_welcome.png",
    ),

    // Screen 2: Features
    const OnboardingPageWidget(
      title: "كل ما يحتاجه المسلم في مكان واحد",
      description:
          "مواقيت دقيقة، سبحة إلكترونية، ومكتبة إسلامية شاملة بين يديك.",
      imagePath: "assets/Images/onboarding_features.png",
    ),

    // Screen 3: Permissions
    const PermissionsPageWidget(),

    // Screen 4: Start
    OnboardingPageWidget(
      title: "ابدأ رحلة الطمأنينة",
      description:
          "انضم إلينا لنبني معاً عادات إيمانية يومية، ونملأ يومك بالذكر والراحة النفسية .",
      imagePath: "assets/Images/onboarding_start.png",
      isLastPage: true,
      onStartPressed: _finishOnboarding,
    ),
  ];

  void _onNext() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      await _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    // Ensure storage is initialized and save the value
    await StorageService().setBool('has_completed_onboarding', true);

    if (!mounted) return;

    // Use pushNamedAndRemoveUntil to prevent going back to onboarding
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Off-white
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 0.0;
                  if (_pageController.position.haveDimensions) {
                    value = index - (_pageController.page ?? 0);
                    value = value.clamp(-1.0, 1.0);
                  }

                  final curve = Curves.easeOut;
                  final double scale = curve.transform(1 - (value.abs() * 0.2));
                  final double opacity = curve.transform(
                    1 - (value.abs() * 0.5),
                  );

                  return Transform(
                    transform: Matrix4.identity()
                      ..scale(scale, scale)
                      ..translate(value * 20), // Slight parallax
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: _pages[index],
              );
            },
          ),

          // Bottom Controls
          if (_currentPage != _pages.length - 1)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip Button
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        "تخطي",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    )
                  else
                    const SizedBox(width: 60), // Spacer
                  // Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next Button
                  if (_currentPage < _pages.length - 1)
                    FloatingActionButton(
                      onPressed: _onNext,
                      backgroundColor: AppColors.primaryColor,
                      elevation: 0,
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                      ),
                    )
                  else
                    const SizedBox(width: 60), // Spacer for last page centering
                ],
              ),
            ),
        ],
      ),
    );
  }
}
