import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../../logic/cubit/last_read_cubit.dart';
import '../../logic/cubit/last_read_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_view_page.dart';

class LastReadCard extends StatelessWidget {
  final dynamic surahJsonData;

  const LastReadCard({super.key, required this.surahJsonData});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LastReadCubit, LastReadState>(
      builder: (context, state) {
        if (state is LastReadLoaded && state.lastRead != null) {
          final lastRead = state.lastRead!;
          final primaryColor = AppColors.primaryColor;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScreenUtilInit(
                        designSize: const Size(392.7, 800.7),
                        child: QuranViewPage(
                          shouldHighlightText: true,
                          highlightVerse:
                              " ${lastRead.surahNumber}${lastRead.ayahNumber}",
                          jsonData: surahJsonData,
                          pageNumber: lastRead.pageNumber,
                        ),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    children: [
                      // 🔹 Icon Container
                      Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: primaryColor,
                          size: 26.sp,
                        ),
                      ),

                      SizedBox(width: 16.w),

                      // 🔹 Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "تابع قراءتك",
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "سورة ${lastRead.surahName}",
                                          style: GoogleFonts.amiri(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        WidgetSpan(child: SizedBox(width: 8.w)),
                                        TextSpan(
                                          text: "الآية ${lastRead.ayahNumber}",
                                          style: GoogleFonts.cairo(
                                            fontSize: 14.sp,
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 🔹 Forward Arrow
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14.sp,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
