import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';

class SmartContainerBackground extends StatelessWidget {
  final String assetPath;

  const SmartContainerBackground({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    if (assetPath.endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholderBuilder: (context) =>
            Container(color: AppColors.primaryColor),
      );
    } else {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: AppColors.primaryColor),
      );
    }
  }
}
