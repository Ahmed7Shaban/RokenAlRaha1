import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/presentation/widgets/saved_ayahs_bottom_sheet.dart';
import 'saved_ayahs_banner.dart';

import '../../../../../../../core/widgets/appbar_widget.dart';
import '../../cubit/quran_cubit.dart';
import 'quran_segment_body.dart';
import 'quran_segmented_button.dart';
import 'surah_content_view.dart';
import 'surah_loading_view.dart';

class SurahView extends StatelessWidget {
  const SurahView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuranCubit(),
      child: Builder(
        builder: (context) {
          return Column(
            children: [
              const AppbarWidget(title: 'القرآن الكريم', showActions: false),

              // 🔖 Saved Ayahs Banner
              SavedAyahsBanner(
                onTap: () {
                  final cubit = context.read<QuranCubit>();
                  if (cubit.suraJsonData != null) {
                    SavedAyahsBottomSheet.show(
                      context,
                      jsonData: cubit.suraJsonData,
                    );
                  }
                },
              ),

              // 🔘 Segmented Button
              BlocBuilder<QuranCubit, QuranState>(
                buildWhen: (previous, current) =>
                    previous.segment != current.segment,
                builder: (context, state) {
                  return QuranSegmentedButton(
                    current: state.segment,
                    onChanged: (value) {
                      context.read<QuranCubit>().changeSegment(value);
                    },
                  );
                },
              ),

              // 📖 Segment Body
              Expanded(
                child: BlocBuilder<QuranCubit, QuranState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const SurahLoadingView();
                    }

                    return QuranSegmentBody(
                      segment: state.segment,
                      suraJsonData: state.filteredData,
                      surahContentView: SurahContentView(
                        searchQuery: state.searchQuery,
                        suraJsonData: state.filteredData,
                        filteredData: state.filteredData,
                        pageNumbers: state.pageNumbers,
                        ayatFiltered: state.ayatFiltered,
                        activeMode: state.searchMode,
                        onSearch: (query) {
                          context.read<QuranCubit>().search(query);
                        },
                        onClear: () {
                          context.read<QuranCubit>().clearSearch();
                        },
                        onModeChange: (mode) {
                          context.read<QuranCubit>().changeSearchMode(mode);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
