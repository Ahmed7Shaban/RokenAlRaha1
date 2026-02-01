import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';

import 'package:roken_al_raha/features/Home/presention/views/Hadith/hadith_logic/hadith_books_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_book.dart';

class HadithBookCard extends StatelessWidget {
  final HadithBook book;
  final VoidCallback onTap;

  const HadithBookCard({Key? key, required this.book, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HadithBooksCubit, HadithBooksState>(
      builder: (context, state) {
        bool isDownloading = false;
        double progress = 0.0;

        if (state is HadithBooksLoaded && state.downloadingBookId == book.id) {
          isDownloading = true;
          progress = state.downloadProgress ?? 0.0;
        }

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          elevation: 4,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.primaryColor, width: 2),
            borderRadius: BorderRadius.circular(16.r),
          ),
          clipBehavior: Clip.antiAlias, // Important for overlay
          child: Stack(
            children: [
              InkWell(
                onTap: isDownloading
                    ? null
                    : (book.isDownloaded
                          ? onTap
                          : onTap), // Allow tap if not downloading
                // Actually, if downloading, we block tap.
                borderRadius: BorderRadius.circular(16.r),
                customBorder: RoundedRectangleBorder(
                  side: BorderSide(color: AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              book.name,
                              style: GoogleFonts.cairo(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          if (book.isDownloaded)
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primaryColor,
                              size: 24.sp,
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(
                            "عدد الأحاديث: ${book.totalHadiths ?? 'غير معروف'}",
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          if (book.isDownloaded && book.totalHadiths != null)
                            Text(
                              "المقروء: ${book.readCount} / ${book.totalHadiths}",
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildActionButton(
                        context,
                        book.isDownloaded,
                        isDownloading,
                      ),
                    ],
                  ),
                ),
              ),
              if (isDownloading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress > 0 ? progress : null,
                          color: Theme.of(context).primaryColor,
                          backgroundColor: Colors.white24,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "جاري تحميل الكتاب... ${(progress * 100).toInt()}%",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "يرجى الانتظار",
                          style: GoogleFonts.cairo(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    bool isDownloaded,
    bool isDownloading,
  ) {
    if (isDownloaded) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed:
              null, // Disabled inside Stack interactive area, handled by InkWell or ignored here
          // But visually we want it to look enabled if not downloading.
          // However, onTap is handled by parent InkWell mostly.
          // Let's keep it decorative or non-clickable to avoid conflict.
          icon: Icon(Icons.book, size: 18, color: Colors.white),
          label: Text(
            "تصفح الكتاب",
            style: GoogleFonts.cairo(color: Colors.white),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColors.primaryColor),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      );
    }

    // Not downloaded
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: null, // Parent InkWell handles tap
        icon: Icon(Icons.download, color: Colors.white),
        label: Text(
          "تحميل الكتاب",
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.primaryColor),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}
