import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart' as quran;
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../cubit/audio_quran_cubit.dart';
import '../cubit/audio_quran_state.dart';

class AyahList extends StatelessWidget {
  final VoidCallback onClose;
  const AyahList({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioQuranCubit, AudioQuranState>(
      listener: (context, state) {
        // Auto-scroll logic would go here if we had item keys or a specific scroll controller
      },
      builder: (context, state) {
        final totalAyahs = quran.getVerseCount(state.currentSurahNumber);

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      onPressed: onClose,
                    ),
                    Column(
                      children: [
                        Text(
                          "سورة ${quran.getSurahNameArabic(state.currentSurahNumber)}",
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "القارئ: ${state.selectedReciter.name}",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 48), // Balance
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: totalAyahs,
                  itemBuilder: (context, index) {
                    final ayahNumber = index + 1;
                    final isCurrent = state.currentAyahNumber == ayahNumber;

                    // If isCurrent, we might want to auto-scroll here in a PostFrameCallback?
                    // But standard ListView doesn't support "scroll to index" easily.

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primaryColor.withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: isCurrent
                            ? Border.all(
                                color: AppColors.primaryColor.withOpacity(0.5),
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            quran.getVerse(
                              state.currentSurahNumber,
                              ayahNumber,
                            ),
                            textAlign: TextAlign.justify,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 22.sp,
                              height: 2.2,
                              color: isCurrent ? Colors.black : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "${quran.getSurahNameArabic(state.currentSurahNumber)} - آية $ayahNumber",
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: isCurrent
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
