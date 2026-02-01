import 'package:flutter/material.dart';
import '../../../../../../routes/routes.dart';
import '../masbaha_main_view.dart';

class TasbeehView extends StatelessWidget {
  const TasbeehView({super.key});
  static const String routeName = Routes.tasbeehView;
  @override
  Widget build(BuildContext context) {
    return const MasbahaMainView(initialIndex: 0);
  }
}
