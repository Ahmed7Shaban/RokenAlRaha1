import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../ads/widgets/banner_ad_widget.dart';
import '../../features/Home/presention/views/AllAzkar/widgets/azkar_notification_settings_sheet.dart';
import 'appbar_widget.dart';
import 'zikr_item.dart';

class BodyForAllAzkar extends StatelessWidget {
  const BodyForAllAzkar({
    super.key,
    required this.list,
    required this.title,
    this.specialCounts = const {},
    this.defaultCount = 1,
    this.notificationKey,
  });

  final List<String> list;
  final String title;
  final Map<int, int> specialCounts;
  final int defaultCount;
  final String? notificationKey;

  void _showNotificationSettings(BuildContext context) {
    if (notificationKey == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AzkarNotificationSettingsSheet(
        title: title,
        notificationKey: notificationKey!,
        notificationBody: "حان وقت $title",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppbarWidget(
          title: title,
          onNotificationTap: notificationKey != null
              ? () => _showNotificationSettings(context)
              : null,
        ),
        // const BannerAdWidget(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: list.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final zikrText = list[index];
              final count = specialCounts[index] ?? defaultCount;

              return ZikrItem(title: zikrText, initialCount: count)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (50 * index).ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
            },
          ),
        ),
      ],
    );
  }
}
