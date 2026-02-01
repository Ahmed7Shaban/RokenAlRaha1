import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../cubit/quran_cubit.dart';

class QuranSegmentedButton extends StatefulWidget {
  const QuranSegmentedButton({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final QuranSegment current;
  final ValueChanged<QuranSegment> onChanged;

  @override
  State<QuranSegmentedButton> createState() => _QuranSegmentedButtonState();
}

class _QuranSegmentedButtonState extends State<QuranSegmentedButton> {
  /// التحكم في تفعيل الأنيميشن
  bool _enableAnimation = false;

  @override
  void initState() {
    super.initState();

    /// فعّل الأنيميشن بعد أول فريم لتجنب لاج عند الرجوع للشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _enableAnimation = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SegmentedButton<QuranSegment>(
        showSelectedIcon: false,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.selected)
                ? theme.primaryColor.withOpacity(0.15)
                : Colors.transparent,
          ),
          foregroundColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.selected)
                ? theme.primaryColor
                : Colors.grey.shade600,
          ),
          side: MaterialStateProperty.all(
            BorderSide(color: theme.primaryColor.withOpacity(0.35)),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
        ),
        segments: [
          _segment(QuranSegment.surah, 'السور'),
          _segment(QuranSegment.hizb, 'الأحزاب'),
          _segment(QuranSegment.juz, 'الأجزاء'),
          _segment(QuranSegment.pages, 'الصفحات'),
        ],
        selected: {widget.current},
        onSelectionChanged: (Set<QuranSegment> value) {
          // ⚡ نستخدم النوع الصحيح مباشرة
          widget.onChanged(value.first);
        },
      ),
    );
  }

  /// Helper لبناء كل Segment مع AnimatedSwitcher
  ButtonSegment<QuranSegment> _segment(QuranSegment value, String title) {
    return ButtonSegment(
      value: value,
      label: AnimatedSwitcher(
        duration: _enableAnimation
            ? const Duration(milliseconds: 180)
            : Duration.zero,
        transitionBuilder: (child, animation) {
          if (!_enableAnimation) return child;

          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: Text(
          title,
          key: ValueKey(title),
          style: GoogleFonts.amiri(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
