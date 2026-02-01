import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AudioWaveAnimation extends StatelessWidget {
  final bool isPlaying;
  final Color? color;
  final double height;

  const AudioWaveAnimation({
    Key? key,
    required this.isPlaying,
    this.color,
    this.height = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isPlaying) {
      return SizedBox(height: height, width: 40);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        return Container(
              width: 4,
              height: height * (0.3 + (index * 0.1)),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color ?? Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleY(
              begin: 0.3,
              end: 1.0,
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeInOut,
            );
      }),
    );
  }
}
