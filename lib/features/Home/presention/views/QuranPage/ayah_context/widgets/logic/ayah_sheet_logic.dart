import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AyahSheetLogic {
  static Future<Uint8List?> captureImage(GlobalKey key) async {
    try {
      // Small delay to ensure frame is rendered
      await Future.delayed(const Duration(milliseconds: 20));

      final RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error capturing image: $e");
      return null;
    }
  }

  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) _showSnackBar(context, "Verse copied!", Colors.green);
  }

  static Future<void> shareImage(BuildContext context, Uint8List bytes) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final File file = await File('${tempDir.path}/ayah_share.png').create();
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "Check out this verse from Roken Al-Raha app");

      if (context.mounted) _showSnackBar(context, "Image shared!", Colors.blue);
    } catch (e) {
      if (context.mounted)
        _showSnackBar(context, "Failed to share", Colors.red);
    }
  }

  static Future<void> saveImageToGallery(
    BuildContext context,
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final File file = await File('${appDir.path}/$fileName').create();
      await file.writeAsBytes(bytes);

      if (context.mounted) _showSnackBar(context, "Image saved!", Colors.teal);
    } catch (e) {
      if (context.mounted)
        _showSnackBar(context, "Error saving image", Colors.red);
    }
  }

  static void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
