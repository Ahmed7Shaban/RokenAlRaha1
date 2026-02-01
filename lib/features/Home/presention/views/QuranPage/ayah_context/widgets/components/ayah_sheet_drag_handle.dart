import 'package:flutter/material.dart';

class AyahSheetDragHandle extends StatelessWidget {
  const AyahSheetDragHandle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
      ],
    );
  }
}
