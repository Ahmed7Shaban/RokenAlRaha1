import 'package:flutter/material.dart';
import '../../tafsir/presentation/widgets/ayah_tafsir_sheet.dart'
    as new_feature;

enum TafsirType { muyassar, sahih }

class AyahTafsirSheet extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;
  final TafsirType initialType;

  const AyahTafsirSheet({
    Key? key,
    required this.surahNumber,
    required this.verseNumber,
    this.initialType = TafsirType.muyassar,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required int surahNumber,
    required int verseNumber,
    TafsirType initialType = TafsirType.muyassar,
  }) {
    // Map existing enum to new ID system (ignored for now in new implementation)
    // Muyassar = 1
    // Sahih = 900 (Check TafsirLocalSourceImpl.kSahihId)
    // final int tafsirId = initialType == TafsirType.sahih ? 900 : 1;

    return new_feature.AyahTafsirSheet.show(
      context,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    // final int tafsirId = initialType == TafsirType.sahih ? 900 : 1;

    return new_feature.AyahTafsirSheet(
      surahNumber: surahNumber,
      verseNumber: verseNumber,
    );
  }
}
