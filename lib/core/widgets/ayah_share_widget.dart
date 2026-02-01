import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

Future<void> createAndShareImage(String text) async {
  // تحميل الصورة من assets بدون أي context
  final imageData = await rootBundle.load('assets/Images/backayah.png');
  final bytes = imageData.buffer.asUint8List();

  // تحويل الصورة إلى ui.Image
  final uiCodec = await ui.instantiateImageCodec(bytes);
  final uiFrame = await uiCodec.getNextFrame();
  final ui.Image image = uiFrame.image;

  // إعداد Canvas للرسم
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();
  final size = Size(image.width.toDouble(), image.height.toDouble());

  // رسم الخلفية
  canvas.drawImage(image, Offset.zero, paint);

  // إعداد نص الآية
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 48, // ممكن تضبط حسب حجم الصورة
        color: AppColors.primaryColor,
        //        fontFamily: 'Taha',
      ),
    ),
    textDirection: TextDirection.rtl,
    textAlign: TextAlign.center,
    maxLines: null, // عدد الأسطر غير محدود
  );

  // تحديد الحد الأقصى للعرض مع Padding
  textPainter.layout(maxWidth: size.width - 60);

  // وضع النص في منتصف الصورة عموديًا وأفقيًا
  final offset = Offset(
    (size.width - textPainter.width) / 2,
    (size.height - textPainter.height) / 2,
  );

  // رسم النص على الصورة
  textPainter.paint(canvas, offset);

  // تحويل الرسم إلى صورة
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();

  // حفظ الصورة مؤقت
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/ayah.png');
  await file.writeAsBytes(pngBytes);

  // مشاركة الصورة
  await Share.shareXFiles([XFile(file.path)], text: "$text\n\nركن الراحة 🌿");
}
