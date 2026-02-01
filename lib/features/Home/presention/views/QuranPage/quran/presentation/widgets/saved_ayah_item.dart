import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import '../../data/models/ayah_bookmark_model.dart';
import '../../../../../../../../core/theme/app_colors.dart';

class SavedAyahItem extends StatelessWidget {
  final AyahBookmarkModel bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SavedAyahItem({
    Key? key,
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(bookmark.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 24.w),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Color Indicator
              Container(
                width: 12.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: bookmark.color, // Color from bookmark model
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: 16.w),

              // 2. Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quran.getSurahNameArabic(bookmark.surahNumber),
                      style: GoogleFonts.amiri(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "آية رقم ${bookmark.verseNumber} • صفحة ${quran.getPageNumber(bookmark.surahNumber, bookmark.verseNumber)}",
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Delete Button (for explicit action)
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_rounded,
                  color: Colors.red.shade300,
                  size: 24.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
