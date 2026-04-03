import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mml_app/gen/assets.gen.dart';

/// Animation for the registration intro screen.
class IntroRegisterAnimation extends StatelessWidget {
  /// Initializes the animation.
  const IntroRegisterAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      Assets.animations.introScan,
      repeat: true,
      animate: true,
      fit: BoxFit.contain,
    );
  }
}
