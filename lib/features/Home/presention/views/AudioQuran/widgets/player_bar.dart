import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../cubit/audio_quran_cubit.dart';
import '../cubit/audio_quran_state.dart';

class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Base opacity
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Info Row
                const _PlayerInfoRow(),

                SizedBox(height: 12.h),

                // 2. Progress Bar
                const _PlayerProgressBar(),

                SizedBox(height: 8.h),

                // 3. Controls
                const _PlayerControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerInfoRow extends StatelessWidget {
  const _PlayerInfoRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioQuranCubit, AudioQuranState>(
      // Listen to error message changes specially
      buildWhen: (p, c) =>
          p.currentSurahNumber != c.currentSurahNumber ||
          p.currentAyahNumber != c.currentAyahNumber ||
          p.selectedReciter != c.selectedReciter ||
          p.status != c.status ||
          p.errorMessage != c.errorMessage,
      builder: (context, state) {
        // Intelligence: Show status message if retrying or error
        if (state.errorMessage != null ||
            state.status == AudioPlaybackStatus.error) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            width: double.infinity,
            child: Text(
              state.errorMessage ?? "حدث خطأ غير متوقع",
              style: GoogleFonts.cairo(
                color: Colors.redAccent,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }

        final surahName = quran.getSurahNameArabic(state.currentSurahNumber);
        final ayahInfo = "آية ${state.currentAyahNumber}";

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "سورة $surahName",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.amiri(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ayahInfo,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                state.selectedReciter.name,
                style: GoogleFonts.cairo(
                  fontSize: 10.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlayerProgressBar extends StatelessWidget {
  const _PlayerProgressBar();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AudioQuranCubit>();

    return BlocBuilder<AudioQuranCubit, AudioQuranState>(
      buildWhen: (p, c) => p.totalDuration != c.totalDuration,
      builder: (context, state) {
        final totalMs = state.totalDuration.inMilliseconds.toDouble();
        final safeMax = totalMs > 0 ? totalMs : 1.0;

        return StreamBuilder<Duration>(
          stream: cubit.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final currentMs = position.inMilliseconds.toDouble();
            final safeValue = currentMs.clamp(0.0, safeMax);

            return Theme(
              data: Theme.of(context).copyWith(
                sliderTheme: SliderThemeData(
                  trackHeight: 4.h,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
                  activeTrackColor: AppColors.primaryColor,
                  inactiveTrackColor: Colors.grey.withOpacity(0.2),
                  thumbColor: AppColors.primaryColor,
                  overlayColor: AppColors.primaryColor.withOpacity(0.1),
                ),
              ),
              child: Slider(
                value: safeValue,
                min: 0.0,
                max: safeMax,
                onChanged: (value) {},
                onChangeEnd: (value) {
                  cubit.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioQuranCubit, AudioQuranState>(
      buildWhen: (prev, curr) =>
          prev.status != curr.status, // Only rebuild on status change
      builder: (context, state) {
        final cubit = context.read<AudioQuranCubit>();
        final bool isPlaying = state.status == AudioPlaybackStatus.playing;
        final bool isLoading = state.status == AudioPlaybackStatus.loading;

        return Directionality(
          textDirection: TextDirection.ltr, // Force Standard Media Layout
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous
              IconButton(
                onPressed: () => cubit.previousAyah(),
                icon: Icon(
                  Icons.skip_previous_rounded,
                  size: 32.sp,
                  color: Colors.black87,
                ),
              ),

              SizedBox(width: 24.w),

              // Play / Pause / Load
              GestureDetector(
                onTap: () => cubit.togglePlay(),
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 36.sp,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),

              SizedBox(width: 24.w),

              // Next
              IconButton(
                onPressed: () => cubit.nextAyah(),
                icon: Icon(
                  Icons.skip_next_rounded,
                  size: 32.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
