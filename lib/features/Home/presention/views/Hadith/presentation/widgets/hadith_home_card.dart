import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/hadith_book.dart';
import '../../data/models/hadith_content.dart';
import '../../hadith_logic/hadith_data_controller.dart';
import '../../hadith_logic/hadith_home_state.dart';
import '../../services/share_logic_service.dart';
import 'package:roken_al_raha/services/hadith_notification_service.dart';

class HadithHomeCard extends StatelessWidget {
  const HadithHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HadithDataController()..fetchRandomHadith(),
      child: const _HadithCardView(),
    );
  }
}

class _HadithCardView extends StatelessWidget {
  const _HadithCardView();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 300, // Fixed height for consistency on Home
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.primaryColor,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BlocBuilder<HadithDataController, HadithHomeState>(
          builder: (context, state) {
            // Handle Loading State specifically with Shimmer
            if (state is HadithHomeLoading) {
              return _buildLoadingState();
            }

            // Handle Error
            if (state is HadithHomeError) {
              return _buildErrorState(context, state.message);
            }

            // Handle Loaded
            if (state is HadithHomeLoaded) {
              return _buildLoadedState(context, state.hadith, state.book);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 20, width: 100, color: Colors.white),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(height: 15, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () =>
                  context.read<HadithDataController>().fetchRandomHadith(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text("محاولة مجدداً"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    HadithContent hadith,
    HadithBook book,
  ) {
    return Stack(
      children: [
        // Content
        Column(
          children: [
            // Header: Card Title/Book Name
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "حديث مختار",
                        style: GoogleFonts.amiri(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Notification Settings Icon
                      GestureDetector(
                        onTap: () => _showNotificationSettings(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active_outlined,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      book.name,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Hadith Text
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  hadith.hadith,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    height: 1.8,
                    color: Colors.black87,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),

            // Actions Footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ActionButton(
                    icon: Icons.share_rounded,
                    label: "مشاركة",
                    onTap: () {
                      ShareLogicService().shareHadith(context, hadith, book);
                    },
                  ),
                  _ActionButton(
                    icon: Icons.info_outline_rounded,
                    label: "المصدر",
                    onTap: () {
                      _showSourceInfo(context, book);
                    },
                  ),
                  _ActionButton(
                    icon: Icons.shuffle_rounded,
                    label: "حديث آخر",
                    color: AppColors.primaryColor,
                    isPrimary: true,
                    onTap: () {
                      context.read<HadithDataController>().fetchRandomHadith();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSourceInfo(BuildContext context, HadithBook book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "معلومات المصدر",
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.book, color: AppColors.primaryColor),
              title: Text(
                book.name,
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "عدد الأحاديث: ${book.totalHadiths ?? 'غير معروف'}",
                style: GoogleFonts.cairo(),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _HadithNotificationSheet(),
    );
  }
}

class _HadithNotificationSheet extends StatefulWidget {
  const _HadithNotificationSheet();

  @override
  State<_HadithNotificationSheet> createState() =>
      _HadithNotificationSheetState();
}

class _HadithNotificationSheetState extends State<_HadithNotificationSheet> {
  bool _isEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await HadithNotificationService.getSettings();
    if (mounted) {
      setState(() {
        _isEnabled = settings['enabled'];
        _selectedTime = settings['time'];
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    await HadithNotificationService.saveSettings(
      enabled: _isEnabled,
      time: _selectedTime,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الإعدادات بنجاح', style: GoogleFonts.cairo()),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "إعدادات الإشعار اليومي",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primaryColor,
                  title: Text(
                    "تفعيل إشعار حديث اليوم",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _isEnabled,
                  onChanged: (val) {
                    setState(() => _isEnabled = val);
                  },
                ),
                if (_isEnabled) ...[
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "وقت الإشعار",
                      style: GoogleFonts.cairo(fontSize: 16),
                    ),
                    trailing: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "حفظ التغييرات",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final finalColor = color ?? Colors.grey[700];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: isPrimary
                  ? BoxDecoration(
                      color: finalColor!.withOpacity(0.1),
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(icon, color: finalColor, size: isPrimary ? 24 : 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: finalColor,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
