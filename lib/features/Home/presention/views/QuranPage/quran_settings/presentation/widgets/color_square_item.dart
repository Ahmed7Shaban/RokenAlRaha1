import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/reading_theme_model.dart';
import '../../../../../../../../../../core/theme/app_colors.dart';

class ColorSquareItem extends StatelessWidget {
  final ReadingTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorSquareItem({
    Key? key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: theme.textColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
