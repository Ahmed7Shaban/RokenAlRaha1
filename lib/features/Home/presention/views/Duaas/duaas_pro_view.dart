import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/body_for_all_azkar.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../routes/routes.dart';
import '../../../../../core/widgets/shared_branding_widget.dart';
import 'date/duaas_list.dart';

class DuaasProView extends StatefulWidget {
  const DuaasProView({super.key});
  static const String routeName = Routes.Duaas;

  @override
  State<DuaasProView> createState() => _DuaasProViewState();
}

class _DuaasProViewState extends State<DuaasProView> {
  // Categorized Lists - initialized directly
  List<String> prophetsDuaas = prophetsDuaasList;
  List<String> praiseDuaas = [
    ...praiseDuaasList,
    ...thanksDuaasList,
  ]; // Merging Praise & Thanks
  List<String> refugeDuaas = refugeDuaasList;
  List<String> guidanceDuaas = [
    ...guidanceDuaasList,
    ...helpDuaasList,
  ]; // Merging Guidance & Help
  List<String> repentanceDuaas = repentanceDuaasList;
  List<String> variousDuaas = []; // Can be used for user added or extra
  List<String> customDuaas = []; // User added

  // Settings
  bool _isNotificationEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);

  // Stats
  Map<String, int> _readCounts = {};
  Set<String> _favorites = {}; // New: Favorites Set

  @override
  void initState() {
    super.initState();
    // No filtering needed anymore
    _loadSettings();
    _loadCustomDuaas();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isNotificationEnabled = prefs.getBool('duaa_notif_enabled') ?? false;
      final hour = prefs.getInt('duaa_notif_hour') ?? 8;
      final minute = prefs.getInt('duaa_notif_minute') ?? 0;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);

      final statsString = prefs.getString('duaa_stats');
      if (statsString != null) {
        Map<String, dynamic> json = jsonDecode(statsString);
        _readCounts = json.map((key, value) => MapEntry(key, value as int));
      }

      // Load Favorites
      final favList = prefs.getStringList('duaa_favorites');
      if (favList != null) {
        _favorites = favList.toSet();
      }
    });

    if (_isNotificationEnabled) {
      _scheduleNotification();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('duaa_notif_enabled', _isNotificationEnabled);
    await prefs.setInt('duaa_notif_hour', _notificationTime.hour);
    await prefs.setInt('duaa_notif_minute', _notificationTime.minute);
  }

  Future<void> _loadCustomDuaas() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList('custom_duaas_list');
    if (stored != null) {
      setState(() {
        customDuaas = stored;
      });
    }
  }

  Future<void> _saveCustomDuaas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_duaas_list', customDuaas);
  }

  Future<void> _scheduleNotification() async {
    if (!_isNotificationEnabled) return;

    // Use the new rotation method to schedule 7 days of random duaas
    // Use the combined list for random notifications
    await NotificationService().scheduleDuaaRotations(
      duaas: allDuaasList,
      time: _notificationTime,
    );
  }

  Future<void> _cancelNotification() async {
    await NotificationService().cancelDuaaRotations();
  }

  void _incrementCount(String duaa) {
    setState(() {
      _readCounts[duaa] = (_readCounts[duaa] ?? 0) + 1;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('duaa_stats', jsonEncode(_readCounts));
    });
  }

  // Method to toggle favorite
  void _toggleFavorite(String duaa) async {
    setState(() {
      if (_favorites.contains(duaa)) {
        _favorites.remove(duaa);
      } else {
        _favorites.add(duaa);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('duaa_favorites', _favorites.toList());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'أدعية مختارة',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: _showStatistics,
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: _showNotificationSettings,
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.tajawal(),
            indicatorColor: AppColors.goldenYellow,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'أدعية الأنبياء'),
              Tab(text: 'الثناء والحمد'),
              Tab(text: 'الاستعاذة'),
              Tab(text: 'الهداية'),
              Tab(text: 'التوبة'),
              Tab(text: 'متنوعة والمضاف'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProBody(prophetsDuaas, "أدعية الأنبياء"),
            _buildProBody(praiseDuaas, "الثناء والحمد"),
            _buildProBody(refugeDuaas, "الاستعاذة"),
            _buildProBody(guidanceDuaas, "الهداية والثبات"),
            _buildProBody(repentanceDuaas, "التوبة والمغفرة"),
            _buildProBody([...customDuaas, ...variousDuaas], "أدعية متنوعة"),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: _showAddDuaaDialog,
        ),
      ),
    );
  }

  Widget _buildProBody(List<String> list, String title) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          "لا توجد أدعية في هذا القسم",
          style: GoogleFonts.tajawal(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final duaa = list[index];
        final isCustom = customDuaas.contains(duaa);
        final isFav = _favorites.contains(duaa); // Check fav status

        if (isCustom) {
          return Dismissible(
            key: Key(duaa), // Unique Key for Dismissible
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                customDuaas.remove(duaa);
                if (_favorites.contains(duaa)) {
                  _favorites.remove(duaa); // Also remove from favorites
                  _toggleFavorite(
                    duaa,
                  ); // Trigger save (hacky reusing toggle, better to separate save)
                }
              });
              _saveCustomDuaas();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف الدعاء', style: GoogleFonts.tajawal()),
                ),
              );
            },
            background: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 30,
              ),
            ),
            child: DuaaCard(
              key: ValueKey(duaa), // Force re-init on list changes
              duaa: duaa,
              count: _readCounts[duaa] ?? 0,
              isFav: isFav, // Pass prop
              onFav: () => _toggleFavorite(duaa), // Pass callback
              onRead: () => _incrementCount(duaa),
              tag: "مضاف",
            ),
          );
        }

        return DuaaCard(
          key: ValueKey(
            duaa,
          ), // Critical: Forces state recreation if config changes, fixing hot reload issues
          duaa: duaa,
          count: _readCounts[duaa] ?? 0,
          isFav: isFav, // Pass prop
          onFav: () => _toggleFavorite(duaa), // Pass callback
          onRead: () => _incrementCount(duaa),
        );
      },
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "إعدادات التنبيه",
                  style: GoogleFonts.tajawal(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: Text(
                    "تفعيل التنبيه اليومي",
                    style: GoogleFonts.tajawal(),
                  ),
                  value: _isNotificationEnabled,
                  activeColor: AppColors.primaryColor,
                  onChanged: (val) {
                    setSheetState(() => _isNotificationEnabled = val);
                    setState(() => _isNotificationEnabled = val);
                    _saveSettings();
                    if (val) {
                      _scheduleNotification();
                    } else {
                      _cancelNotification();
                    }
                  },
                ),
                ListTile(
                  title: Text("وقت التنبيه", style: GoogleFonts.tajawal()),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _notificationTime.format(context),
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _notificationTime,
                    );
                    if (picked != null) {
                      setSheetState(() => _notificationTime = picked);
                      setState(() => _notificationTime = picked);
                      _saveSettings();
                      _scheduleNotification();
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showStatistics() {
    int totalReads = _readCounts.values.fold(0, (sum, count) => sum + count);
    int uniqueDuaas = _readCounts.keys.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "إحصائياتك",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow("عدد الأدعية المقروءة", "$uniqueDuaas"),
            const Divider(),
            _buildStatRow("إجمالي التكرارات", "$totalReads"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.tajawal()),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDuaaDialog() {
    final controller = TextEditingController();
    TimeOfDay? customTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            "إضافة دعاء جديد",
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'اكتب الدعاء هنا...',
                  hintStyle: GoogleFonts.tajawal(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "تنبيه خاص بهذا الدعاء؟",
                  style: GoogleFonts.tajawal(fontSize: 14),
                ),
                trailing: customTime == null
                    ? TextButton(
                        child: Text("تحديد وقت", style: GoogleFonts.tajawal()),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null)
                            setDialogState(() => customTime = picked);
                        },
                      )
                    : Chip(
                        label: Text(customTime!.format(context)),
                        onDeleted: () =>
                            setDialogState(() => customTime = null),
                      ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "إلغاء",
                style: GoogleFonts.tajawal(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() => customDuaas.add(controller.text));
                  _saveCustomDuaas();

                  if (customTime != null) {
                    NotificationService().scheduleCustomDhikrReminder(
                      id: DateTime.now().millisecond, // Random ID
                      title: "دعاؤك الخاص",
                      body: controller.text,
                      time: customTime!,
                    );
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(
                "حفظ",
                style: GoogleFonts.tajawal(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DuaaCard extends StatefulWidget {
  final String duaa;
  final int count;
  final VoidCallback onRead;
  final String? tag;
  final bool isFav; // New prop
  final VoidCallback onFav; // New prop

  const DuaaCard({
    super.key,
    required this.duaa,
    required this.count,
    required this.onRead,
    required this.isFav,
    required this.onFav,
    this.tag,
  });

  @override
  State<DuaaCard> createState() => _DuaaCardState();
}

class _DuaaCardState extends State<DuaaCard>
    with SingleTickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.02,
    );
    _scaleController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.forward().then((_) => _scaleController.reverse());
    widget.onRead();
  }

  Future<void> _shareAsImage() async {
    try {
      final widgetToCapture = Container(
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
        ),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.format_quote_rounded,
              size: 40,
              color: AppColors.primaryColor.withOpacity(0.2),
            ),
            const SizedBox(height: 20),
            Text(
              widget.duaa,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 26,
                color: const Color(0xFF2D2D2D),
                height: 1.8,
              ),
            ),
            const SizedBox(height: 40),
            const Divider(color: Color(0xFFEEEEEE), thickness: 1),
            const SizedBox(height: 20),
            const SharedBrandingWidget(fontSize: 18),
          ],
        ),
      );

      final Uint8List imageBytes = await _screenshotController
          .captureFromWidget(
            widgetToCapture,
            delay: const Duration(milliseconds: 150),
            pixelRatio: 3.0,
          );

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/duaa_share.png').create();
      await imagePath.writeAsBytes(imageBytes);

      await Share.shareXFiles([XFile(imagePath.path)], text: widget.duaa);
    } catch (e) {
      debugPrint("Error sharing image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = 1.0 - _scaleController.value;

    return Transform.scale(
      scale: scale,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade50),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D5491).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Tag
            if (widget.tag != null)
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.tag!,
                    style: GoogleFonts.tajawal(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),

            // Main Content Area (Tappable)
            GestureDetector(
              onTap: _handleTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  widget.duaa,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    height: 1.8,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade200, Colors.white],
                  ),
                ),
              ),
            ),

            // Actions Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.share_rounded,
                        onTap: () => Share.share(widget.duaa),
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.image_outlined,
                        onTap: _shareAsImage,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),

                  _buildActionButton(
                    icon: widget.isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded, // Use widget.isFav
                    onTap: widget.onFav, // Use widget.onFav
                    color: widget.isFav
                        ? Colors.red.shade400
                        : Colors.grey.shade600,
                    bgColor: widget.isFav
                        ? Colors.red.withOpacity(0.05)
                        : Colors.transparent,
                  ),

                  // Animated Read Button
                  InkWell(
                    onTap: _handleTap,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                            child: Text(
                              "${widget.count}",
                              key: ValueKey<int>(widget.count),
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
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
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    Color bgColor = Colors.transparent,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
