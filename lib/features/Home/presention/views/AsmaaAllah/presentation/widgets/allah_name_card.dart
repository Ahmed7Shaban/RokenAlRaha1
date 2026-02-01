import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/core/widgets/branding_widget.dart';
import '../../../../../../../core/widgets/shared_branding_widget.dart';
import '../../data/models/allah_name_model.dart';
import 'package:roken_al_raha/source/app_images.dart';

class AllahNameCard extends StatelessWidget {
  final AllahNameModel nameModel;
  final int index;

  const AllahNameCard({
    super.key,
    required this.nameModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          // Background Pattern (Mosque Watermark)
          Positioned(
            bottom: -10,
            left: -3,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                Assets.imagesMosque,
                width: 120,
                color: AppColors.primaryColor,
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nameModel.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(
                Icons.share_rounded,
                size: 20,
                color: AppColors.primaryColor,
              ),
              onPressed: () => _shareName(context),
            ),
          ),
          Positioned(
            top: 8,
            right: 12,
            child: Text(
              "${index + 1}",
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.primaryColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareName(BuildContext context) async {
    final screenshotController = ScreenshotController();

    try {
      // Create the widget to capture
      // Note: We use a specific design for sharing as requested
      final widgetToCapture = Container(
        width: 1080,
        height: 1920, // Story/Phone Ratio
        color: AppColors.primaryColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Pattern (Optional subtle circle)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Main Card
            Container(
              width: 800,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_outline_rounded,
                    size: 50,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "من أسماء الله الحسنى",
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // The Name (Fitted)
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        nameModel.name,
                        style: GoogleFonts.amiri(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          fontSize: 200, // Reduced base size allowing scaleDown
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Branding inside the card (Clean look)
                  const BrandingWidget(dark: false),
                ],
              ),
            ),

            // Footer text
            Positioned(bottom: 20, child: SharedBrandingWidget()),
          ],
        ),
      );

      // Capture
      final Uint8List response = await screenshotController.captureFromWidget(
        widgetToCapture,
        delay: const Duration(milliseconds: 10),
        pixelRatio: 3.0, // High quality
      );

      // Save to temp
      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/allah_name_${nameModel.name}.png',
      ).create();
      await imagePath.writeAsBytes(response);

      // Share
      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text:
              'اسم من أسماء الله الحسنى: ${nameModel.name}\nتم المشاركة عبر تطبيق ركن الراحة',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء المشاركة: $e')));
      }
    }
  }
}
