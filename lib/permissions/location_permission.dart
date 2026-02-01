import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/theme/app_colors.dart';
import '../source/app_lottie.dart';


Future<void> requestLocationPermission(BuildContext context) async {

  var status = await Permission.location.status;

  if (!status.isGranted) {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        title: Lottie.asset(
          AppLottie.Location,
          width: 80,
          height: 80,
          repeat: true,
        ),
        content: Text(
          "يحتاج تطبيق ركن الراحة للوصول إلى موقعك لتحديد اتجاه القبلة بدقة وعرض أوقات الصلاة الصحيحة.\n"
              "نحن لا نخزن أو نشارك موقعك مع أي طرف ثالث.",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 20,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              var result = await Permission.location.request();
              if (result.isGranted) {
                print('✅ تم منح إذن الموقع');
              } else {
                print('❌ تم رفض إذن الموقع');
              }
            },

            child: Text(
              "تفعيل الموقع",
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.pureWhite,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "إغلاق",
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  } else {
    print('✅ إذن الموقع موجود مسبقًا');
  }
}
