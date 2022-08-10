import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Animation for the records intro screen.
class IntroRecordsAnimation extends StatelessWidget {
  /// Initializes the animation.
  const IntroRecordsAnimation({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      'assets/animations/mml.riv',
      onInit: (Artboard artboard) {
        artboard.forEachComponent(
          (child) {
            if (child.name == 'shield') {
              Shape shield = child as Shape;
              for (var element in shield.fills) {
                element.paint.color = Theme.of(context).colorScheme.primary;
              }
            }

            if (child.name.startsWith('key_')) {
              Shape key = child as Shape;
              for (var element in key.fills) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).colorScheme.secondary,
                  BlendMode.xor,
                );
              }

              for (var element in key.strokes) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).colorScheme.secondary,
                  BlendMode.xor,
                );
              }
            }
          },
        );
      },
      artboard: 'Intro_Records',
      animations: const ['animation_records'],
    );
  }
}
