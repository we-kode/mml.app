import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mml_app/gen/assets.gen.dart';

/// Animation for the records intro screen.
class IntroRecordsAnimation extends StatelessWidget {
  /// Initializes the animation.
  const IntroRecordsAnimation({
    super.key,
  });

   @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      Assets.animations.introPlay,
      repeat: true,
      animate: true,
      fit: BoxFit.contain,
    );
  }
}
