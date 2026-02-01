import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementBadge {
  final String title;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  final String description; // Adding description field

  AchievementBadge({
    required this.title,
    required this.description, // Required parameter
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });
}

class AchievementBadgesSection extends StatefulWidget {
  final List<AchievementBadge> badges;

  const AchievementBadgesSection({super.key, required this.badges});

  @override
  State<AchievementBadgesSection> createState() =>
      _AchievementBadgesSectionState();
}

class _AchievementBadgesSectionState extends State<AchievementBadgesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.badges.isEmpty) return const SizedBox.shrink();

    // Count unlocked badges
    int unlockedCount = widget.badges.where((b) => b.isUnlocked).length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle Header
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.amber[700],
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "أوسمة الإنجاز",
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "$unlockedCount / ${widget.badges.length} مكتمل",
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),

        // Animated Content
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
            child: Wrap(
              spacing: 12,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: widget.badges
                  .map((badge) => _buildBadgeItem(badge))
                  .toList(),
            ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(AchievementBadge badge) {
    return Tooltip(
      message: badge.isUnlocked
          ? "تم الحصول على هذا الوسام!"
          : badge.description,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 3),
      preferBelow: false,
      textStyle: GoogleFonts.tajawal(color: Colors.white, fontSize: 13),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: badge.isUnlocked
                      ? LinearGradient(
                          colors: [
                            badge.color.withOpacity(0.2),
                            badge.color.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: badge.isUnlocked ? null : Colors.grey[100],
                  border: Border.all(
                    color: badge.isUnlocked ? badge.color : Colors.grey[300]!,
                    width: 2,
                  ),
                  boxShadow: badge.isUnlocked
                      ? [
                          BoxShadow(
                            color: badge.color.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  badge.isUnlocked ? badge.icon : Icons.lock_outline_rounded,
                  color: badge.isUnlocked ? badge.color : Colors.grey[400],
                  size: 28,
                ),
              ),
              if (badge.isUnlocked)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              badge.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                fontWeight: badge.isUnlocked
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: badge.isUnlocked ? Colors.black87 : Colors.grey,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
