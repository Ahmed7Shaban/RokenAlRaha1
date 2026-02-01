import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../widgets/ramadan_background.dart';
import 'cubit/hamed_cubit.dart';
import 'cubit/hamed_state.dart';
import 'tabs/hamed_dhikr_tab.dart';
import 'tabs/blessings_journal_tab.dart';
import 'widgets/share_card.dart';

class HamedView extends StatelessWidget {
  const HamedView({super.key});
  static const String routeName = '/hamed';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HamedCubit()..loadData(),
      child: const _HamedViewBody(),
    );
  }
}

class _HamedViewBody extends StatefulWidget {
  const _HamedViewBody();

  @override
  State<_HamedViewBody> createState() => _HamedViewBodyState();
}

class _HamedViewBodyState extends State<_HamedViewBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 140, // Reduced height for cleaner look
              pinned: true,
              backgroundColor: AppColors.primaryColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              leading: const BackButton(color: Colors.white),
              title: Text(
                'الحمد والشكر',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                BlocBuilder<HamedCubit, HamedState>(
                  builder: (context, state) {
                    return IconButton(
                      icon: const Icon(Icons.bar_chart, color: Colors.white),
                      tooltip: 'الإحصائيات',
                      onPressed: () {
                        if (state is HamedLoaded) {
                          _showStatsBottomSheet(context, state);
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                  ),
                  tooltip: 'تنبيه النعم',
                  onPressed: () => _showNotificationSettings(context),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 4,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                tabs: const [
                  Tab(text: 'أوراد الحمد'),
                  Tab(text: 'مفكرة النعم'),
                ],
              ),
            ),
          ];
        },
        body: RamadanBackground(
          child: TabBarView(
            controller: _tabController,
            children: [
              HamedDhikrTab(onShare: _shareDhikr),
              BlessingsJournalTab(onShare: _shareDhikr),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareDhikr(String text, int count) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Generate Image
      final imageBytes = await _screenshotController.captureFromWidget(
        ShareCard(text: text, count: count),
        delay: const Duration(milliseconds: 10),
        pixelRatio: 2.0, // High quality
      );

      Navigator.pop(context); // Hide loading

      // Save to temp file
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/hamed_share.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      // Share
      await Share.shareXFiles([
        XFile(imagePath),
      ], text: 'من تطبيق ركن الراحة - أوراد الحمد');
    } catch (e) {
      Navigator.pop(context); // Hide loading on error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء المشاركة: $e')));
    }
  }

  void _showStatsBottomSheet(BuildContext context, HamedLoaded state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'لوحة الإحصائيات',
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'مجموع الحمد',
                    '${state.totalPraises}',
                    Icons.favorite,
                    Colors.red.shade100,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'عدد النعم',
                    '${state.blessings.length}',
                    Icons.book,
                    Colors.blue.shade100,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFD4AF37),
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'استمر في حمد الله، فبالشكر تدوم النعم.',
                      style: GoogleFonts.amiri(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _shareStats(state.totalPraises, state.blessings.length);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: Text(
                  'مشاركة إنجازك',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareStats(int totalPraises, int blessingsCount) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final imageBytes = await _screenshotController.captureFromWidget(
        ShareCard(
          text:
              "الحمد لله الذي بنعمته تتم الصالحات\n\nإجمالي الحمد: $totalPraises\nعدد النعم المسجلة: $blessingsCount",
          count: totalPraises,
        ),
        delay: const Duration(milliseconds: 10),
        pixelRatio: 2.0,
      );

      Navigator.pop(context);

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/hamed_stats_share.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles([
        XFile(imagePath),
      ], text: 'إحصائياتي في تطبيق ركن الراحة');
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color bg,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.tajawal(color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<HamedCubit>(),
        child: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تنبيه مفكرة النعم',
                    style: GoogleFonts.tajawal(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'حدد وقتاً يومياً لتذكيرك بتسجيل نعم الله عليك',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<HamedCubit, HamedState>(
                    builder: (context, state) {
                      final time = (state is HamedLoaded)
                          ? state.reminderTime
                          : null;
                      return ListTile(
                        title: Text(
                          time != null
                              ? 'وقت التنبيه: ${time.format(context)}'
                              : 'لم يتم تعيين وقت',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Switch(
                          value: time != null,
                          activeColor: AppColors.primaryColor,
                          onChanged: (val) async {
                            if (val) {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primaryColor,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                context.read<HamedCubit>().setReminderTime(
                                  picked,
                                );
                              }
                            } else {
                              context.read<HamedCubit>().setReminderTime(null);
                            }
                          },
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: time ?? TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primaryColor,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            context.read<HamedCubit>().setReminderTime(picked);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
