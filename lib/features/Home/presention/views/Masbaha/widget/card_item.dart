import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../source/app_images.dart';

class CardItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isCustom;

  const CardItem({
    super.key,
    required this.title,
    this.onTap,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: -10,
                offset: const Offset(0, 15),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, AppColors.primaryColor.withOpacity(0.08)],
            ),
            border: Border.all(
              color: isCustom
                  ? const Color(0xFFD4AF37)
                  : AppColors.primaryColor.withOpacity(0.2),
              width: isCustom ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Row(
                  children: [
                    if (isCustom)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.bookmark,
                          color: const Color(0xFFD4AF37),
                          size: 20,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.titleStyle.copyWith(
                          fontSize: 24,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          shadows: [], // Remove old shadow for cleaner look
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Image(
                          image: AssetImage(Assets.share),
                          width: 25,
                          height: 25,
                          color: AppColors.primaryColor,
                        ),
                        onPressed: () => _shareAsImage(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareAsImage(BuildContext context) async {
    final screenshotController = ScreenshotController();

    // Create the widget to be captured
    final captureWidget = Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E1), // Light cream/parchment color
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage(
            'assets/Images/backimg.jpg',
          ), // Assuming this exists or similar pattern
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
        border: Border.all(
          color: const Color(0xFFD4AF37),
          width: 3,
        ), // Gold border
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Logo or Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/app_icon/icon.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const Icon(
                  Icons.mosque,
                  size: 50,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'arsura', // Or default if not available
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Footer
          const Text(
            'تطبيق ركن الراحة',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    try {
      final imageBytes = await screenshotController.captureFromWidget(
        captureWidget,
        delay: const Duration(milliseconds: 10),
        pixelRatio: 2.0,
      );

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/masbaha_share_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await imagePath.writeAsBytes(imageBytes);

      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'مشاركة من تطبيق ركن الراحة');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء المشاركة: $e')));
    }
  }
}
