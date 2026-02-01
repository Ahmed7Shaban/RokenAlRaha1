import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_card.dart';

class NotificationSettingsCard extends StatelessWidget {
  final bool isNotificationEnabled;
  final List<TimeOfDay> reminderTimes;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAddTime;
  final Function(int index) onRemoveTime; // Callback to remove time by index
  final Function(int index) onEditTime; // Callback to edit time by index

  const NotificationSettingsCard({
    super.key,
    required this.isNotificationEnabled,
    required this.reminderTimes,
    required this.onToggle,
    required this.onAddTime,
    required this.onRemoveTime,
    required this.onEditTime,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "تذكير يومي",
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: isNotificationEnabled,
                activeColor: const Color(0xFFD4AF37),
                onChanged: onToggle,
              ),
            ],
          ),
          if (isNotificationEnabled) ...[
            const Divider(color: Colors.white12),
            const SizedBox(height: 10),

            // Header for times list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "أوقات التذكير",
                  style: GoogleFonts.tajawal(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                TextButton.icon(
                  onPressed: onAddTime,
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                    color: Color(0xFFD4AF37),
                  ),
                  label: Text(
                    "إضافة وقت",
                    style: GoogleFonts.tajawal(
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                  ),
                ),
              ],
            ),

            // List of Times
            if (reminderTimes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "لم يتم إضافة أوقات تذكير",
                    style: GoogleFonts.tajawal(color: Colors.white38),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reminderTimes.length,
                separatorBuilder: (ctx, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final time = reminderTimes[index];
                  return InkWell(
                    onTap: () => onEditTime(index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                color: Colors.white54,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                time.format(context),
                                style: GoogleFonts.tajawal(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                color: const Color(0xFFD4AF37).withOpacity(0.5),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () => onRemoveTime(index),
                                tooltip: "حذف التذكير",
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}
