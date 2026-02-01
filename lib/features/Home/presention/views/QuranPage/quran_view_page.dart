import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/quran.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/widgets/quran_page.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/widgets/page_options_widget.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/sharing/quran_share_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/presentation/widgets/arrival_motivation_overlay.dart';

import 'package:roken_al_raha/features/Home/presention/views/QuranPage/widgets/ward_overlay.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class QuranViewPage extends StatefulWidget {
  final int pageNumber;
  final dynamic jsonData;
  final bool shouldHighlightText;
  final String highlightVerse;
  final bool showResumeOverlay;
  final int? resumeJuzNumber;
  final String? resumeSurahName;
  final int? resumeAyahNumber;
  final ValueChanged<int>? onPageChanged;

  // Khatma Mode Params
  final bool isWardMode;
  final int? wardStartPage;
  final int? wardEndPage;

  QuranViewPage({
    Key? key,
    required this.pageNumber,
    required this.jsonData,
    required this.shouldHighlightText,
    required this.highlightVerse,
    this.showResumeOverlay = false,
    this.resumeJuzNumber,
    this.resumeSurahName,
    this.resumeAyahNumber,
    this.onPageChanged,
    this.isWardMode = false,
    this.wardStartPage,
    this.wardEndPage,
  }) : super(key: key);

  @override
  State<QuranViewPage> createState() => _QuranViewPageState();
}

class _QuranViewPageState extends State<QuranViewPage> {
  late PageController _pageController;
  int index = 0;
  String selectedSpan = "";
  // Flag to prevent multiple dialogs
  bool _celebrationShown = false;

  @override
  void initState() {
    super.initState();
    index = widget.pageNumber;
    _pageController = PageController(initialPage: index);

    // Calm Highlight Animation Logic
    if (widget.shouldHighlightText && widget.highlightVerse.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            selectedSpan = widget.highlightVerse;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() => selectedSpan = "");
            }
          });
        }
      });
    }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();

    if (widget.showResumeOverlay) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          ArrivalMotivationOverlay.show(
            context,
            surahName: widget.resumeSurahName ?? "",
            ayahNumber: widget.resumeAyahNumber ?? 1,
            juzNumber: widget.resumeJuzNumber ?? 1,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.onPageChanged != null && index > 0) {
      widget.onPageChanged!(index);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _shareCurrentPage(BuildContext context) async {
    final currentIndex = index;
    final pageData = getPageData(currentIndex);
    await QuranShareService().sharePage(context, currentIndex, pageData);
  }

  void _checkWardCompletion(int newIndex) {
    if (!widget.isWardMode || widget.wardEndPage == null || _celebrationShown)
      return;

    if (newIndex >= widget.wardEndPage!) {
      // Completed!
      setState(() {
        _celebrationShown = true;
      });

      // Delay slightly to let user see the page first
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _showCompletionDialog();
        }
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E1E2C),
                const Color(0xFF1E1E2C).withOpacity(0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.goldenYellow, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldenYellow.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.goldenYellow,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                "ورد اليوم اكتمل",
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "تقبل الله منك صالح الاعمال",
                style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "إغلاق",
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _shareCurrentPage(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldenYellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.share, size: 18),
                      label: Text(
                        "مشاركة",
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. PageView
          BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
            builder: (context, state) {
              ReadingScrollMode scrollMode = ReadingScrollMode.vertical;
              if (state is ReadingSettingsLoaded) {
                scrollMode = state.scrollMode;
              }

              final isHorizontal = scrollMode == ReadingScrollMode.horizontal;

              return PageView.builder(
                reverse:
                    isHorizontal, // True for horizontal RTL, false for vertical TTB
                scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
                controller: _pageController,
                itemCount: totalPagesCount + 1,
                onPageChanged: (a) {
                  setState(() => selectedSpan = "");
                  index = a;
                  if (widget.onPageChanged != null) {
                    widget.onPageChanged!(a);
                  }
                  // Check completion logic
                  _checkWardCompletion(a);
                },
                itemBuilder: (context, pageIndex) {
                  return ScreenUtilInit(
                    designSize: const Size(392.7, 800.7),
                    child: QuranPage(
                      pageIndex: pageIndex,
                      jsonData: widget.jsonData,
                      selectedSpan: selectedSpan,
                      onSelectedSpanChange: (v) =>
                          setState(() => selectedSpan = v),
                    ),
                  );
                },
              );
            },
          ),

          // 2. Smart Ward Overlay (Top Header)
          if (widget.isWardMode &&
              widget.wardStartPage != null &&
              widget.wardEndPage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: WardOverlay(
                currentPage: index,
                startPage: widget.wardStartPage!,
                endPage: widget.wardEndPage!,
              ),
            ),

          // 3. Success Badge (Bottom Toast) - On Last Page Only
          if (widget.isWardMode &&
              widget.wardEndPage != null &&
              index == widget.wardEndPage! &&
              !_celebrationShown)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldenYellow.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified, color: Colors.black87),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "هذه هي الصفحة الأخيرة في وردك اليوم، استعن بالله!",
                        style: GoogleFonts.tajawal(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: PageOptionsWidget(
        pageNumber: index,
        onShare: (c) => _shareCurrentPage(context),
      ),
    );
  }
}
