import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AyahSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTapBack;

  const AyahSheetHeader({
    Key? key,
    required this.title,
    required this.onTapBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              IconButton(
                onPressed: onTapBack,
                icon: const Icon(Icons.close),
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
