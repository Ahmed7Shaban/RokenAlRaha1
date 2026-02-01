import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:quran/quran.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class PageOptionsWidget extends StatelessWidget {
  final int pageNumber;
  final Function(BuildContext)? onShare;

  const PageOptionsWidget({super.key, required this.pageNumber, this.onShare});

  @override
  Widget build(BuildContext context) {
    if (pageNumber <= 0 || pageNumber > 604) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.menu_book_rounded, color: Colors.white),
      onPressed: () => _showOptionsBottomSheet(context),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    final pageData = getPageData(pageNumber);

    final firstSurah = pageData.first['surah'];
    final firstAyah = pageData.first['start'];

    Set<int> surahNumbers = pageData.map<int>((e) => e['surah'] as int).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 🔹 Header
              Column(
                children: [
                  Text(
                    "صفحة $pageNumber",
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _infoChip(
                        context,
                        "الجزء ${getJuzNumber(firstSurah, firstAyah)}",
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),

              /// 🔹 Surah Info
              ...surahNumbers.map((surahNum) {
                final surahName = getSurahNameArabic(surahNum);
                final revelation = getPlaceOfRevelation(surahNum) == 'Makkah'
                    ? 'مكية'
                    : 'مدنية';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(.1),
                      child: Text(
                        surahNum.toString(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      surahName,
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      revelation,
                      style: GoogleFonts.cairo(fontSize: 13),
                    ),
                  ),
                );
              }),

              const Divider(),
              const SizedBox(height: 12),

              /// 🔹 Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        if (onShare != null) {
                          onShare!(context);
                        } else {
                          _sharePageText(pageNumber);
                        }
                      },
                      icon: const Icon(Icons.share),
                      label: const Text("مشاركة"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.pureWhite,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _copyPageText(context, pageNumber);
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text("نسخ"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.pureWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoChip(BuildContext context, String text) {
    return Chip(
      label: Text(text, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void _sharePageText(int page) {
    Share.share(_getPageText(page), subject: "صفحة $page من القرآن");
  }

  void _copyPageText(BuildContext context, int page) {
    Clipboard.setData(ClipboardData(text: _getPageText(page)));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("تم نسخ الصفحة")));
  }

  String _getPageText(int page) {
    final data = getPageData(page);
    final buffer = StringBuffer("صفحة $page\n");

    for (var item in data) {
      final surah = item['surah'];
      final start = item['start'];
      final end = item['end'];

      buffer.writeln("\nسورة ${getSurahNameArabic(surah)}");
      for (int i = start; i <= end; i++) {
        buffer.write("${getVerse(surah, i)} ");
      }
    }

    return buffer.toString();
  }
}
