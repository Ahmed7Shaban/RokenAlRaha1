import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/source/app_lottie.dart';

class LocationPermissionErrorWidget extends StatelessWidget {
  final VoidCallback onRequestPermission;
  final VoidCallback onBack;

  const LocationPermissionErrorWidget({
    super.key,
    required this.onRequestPermission,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.goldenYellow.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              AppLottie.Location,
              width: 100,
              height: 100,
              repeat: true,
            ),
            const SizedBox(height: 20),
            Text(
              "يرجى تفعيل الموقع",
              style: GoogleFonts.cairo(
                fontSize: 22,
                color: AppColors.goldenYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "نحتاج إلى معرفة موقعك الحالي لنتمكن من تحديد اتجاه القبلة بدقة من أي مكان في العالم.",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldenYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: onRequestPermission,
              child: Text(
                "تفعيل الوصول",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: onBack,
              child: Text(
                "رجوع للقائمة",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
