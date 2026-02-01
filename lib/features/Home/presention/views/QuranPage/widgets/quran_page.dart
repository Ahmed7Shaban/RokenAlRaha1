import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'quran_header.dart';
import 'quran_rich_text.dart';

import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/data/models/reading_theme_model.dart';

class QuranPage extends StatelessWidget {
  final int pageIndex;
  final dynamic jsonData;
  final String selectedSpan;
  final Function(String) onSelectedSpanChange;
  final Widget? bottomWidget;

  const QuranPage({
    Key? key,
    required this.pageIndex,
    required this.jsonData,
    required this.selectedSpan,
    required this.onSelectedSpanChange,
    this.bottomWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (pageIndex == 0) {
      return Center(
        child: SizedBox(
          width: screenSize.width * 0.6,
          height: screenSize.width * 0.6,
          child: SvgPicture.asset(
            "assets/Images/Quran.svg",
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
      builder: (context, state) {
        ReadingTheme currentTheme = ReadingTheme.defaultTheme;
        if (state is ReadingSettingsLoaded) {
          currentTheme = state.theme;
        }

        return Container(
          decoration: BoxDecoration(color: currentTheme.backgroundColor),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      QuranHeader(pageIndex: pageIndex, jsonData: jsonData),
                      if (pageIndex == 1 || pageIndex == 2)
                        const SizedBox(height: 30),
                      QuranRichText(
                        pageIndex: pageIndex,
                        jsonData: jsonData,
                        selectedSpan: selectedSpan,
                        onSelectedSpanChange: onSelectedSpanChange,
                      ),
                      if (bottomWidget != null) bottomWidget!,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
