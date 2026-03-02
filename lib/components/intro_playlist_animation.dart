import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mml_app/gen/assets.gen.dart';

/// Animation for the playlist intro screen.
class IntroPlaylistAnimation extends StatelessWidget {
  /// Initializes the animation.
  const IntroPlaylistAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      Assets.animations.introFav,
      repeat: true,
      animate: true,
      fit: BoxFit.contain,
    );
  }
}
