import 'package:flutter/material.dart';
import 'seerah_screen.dart';

// Redirect old View to new Screen to maintain route compatibility if necessary
class SeerahView extends StatelessWidget {
  static const String routeName = '/Seerah';
  const SeerahView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SeerahScreen();
  }
}
