import 'package:flutter/material.dart';
import 'package:mml_app/gen/assets.gen.dart';
import 'package:rive/rive.dart';

/// Animation for the playlist intro screen.
class IntroPlaylistAnimation extends StatelessWidget {
  /// Initializes the animation.
  const IntroPlaylistAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      Assets.animations.mml,
      onInit: (Artboard artboard) {
        artboard.forEachComponent(
          (child) {
            if (child.name == 'phone') {
              Shape shield = child as Shape;
              for (var element in shield.fills) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                );
              }
            }

            if (child.name == 'appbar') {
              Shape shield = child as Shape;
              for (var element in shield.fills) {
                element.paint.colorFilter = ColorFilter.mode(
                  Theme.of(context).colorScheme.surface,
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
          },
        );
      },
      artboard: 'Intro_Playlists',
      animations: const ['animation_playlists'],
    );
  }
}
