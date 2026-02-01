import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title; // String or Widget
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onLeadingPressed;
  final bool centerTitle;
  final Color? backgroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final double height;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.onLeadingPressed,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
    this.bottom,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    bottom == null ? height : height + bottom!.preferredSize.height,
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading:
          false, // We handle leading manually for more control
      leading:
          leading ??
          (Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black87,
                    size: 20.sp,
                  ),
                  onPressed:
                      onLeadingPressed ?? () => Navigator.of(context).pop(),
                  tooltip: "رجوع",
                )
              : null),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (title is Widget)
            title
          else
            Text(
              title.toString(),
              style: GoogleFonts.amiri(
                textStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (subtitle != null) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle!,
              style: GoogleFonts.cairo(
                textStyle: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: actions != null
          ? actions!.map((action) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: action,
              );
            }).toList()
          : null,
      bottom: bottom,
      shape: elevation! > 0
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16.r),
              ),
            )
          : null,
    );
  }
}
