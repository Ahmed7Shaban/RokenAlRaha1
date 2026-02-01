import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AyahPreviewCard extends StatelessWidget {
  final String verseText;
  final String contentText;
  final String surahName;
  final int verseNumber;
  final TextDirection contentDirection;

  const AyahPreviewCard({
    Key? key,
    required this.verseText,
    required this.contentText,
    required this.surahName,
    required this.verseNumber,
    this.contentDirection = TextDirection.ltr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Arabic Verse
          Text(
            verseText,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: "QCF_P002",
              fontSize: 26.sp,
              height: 1.8,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 20.h),
          Divider(color: Colors.grey[200], thickness: 1),
          SizedBox(height: 20.h),

          // Content Area (Translation or Tafseer)
          Text(
            contentText,
            textAlign: TextAlign.center,
            textDirection: contentDirection,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),

          SizedBox(height: 24.h),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B4332).withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              "$surahName - $verseNumber",
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B4332),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Footer Text
          Text(
            "From the Roken Al-Raha app",
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
