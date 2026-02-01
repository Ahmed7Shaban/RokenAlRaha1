import 'package:flutter/material.dart';
import '../../../widgets/sub_title.dart';

class AzkarListHeader extends StatelessWidget {
  const AzkarListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [SubTitle(subTitle: "جميع الأذكار")],
    );
  }
}
