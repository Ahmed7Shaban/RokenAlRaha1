import 'package:flutter/material.dart';

import '../../../../../../core/widgets/body_for_all_azkar.dart';
import '../../../../../../routes/routes.dart';
import '../date/morning_list.dart';

class MorningAzkar extends StatelessWidget {
  const MorningAzkar({super.key});
  static const String routeName = Routes.MorningAzkar;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyForAllAzkar(
        list: morningAzkar,
        title: 'أذكار الصباح',
        notificationKey: 'morning_azkar',
        specialCounts: {
          4: 3,
          3: 9,
          5: 3,
          6: 3,
          7: 3,
          8: 3,
          9: 3,
          10: 3,
          11: 3,
          12: 100,
          13: 10,
          14: 3,
          15: 10,
          16: 3,
          17: 3,
          18: 3,
          19: 3,
          21: 100,
          22: 100,
          23: 100,
          24: 100,
        },
      ),
    );
  }
}
