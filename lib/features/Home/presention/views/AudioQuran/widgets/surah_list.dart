import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../cubit/audio_quran_cubit.dart';
import '../cubit/audio_quran_state.dart';
import 'audio_wave_animation.dart';

class SurahList extends StatelessWidget {
  const SurahList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioQuranCubit, AudioQuranState>(
      buildWhen: (previous, current) =>
          previous.currentSurahNumber != current.currentSurahNumber ||
          previous.status != current.status ||
          previous.downloadedSurahs != current.downloadedSurahs ||
          previous.downloadingSurahId != current.downloadingSurahId ||
          previous.downloadProgress != current.downloadProgress,
      builder: (context, state) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: 114,
          itemBuilder: (context, index) {
            final surahNumber = index + 1;
            final isCurrentSurah = state.currentSurahNumber == surahNumber;
            final isPlaying =
                isCurrentSurah && state.status == AudioPlaybackStatus.playing;

            final isDownloaded = state.downloadedSurahs.contains(surahNumber);
            final isDownloading = state.downloadingSurahId == surahNumber;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(vertical: 4.h),
              decoration: BoxDecoration(
                color: isCurrentSurah
                    ? AppColors.primaryColor.withOpacity(0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isCurrentSurah
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 4.h,
                ),
                onTap: () {
                  context.read<AudioQuranCubit>().playSurah(surahNumber);
                },
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrentSurah
                        ? AppColors.primaryColor
                        : const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    boxShadow: isCurrentSurah
                        ? [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    "$surahNumber",
                    style: GoogleFonts.cairo(
                      color: isCurrentSurah ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                title: Text(
                  "سورة ${quran.getSurahNameArabic(surahNumber)}",
                  style: GoogleFonts.amiri(
                    fontSize: 18.sp,
                    fontWeight: isCurrentSurah
                        ? FontWeight.bold
                        : FontWeight.w600,
                    color: isCurrentSurah
                        ? AppColors.primaryColor
                        : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  "${quran.getVerseCount(surahNumber)} آية • ${quran.getPlaceOfRevelation(surahNumber)}",
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Playback Animation
                    if (isCurrentSurah) ...[
                      AudioWaveAnimation(isPlaying: isPlaying),
                      SizedBox(width: 16.w),
                    ],

                    // Download Button / Status
                    if (isDownloading)
                      SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: CircularProgressIndicator(
                          value: state.downloadProgress > 0
                              ? state.downloadProgress
                              : null,
                          strokeWidth: 3,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          color: AppColors.primaryColor,
                        ),
                      )
                    else if (isDownloaded)
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 26.sp,
                      )
                    else
                      IconButton(
                        onPressed: () {
                          // Prevent triggering play on row tap
                          context.read<AudioQuranCubit>().downloadSurah(
                            surahNumber,
                          );
                        },
                        icon: Icon(
                          Icons.download_rounded,
                          color: Colors.grey.shade400,
                          size: 26.sp,
                        ),
                        splashRadius: 20,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
