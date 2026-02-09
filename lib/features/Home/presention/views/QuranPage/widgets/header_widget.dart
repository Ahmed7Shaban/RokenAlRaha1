import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/data/models/reading_theme_model.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart';

class HeaderWidget extends StatelessWidget {
  final dynamic e;
  final dynamic jsonData;

  const HeaderWidget({super.key, required this.e, required this.jsonData});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
      builder: (context, state) {
        // Safe access to theme color
        ReadingTheme currentTheme = ReadingTheme.defaultTheme;
        if (state is ReadingSettingsLoaded) {
          currentTheme = state.theme;
        }
        final Color textColor = currentTheme.textColor;

        return SizedBox(
          height: 50, // زيادة ارتفاع الهيدر شويه
          child: Stack(
            children: [
              Center(
                child: Image.asset(
                  "assets/Images/888-02.png",
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.7,
                  vertical: 7,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // عدد الآيات
                    Text(
                      "${getVerseCount(e["surah"])}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10, // زيادة حجم الخط
                        fontWeight: FontWeight.bold, // جعله واضح
                        fontFamily: "UthmanicHafs13",
                        color: textColor, // Applied Dynamic Color
                      ),
                    ),
                    // اسم السورة
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: e["surah"].toString(),
                          style: TextStyle(
                            fontFamily: "arsura",
                            fontSize: 27,
                            color: textColor, // Applied Dynamic Color
                          ),
                        ),
                      ),
                    ),
                    // ترتيب السورة
                    Text(
                      "${e["surah"]}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14, // زيادة حجم الخط
                        fontWeight: FontWeight.bold,
                        fontFamily: "UthmanicHafs13",
                        color: textColor, // Applied Dynamic Color
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
