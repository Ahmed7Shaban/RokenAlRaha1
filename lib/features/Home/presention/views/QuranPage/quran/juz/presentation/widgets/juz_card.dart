import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_view_page.dart';
import '../../logic/cubit/juz_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/data/models/last_read_model.dart';

class JuzCard extends StatefulWidget {
  final JuzUiModel model;
  final LastReadModel? lastRead; // Changed from lastReadPage

  const JuzCard({super.key, required this.model, required this.lastRead});

  @override
  State<JuzCard> createState() => _JuzCardState();
}

class _JuzCardState extends State<JuzCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _onTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _onContinuePressed(BuildContext context) {
    int targetPage = widget.model.data.startPage;
    int targetSurah = -1;
    int targetAyah = widget.model.data.startAyahNumber;

    // Check if Last Read is valid for this Juz
    bool isResume = false;
    if (widget.lastRead != null) {
      final lr = widget.lastRead!;
      if (lr.pageNumber >= widget.model.data.startPage &&
          lr.pageNumber <= widget.model.data.endPage) {
        targetPage = lr.pageNumber;
        targetSurah = lr.surahNumber;
        targetAyah = lr.ayahNumber;
        isResume = true;
      }
    }

    // If starting fresh, find the surah number for the start of the Juz
    if (!isResume) {
      try {
        // getSurahAndVersesFromJuz returns Map<int, List<int>> where key is Surah Number
        final juzMap = getSurahAndVersesFromJuz(widget.model.data.number);
        if (juzMap.isNotEmpty) {
          targetSurah = juzMap.keys.first;
        }
      } catch (e) {
        debugPrint("Error finding start surah for juz: $e");
      }
    }

    // Prepare highlight string " SurahNumVerseNum"
    String highlightString = "";
    if (targetSurah != -1) {
      highlightString = " $targetSurah$targetAyah";
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenUtilInit(
          designSize: const Size(392.7, 800.7),
          child: QuranViewPage(
            pageNumber: targetPage,
            jsonData: const [],
            shouldHighlightText: highlightString.isNotEmpty,
            highlightVerse: highlightString,
            showResumeOverlay: false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressFn = widget.model.progress;
    final primary = AppColors.primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _isExpanded
                ? primary.withOpacity(0.15)
                : Colors.black.withOpacity(0.04),
            blurRadius: _isExpanded ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: _isExpanded
            ? Border.all(color: primary.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Column(
        children: [
          // Header / Summary
          InkWell(
            onTap: _onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // Juz Number Badge
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: widget.model.isCurrent
                          ? primary
                          : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${widget.model.data.number}",
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: widget.model.isCurrent
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "الجزء ${widget.model.data.number}",
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "يبدأ من ${widget.model.data.startSurahName} - آية ${widget.model.data.startAyahNumber}",
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Circle or Arrow
                  if (widget.model.isCompleted)
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 28.sp,
                    )
                  else if (widget.model.isCurrent)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progressFn,
                          strokeWidth: 3,
                          backgroundColor: primary.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(primary),
                        ),
                        Text(
                          "${(progressFn * 100).toInt()}%",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ],
                    )
                  else
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ),

          // Expanded Details
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(color: Colors.grey[200]),
                  SizedBox(height: 12.h),

                  // Metadata
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMeta(
                        "بداية الجزء",
                        widget.model.data.startSurahName,
                        "${widget.model.data.startAyahNumber}",
                      ),
                      _buildMeta(
                        "نهاية الجزء",
                        widget.model.data.endSurahName,
                        "${widget.model.data.endAyahNumber}",
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Interaction Button
                  ElevatedButton(
                    onPressed: () => _onContinuePressed(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.model.isCurrent ? "تابع القراءة" : "ابدأ القراءة",
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildMeta(String label, String surah, String ayah) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 11.sp, color: Colors.grey[500]),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Text(
              surah,
              style: GoogleFonts.amiri(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              "($ayah)",
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
