import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AyahActionSheet extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;
  final String verseText;

  // Callbacks
  final VoidCallback onTafsir;
  final VoidCallback onTranslation;
  final VoidCallback onCopy;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onListen;
  final VoidCallback onAsbabAlNuzul;
  final VoidCallback onWordMeanings;
  final VoidCallback onAyahTopic;
  final VoidCallback onDictionary;
  final VoidCallback onItalianTranslation;

  const AyahActionSheet({
    Key? key,
    required this.surahNumber,
    required this.verseNumber,
    required this.verseText,
    required this.onTafsir,
    required this.onTranslation,
    required this.onCopy,
    required this.onSave,
    required this.onShare,
    required this.onListen,
    required this.onAsbabAlNuzul,
    required this.onWordMeanings,
    required this.onAyahTopic,
    required this.onDictionary,
    required this.onItalianTranslation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final Color primaryColor = const Color(0xFF1B4332); // Deep Green
    final Color accentColor = const Color(0xFFD4AF37); // Gold
    final Color bgColor = const Color(0xFFF8F9FA);

    // New Action Colors
    const Color cListen = Color(0xFF2A9D8F);
    const Color cAsbab = Color(0xFF457B9D);
    const Color cMeanings = Color(0xFFE76F51);
    const Color cTopic = Color(0xFFF4A261);
    const Color cDict = Color(0xFF1D3557);
    const Color cItalian = Color(0xFFCE4257);
    const Color cCopy = Color(0xFFE9C46A);
    const Color cShare = Color(0xFF264653);

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
          // 1. Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 2. Header
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
                _buildVerseBadge(surahNumber, verseNumber, primaryColor),
              ],
            ),
          ),

          const Divider(height: 1),

          // 3. Verse Preview
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
                    verseText,
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

          // 4. Horizontal Action List
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
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tafsir
                  _buildActionButton(
                    context,
                    label: "تفسير",
                    icon: Icons.menu_book_rounded,
                    color: primaryColor,
                    onTap: onTafsir,
                  ),
                  SizedBox(width: 16.w),

                  // 2. Translation
                  _buildActionButton(
                    context,
                    label: "ترجمة",
                    icon: Icons.translate_rounded,
                    color: Colors.blueGrey,
                    onTap: onTranslation,
                  ),
                  SizedBox(width: 16.w),

                  // 3. Copy
                  _buildActionButton(
                    context,
                    label: "نسخ",
                    icon: Icons.copy_rounded,
                    color: cCopy, // Orange-ish
                    onTap: onCopy,
                  ),
                  SizedBox(width: 16.w),

                  // 4. Save / Bookmark
                  _buildActionButton(
                    context,
                    label: "حفظ",
                    icon: Icons.bookmark_border_rounded,
                    color: accentColor,
                    onTap: onSave,
                  ),
                  SizedBox(width: 16.w),

                  // 5. Share
                  _buildActionButton(
                    context,
                    label: "مشاركة",
                    icon: Icons.share_rounded,
                    color: cShare,
                    onTap: onShare,
                  ),
                  SizedBox(width: 16.w),

                  // 6. Listen
                  _buildActionButton(
                    context,
                    label: "استماع",
                    icon: Icons.play_circle_filled_rounded,
                    color: cListen,
                    onTap: onListen,
                  ),
                  SizedBox(width: 16.w),

                  // 7. Asbab Al-Nuzul
                  _buildActionButton(
                    context,
                    label: "أسباب النزول",
                    icon: Icons.history_edu_rounded,
                    color: cAsbab,
                    onTap: onAsbabAlNuzul,
                  ),
                  SizedBox(width: 16.w),

                  // 8. Word Meanings
                  _buildActionButton(
                    context,
                    label: "معاني الكلمات",
                    icon: Icons.school_rounded,
                    color: cMeanings,
                    onTap: onWordMeanings,
                  ),
                  SizedBox(width: 16.w),

                  // 9. Ayah Topic
                  _buildActionButton(
                    context,
                    label: "موضوع الآية",
                    icon: Icons.lightbulb_rounded,
                    color: cTopic,
                    onTap: onAyahTopic,
                  ),
                  SizedBox(width: 16.w),

                  // 10. Dictionary
                  _buildActionButton(
                    context,
                    label: "المعجم",
                    icon: Icons.manage_search_rounded,
                    color: cDict,
                    onTap: onDictionary,
                  ),
                  SizedBox(width: 16.w),

                  // 11. Italian Translation
                  _buildActionButton(
                    context,
                    label: "إيطالي",
                    icon: Icons.language_rounded,
                    color: cItalian,
                    onTap: onItalianTranslation,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$verse :$surah",
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 70.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
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
