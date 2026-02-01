import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../../core/theme/app_colors.dart';
import '../../../logic/khatma_cubit.dart';

// --- Premium Islamic Theme Constants ---
const Color kDeepDark = Color(0xFF121212);
const Color kPrimaryGolden = Color(0xFFD4AF37);

class CreateKhatmaBottomSheet extends StatefulWidget {
  const CreateKhatmaBottomSheet({Key? key}) : super(key: key);

  @override
  State<CreateKhatmaBottomSheet> createState() =>
      _CreateKhatmaBottomSheetState();
}

class _CreateKhatmaBottomSheetState extends State<CreateKhatmaBottomSheet> {
  final TextEditingController _nameController = TextEditingController(
    text: "ختمة جديدة",
  );
  final TextEditingController _daysController = TextEditingController(
    text: "30",
  );
  int _selectedDuration = 30;
  String _selectedType = 'fixed';

  // Notifications State
  bool _remindersEnabled = false;
  final List<TimeOfDay> _reminderTimes = [];
  TimeOfDay? _deadlineTime;

  @override
  Widget build(BuildContext context) {
    // Bottom padding to handle keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 31, 26, 60),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // 1. Watermark Background
          // Positioned.fill(child: CustomPaint(painter: IslamicPatternPainter())),

          // 2. Content
          SingleChildScrollView(
            // Ensure content moves up with keyboard
            padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Golden Handle
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kPrimaryGolden,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  "ابدأ رحلة الختم",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryGolden,
                  ),
                ),
                const SizedBox(height: 32),

                // Name Input
                _buildIslamicTextField(
                  controller: _nameController,
                  label: "اسم الختمة",
                  icon: Icons.menu_book_rounded,
                ),
                const SizedBox(height: 24),

