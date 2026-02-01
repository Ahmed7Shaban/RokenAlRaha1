import 'package:flutter/material.dart';

import 'widgets/surah_view.dart';

class QuranPageView extends StatelessWidget {
  const QuranPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SurahView());
  }
}
