import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';

import '../../logic/cubit/ayah_bookmark_cubit.dart';
import '../../logic/cubit/ayah_bookmark_state.dart';
import 'ayah_color_picker.dart';

class AyahActionSheet extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;
  final String verseText;

  // Callbacks
  final VoidCallback onTafsir;
  //  final VoidCallback onTranslation;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onListen;
  //  final VoidCallback onAsbabAlNuzul;
  final VoidCallback onWordMeanings;
  //  final VoidCallback onAyahTopic;
  //  final VoidCallback onDictionary;
  //  final VoidCallback onItalianTranslation;
  final VoidCallback onE3rab;

  // Optional: Allow parent to handle save legacy if needed, but we prefer Cubit
  final VoidCallback? onSaveLegacy;
  final VoidCallback? onSaveLastRead;

  const AyahActionSheet({
    Key? key,
    required this.surahNumber,
    required this.verseNumber,
    required this.verseText,
    required this.onTafsir,
    // required this.onTranslation,
    required this.onCopy,
    required this.onShare,
    required this.onListen,
    // required this.onAsbabAlNuzul,
    required this.onWordMeanings,
    // required this.onAyahTopic,
    // required this.onDictionary,
    // required this.onItalianTranslation,
    required this.onE3rab,
    this.onSaveLegacy,
    this.onSaveLastRead,
    required VoidCallback onSave,
  }) : super(key: key);

  @override
  State<AyahActionSheet> createState() => _AyahActionSheetState();
}

class _AyahActionSheetState extends State<AyahActionSheet> {
  bool _showColorPicker = false;

  void _toggleColorPicker() {
    setState(() {
      _showColorPicker = !_showColorPicker;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final Color primaryColor = const Color(0xFF1B4332);
    final Color accentColor = const Color(0xFFD4AF37);
    final Color bgColor = const Color(0xFFF8F9FA);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "خيارات الآية",
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                _buildVerseBadge(
                  widget.surahNumber,
                  widget.verseNumber,
                  primaryColor,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Verse Preview
          Flexible(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: 0.35.sh,
                minHeight: 0.1.sh,
              ),
              color: Colors.white,
              child: Scrollbar(
                thumbVisibility: true,
                radius: const Radius.circular(4),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    widget.verseText,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: "QCF_P002",
                      fontSize: 22.sp,
                      height: 1.8,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Color Picker Panel (Animated visibility)
          if (_showColorPicker)
            BlocBuilder<AyahBookmarkCubit, AyahBookmarkState>(
              builder: (context, state) {
                int? currentColor;
                if (state is AyahBookmarkLoaded) {
                  final color = state.getColor(
                    widget.surahNumber,
                    widget.verseNumber,
                  );
                  if (color != null) currentColor = color.value;
                }

                return AyahColorPicker(
                  selectedColorValue: currentColor,
                  onColorSelected: (colorVal) {
                    // Update Cubit
                    context.read<AyahBookmarkCubit>().toggleBookmark(
                      widget.surahNumber,
                      widget.verseNumber,
                      colorVal,
                    );
                    // Close picker after selection? Or keep open?
                    // Usually better to keep open or close. Let's close to be clean.
                    setState(() => _showColorPicker = false);
                  },
                );
              },
            ),

          // Actions
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildButton(
                    context,
                    "تفسير",
                    Icons.menu_book_rounded,
                    primaryColor,
                    widget.onTafsir,
                  ),
                  // SizedBox(width: 16.w),
                  // _buildButton(
                  //   context,
                  //   "ترجمة",
                  //   Icons.translate_rounded,
                  //   Colors.blueGrey,
                  //   widget.onTranslation,
                  // ),
                  SizedBox(width: 16.w),

                  // Bookmark Button with State
                  BlocBuilder<AyahBookmarkCubit, AyahBookmarkState>(
                    builder: (context, state) {
                      bool isBookmarked = false;
                      Color btnColor = accentColor;

                      if (state is AyahBookmarkLoaded) {
                        isBookmarked = state.isBookmarked(
                          widget.surahNumber,
                          widget.verseNumber,
                        );
                        if (isBookmarked) {
                          // Use the bookmark color or just accent?
                          // User said 'show bookmark button as active'.
                          btnColor =
                              state.getColor(
                                widget.surahNumber,
                                widget.verseNumber,
                              ) ??
                              accentColor;
                        }
                      }

                      return _buildButton(
                        context,
                        isBookmarked ? "محفوظ" : "حفظ",
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        btnColor,
                        _toggleColorPicker, // Toggles local state
                        isActive: isBookmarked || _showColorPicker,
                      );
                    },
                  ),
                  SizedBox(width: 16.w),
                  _buildButton(
                    context,
                    "آخر قراءة",
                    Icons.history_edu_rounded,
                    const Color(0xFF009688), // Teal
                    widget.onSaveLastRead != null
                        ? widget.onSaveLastRead!
                        : () {},
                  ),

                  SizedBox(width: 16.w),
                  _buildButton(
                    context,
                    "مشاركة",
                    Icons.share_rounded,
                    const Color(0xFF264653),
                    widget.onShare,
                  ),
                  SizedBox(width: 16.w),
                  _buildButton(
                    context,
                    "استماع",
                    Icons.play_circle_filled_rounded,
                    const Color(0xFF2A9D8F),
                    widget.onListen,
                  ),
                  SizedBox(width: 16.w),

                  // SizedBox(width: 16.w),
                  // _buildButton(
                  //   context,
                  //   "أسباب النزول",
                  //   Icons.history_edu_rounded,
                  //   const Color(0xFF457B9D),
                  //   widget.onAsbabAlNuzul,
                  // ),
                  // ... Add other buttons similarly ...
                  _buildButton(
                    context,
                    "إعراب",
                    Icons.segment_rounded,
                    AppColors.primaryColor, // Brown
                    widget.onE3rab,
                  ),
                  SizedBox(width: 16.w),
                  _buildButton(
                    context,
                    "معاني",
                    Icons.menu_book_rounded,
                    const Color(0xFF5D4037), // Darker Brown
                    widget.onWordMeanings,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildVerseBadge(int surah, int verse, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        "$verse :$surah",
        style: GoogleFonts.cairo(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 70.w,
        child: Column(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: isActive ? color : color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: isActive
                    ? null
                    : Border.all(color: color.withOpacity(0.3)),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : color,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
