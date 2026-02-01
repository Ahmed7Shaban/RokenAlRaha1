import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import '../QuranPage/SurahView/quran_page_view.dart';

class QuranBuView extends StatelessWidget {
  const QuranBuView({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (builder) => const QuranPageView()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
        child: Container(
          padding: EdgeInsets.all(40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primaryColor,
          ),
          child: Row(
            children: [
              Text(
                "القرآن الكريم",
                style: GoogleFonts.amiri(
                  textStyle: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 30),
              SvgPicture.asset(
                "assets/Images/Quran.svg",
                width: 60,
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
