import 'package:flutter/material.dart';

import '../../../../../../../constants.dart';
import '../../cubit/quran_cubit.dart';
import '../HizbView/hizb_view.dart';
import '../JuzView/juz_view.dart';
import 'animated_segment_switcher.dart';
import 'pages_grid_view.dart';

class QuranSegmentBody extends StatelessWidget {
  const QuranSegmentBody({
    super.key,
    required this.segment,
    required this.suraJsonData,
    required this.surahContentView,
  });

  final QuranSegment segment;
  final dynamic suraJsonData;
  final Widget surahContentView;

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (segment) {
      case QuranSegment.surah:
        child = surahContentView;
        break;

      case QuranSegment.hizb:
        child = const HizbView();
        break;

      case QuranSegment.juz:
        child = const JuzView();
        break;

      case QuranSegment.pages:
        child = const PagesGridView();
        break;
    }

    return AnimatedSegmentSwitcher(
      child: KeyedSubtree(key: ValueKey(segment), child: child),
    );
  }
}
