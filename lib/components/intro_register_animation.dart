import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Animation for the registration intro screen.
class IntroRegisterAnimation extends StatelessWidget {
  /// Initializes the animation.
  const IntroRegisterAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      'assets/animations/mml.riv',
      onInit: (Artboard artboard) {
        artboard.forEachComponent(
          (child) {
            if (child.name == 'phone') {
              Shape shield = child as Shape;
              for (var element in shield.fills) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).colorScheme.onBackground,
                  BlendMode.srcIn,
                );
              }
            }

            if (child.name == 'cam') {
              Shape shield = child as Shape;
              for (var element in shield.fills) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).colorScheme.background,
                  BlendMode.srcIn,
                );
              }
            }

            if (child.name == 'qr') {
              Shape key = child as Shape;
              for (var element in key.fills) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                );
              }
            }
          },
        );
      },
      artboard: 'Intro_Scan',
      animations: const ['animation_scan'],
    );
  }
}
