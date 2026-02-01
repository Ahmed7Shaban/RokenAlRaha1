import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AyahColorPicker extends StatefulWidget {
  final int? selectedColorValue;
  final ValueChanged<int> onColorSelected;

  const AyahColorPicker({
    Key? key,
    this.selectedColorValue,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  State<AyahColorPicker> createState() => _AyahColorPickerState();
}

class _AyahColorPickerState extends State<AyahColorPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final List<int> _colors = [
    0xFFFFF59D, // Yellow (Soft)
    0xFFA5D6A7, // Green (Soft)
    0xFF90CAF9, // Blue (Soft)
    0xFFF48FB1, // Pink (Soft)
    0xFFCE93D8, // Purple (Soft)
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: _colors.map((colorVal) {
            final isSelected = widget.selectedColorValue == colorVal;
            return GestureDetector(
              onTap: () => widget.onColorSelected(colorVal),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Color(colorVal),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.black54, width: 2)
                      : Border.all(color: Colors.transparent),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Color(colorVal).withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16.sp, color: Colors.black54)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
