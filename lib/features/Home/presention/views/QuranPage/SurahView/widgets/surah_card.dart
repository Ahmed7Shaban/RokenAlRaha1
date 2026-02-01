import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../../source/app_images.dart';

class SurahCard extends StatelessWidget {
  final VoidCallback onTap;
  final String surahName;
  final int surahNumber;
  final int ayahNumber;

  final String? searchQuery;

  const SurahCard({
    super.key,
    required this.onTap,
    required this.surahName,
    required this.ayahNumber,
    required this.surahNumber,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    // final String iconPath = surah.revelationType == 'Meccan'
    //     ? Assets.imagesKaaba
    //     : Assets.imagesMosque;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // نحدد أحجام نسبية حسب حجم الشاشة
    final paddingH = screenWidth * 0.060; //
    final paddingV = screenHeight * 0.0278;

    final iconSize = screenWidth * 0.07; // 7% من العرض
    final textSize = screenWidth * 0.06; // 6% من العرض
    final spacing = screenWidth * 0.08;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.03), // حوالي 12px عادي
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: paddingV,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [AppColors.pureWhite, AppColors.primaryColor],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      surahName,
                      style: AppTextStyles.titleStyle.copyWith(
                        fontSize: textSize,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.02),

              Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    Assets.imagesNumberAya,
                    width: screenWidth * 0.11, // حجم الصورة
                    height: screenWidth * 0.11, // نخليها مربعة عشان الرقم يتوسط
                  ),
                  FittedBox(
                    // يضمن أن النص يتناسب مع حجم الصورة
                    fit: BoxFit.scaleDown,
                    child: Text(
                      ayahNumber.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "arsura",
                        fontWeight: FontWeight.bold,
                        fontSize:
                            screenWidth * 0.04, // حجم النص متناسب مع الشاشة
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(width: screenWidth * 0.02),
              NumberBox(number: surahNumber),
            ],
          ),
        ),
      ),
    );
  }
}

class NumberBox extends StatelessWidget {
  final int number;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  const NumberBox({
    super.key,
    required this.number,
    this.size = 40,
    this.backgroundColor = Colors.white,
    this.textColor = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8), // الحواف مدورة
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        number.toString(),
        style: TextStyle(
          color: textColor,
          fontFamily: "arsura",
          fontWeight: FontWeight.bold,
          fontSize: size * 0.5, // حجم الخط بالنسبة للمربع
        ),
      ),
    );
  }
}
