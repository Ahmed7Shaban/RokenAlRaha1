import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/source/app_lottie.dart';
import 'package:roken_al_raha/storage/masbaha_storage_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'model/masbaha_model.dart';

class MasbahaHistoryScreen extends StatefulWidget {
  const MasbahaHistoryScreen({super.key});

  @override
  State<MasbahaHistoryScreen> createState() => _MasbahaHistoryScreenState();
}

class _MasbahaHistoryScreenState extends State<MasbahaHistoryScreen> {
  final MasbahaStorageService _storageService = MasbahaStorageService();
  List<MasbahaModel> _historyItems = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyItems = _storageService.getAllItems();
      // Sort by date descending
      _historyItems.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return "أقل من ثانية";
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _deleteItem(int index) async {
    // Hive indices might shift, generally safe to delete by key if available,
    // but assuming simple box behavior here matching previous logic.
    // If the box is linear, deleting at index is fine IF we reload/sync indices.
    // Ideally we should delete by key, but model might not extend HiveObject.
    // We will stick to the service method provided.

    // NOTE: Deleting from Hive by index changes the indices of subsequent items.
    // We must ensure the service handles this or we reload immediately.
    await _storageService.deleteItem(index);
    _loadHistory();
  }

  Future<void> _shareItem(MasbahaModel item) async {
    final screenshotController = ScreenshotController();

    // Custom Design for Sharing
    final shareWidget = Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0), // Creamy background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern (simulated with opacity)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/Images/backimg.jpg', // Assuming available
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.primaryColor),
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              Container(
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 50,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'إنجاز جديد',
                style: GoogleFonts.tajawal(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),

              const SizedBox(height: 10),
              const Divider(
                indent: 50,
                endIndent: 50,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(height: 20),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${item.count}',
                    style: GoogleFonts.outfit(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'تسبيحة',
                    style: GoogleFonts.tajawal(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Duration
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(item.durationInSeconds),
                      style: GoogleFonts.tajawal(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: AppColors.primaryColor,
                child: Text(
                  'تطبيق ركن الراحة',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    try {
      final Uint8List imageBytes = await screenshotController.captureFromWidget(
        shareWidget,
        delay: const Duration(milliseconds: 20),
        pixelRatio: 2.5,
      );

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/masbaha_history_share_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await imagePath.writeAsBytes(imageBytes);

      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'تم بحمد الله الانتهاء من ورودي اليومي عبر تطبيق ركن الراحة');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء المشاركة: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA), // Very light grey bg
      appBar: AppBar(
        title: Text(
          'سجل الطاعات',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        toolbarHeight: 120,
        actions: [
          if (_historyItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              tooltip: 'مسح الكل',
              onPressed: () => _confirmDeleteAll(),
            ),
        ],
      ),
      body: _historyItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    AppLottie.EmptyList, // Verify usage
                    width: 250,
                    height: 250,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.history_toggle_off,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'لا توجد سجلات بعد',
                    style: GoogleFonts.tajawal(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 600.ms)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
              itemCount: _historyItems.length,
              itemBuilder: (context, index) {
                final item = _historyItems[index];
                // Since this uses Hive index, and list is sorted,
                // we technically need the *original* index in the Hive box to delete correctly
                // if we strictly use deleteAt(index).
                // Assuming getAllItems returns items in order 0..N, but we sorted _historyItems.
                // WE HAVE A PROBLEM: _historyItems is sorted, so 'index' here does NOT match Hive index.
                // FIX: MasbahaStorageService deleteItem must take a key, or we must find the item's key.
                // If MasbahaModel extends HiveObject, it has .key.
                // Let's assume for now we might have issue if we don't use keys.
                // However, user just wants UI update.
                // CRITICAL FIX: The current simple storage service (as seen in previous turns) likely uses add() (auto-increment keys).
                // deleteAt(index) works on the box's internal order.
                // If we sort the list, we lose the original index mapping.
                // We should technically pass the KEY. But we only saw `deleteItem(int index)`.
                // For this task, to be safe without refactoring the Service/Model too deep:
                // We will disable sorting OR we refactor service to use keys.
                // Refactoring service is risky without seeing model structure fully (does it extend HiveObject?).
                // I will assume for now I should NOT sort or I handle it carefully.
                // To support "Delete", I will just reverse the list visually but keep indices?
                // Or better, let's look at the storage service again?
                // It had `box.values.toList()`.
                // I will reload data -> it comes as list.
                // I will NOT sort for now to ensure index delete works, OR I will assume index 0 is valid.
                // Wait, if I delete item 5, item 6 becomes 5.
                // If I sort, I can't know the real index.
                // I will simply DISPLAY in reverse order (newest first) but keep the original list for deletion?
                // No, I'll update the logic to just display what comes from service (usually insertion order).
                // If user wants newest first, I should iterate backwards.

                return Dismissible(
                  key: UniqueKey(), // Ideally use item key
                  direction: DismissDirection
                      .startToEnd, // Pull "Right" in LTR, or logic for "Right" visual
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment
                        .centerLeft, // Left side corresponds to "Start" in LTR
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'حذف',
                          style: GoogleFonts.tajawal(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (direction) async {
                    // We need to find the REAL index in the box.
                    // If we sorted, we are in trouble.
                    // Solution: Find the item in the ORIGINAL unsorted list from service.
                    // Or better, since we can't easily change service now, let's match by equality?
                    // Safe approach: Reload all, find index of this object (if objects are equal), delete at that index.
                    // But Hive objects might not be equal if new instances.
                    // I will attempt simple delete by index assuming _historyItems correlates to box.
                    // To do this safely: I will NOT sort _historyItems in place.
                    // I will read items: [0, 1, 2].
                    // To show newest first, I will use reversed index in ListView.

                    // Actually, let's just use the index passed to list builder assuming we fix the list order issue.
                    // I will implement _actualDelete logic below.
                    await _deleteItemWithAdjustment(item);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {}, // Maybe details?
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              // Count Badge
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryColor,
                                      AppColors.primaryColor.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${item.count}',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.tajawal(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${item.date.year}/${item.date.month}/${item.date.day}",
                                          style: GoogleFonts.tajawal(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 14,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDuration(
                                            item.durationInSeconds,
                                          ),
                                          style: GoogleFonts.tajawal(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Share Button
                              IconButton(
                                onPressed: () => _shareItem(item),
                                icon: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primaryColor
                                      .withOpacity(0.05),
                                  child: Icon(
                                    Icons.share,
                                    color: AppColors.primaryColor,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().slideX(begin: 1, duration: 400.ms, curve: Curves.easeOutQuart).fadeIn();
              },
            ),
    );
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'مسح السجل',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من مسح كل السجل؟\nلا يمكن التراجع عن هذه الخطوة.',
          style: GoogleFonts.tajawal(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _storageService.clearAll();
              _loadHistory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'مسح الكل',
              style: GoogleFonts.tajawal(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItemWithAdjustment(MasbahaModel item) async {
    // To safely delete, we assume keys are not available and we must rely on index.
    // We reload the RAW list from storage.
    final rawList = _storageService.getAllItems();
    // Find the index of the item that matches our current item
    // (Assuming simple object reference check might fail if new instances, checking props)
    final indexToDelete = rawList.indexWhere(
      (element) =>
          element.date == item.date &&
          element.count == item.count &&
          element.title == item.title,
    );

    if (indexToDelete != -1) {
      await _storageService.deleteItem(indexToDelete);
      _loadHistory(); // Reloads and re-sorts
    }
  }
}
