import 'package:flutter/material.dart';
import '../sub_title.dart';
import '../khatma_image_button.dart';

class HomeKhatmaSection extends StatelessWidget {
  const HomeKhatmaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SubTitle(subTitle: "ابدأ رحلة الختم الآن"),
        const KhatmaImageButton(),
        const SizedBox(height: 40), // Bottom padding
      ],
    );
  }
}
