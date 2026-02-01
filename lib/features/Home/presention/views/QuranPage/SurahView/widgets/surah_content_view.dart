import 'package:flutter/material.dart';
import 'ayat_filtered_list_view.dart';
import 'page_numbers_view.dart';
import 'search_text_field_view.dart';
import 'surah_list_section.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/cubit/quran_cubit.dart'; // For SearchMode
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/presentation/widgets/last_read_card.dart';

class SurahContentView extends StatelessWidget {
  const SurahContentView({
    super.key,
    required this.searchQuery,
    required this.suraJsonData,
    required this.filteredData,
    required this.pageNumbers,
    required this.ayatFiltered,
    required this.activeMode,
    required this.onSearch,
    required this.onClear,
    required this.onModeChange,
  });

  final String searchQuery;
  final dynamic suraJsonData;
  final dynamic filteredData;
  final List pageNumbers;
  final dynamic ayatFiltered;
  final SearchMode activeMode;
  final Function(String) onSearch;
  final VoidCallback onClear;
  final Function(SearchMode) onModeChange;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LastReadCard(surahJsonData: suraJsonData),

              SearchTextFieldView(
                initialQuery: searchQuery,
                onSearch: onSearch,
                onClear: onClear,
                activeMode: activeMode,
                onModeChange: onModeChange,
              ),

              if (pageNumbers.isNotEmpty)
                PageNumbersView(pageNumbers: pageNumbers),
            ],
          ),
        ),

        // 1. Surah List (Always Visible - Filtered or Full)
        SurahListSection(filteredData: filteredData, jsonData: suraJsonData),

        // 2. Ayat Result (Visible if matches exist)
        if (ayatFiltered != null)
          SliverToBoxAdapter(
            child: AyatFilteredListView(
              ayatFiltered: ayatFiltered,
              searchQuery: searchQuery,
              suraJsonData: suraJsonData,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
