import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart' as quran;
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/features/Home/presention/views/AudioQuran/cubit/audio_quran_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/AudioQuran/cubit/audio_quran_state.dart';

import '../../features/Home/presention/views/AudioQuran/audio_quran_page.dart';
import '../../routes/routes.dart';

// Global Route Observer to track current route
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class GlobalAudioOverlay extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final Widget child;

  const GlobalAudioOverlay({Key? key, required this.child, this.navigatorKey})
    : super(key: key);

  @override
  State<GlobalAudioOverlay> createState() => _GlobalAudioOverlayState();
}

// Simple logic to track global route for overlay visibility
class GlobalRouteObserver extends NavigatorObserver {
  static final ValueNotifier<String?> currentRouteName = ValueNotifier<String?>(
    null,
  );

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      currentRouteName.value = route.settings.name;
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute?.settings.name != null) {
      currentRouteName.value = newRoute!.settings.name;
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.settings.name != null) {
      currentRouteName.value = previousRoute!.settings.name;
    }
    super.didPop(route, previousRoute);
  }
}

class _GlobalAudioOverlayState extends State<GlobalAudioOverlay> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. App Content + Overlay Logic
    // We place the app content first.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        child: Stack(
          children: [
            widget.child,

            // Overlay Visibility
            ValueListenableBuilder<String?>(
              valueListenable: GlobalRouteObserver.currentRouteName,
              builder: (context, routeName, _) {
                // Hide on Splash
                if (routeName == Routes.splash) {
                  return const SizedBox.shrink();
                }

                // We provide a local Overlay for the floating player.
                // IMPORTANT: We do NOT wrap this Overlay in a BlocBuilder.
                // If we did, the Overlay would rebuild on state changes, but Overlay.initialEntries
                // is ignored on updates, causing the internal OverlayEntry to hold onto stale state/closures.
                // Instead, we put the BlocBuilder INSIDE the OverlayEntry.
                return Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (context) => _buildAudioInterface(context),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioInterface(BuildContext context) {
    return BlocBuilder<AudioQuranCubit, AudioQuranState>(
      // Optimize rebuilds
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.currentSurahNumber != current.currentSurahNumber ||
          previous.currentAyahNumber != current.currentAyahNumber ||
          previous.volume != current.volume ||
          previous.downloadProgress != current.downloadProgress ||
          previous.downloadingSurahId != current.downloadingSurahId,
      builder: (context, state) {
        return Stack(
          children: [
            if (_isExpanded) ...[
              // Barrier
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleExpanded,
                  child: Container(
                    color: Colors.black26,
                  ), // slightly visible dim
                ),
              ),
              // Panel
              Positioned(
                right: 16.w,
                bottom: 120.h,
                child: _ExpandedPlayerPanel(
                  state: state,
                  onClose: _toggleExpanded,
                  navigatorKey: widget.navigatorKey,
                ),
              ),
            ] else ...[
              // Tab
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                right: 0,
                bottom: 150.h,
                child: GestureDetector(
                  onTap: _toggleExpanded,
                  child: _buildEdgeTab(state),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEdgeTab(AudioQuranState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 8.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.95),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          bottomLeft: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_note_rounded, color: Colors.white, size: 22.sp),
          if (state.isPlaying)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: SizedBox(
                width: 12.w,
                height: 12.w,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpandedPlayerPanel extends StatelessWidget {
  final AudioQuranState state;
  final VoidCallback onClose;
  final GlobalKey<NavigatorState>? navigatorKey;

  const _ExpandedPlayerPanel({
    Key? key,
    required this.state,
    required this.onClose,
    this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AudioQuranCubit>();
    final surahName = quran.getSurahNameArabic(state.currentSurahNumber);
    final bool isDownloading = state.downloadingSurahId != null;

    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: 280.w,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "سورة $surahName",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                fontFamily: 'Amiri',
                              ),
                            ),
                            Text(
                              "الآية ${state.currentAyahNumber}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(
                          Icons.keyboard_arrow_right_rounded,
                          size: 28,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24.h),

                  // Controls
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: cubit.previousAyah,
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            size: 28,
                          ),
                        ),
                        // Play/Pause
                        GestureDetector(
                          onTap: cubit.togglePlay,
                          child: Container(
                            width: 50.w,
                            height: 50.w,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: state.status == AudioPlaybackStatus.loading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    state.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 30.sp,
                                  ),
                          ),
                        ),
                        IconButton(
                          onPressed: cubit.nextAyah,
                          icon: const Icon(Icons.skip_next_rounded, size: 28),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Volume
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        Icon(
                          Icons.volume_down_rounded,
                          size: 18.sp,
                          color: Colors.grey,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: RoundSliderOverlayShape(
                                overlayRadius: 12,
                              ),
                              activeTrackColor: AppColors.primaryColor,
                              inactiveTrackColor: Colors.grey[300],
                              thumbColor: AppColors.primaryColor,
                            ),
                            child: Slider(
                              value: state.volume,
                              onChanged: (val) => cubit.setVolume(val),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.volume_up_rounded,
                          size: 18.sp,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  if (isDownloading) ...[
                    SizedBox(height: 8.h),
                    LinearProgressIndicator(
                      value: state.downloadProgress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    SizedBox(height: 4.h),
                    Center(
                      child: Text(
                        "جاري التحميل...",
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                    ),
                  ],

                  SizedBox(height: 8.h),

                  // Navigation Link
                  TextButton(
                    onPressed: () {
                      onClose();
                      if (navigatorKey?.currentState != null) {
                        navigatorKey!.currentState!.push(
                          MaterialPageRoute(
                            builder: (_) => const AudioQuranPage(),
                          ),
                        );
                      } else {
                        // Fallback attempt
                        try {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const AudioQuranPage(),
                            ),
                          );
                        } catch (e) {
                          debugPrint("Nav Error: $e");
                        }
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "فتح المشغل الكامل",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.open_in_new_rounded, size: 14.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
