import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Animation for the records intro screen.
class IntroRecordsAnimation extends StatelessWidget {
  /// Initializes the animation.
  const IntroRecordsAnimation({
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

            if (child.name == 'appbar') {
              Shape shield = child as Shape;
              for (var element in shield.fills) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).colorScheme.background,
                  BlendMode.srcIn,
                );
              }
            }

            if (child.name == 'card') {
              Shape shield = child as Shape;
              for (var element in shield.fills) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).cardColor,
                  BlendMode.srcIn,
                );
              }
            }

            if (child.name == 'title' || child.name == 'subtitle') {
              Shape key = child as Shape;
              for (var element in key.fills) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                );
              }
            }

            if (child.name == 'seek') {
              Shape key = child as Shape;
              for (var element in key.fills) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                );
              }
            }

            if (child.name == 'button') {
              Shape key = child as Shape;
              for (var element in key.fills) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).colorScheme.onBackground,
                  BlendMode.srcIn,
                );
              }
            }

            if (child.name == 'play') {
              Shape key = child as Shape;
              for (var element in key.fills) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).cardColor,
                  BlendMode.srcIn,
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
