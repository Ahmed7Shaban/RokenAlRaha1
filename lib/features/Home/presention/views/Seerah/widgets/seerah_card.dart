import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../models/seerah_model.dart';

class SeerahCard extends StatelessWidget {
  final SeerahItem item;
  final bool isLast;
  final VoidCallback onShare;

  final bool isRead;
  final Function(bool?) onReadToggle;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;

  const SeerahCard({
    super.key,
    required this.item,
    this.isLast = false,
    required this.onShare,
    required this.isRead,
    required this.onReadToggle,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  IconData _getEventIcon(String title) {
    if (title.contains("الطفولة") ||
        title.contains("الرضاعة") ||
        title.contains("رعي"))
      return Icons.child_care;
    if (title.contains("الوحي") || title.contains("قرآن"))
      return Icons.menu_book;
    if (title.contains("مكة")) return Icons.mosque;
    if (title.contains("الهجرة")) return Icons.directions_walk;
    if (title.contains("غزوة") || title.contains("فتح")) return Icons.shield;
    if (title.contains("وفاة")) return Icons.volunteer_activism;
    if (title.contains("زواج") || title.contains("زوجات"))
      return Icons.favorite;

    return Icons.star; // Default
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isRead ? AppColors.primaryColor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isRead ? Icons.check : _getEventIcon(item.title),
                  size: 16,
                  color: isRead ? Colors.white : AppColors.primaryColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isRead
                        ? AppColors.primaryColor
                        : AppColors.primaryColor.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isRead ? const Color(0xFFF0FDF4) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isRead
                      ? Border.all(color: Colors.green.withOpacity(0.3))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                              decoration: isRead
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isBookmarked ? Colors.red : Colors.grey,
                                size: 24,
                              ),
                              onPressed: onBookmarkToggle,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                            SizedBox(width: 8),
                            Transform.scale(
                              scale: 1.1,
                              child: Checkbox(
                                value: isRead,
                                activeColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: onReadToggle,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category.displayName,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.content,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: const Color(0xFF4A4A4A),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onShare,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          backgroundColor: AppColors.primaryColor.withOpacity(
                            0.05,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: Text(
                          "مشاركة",
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
