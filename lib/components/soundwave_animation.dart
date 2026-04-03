import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mml_app/gen/assets.gen.dart';

/// Animation for the livestream.
class SoundwaveAnimation extends StatelessWidget {
  /// Initializes the animation.
  const SoundwaveAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      Assets.animations.soundwave,
      repeat: true,
      animate: true,
      fit: BoxFit.contain,
    );
  }
}
