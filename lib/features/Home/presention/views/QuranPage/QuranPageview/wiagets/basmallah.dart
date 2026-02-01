import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/data/models/reading_theme_model.dart';

class Basmallah extends StatelessWidget {
  final int index;
  const Basmallah({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
      builder: (context, state) {
        ReadingTheme currentTheme = ReadingTheme.defaultTheme;
        if (state is ReadingSettingsLoaded) {
          currentTheme = state.theme;
        }

        return SizedBox(
          width: screenSize.width,
          child: Padding(
            padding: EdgeInsets.only(
              left: (screenSize.width * .2),
              right: (screenSize.width * .2),
              top: 8,
              bottom: 2,
            ),
            child: Image.asset(
              "assets/Images/Basmala.png",
              color: currentTheme.textColor,
              width: MediaQuery.of(context).size.width * .4,
            ),
          ),
        );
      },
    );
  }
}
