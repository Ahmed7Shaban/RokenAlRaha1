import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:roken_al_raha/core/theme/app_colors.dart';

import '../../data/reciters_data.dart';
import '../cubit/audio_player_cubit.dart';
import '../cubit/audio_player_state.dart';

class AyahAudioSheet extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;

  const AyahAudioSheet({
    Key? key,
    required this.surahNumber,
    required this.verseNumber,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required int surahNumber,
    required int verseNumber,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (_) => AudioPlayerCubit(
          initialSurah: surahNumber,
          initialVerse: verseNumber,
        )..loadAndPlayVerse(),
        child: AyahAudioSheet(
          surahNumber: surahNumber,
          verseNumber: verseNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFDFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 48.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 24.h),

              // Title: Surah & Verse
              BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                buildWhen: (previous, current) =>
                    previous.currentVerse != current.currentVerse ||
                    previous.currentSurah != current.currentSurah,
                builder: (context, state) {
                  return Text(
                    "${quran.getSurahNameArabic(state.currentSurah)} - الآية ${state.currentVerse}",
                    style: GoogleFonts.amiri(
                      fontSize: 18.sp,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),

              // Verse Text (Swipeable)
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  constraints: BoxConstraints(maxHeight: 0.3.sh),
                  child: BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                    buildWhen: (previous, current) =>
                        previous.currentVerse != current.currentVerse ||
                        previous.currentSurah != current.currentSurah,
                    builder: (context, state) {
                      final verseText = quran.getVerse(
                        state.currentSurah,
                        state.currentVerse,
                        verseEndSymbol: true,
                      );

                      // Gesture Detector for Swiping
                      return GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity! < 0) {
                            // Swipe Left -> Next (RTL Logic: Left implies forward in time usually, or depending on UX.
                            // In RTL apps, Right swipe usually means Back/Prev, Left swipe means Next.
                            context.read<AudioPlayerCubit>().nextVerse();
                          } else if (details.primaryVelocity! > 0) {
                            // Swipe Right -> Prev
                            context.read<AudioPlayerCubit>().prevVerse();
                          }
                        },
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            verseText,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Reciter Selector
              // Reciter Selector (Custom Card-Like)
              BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                buildWhen: (p, c) => p.selectedReciter != c.selectedReciter,
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () {
                      _showReciterSelectionSheet(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.mic_rounded,
                                  color: AppColors.primaryColor,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                state.selectedReciter.name,
                                style: GoogleFonts.amiri(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey,
                            size: 24.sp,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),

              // Progress Bar
              BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                buildWhen: (p, c) =>
                    p.currentPosition != c.currentPosition ||
                    p.totalDuration != c.totalDuration,
                builder: (context, state) {
                  final position = state.currentPosition.inMilliseconds
                      .toDouble();
                  final duration = state.totalDuration.inMilliseconds
                      .toDouble();
                  final max = duration > 0 ? duration : 1.0;
                  final value = position.clamp(0.0, max);

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          trackHeight: 4,
                          activeTrackColor: AppColors.primaryColor,
                          inactiveTrackColor: AppColors.primaryColor
                              .withOpacity(0.2),
                          thumbColor: AppColors.primaryColor,
                        ),
                        child: Slider(
                          value: value,
                          min: 0.0,
                          max: max,
                          onChanged: (val) {
                            context.read<AudioPlayerCubit>().seek(
                              Duration(milliseconds: val.toInt()),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(state.currentPosition),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              _formatDuration(state.totalDuration),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 16.h),

              // Controls (Force LTR for standard player feel)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<AudioPlayerCubit>().prevVerse();
                      },
                      icon: const Icon(Icons.skip_previous_rounded, size: 36),
                    ),
                    SizedBox(width: 24.w),

                    BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                      buildWhen: (p, c) => p.status != c.status,
                      builder: (context, state) {
                        final isPlaying = state.status == AudioStatus.playing;
                        final isLoading = state.status == AudioStatus.loading;

                        return Container(
                          height: 64.w,
                          width: 64.w,
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
                          child: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : IconButton(
                                  onPressed: () {
                                    context
                                        .read<AudioPlayerCubit>()
                                        .togglePlayPause();
                                  },
                                  icon: Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                        );
                      },
                    ),

                    SizedBox(width: 24.w),
                    IconButton(
                      onPressed: () {
                        context.read<AudioPlayerCubit>().nextVerse();
                      },
                      icon: const Icon(Icons.skip_next_rounded, size: 36),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  void _showReciterSelectionSheet(BuildContext parentContext) {
    // We need to capture the cubit from the parent context (the sheet context)
    // because showModalBottomSheet creates a new context branch.
    final cubit = parentContext.read<AudioPlayerCubit>();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFDFDFD),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  // Handle
                  Container(
                    width: 48.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    "اختر القارئ",
                    style: GoogleFonts.amiri(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Divider(color: Colors.grey.withOpacity(0.1)),
                  Expanded(
                    child: BlocProvider.value(
                      value: cubit,
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: availableReciters.length,
                        separatorBuilder: (c, i) => Divider(
                          color: Colors.grey.withOpacity(0.05),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final reciter = availableReciters[index];
                          return BlocBuilder<
                            AudioPlayerCubit,
                            AudioPlayerState
                          >(
                            buildWhen: (p, c) =>
                                p.selectedReciter != c.selectedReciter,
                            builder: (context, state) {
                              final isSelected =
                                  state.selectedReciter.id == reciter.id;
                              return InkWell(
                                onTap: () {
                                  context
                                      .read<AudioPlayerCubit>()
                                      .changeReciter(reciter);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 16.h,
                                  ),
                                  color: isSelected
                                      ? AppColors.primaryColor.withOpacity(0.05)
                                      : null,
                                  child: Row(
                                    children: [
                                      // Optional Avatar/Icon Placeholder
                                      Container(
                                        width: 48.w,
                                        height: 48.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? AppColors.primaryColor
                                                    .withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.1),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.person_rounded,
                                            color: isSelected
                                                ? AppColors.primaryColor
                                                : Colors.grey,
                                            size: 24.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Text(
                                          reciter.name,
                                          style: GoogleFonts.amiri(
                                            fontSize: 18.sp,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? AppColors.primaryColor
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.primaryColor,
                                          size: 24.sp,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
