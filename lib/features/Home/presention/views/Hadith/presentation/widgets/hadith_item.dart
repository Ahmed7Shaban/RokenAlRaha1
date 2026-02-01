import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:roken_al_raha/core/widgets/shared_branding_widget.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_content.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../../../../../../core/theme/app_colors.dart';

class HadithItem extends StatefulWidget {
  final HadithContent hadith;
  final int index;
  final int? totalHadiths;
  final String? highlightQuery;
  final bool isFavorite;
  final bool isRead;
  final String? note;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onAddNote;

  const HadithItem({
    Key? key,
    required this.hadith,
    required this.index,
    this.totalHadiths,
    this.highlightQuery,
    this.isFavorite = false,
    this.isRead = false,
    this.note,
    this.onToggleFavorite,
    this.onAddNote,
  }) : super(key: key);

  @override
  State<HadithItem> createState() => _HadithItemState();
}

class _HadithItemState extends State<HadithItem> {
  bool _isNoteExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: widget.isRead
            ? BorderSide(color: AppColors.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: widget.isRead
              ? AppColors.primaryColor.withOpacity(0.03) // Very subtle tint
              : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  child: Text(
                    "${widget.hadith.number ?? widget.index + 1}",
                    style: GoogleFonts.cairo(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                if (widget.totalHadiths != null)
                  Text(
                    "/ ${widget.totalHadiths}",
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const Spacer(),
                // Header Actions
                Row(
                  children: [
                    // Favorite
                    if (widget.onToggleFavorite != null)
                      InkWell(
                        onTap: widget.onToggleFavorite,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.all(6.w),
                          child: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.isFavorite
                                ? Colors.red
                                : Colors.grey[400],
                            size: 24.sp,
                          ),
                        ),
                      ),
                    SizedBox(width: 4.w),
                    // Add Note
                    if (widget.onAddNote != null)
                      InkWell(
                        onTap: widget.onAddNote,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.all(6.w),
                          child: Icon(
                            widget.note != null
                                ? Icons.edit_note
                                : Icons.note_add_outlined,
                            color: AppColors.primaryColor,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    SizedBox(width: 4.w),
                    // Share
                    InkWell(
                      onTap: () => _shareAsImage(context),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.all(6.w),
                        child: Icon(
                          Icons.share_outlined,
                          color: AppColors.primaryColor,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildHadithText(context),
            if (widget.hadith.description != null &&
                widget.hadith.description!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                widget.hadith.description!,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: widget.note != null
                  ? Container(
                      key: const ValueKey("note_section"),
                      width: double.infinity, // Ensure full width
                      child: _buildNoteSection(context),
                    )
                  : const SizedBox.shrink(key: ValueKey("empty_note")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        InkWell(
          onTap: () {
            setState(() {
              _isNoteExpanded = !_isNoteExpanded;
            });
          },
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.note,
                      size: 16.sp,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "ملاحظة",
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _isNoteExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16.sp,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: Container(),
                  secondChild: Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      widget.note!,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  crossFadeState: _isNoteExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHadithText(BuildContext context) {
    if (widget.highlightQuery == null || widget.highlightQuery!.isEmpty) {
      return Text(
        widget.hadith.hadith,
        style: GoogleFonts.amiri(
          fontSize: 18.sp,
          height: 1.8,
          color: widget.isRead ? Colors.black54 : Colors.black87,
        ),
        textAlign: TextAlign.justify,
      );
    }
    // Highlighting Logic
    final text = widget.hadith.hadith;
    final query = widget.highlightQuery!;
    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            backgroundColor: AppColors.primaryColor.withOpacity(0.4),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = index + query.length;
    }

    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: GoogleFonts.amiri(
          fontSize: 18.sp,
          height: 1.8,
          color: widget.isRead ? Colors.black54 : Colors.black87,
        ),
        children: spans,
      ),
    );
  }

  void _shareAsImage(BuildContext context) async {
    final screenshotController = ScreenshotController();
    final text = widget.hadith.hadith;
    final int maxChars = 800;

    try {
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      List<String> imagePaths = [];

      // Split text if too long
      List<String> chunks = [];
      if (text.length > maxChars) {
        int start = 0;
        while (start < text.length) {
          int end = start + maxChars;
          if (end >= text.length) {
            chunks.add(text.substring(start));
            break;
          }
          // Find last space
          int lastSpace = text.lastIndexOf(' ', end);
          if (lastSpace > start) {
            chunks.add(text.substring(start, lastSpace));
            start = lastSpace + 1;
          } else {
            // Force split
            chunks.add(text.substring(start, end));
            start = end;
          }
        }
      } else {
        chunks.add(text);
      }

      for (int i = 0; i < chunks.length; i++) {
        final chunk = chunks[i];
        final imageBytes = await screenshotController.captureFromWidget(
          Container(
            width: 375.w,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFF9F9F9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i == 0) ...[
                  Text(
                    "حديث نبوي",
                    style: GoogleFonts.amiri(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 2,
                    color: const Color(0xFFD4AF37),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  chunk,
                  style: GoogleFonts.amiri(
                    fontSize: 20,
                    height: 1.8,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 30),
                if (i == chunks.length - 1) const SharedBrandingWidget(),
                if (i < chunks.length - 1)
                  Text(
                    "  يتبع... من تطببق ركن الراحة",
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                  ),

                const SizedBox(height: 10),
              ],
            ),
          ),
          delay: const Duration(milliseconds: 10),
          pixelRatio: pixelRatio,
        );

        final directory = await getTemporaryDirectory();
        final imagePath = await File(
          '${directory.path}/hadith_${widget.hadith.number ?? widget.index}_part_$i.png',
        ).create();
        await imagePath.writeAsBytes(imageBytes);
        imagePaths.add(imagePath.path);
      }

      await Share.shareXFiles(
        imagePaths.map((path) => XFile(path)).toList(),
        text: "حديث نبوي من تطبيق ركن الراحة",
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ أثناء المشاركة", style: GoogleFonts.cairo()),
          ),
        );
      }
    }
  }
}
