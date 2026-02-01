import 'package:flutter/material.dart';
import '../../../../../../routes/routes.dart';
import '../masbaha_main_view.dart';

class IstighfarView extends StatelessWidget {
  const IstighfarView({super.key});
  static const String routeName = Routes.istighfarView;
  @override
  Widget build(BuildContext context) {
    return const MasbahaMainView(initialIndex: 1);
  }
}
