import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart' as quran;
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/core/widgets/custom_app_bar.dart';
import '../widgets/ramadan_background.dart';
import 'cubit/audio_quran_cubit.dart';
import 'cubit/audio_quran_state.dart';
import 'widgets/ayah_list.dart';
import 'widgets/player_bar.dart';
import 'widgets/reciter_selector.dart';
import 'widgets/surah_list.dart';

class AudioQuranPage extends StatelessWidget {
  const AudioQuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AudioQuranView();
  }
}

class AudioQuranView extends StatefulWidget {
  const AudioQuranView({super.key});

  @override
  State<AudioQuranView> createState() => _AudioQuranViewState();
}

class _AudioQuranViewState extends State<AudioQuranView> {
  bool _showAyahList = false;

  void _toggleAyahList() {
    setState(() {
      _showAyahList = !_showAyahList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioQuranCubit, AudioQuranState>(
      buildWhen: (previous, current) =>
          previous.currentSurahNumber != current.currentSurahNumber ||
          previous.currentAyahNumber != current.currentAyahNumber ||
          previous.status != current.status ||
          previous.selectedReciter != current.selectedReciter,
      builder: (context, state) {
        final isPlayingOrPaused =
            state.status == AudioPlaybackStatus.playing ||
            state.status == AudioPlaybackStatus.paused;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: CustomAppBar(
            height: 100.h,
            title: isPlayingOrPaused
                ? "سورة ${quran.getSurahNameArabic(state.currentSurahNumber)}"
                : "القرآن المسموع",
            subtitle: isPlayingOrPaused
                ? "الآية ${state.currentAyahNumber} • ${state.selectedReciter.name}"
                : "استمع لأعذب التلاوات",
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  _showAyahList
                      ? Icons.format_list_bulleted_rounded
                      : Icons.article_rounded,
                  color: AppColors.primaryColor,
                ),
                tooltip: _showAyahList ? "عرض السور" : "عرض الآيات",
                onPressed: () {
                  _toggleAyahList();
                },
              ),
            ],
          ),
          body: RamadanBackground(
            child: Stack(
              children: [
                // Main Content (Surah List)
                Column(
                  children: [
                    const ReciterSelector(),
                    const Expanded(child: SurahList()),
                    // Spacing for PlayerBar
                    SizedBox(height: 120.h),
                  ],
                ),

                // Ayah List Overlay
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                          ),
                      child: child,
                    );
                  },
                  child: _showAyahList
                      ? AyahList(
                          key: const ValueKey('AyahList'),
                          onClose: _toggleAyahList,
                        )
                      : const SizedBox.shrink(),
                ),

                // Floating Player Bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      if (!_showAyahList) _toggleAyahList();
                    },
                    child: const PlayerBar(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
