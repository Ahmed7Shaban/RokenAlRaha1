import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../../logic/cubit/hizb_state.dart';
import 'hizb_sub_card.dart';

class HizbCard extends StatefulWidget {
  final HizbUiModel model;
  final Function(int page, int surahNum, int ayahNum) onNavigate;

  const HizbCard({super.key, required this.model, required this.onNavigate});

  @override
  State<HizbCard> createState() => _HizbCardState();
}

class _HizbCardState extends State<HizbCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.model.data;
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
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Badge
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
                          "${data.number}",
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.model.isCurrent
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Titles
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "الحزب ${data.number}",
                              style: GoogleFonts.cairo(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${data.startSurahName} (${data.startAyahNumber}) - ${data.endSurahName} (${data.endAyahNumber})",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status Icon
                      if (widget.model.isCompleted)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24.sp,
                        )
                      else if (widget.model.isCurrent)
                        SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            value: widget.model.progress,
                            strokeWidth: 3,
                            backgroundColor: primary.withOpacity(0.1),
                            color: primary,
                          ),
                        )
                      else
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Sub-Cards List (Collapsible)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
              child: Column(
                children: [
                  // Sub-cards (Q1..Q4)
                  ...widget.model.quarters.map(
                    (q) => HizbSubCard(
                      model: q,
                      onTap: () => widget.onNavigate(
                        q.targetPage,
                        q.targetSurah,
                        q.targetAyah,
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
}
