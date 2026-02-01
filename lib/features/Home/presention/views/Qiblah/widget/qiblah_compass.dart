import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/widgets/lottie_loader.dart';

import '../../../../../../source/app_images.dart';
import '../helper/qiblah_direction_helper.dart';
// import '../../../../../../core/widgets/location_text_widget.dart';

class QiblahCompass extends StatelessWidget {
  const QiblahCompass({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LottieLoader();
        }

        if (snapshot.hasError) {
          return Center(child: Text("خطأ: ${snapshot.error}"));
        }

        final qiblahDirection = snapshot.data!;
        final double angle = qiblahDirection.qiblah;
        final String direction = getDirectionFromDegree(angle);
        final String arabicAngle = convertToArabicNumbers(
          angle.toStringAsFixed(2),
        );

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: 500,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SvgPicture.asset("assets/Images/compass.svg"),
                      ),
                      Center(
                        child: Transform.rotate(
                          angle: angle * (3.1416 / 180) * -1,
                          child: Image.asset(Assets.compass, width: 200),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "اتجاه القبلة: $arabicAngle° ($direction)",
                        style: GoogleFonts.cairo(
                          textStyle: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
