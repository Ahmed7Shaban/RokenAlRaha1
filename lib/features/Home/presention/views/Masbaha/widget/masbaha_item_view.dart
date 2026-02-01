import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../../../../../../storage/masbaha_storage_service.dart';
import '../cubit/masbaha_cubit.dart';
import '../../../../../../core/widgets/count_action.dart';
import '../../../../../../core/widgets/count_text.dart';
import 'card_item.dart';
import 'masbaha_vertical_string.dart';
import 'timer_box.dart';

class MasbahaItemView extends StatefulWidget {
  const MasbahaItemView({super.key, required this.title});
  final String title;

  @override
  State<MasbahaItemView> createState() => _MasbahaItemViewState();
}

class _MasbahaItemViewState extends State<MasbahaItemView>
    with WidgetsBindingObserver {
  bool showSpecial = false;
  bool showPlusOne = false;
  CountAction? currentAction;

  MasbahaCubit? _masbahaCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Store the cubit reference while context is valid
    _masbahaCubit = context.read<MasbahaCubit>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveData();
    }
  }

  @override
  void dispose() {
    _saveData();
    WidgetsBinding.instance.removeObserver(this);
    // AdService.showInterstitialAd();
    super.dispose();
  }

  Future<void> _saveData() async {
    // Use stored reference instead of context.read()
    final state = _masbahaCubit?.state;

    if (state is MisbahaUpdated && state.count > 0) {
      await MasbahaStorageService().saveMasbaha(
        title: widget.title,
        count: state.count,
        duration: Duration(seconds: state.seconds),
      );
    }
  }

  void handleMilestoneAnimation() {
    setState(() => showSpecial = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => showSpecial = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MasbahaCubit>().state;
    final currentCount = state is MisbahaUpdated ? state.count : 0;
    final currentSeconds = state is MisbahaUpdated ? state.seconds : 0;
    final currentScore = state is MisbahaUpdated ? state.score : 0;

    return Scaffold(
      body: BlocListener<MasbahaCubit, MasbahaState>(
        listenWhen: (previous, current) {
          if (current is MisbahaUpdated) {
            return current.count > 0 && current.count % 33 == 0;
          }
          return false;
        },
        listener: (context, state) => handleMilestoneAnimation(),
        child: Stack(
          children: [
            // Layer 1: Right-side Beads Animation
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              width:
                  70, // Explicit width to ensure Stack constraints are bounded
              child: MasbahaVerticalString(count: currentCount),
            ),

            // Layer 2: Main UI Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                  left: 20,
                  right: 80,
                ), // Right padding for beads
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CardItem(title: widget.title)
                        .animate()
                        .fade(duration: 400.ms)
                        .slideY(begin: -0.3, duration: 400.ms),

                    TimerBox(
                      seconds: currentSeconds,
                    ).animate().fade(duration: 500.ms).slideY(begin: 0.3),

                    // Score Badge
                    if (currentScore > 0)
                      Container(
                            width: 150,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'دورات: $currentScore',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(target: currentScore > 0 ? 1 : 0)
                          .scale(duration: 300.ms, curve: Curves.elasticOut),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CountText(count: '$currentCount', action: currentAction)
                            .animate()
                            .fade(duration: 500.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                        if (showPlusOne)
                          Text(
                                '+1',
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                              .animate()
                              .moveY(
                                begin: 0,
                                end: -60,
                                duration: 500.ms,
                              ) // Increased travel for floating effect
                              .fadeOut(duration: 500.ms),
                      ],
                    ),

                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.read<MasbahaCubit>().increment();
                        setState(() {
                          currentAction = CountAction.increase;
                          showPlusOne = true;
                        });
                        Future.delayed(500.ms, () {
                          if (mounted) {
                            setState(() => showPlusOne = false);
                          }
                        });
                      },
                      child:
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.touch_app,
                              color: Colors.white,
                              size: 35,
                            ),
                          ).animate().scale(
                            duration: 100.ms,
                            curve: Curves.easeInOut,
                          ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            if (showSpecial)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                              Icons.verified,
                              color: Color(0xFFFFD700),
                              size: 100,
                            )
                            .animate()
                            .scale(duration: 500.ms, curve: Curves.elasticOut)
                            .then()
                            .shimmer(duration: 1000.ms),
                        const SizedBox(height: 20),
                        Text(
                              "تقبل الله",
                              style: GoogleFonts.arefRuqaa(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  const BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 10,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.5, end: 0),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),
          ],
        ),
      ),
    );
  }
}