                // Type Selection
                Row(
                  children: [
                    Expanded(child: _buildTypeSegment("ختمة محددة", "fixed")),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTypeSegment("ختمة رمضان", "special")),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTypeSegment("مستمرة", "continuous")),
                  ],
                ),
                const SizedBox(height: 24),

                // Duration Logic
                if (_selectedType == 'fixed' || _selectedType == 'special') ...[
                  Text(
                    "المدة (بالأيام)",
                    style: GoogleFonts.tajawal(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDurationChip(30),
                      const SizedBox(width: 8),
                      _buildDurationChip(15),
                      const SizedBox(width: 8),
                      _buildDurationChip(60),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildIslamicTextField(
                    controller: _daysController,
                    label: "أدخل عدد الأيام يدوياً",
                    icon: Icons.calendar_month_rounded, // Calendar icon
                    isNumber: true,
                    onChanged: (v) {
                      setState(() {
                        _selectedDuration = int.tryParse(v) ?? 30;
                      });
                    },
                  ),
                ] else ...[
                  // Continuous description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kPrimaryGolden.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: kPrimaryGolden.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: kPrimaryGolden,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "في الختمة المستمرة، لا يوجد وقت محدد للانتهاء. اقرأ ما تيسر لك يومياً.",
                            style: GoogleFonts.tajawal(
                              color: Colors.white70,
                              height: 1.5,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),

                // Notifications Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: kPrimaryGolden,
                  inactiveTrackColor: Colors.white10,
                  title: Text(
                    "تفعيل التذكيرات",
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _remindersEnabled,
                  onChanged: (val) {
                    setState(() {
                      _remindersEnabled = val;
                    });
                  },
                ),

                if (_remindersEnabled) ...[
                  const SizedBox(height: 12),
                  Text(
                    "أوقات التذكير:",
                    style: GoogleFonts.tajawal(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._reminderTimes.map(
                        (time) => Chip(
                          label: Text(
                            time.format(context),
                            style: GoogleFonts.tajawal(
                              color: kPrimaryGolden,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: kPrimaryGolden.withOpacity(0.15),
                          side: BorderSide.none,
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 16,
                            color: kPrimaryGolden,
                          ),
                          onDeleted: () {
                            setState(() {
                              _reminderTimes.remove(time);
                            });
                          },
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final picked = await _pickTime(TimeOfDay.now());
                          if (picked != null &&
                              !_reminderTimes.contains(picked)) {
                            setState(() {
                              _reminderTimes.add(picked);
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryGolden,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    tileColor: Colors.white.withOpacity(0.02),
                    title: Text(
                      "تذكير المهلة الأخيرة",
                      style: GoogleFonts.tajawal(color: Colors.white),
                    ),
                    subtitle: Text(
                      "تنبيه إذا لم يتم إنهاء الورد في نهاية اليوم",
                      style: GoogleFonts.tajawal(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final picked = await _pickTime(
                          _deadlineTime ?? const TimeOfDay(hour: 22, minute: 0),
                        );
                        if (picked != null) {
                          setState(() {
                            _deadlineTime = picked;
                          });
                        }
                      },
                      child: Text(
                        _deadlineTime != null
                            ? _deadlineTime!.format(context)
                            : "تعيين",
                        style: GoogleFonts.tajawal(
                          color: kPrimaryGolden,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Action Button with Gradient
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [kPrimaryGolden, Color(0xFFE5C566)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryGolden.withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _handleCreateKhatma,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "تثبيت الختمة",
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryGolden,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E2E),
              onSurface: kPrimaryGolden,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kPrimaryGolden),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _handleCreateKhatma() {
    final name = _nameController.text;
    int days = int.tryParse(_daysController.text) ?? 30;

    if (_selectedType == 'continuous') {
      days = 365; // Logical default for continuous
    }

    if (name.isNotEmpty && days > 0) {
      // Format times
      List<String> formattedTimes = _reminderTimes
          .map(
            (t) =>
                "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}",
          )
          .toList();
      String? formattedDeadline = _deadlineTime != null
          ? "${_deadlineTime!.hour.toString().padLeft(2, '0')}:${_deadlineTime!.minute.toString().padLeft(2, '0')}"
          : null;

      context.read<KhatmaCubit>().createKhatma(
        name: name,
        durationDays: days,
        type: _selectedType,
        remindersEnabled: _remindersEnabled,
        reminderTimes: formattedTimes,
        reminderDeadline: formattedDeadline,
      );
      Navigator.pop(context);
    }
  }

  Widget _buildIslamicTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16),
      onChanged: onChanged,
      cursorColor: kPrimaryGolden,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.tajawal(color: Colors.white54),
        prefixIcon: Icon(icon, color: kPrimaryGolden.withOpacity(0.8)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white10),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kPrimaryGolden),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildTypeSegment(String label, String value) {
    final isSelected = _selectedType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = value;
          if (value == 'special') {
            _nameController.text = "ختمة رمضان";
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryGolden : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPrimaryGolden : Colors.white10,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.tajawal(
              color: isSelected ? Colors.black : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(int days) {
    final isSelected = _selectedDuration == days;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDuration = days;
          _daysController.text = days.toString();
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? kPrimaryGolden.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? kPrimaryGolden : Colors.white12,
          ),
        ),
        child: Text(
          "$days يوم",
          style: GoogleFonts.tajawal(
            color: isSelected ? kPrimaryGolden : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// --- Islamic Pattern Painter ---
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double step = 50;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        _drawStar(canvas, paint, Offset(x, y), step / 2.5);
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    // Simple 8-point geometric star shape typical in Islamic art
    final path = Path();
    // This is a simplified "Rub el Hizb" style shape or simple crossed squares
    final double r = radius;

    // First square
    path.addRect(
      Rect.fromCenter(center: center, width: r * 1.4, height: r * 1.4),
    );

    // Rotate 45 degrees for second square (manual path)
    // Actually simplicity is better for watermark: Just diamond shapes

    final pathDiamond = Path();
    pathDiamond.moveTo(center.dx, center.dy - r);
    pathDiamond.lineTo(center.dx + r, center.dy);
    pathDiamond.lineTo(center.dx, center.dy + r);
    pathDiamond.lineTo(center.dx - r, center.dy);
    pathDiamond.close();

    canvas.drawPath(pathDiamond, paint);

    // Add a circle in center
    canvas.drawCircle(center, r * 0.2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
