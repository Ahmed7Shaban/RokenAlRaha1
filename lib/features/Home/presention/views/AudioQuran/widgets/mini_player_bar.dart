import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran;
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/features/Home/presention/views/AudioQuran/cubit/audio_quran_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/AudioQuran/cubit/audio_quran_state.dart';
import '../audio_quran_page.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioQuranCubit, AudioQuranState>(
      builder: (context, state) {
        if (state.status == AudioPlaybackStatus.initial ||
            state.status == AudioPlaybackStatus.stopped) {
          return const SizedBox.shrink();
        }

        final surahName = quran.getSurahNameArabic(state.currentSurahNumber);
        final ayahNum = state.currentAyahNumber;

        return Dismissible(
          key: const Key('mini_player_bar'),
          direction: DismissDirection.down,
          onDismissed: (_) {
            context.read<AudioQuranCubit>().togglePlay();
          },
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AudioQuranPage()),
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // 1. Icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.music_note_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // 2. Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "سورة $surahName",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "الآية $ayahNum • ${state.selectedReciter.name}",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // 3. Controls (Standard LTR)
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => context
                                        .read<AudioQuranCubit>()
                                        .previousAyah(),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.skip_previous_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Play/Pause
                                  Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: GestureDetector(
                                      onTap: () => context
                                          .read<AudioQuranCubit>()
                                          .togglePlay(),
                                      child:
                                          state.status ==
                                              AudioPlaybackStatus.loading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: AppColors.primaryColor,
                                              ),
                                            )
                                          : Icon(
                                              state.isPlaying
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: AppColors.primaryColor,
                                              size: 28,
                                            ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  IconButton(
                                    onPressed: () => context
                                        .read<AudioQuranCubit>()
                                        .nextAyah(),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.skip_next_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: state.totalDuration.inMilliseconds > 0
                                ? (state.currentPosition.inMilliseconds /
                                          state.totalDuration.inMilliseconds)
                                      .clamp(0.0, 1.0)
                                : 0.0,
                            backgroundColor: Colors.black.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
