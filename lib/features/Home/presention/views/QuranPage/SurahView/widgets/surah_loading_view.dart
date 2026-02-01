import 'package:flutter/material.dart';

import '../../../../../../../core/widgets/appbar_widget.dart';
import 'surah_card_skeleton.dart';

class SurahLoadingView extends StatelessWidget {
  const SurahLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      itemCount: 10,
      itemBuilder: (context, index) {
        return const SurahCardSkeleton();
      },
    );
  }
}
