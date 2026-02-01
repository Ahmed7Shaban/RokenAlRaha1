import 'package:flutter/material.dart';
import 'package:quran/quran.dart';

import 'surah_card.dart';

class SurahListView extends StatelessWidget {
  final List filteredData;
  final dynamic jsonData;
  final Function(BuildContext context, int index, dynamic surah) onTap;

  final String? searchQuery;

  const SurahListView({
    super.key,
    required this.filteredData,
    required this.jsonData,
    required this.onTap,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredData.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final surah = filteredData[index];

        // Ensure we use the actual number from JSON, not the list index
        final int surahNumber = surah["number"];
        final String arabicName = getSurahNameArabic(surahNumber);
        final int ayahCount = getVerseCount(surahNumber);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SurahCard(
              onTap: () => onTap(context, index, surah),
              surahName: "سورة $arabicName",
              ayahNumber: ayahCount,
              surahNumber: surahNumber,
              searchQuery: searchQuery,
            ),
            if (index < filteredData.length - 1)
              Divider(color: Colors.grey.withOpacity(.5), height: 1),
          ],
        );
      }, childCount: filteredData.length),
    );
  }
}
