import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../../core/theme/app_colors.dart';

class SurahCardSkeleton extends StatelessWidget {
  const SurahCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final paddingH = screenWidth * 0.060;
    final paddingV = screenHeight * 0.0278;
    final spacing = screenWidth * 0.08;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.03),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: paddingV,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.grey.shade300, Colors.grey.shade200],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Container(
                  height: screenHeight * 0.03,
                  color: Colors.grey.shade400,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              // مكان أيقونة الرقم
              Container(
                width: screenWidth * 0.11,
                height: screenWidth * 0.11,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(screenWidth * 0.055),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              // مكان NumberBox
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
