import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../date/buttons_list_item.dart';
import '../sub_title.dart';
import '../buttons_list.dart';

class HomeServicesSection extends StatelessWidget {
  const HomeServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubTitle(subTitle: 'استكشف مميزات ركن الراحة'),
        const SizedBox(height: 10),

        ButtonsList(
          buttonsItems: itemsQ,
          width: double.infinity,
          height: 130,
          heightList: 130,
        ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.3, end: 0),

        const SizedBox(height: 10),

        ButtonsList(
          buttonsItems: itemsMasbaha,
          width: double.infinity,
          height: 30,
          heightList: 70,
        ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.3, end: 0),
      ],
    );
  }
}
