import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Animation for the livestream.
class SoundwaveAnimation extends StatelessWidget {
  /// Initializes the animation.
  const SoundwaveAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      'assets/animations/soundwave.riv',
      onInit: (Artboard artboard) {
        artboard.forEachComponent(
          (child) {
            if (child is Shape) {
              Shape wave = child;
              for (var element in wave.strokes) {
                element.paint.color = Theme.of(context).colorScheme.primary;
              }
            }
          },
        );
      },
      animations: const ['Animation 1'],
    );
  }
}
