import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../quran_view_page.dart';
import 'surah_list_view.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/logic/cubit/ayah_bookmark_cubit.dart';

class SurahListSection extends StatelessWidget {
  const SurahListSection({
    super.key,
    required this.filteredData,
    required this.jsonData,
  });

  final dynamic filteredData;
  final dynamic jsonData;

  @override
  Widget build(BuildContext context) {
    return SurahListView(
      filteredData: filteredData,
      jsonData: jsonData,
      onTap: (context, index, surah) {
        // Capture cubits
        final readingSettingsCubit = context.read<ReadingSettingsCubit>();
        final ayahBookmarkCubit = context.read<AyahBookmarkCubit>();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: readingSettingsCubit),
                BlocProvider.value(value: ayahBookmarkCubit),
              ],
              child: ScreenUtilInit(
                designSize: const Size(392.7, 800.7),
                child: QuranViewPage(
                  shouldHighlightText: false,
                  highlightVerse: "",
                  jsonData: jsonData,
                  pageNumber: getPageNumber(surah['number'], 1),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
